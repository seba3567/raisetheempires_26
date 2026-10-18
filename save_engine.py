import configparser
import copy
import logging
import os
import shutil
import sys
from datetime import datetime
from functools import reduce
from pathlib import Path

import daiquiri
import editor
from flask import current_app, session
from flask_session.sqlalchemy import SqlAlchemySessionInterface
from flask_sqlalchemy import SQLAlchemy

from save_store import WriteConflict

crash_log = True

db = SQLAlchemy()

def ensure_fleets(save=None):
    """``session['fleets']`` as a dict, creating or repairing it if needed.

    The fleet registry is the most-mutated corner of the save -- battle_engine
    alone touches it 43 times -- and it had three independent ways of arriving
    broken, each of which surfaced as a 500 on a gateway call:

    * the key was simply absent. ``add_fleet_response`` indexed
      ``session["fleets"][name]`` with no guard, so a save that had never run
      the startup call (or one restored from a paste) raised KeyError;
    * the value was ``None``. ``/editor/save`` writes
      ``save_game.get('fleets')``, which is None for a paste that omits the
      key, and every later ``session["fleets"][x] = y`` then raised TypeError
      instead of KeyError -- a different traceback for the same mistake;
    * the two guards battle_engine already had only checked for a *missing*
      key, so neither of them helped once the value was None.

    Repairing it in one place is why this exists: callers stop having to know
    which of the three ways the session got here.
    """
    target = session if save is None else save
    fleets = target.get('fleets')
    if not isinstance(fleets, dict):
        if fleets is not None:
            print("WARNING: session['fleets'] was", type(fleets).__name__,
                  "and is being reset to {}")
        target['fleets'] = {}
    return target['fleets']


def lookup_object(id):
    [game_object] = [e for e in session['user_object']["userInfo"]["world"]["objects"] if e['id'] == id]
    return game_object


def lookup_object_save(save, id):
    [game_object] = [e for e in save['user_object']["userInfo"]["world"]["objects"] if e['id'] == id]
    return game_object


def lookup_objects_by_item_name(id):
    return [e for e in session['user_object']["userInfo"]["world"]["objects"] if e['itemName'] == id]


def lookup_objects_save_by_position(save, x, y, r):
    return [e for e in save['user_object']["userInfo"]["world"]["objects"]
            if x <= int(e["position"].split(",")[0]) <= (x + r) and
            y <= int(e["position"].split(",")[1]) <= (y + r)]


# What one backup holds: the save itself plus the backup it replaced. Kept in
# one place because the editor lists exactly this and must not drift from it.
BACKUP_KEYS = ['user_object', 'quests', 'battle', 'fleets', 'population', 'saved', 'saved_on',
               'save_version', 'original_save_version', 'backup']

# How many backups to keep. One backup is a full deep copy of the save (~38 KB
# for a level-85 empire) and every node nests the one it replaced, so the row
# grows by a whole save per backup and flask-session decodes the lot on every
# request. Measured on the Rising Empire save, which had stacked 85 of them:
#
#     backups   row      decode per request
#          1    39 KB      0.2 ms
#         10   359 KB      2.3 ms
#         20   715 KB      4.1 ms
#         40  1427 KB      8.5 ms
#         85  3029 KB     18.7 ms
#
# Ten is the point where the curve flattens into the recent past: those 85 were
# almost all "Level N" milestones from level 2 to 85, which nobody wants back,
# while ten restores is still far more than an admin needs after a bad paste.
MAX_BACKUPS = 10


def backup_chain(save=None):
    """The stacked backups, newest first.

    ``save['backup']`` is the most recent backup and every node links to the
    one it replaced, so walking down the chain is the order the 2013 editor
    listed them in. Index 0 is the save immediately before the current one.

    A link that is not a dict ends the walk instead of raising: the editor
    calls ``.get()`` on every node it lists, so handing it one of those would
    take the page down over a single half-written link.
    """
    save = session if save is None else save
    chain = []
    node = save
    while isinstance(node, dict):
        child = node.get("backup")
        if not isinstance(child, dict):
            break
        chain.append(child)
        node = child
    return chain


def trim_backups(limit=MAX_BACKUPS, save=None):
    """Drop the oldest backups so the chain stops growing without bound.

    Only the tail of the chain is cut, and only the link to the first dropped
    node is removed: the backups that survive are the same objects the editor
    already lists, and the save itself is never touched.

    ``limit=0`` clears every backup, which is the way to reclaim the space of
    a save that grew large before this existed.
    """
    save = session if save is None else save
    chain = backup_chain(save)
    if len(chain) <= limit:
        return 0
    if limit:
        chain[limit - 1].pop("backup", None)
    else:
        save.pop("backup", None)
    dropped = len(chain) - limit
    # The chain lives inside one session key, so cutting it mutates the session
    # in place. The server-side interface upserts on every request, but the
    # cookie interface only rewrites a session it believes changed, so say so.
    if hasattr(save, "modified"):
        save.modified = True
    return dropped


def create_backup(message, limit=MAX_BACKUPS):
    timestamp = datetime.now().timestamp()
    session["backup"] = copy.deepcopy({k: v for k, v in session.items() if
                         k in BACKUP_KEYS})  # nested backups
    session['saved_on'] = timestamp
    session["backup"]['replaced_on'] = timestamp
    session["backup"]['message'] = message
    trim_backups(limit)

def save_database_uri(root_path, instance_path):
    save_db_path = os.path.join(my_games_path(), "save.db")

    if os.path.samefile(my_games_path(), root_path):
        new_save_db_path = os.path.join(instance_path, "save.db")
        if os.path.exists(save_db_path):
            if not os.path.exists(new_save_db_path):
                print("INFORMATION: You're running from source, and because of Flask update save.db has to be moved to the instance folder. Installs out of folder should be unaffected")
                if not os.path.exists(instance_path):
                    os.makedirs(instance_path)
                backup_save_dir_path = os.path.join(my_games_path(), "backup-save-db")
                if not os.path.exists(backup_save_dir_path):
                    os.makedirs(backup_save_dir_path)
                shutil.copy(save_db_path, backup_save_dir_path)
                shutil.move(save_db_path, new_save_db_path)
                print("Moved your save.db to", instance_path, "and a backup can be found at", backup_save_dir_path)
            else:
                print("WARNING: You have a save.db in both the root as the instance folder (when running from source), only the instance one will be used!")
        save_db_path = new_save_db_path

    # SQLite does not create the folder that holds the database file. On a fresh
    # clone there is no save.db in the project root, so the instance folder was
    # never created above and the first connection failed with
    # "unable to open database file".
    save_db_dir = os.path.dirname(os.path.abspath(save_db_path))
    if save_db_dir and not os.path.isdir(save_db_dir):
        print("Creating save database folder", save_db_dir)
        os.makedirs(save_db_dir, exist_ok=True)

    print("SQLITE", f"sqlite:///{save_db_path}")

    return f"sqlite:///{save_db_path}"


def my_games_path():
    return config['InstallFolders']['MyGamesPath']


def install_path():
    return config['InstallFolders']['InstallPath']


def base_path():
    return Path(sys.executable).parent if getattr(sys, 'frozen', False) else Path(__file__).parent


def log_path():
    if os.path.exists(my_games_path()):
        return my_games_path()
    print("Warning: folder in My games missing, falling back to install folder.")
    return "."


def set_crash_log(toggle):
    global crash_log

    crash_log = toggle


def _crash_editor_allowed():
    """Whether an unhandled exception may pop up the log editor.

    ``editor.edit()`` blocks until the window is closed, so a single unhandled
    error freezes the whole server. It must never do that in an automated
    context, where an exception is an expected observation and nothing is
    watching the screen.
    """
    if os.environ.get("RTE_NO_CRASH_EDITOR"):
        return False
    return "pytest" not in sys.modules


def exception_handler(exc_type, exc_value, exc_traceback):
    if issubclass(exc_type, KeyboardInterrupt):
        sys.__excepthook__(exc_type, exc_value, exc_traceback)
        return

    logger.error("Uncaught exception", exc_info=(exc_type, exc_value, exc_traceback))
    log_file = os.path.join(log_path(), "log.txt")
    if crash_log:
        if _crash_editor_allowed():
            editor.edit(filename=log_file)
        else:
            logger.error("Crash log editor suppressed (automated run); see %s", log_file)

# logger = logging.getLogger(__name__)
# handler = logging.StreamHandler(stream=sys.stdout)
# logger.addHandler(handler)


config = configparser.ConfigParser()
config.read('RaiseTheEmpires.ini')

daiquiri.setup(level=logging.INFO, outputs=(
    daiquiri.output.Stream(sys.stdout),
    daiquiri.output.File(os.path.join(log_path(), "log.txt"), formatter=daiquiri.formatter.TEXT_FORMATTER),
    ))
logger = daiquiri.getLogger(__name__)

sys.excepthook = exception_handler


def get_all_sessions():
    sess_int: SqlAlchemySessionInterface = current_app.session_interface
    sess_model = sess_int.sql_session_model
    # record = sess_model.query.filter_by(
    #         id=17).first()
    records = sess_model.query.all()
    return records

def decode_save(serialized_save):
    try:
        sess_int: SqlAlchemySessionInterface = current_app.session_interface
        return sess_int.serializer.decode(serialized_save)
    except Exception as e:
        print("Skipping corrupt save")
        print(e)
        return None


def get_saves():
    """Every save in the database, each stamped with the revision it was read at.

    Reads through the interface, which now persists into ``save_store`` rather
    than the sessions table -- so this no longer queries ``sql_session_model``
    directly, because nothing writes there any more. The revision comes back
    with the save so :func:`store_session` can guard its write; without it the
    write is a blind overwrite, which is the lost update the rebuild removed.

    A row whose ``user_object`` key is present but None is skipped rather than
    handed on: the old filter tested for the key, not for a value, and callers
    then did ``save['user_object'][...]`` on it.
    """
    interface = current_app.session_interface
    store = interface.save_store
    saves = []
    with store._connect() as connection:
        rows = connection.execute(
            "SELECT store_id, data FROM saves ORDER BY store_id").fetchall()

    for row in rows:
        loaded = store.load(row["store_id"])
        if loaded is None or not loaded.data:
            continue
        if not loaded.data.get("user_object"):
            continue
        loaded.data["session_id"] = loaded.store_id
        loaded.data["__save_revision"] = loaded.revision
        saves.append(loaded.data)
    return saves


def enrich_save(save, record):
    save["session_id"] = record.session_id
    return save


def store_session(save):
    """Persist one save, in the format the reader expects.

    This function had two independent faults and had never once written a save.

    **It could not commit.** It called ``sess_int.db.session.commit()``, but
    flask-session 0.8.0's SqlAlchemySessionInterface keeps the SQLAlchemy handle
    on ``self.client`` (``self.client = client`` in its ``__init__``). There is
    no ``.db`` on the interface, so the line raised AttributeError before
    anything was written -- on every call, in every path that reached it. The
    invasion, pillage and invasion-cleanup handlers all reach it.

    **It wrote the wrong format.** It filled ``record.data`` with
    ``pickle.dumps``, which nothing else here decodes: flask-session's own save
    path and ``decode_save`` both go through ``session_interface.serializer``,
    and empires-server patches that to msgspec.msgpack (see
    ``serializer_init_patch``; the note at empires-server.py:143 records that json
    was switched off exactly because msgspec makes the payload unpicklable). The
    damage would have been silent too -- decode_save catches the mismatch, prints
    "Skipping corrupt save" and returns None, and get_saves drops any row that
    decodes to None.

    Returns whether the write happened, so a caller can tell "saved" from "there
    was nothing to save into".
    """
    sess_int: SqlAlchemySessionInterface = current_app.session_interface
    session_id = save.get("session_id")
    revision = save.get("__save_revision")

    # The store key is how the row is found, not part of the empire. The
    # revision is bookkeeping for this write, not state either.
    payload = {key: value for key, value in save.items()
               if key not in ("session_id", "__save_revision")}

    try:
        sess_int.save_store.store(session_id, payload, expected_revision=revision)
    except WriteConflict as conflict:
        # Someone wrote between this save being read and now. Refusing is the
        # safe half: the alternative is overwriting their turn, which is the bug
        # this whole rebuild exists to stop.
        print("store_session refused a stale write for", session_id, ":", conflict)
        return False
    return True


def validate_save(save, blank_allowed = False):
    player = get_dict(save, "user_object", "userInfo", "player")
    return (isinstance(player.get("level"), int) and
            isinstance(player.get("uid", {}), int) and
            isinstance(get_dict(save, "user_object", "userInfo").get("worldName"), str) and
            isinstance(player.get("xp", {}), (int, float)) and
            isinstance(player.get("playerResourceType", {}), int) and
            isinstance(get_dict(save, "user_object", "userInfo", "world", "resources").get("coins"), (int, float)) and
            isinstance(player.get("socialXpGood", {}), (int, float)) and
            isinstance(player.get("socialLevelGood", {}), int) and
            isinstance(player.get("socialXpBad", {}), (int, float)) and
            isinstance(player.get("socialLevelBad", {}), int)) or \
           (blank_allowed and 'user_object' not in save)


def get_dict(*args):
    return reduce((lambda a, b: a.get(b, {}) if isinstance(a.get(b, {}), dict) else {}), args)


class InvalidSaveException(Exception):
    """Exception when save is invalid while loading."""

