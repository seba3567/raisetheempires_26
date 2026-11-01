from __future__ import annotations

import atexit
import configparser
import logging
import os
import subprocess
import sys
from functools import reduce
from logging.handlers import RotatingFileHandler
from pathlib import Path
from typing import Any

from flask import current_app, has_app_context, has_request_context, session
from flask_session.sqlalchemy import SqlAlchemySessionInterface
from flask_sqlalchemy import SQLAlchemy

import contract
from save_store import WriteConflict, save_uid

crash_log = True

db = SQLAlchemy()

def ensure_fleets(save: dict[str, Any] | None = None) -> dict[str, Any]:
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


def query_db_rows(sql: str, params: tuple = ()) -> list[dict[str, Any]]:
    """Helper seguro para consultar PostgreSQL. Devuelve lista vacia si la BD no esta disponible."""
    try:
        import psycopg2.extras

        from save_store import connect
        url = save_store_url()
        with connect(url) as conn, conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor) as cur:
            cur.execute(sql, params)
            return [dict(row) for row in cur.fetchall()]
    except Exception as e:
        return []


def execute_db(sql: str, params: tuple = ()) -> int:
    """Helper seguro para escribir en PostgreSQL. Devuelve las filas afectadas, 0 si falla.

    The counterpart of :func:`query_db_rows`. The connection is opened in
    autocommit mode, so a write lands as soon as it succeeds.

    Statements that have to stand or fall together should be written as one
    statement with a data-modifying CTE rather than several calls here: this
    helper gives each call its own connection.
    """
    try:
        from save_store import connect
        url = save_store_url()
        with connect(url) as conn:
            cursor = conn.execute(sql, params)
            return cursor.rowcount
    except Exception as e:
        logger.debug("Failed to write to the database: %s", e)
        return 0


def sync_account_progress(save: dict[str, Any]) -> None:
    """Sincroniza nivel, XP y world_name desde la partida hacia la tabla `progress` de PostgreSQL."""
    try:
        uinfo = get_dict(save, "user_object", "userInfo")
        player = uinfo.get("player")
        if not isinstance(player, dict):
            return
        uid = player.get("uid")
        if not isinstance(uid, int) or isinstance(uid, bool) or uid <= 0:
            return
        level = int(player.get("level", 1) or 1)
        xp = int(player.get("xp", 0) or 0)
        world_name = str(uinfo.get("worldName") or player.get("name") or "Empire")[:255]
        execute_db(
            """
            INSERT INTO progress (user_id, level, xp, world_name, updated_at)
            SELECT id, %s, %s, %s, CURRENT_TIMESTAMP
              FROM users
             WHERE zid = %s
            ON CONFLICT (user_id) DO UPDATE
               SET level = EXCLUDED.level,
                   xp = EXCLUDED.xp,
                   world_name = EXCLUDED.world_name,
                   updated_at = CURRENT_TIMESTAMP
            """,
            (level, xp, world_name, uid),
        )
    except Exception as e:
        logger.debug("Failed to sync account progress: %s", e)


def fetch_all_commanders() -> list[dict[str, Any]]:
    """Devuelve la lista de comandantes reales registrados en PostgreSQL."""
    sql = """
        SELECT u.id, u.zid, u.username, 
               COALESCE(p.level, 10) as level, 
               COALESCE(p.xp, 0) as xp, 
               COALESCE(p.world_name, u.username) as world_name
        FROM users u
        LEFT JOIN progress p ON p.user_id = u.id
        ORDER BY p.xp DESC, p.level DESC
        LIMIT 50
    """
    rows = query_db_rows(sql)
    commanders: list[dict[str, Any]] = []
    for r in rows:
        uid = r["zid"]
        commanders.append({
            "uid": uid,
            "zid": uid,
            "name": r["world_name"] or r["username"],
            "first_name": r["username"],
            "pic": "assets/game/GeneralAssetGroup_UI.swf/TheVille_50.png",
            "pic_square": "assets/game/GeneralAssetGroup_UI.swf/TheVille_50.png",
            "picture_url": "assets/game/GeneralAssetGroup_UI.swf/TheVille_50.png",
            "country": "ES",
            "level": int(r["level"]),
            "xp": int(r["xp"]),
            "rating": 1200 + int(r["level"]) * 25,
            "score": int(r["xp"]),
            "engagement_7day": 1,
            "is_real": True,
        })
    return commanders


def _get_world_objects(container: Any) -> list[dict[str, Any]]:
    if not isinstance(container, dict):
        return []
    user_obj = container.get('user_object')
    if not isinstance(user_obj, dict):
        return []
    user_info = user_obj.get("userInfo")
    if not isinstance(user_info, dict):
        return []
    world = user_info.get("world")
    if not isinstance(world, dict):
        return []
    objs = world.get("objects")
    return objs if isinstance(objs, list) else []


def world_objects(container: Any) -> list[dict[str, Any]]:
    """The objects of a save, or of the session's save.

    ``container`` is either a save or the session itself. It used to be
    private, and the only reader was ``lookup_object``; the neighbour poll
    needs the objects of *another* player's save, which is what this is for.
    """
    return _get_world_objects(container)


def lookup_object(id: Any) -> dict[str, Any]:
    objects = _get_world_objects(session)
    target = str(id)
    matches = [e for e in objects if isinstance(e, dict) and str(e.get('id')) == target]
    return matches[0] if matches else {}


def lookup_object_save(save: dict[str, Any], id: Any) -> dict[str, Any]:
    objects = _get_world_objects(save)
    target = str(id)
    matches = [e for e in objects if isinstance(e, dict) and str(e.get('id')) == target]
    return matches[0] if matches else {}


def lookup_objects_by_item_name(id: Any) -> list[dict[str, Any]]:
    objects = _get_world_objects(session)
    return [e for e in objects if isinstance(e, dict) and e.get('itemName') == id]


def lookup_objects_save_by_position(save: dict[str, Any], x: int, y: int, r: int) -> list[dict[str, Any]]:
    objects = _get_world_objects(save)
    results = []
    for e in objects:
        if not isinstance(e, dict):
            continue
        pos = e.get("position", "")
        parts = pos.split(",")
        if len(parts) >= 2:
            try:
                px, py = int(parts[0]), int(parts[1])
                if x <= px <= (x + r) and y <= py <= (y + r):
                    results.append(e)
            except ValueError:
                continue
    return results


# What one backup holds: the save itself plus the backup it replaced. Kept in
# one place because the editor lists exactly this and must not drift from it.
#: Set by :func:`create_backup` to say *why* the next write happens. The session
#: interface hands it to ``save_store.Store.store(reason=...)``, which is what
#: puts it on the snapshot it creates.
BACKUP_REASON_KEY = "__backup_reason"

# How many snapshots to keep per save. Ten was the old in-blob limit and is the
# same number here, but it is now a DELETE on save_backups rather than a slice
# of a nested list -- which is the whole point of the rebuild. The old curve,
# measured on the Rising Empire save, for the record:
#
#     backups   row      decode per request
#          1    39 KB      0.2 ms
#         10   359 KB      2.3 ms
#         85  3029 KB     18.7 ms
#
# The row is now the empire's size at every one of those points.
MAX_BACKUPS = 10


def backup_chain(save: dict[str, Any] | None = None) -> list[Any]:
    """The snapshots for the current save, newest first.

    Used to walk ``save['backup']``, a chain of nested copies living inside the
    payload -- which is why one row reached 404 KB and every request decoded the
    lot. History is a table now, so this is a query. The payloads are *not*
    fetched: the editor only needs the label and the level, and selecting ten
    40 KB blobs to render a menu is the cost this removed.
    """
    from flask import current_app

    store = current_app.session_interface.save_store
    store_id = (save or session).get("session_id") if save else _current_store_id()
    if not store_id:
        return []
    return store.history(store_id)


def _current_store_id() -> str | None:
    """The store id the current request writes to, or None if there is no row."""
    from flask import current_app

    return current_app.session_interface._get_store_id(session.sid)


def create_backup(message: str, limit: int = MAX_BACKUPS) -> str:
    """Say why the next write happens. It does not write anything itself.

    It used to deepcopy the save into ``session['backup']``, which made the row
    grow by a whole save per backup and made every request pay to decode the
    history. Now ``save_store.Store.store`` snapshots whatever it replaces on
    every write, so all that was left for this function to contribute is *why* --
    and that is what the editor shows next to each entry.

    Stamping the reason on the session rather than writing a row here is what
    keeps "Level 50" on the snapshot taken by the level-up rather than producing
    a second, near-identical snapshot.
    """
    session[BACKUP_REASON_KEY] = message
    if hasattr(session, "modified"):
        session.modified = True
    return message


def pending_backup_reason() -> str | None:
    """The reason create_backup recorded, or None if it was not called."""
    return session.get(BACKUP_REASON_KEY)

def save_store_url() -> str:
    """The one database URL this project stores everything in (PostgreSQL 18).

    The app's configuration wins over the environment. The test suite points
    the app at a throwaway database, and a helper that read the environment
    instead would quietly reach into the real one: the suite would be writing
    to the live database while believing it was not.
    """
    configured = None
    if has_request_context() or has_app_context():
        configured = current_app.config.get("SAVE_STORE_PATH")
    return _with_installed_driver(configured or contract.env_value(
        contract.ENV_DATABASE_URL) or contract.DATABASE_URL)


def _with_installed_driver(url: str) -> str:
    """Spell the scheme as ``postgresql+psycopg2`` whatever the operator wrote."""
    for shorthand in ("postgres://", "postgresql://"):
        if url.startswith(shorthand):
            return "postgresql+psycopg2://" + url[len(shorthand):]
    return url


def my_games_path() -> str:
    return config['InstallFolders']['MyGamesPath']


def install_path() -> str:
    return config['InstallFolders']['InstallPath']


def base_path() -> Path:
    return Path(sys.executable).parent if getattr(sys, 'frozen', False) else Path(__file__).parent


def log_path() -> str:
    p = Path(my_games_path())
    if p.exists():
        return str(p)
    print("Warning: folder in My games missing, falling back to install folder.")
    return "."


def log_file_name() -> str:
    """The file the gateway writes its log to.

    ``RTE_LOG_FILE`` points it somewhere else, and the test suite uses that.
    Both runtimes share this logging setup, so without it the suite's
    deliberate failures -- it patches handlers to raise, on purpose, to prove
    the gateway survives them -- landed in the server's own log and made it
    look as though the server were the thing that was broken.
    """
    return os.environ.get("RTE_LOG_FILE") or "log.txt"


def set_crash_log(toggle: bool) -> None:
    global crash_log

    crash_log = toggle


def _crash_editor_allowed() -> bool:
    """Whether an unhandled exception may pop up the log editor.

    ``editor.edit()`` blocks until the window is closed, so a single unhandled
    error freezes the whole server. It must never do that in an automated
    context, where an exception is an expected observation and nothing is
    watching the screen.
    """
    if os.environ.get("RTE_NO_CRASH_EDITOR"):
        return False
    return "pytest" not in sys.modules


def exception_handler(exc_type: type[BaseException], exc_value: BaseException, exc_traceback: Any) -> None:
    if issubclass(exc_type, KeyboardInterrupt):
        sys.__excepthook__(exc_type, exc_value, exc_traceback)
        return

    logger.error("Uncaught exception", exc_info=(exc_type, exc_value, exc_traceback))
    log_file = str(Path(log_path()) / "log.txt")
    if crash_log:
        if _crash_editor_allowed():
            try:
                subprocess.Popen(["notepad", log_file] if os.name == "nt" else ["xdg-open", log_file])
            except Exception as e:
                logger.error("Could not launch crash editor: %s", e)
        else:
            logger.error("Crash log editor suppressed (automated run); see %s", log_file)


config = configparser.ConfigParser()
config.read('RaiseTheEmpires.ini')

# Standard logging configuration replacing daiquiri
log_format = "%(asctime)s [%(process)d] %(levelname)-8s %(name)s: %(message)s"
logging.basicConfig(
    level=logging.INFO,
    format=log_format,
    handlers=[
        logging.StreamHandler(sys.stdout),
        # Rotating, not growing. The file used to reach six megabytes and
        # keep going, which made "read the log" a chore rather than a step.
        # Five megabytes, three backups: enough history for a bad afternoon,
        # small enough to open.
        RotatingFileHandler(
            str(Path(log_path()) / log_file_name()),
            encoding="utf-8",
            maxBytes=5 * 1024 * 1024,
            backupCount=3,
        ),
    ],
    # `force=True` is load-bearing, not tidiness. `basicConfig()` does nothing at
    # all when the root logger already has handlers, and Granian installs its
    # own in every worker *before* it imports the app. So the FileHandler above
    # was silently never installed: under Granian the server answered requests
    # and wrote nothing anywhere, and log.txt went quiet at the last request of
    # the old Werkzeug run while still holding every error from that day.
    #
    # `force` also redirects Granian's own logging here, which is the point --
    # one file to read when something has gone wrong.
    force=True,
)
atexit.register(logging.shutdown)
logger = logging.getLogger(__name__)

sys.excepthook = exception_handler


def decode_save(serialized_save: bytes) -> dict[str, Any] | None:
    try:
        sess_int: SqlAlchemySessionInterface = current_app.session_interface
        return sess_int.serializer.decode(serialized_save)
    except Exception as e:
        print("Skipping corrupt save")
        print(e)
        return None


#: The unusable saves already reported, so the operator hears about each one
#: once instead of on every scan.
#:
#: ``get_saves()`` walks the whole table, and several callers ask for it on
#: every request -- the neighbour list, the quest counter, the leaderboard, the
#: admin session list. With a handful of unusable rows in the table that used
#: to mean five lines of output *per request*: three quarters of everything the
#: gateway wrote to stdout, all of it the same five lines. The information is
#: worth having; repeating it three hundred times a session is not.
_reported_unusable_saves: set[str] = set()


def _report_unusable_save(store_id: str, user_object: Any) -> None:
    """Log a save that has to be skipped, once per row and per process."""
    if store_id in _reported_unusable_saves:
        return
    _reported_unusable_saves.add(store_id)
    logger.warning(
        "Skipping save with no usable user_object: %s (%s)",
        store_id, type(user_object).__name__,
    )


def get_saves() -> list[dict[str, Any]]:
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

    if not hasattr(interface, "save_store"):
        # A plain Flask session interface, and not even a server-side one.
        if hasattr(interface, "sql_session_model"):
            # A sqlalchemy-backed one -- a bare app in the older tests, or any
            # deployment that never installed the account-bound interface.
            # Read the sessions table the way this function used to.
            saves = []
            for record in interface.sql_session_model.query.all():
                decoded = decode_save(record.data)
                if not isinstance(decoded, dict):
                    continue
                user_object = decoded.get("user_object")
                if isinstance(user_object, dict) and user_object.get("userInfo"):
                    decoded["session_id"] = record.session_id
                    saves.append(decoded)
            return saves

        # A cookie session. There is no server-side store to enumerate at all --
        # the one save that exists is the session in hand.
        current = dict(session)
        user_object = current.get("user_object")
        if isinstance(user_object, dict) and user_object.get("userInfo"):
            return [current]
        return []

    saves = []
    for loaded in interface.save_store.load_all():
        # The old filter asked whether the key was present and not whether it
        # held anything, so a row with ``user_object: null`` -- or a list, which
        # is what a half-written /editor/save paste leaves -- passed and then
        # blew up the first caller that did ``save['user_object']["userInfo"]``.
        # One unusable row should cost that row, not the whole session list.
        user_object = loaded.data.get("user_object")
        if not isinstance(user_object, dict) or not user_object.get("userInfo"):
            _report_unusable_save(loaded.store_id, user_object)
            continue
        loaded.data["session_id"] = loaded.store_id
        loaded.data["__save_revision"] = loaded.revision
        saves.append(loaded.data)
    return saves


class SaveNotFound(Exception):
    """No save for that uid, where one had to exist.

    Distinct from "this player has no save yet": these are calls that address
    another player by uid -- an invasion, a pillage, a neighbour lookup -- so a
    miss means the server's own state disagrees with itself. Raised rather than
    returning None so it lands in the log; the gateway's catch-all turns it into
    a normal response, so the client is unaffected either way.
    """


def get_save_by_uid(wanted: int | str, required: bool = False) -> dict[str, Any] | None:
    """One save, looked up by the game's player id, or None.

    ``neighbor_repelled``, ``invasion_complete``, ``pillage_response`` and the
    rest used to do this by reading every save in the database and comparing
    ``user_object.userInfo.player.uid`` -- a full deserialisation of every
    empire to find one, on every invasion. The uid is an indexed column now, so
    it is one row.

    The returned dict carries ``session_id`` and ``__save_revision`` like
    :func:`get_saves` does, so it can be handed straight to
    :func:`store_session` with the write guarded.

    ``required=True`` raises instead of returning None.
    """
    from flask import current_app

    interface = current_app.session_interface
    if not hasattr(interface, "save_store"):
        # A plain Flask session interface -- a test building a bare app, or any
        # deployment that never installed the account-bound one. No store to ask,
        # so fall back to the scan this function replaced.
        for candidate in get_saves():
            found = save_uid(candidate)
            if found is not None and str(found) == str(wanted):
                return candidate
        if required:
            raise SaveNotFound(f"no save for uid {wanted!r}")
        return None

    loaded = interface.save_store.load_by_uid(wanted)
    if loaded is None or not loaded.data:
        if required:
            raise SaveNotFound(f"no save for uid {wanted!r}")
        return None
    user_object = loaded.data.get("user_object")
    if not isinstance(user_object, dict) or not user_object.get("userInfo"):
        if required:
            raise SaveNotFound(f"save for uid {wanted!r} has no usable user_object")
        return None
    loaded.data["session_id"] = loaded.store_id
    loaded.data["__save_revision"] = loaded.revision
    return loaded.data


def store_session(save: dict[str, Any]) -> bool:
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
        written = sess_int.save_store.store(session_id, payload,
                                           expected_revision=revision)
    except WriteConflict as conflict:
        # Someone wrote between this save being read and now. Refusing is the
        # safe half: the alternative is overwriting their turn, which is the bug
        # this whole rebuild exists to stop.
        #
        # This is an ERROR and not a debug line. Every caller that reaches here
        # has just thrown away a real change -- an invasion placed, a pillage
        # taken, an ally tended -- and the handler still answers the client
        # with `errorType: 0`, because it never checks this return value. The
        # client is told the action worked and it did not happen.
        #
        # Retrying is not an option: this save was read before the other write,
        # so writing it again would overwrite the turn that won the race, which
        # is the exact loss the revision guard exists to prevent. The write has
        # to be dropped; what must not be dropped is the record that it was.
        logger.error(
            "store_session REFUSED a stale write for %s (expected revision %r): %s. "
            "The change in this call was discarded and the caller is about to "
            "answer the client with success.",
            session_id, revision, conflict)
        return False

    # The session's revision has to follow the row it just wrote.
    #
    # Every request ends with the session interface writing the session back, and
    # it uses this same value as its compare-and-swap target. Left stale, that
    # final write arrives with the revision the request *started* at, finds the
    # row already past it -- its own write -- and raises during response
    # finalisation, which is what answered "It went wrong" on the first turn of
    # a game.
    if has_request_context() and session_id == sess_int._get_store_id(session.sid):
        session["__save_revision"] = written
    sync_account_progress(payload)
    return True


def validate_save(save: dict[str, Any], blank_allowed: bool = False) -> bool:
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


def get_dict(*args: Any) -> dict[str, Any]:
    def _step(acc: Any, key: Any) -> Any:
        if isinstance(acc, dict):
            val = acc.get(key)
            return val if isinstance(val, dict) else {}
        return {}
    return reduce(_step, args) if args else {}


class InvalidSaveException(Exception):
    """Exception when save is invalid while loading."""

