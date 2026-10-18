import os
import webbrowser

import msgspec
from flask_session.base import MsgSpecSerializer

from quest_settings import quest_titles

os.environ["PBR_VERSION"] = '5.4.3'
if not os.environ.get('EDITOR'):
    os.environ["EDITOR"] = 'notepad'  # system specific!

import editor
from tendo import singleton

import init_settings as settings

if __name__ == '__main__':
    settings.read_ops()

if not settings.debug and __name__ == '__main__':
    # Only the launcher takes this lock. A production server imports this
    # module by name in every worker (see wsgi.py), and each of those workers
    # would otherwise contend for a lockfile the parent already holds and die
    # on startup -- granian reports it as "Unexpected exit from worker-1".
    #
    # Flavour the lock by port, so "one instance" means one per port rather
    # than one per machine. Two gateways on different ports are two different
    # services -- useful for a staging instance, and for driving a throwaway
    # copy of this server without stopping the real one.
    me = singleton.SingleInstance(flavor_id=str(settings.port))

if os.name == 'nt':
    os.system('color')

from builtins import print
from datetime import timedelta
from time import sleep

from flask import (
    Flask,
    Response,
    current_app,
    jsonify,
    make_response,
    redirect,
    render_template,
    request,
    send_from_directory,
)

from save_engine import (
    MAX_BACKUPS,
    InvalidSaveException,
    _current_store_id,
    backup_chain,
    base_path,
    db,
    ensure_fleets,
    get_save_by_uid,
    install_path,
    log_path,
    logger,
    lookup_objects_save_by_position,
    my_games_path,
    save_database_uri,
    set_crash_log,
    store_session,
    validate_save,
)
from save_migration import is_0_08a_preview, migrate

try:
    from flask import safe_join  # flask 2.1.0 : safe_join is removed, use werkzeug.utils.safe_join instead."
except ImportError:
    from werkzeug.utils import safe_join
import copy
import json
import random
import threading  #, webbrowaser
import xml.etree.ElementTree as ET
from contextlib import contextmanager

import pyamf
import pyamf.amf0
from pyamf import remoting

import mod_engine
from account_saves import AccountBoundSession
from battle_engine import (
    BattleContext,
    StaleBattleReference,
    assign_consumable_response,
    battle_complete_response,
    cancel_unstarted_invasions,
    decode_unit_count_list,
    encode_unit_strings,
    format_player_fleet,
    get_active_island_by_map,
    get_survival_player_fleet,
    next_campaign_response,
    register_fleetname_fleet,
    set_active_island_by_map,
    spawn_fleet,
)
from game_settings import (
    get_sessions_id,
    get_zid,
    initial_island,
    lookup_crew_template,
    lookup_wave,
    randomReward,
    unlock_expansion,
)
from logger import init_socketio, report_other_log, report_tutorial_step, report_world_log, socketio
from quest_engine import *
from serve import serve
from state_machine import *

try:
    from flask_compress import Compress
except ImportError as error:
    print("Warning: compression can't be initialized. Compression is disabled.", error)
    compression = False

# import logging.config

version = "0.08a.2026_08_13"
release_date = 'Friday, 24 February 2026'

COMPRESS_MIMETYPES = ['text/html', 'text/css', 'text/xml', 'application/json', 'application/javascript',
                      'application/x-amf']
COMPRESS_LEVEL = 6
COMPRESS_MIN_SIZE = 500

# starting seeds
rand_seed_w = 5445  # very random
rand_seed_z = 844

compress = Compress() if settings.compression else None
# AccountBoundSession, not Session: it files each save under the account id
# rather than under the session cookie, so signing in on a second browser opens
# the same empire instead of a fresh one. See account_saves.py.
sess = AccountBoundSession()


start = datetime.now()
app_base_path = base_path()
app: Flask = Flask(__name__, root_path=app_base_path)

print("Root folder", app.root_path)
print("Instance folder", app.instance_path)
app.config['SESSION_TYPE'] = 'sqlalchemy'
app.config['SQLALCHEMY_DATABASE_URI'] = save_database_uri(app.root_path, app.instance_path)
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False # Flask-SQLAlchemy has its own event notification system that gets layered on top of SQLAlchemy. To do this, it tracks modifications to the SQLAlchemy session. This option disables the modification tracking system.
app.config['SESSION_SQLALCHEMY'] = db
app.config['SESSION_COOKIE_HTTPONLY'] = False
#app.config['SESSION_SERIALIZATION_FORMAT '] = 'json' # flask-session uses msgspec by default now which makes it undepickleable
app.config['MAX_FORM_MEMORY_SIZE'] = 5 * 1024 * 1024  # 5 MB
app.permanent_session_lifetime = timedelta(weeks=520)

MIN_ADMIN_ID = -1
STEELE_ID = -1
MAX_ADMIN_ID = 123

@app.route("/")
def index():
    return make_response(redirect("/juego"))


@app.route("/home.html")
def home():
    """The 2012 Facebook frame is gone; /juego is the player now.

    This page used to be the launcher, but its only embed was an
    ``<object>``/``<embed>`` pair pointing at download.macromedia.com, so it sat
    on "Detecting flash..." forever. It is a redirect now, which is what eight
    other routes needed: gazillionaire, deprogress, seed, patch, the three
    quest routes and chooseavatar all finish by sending the browser here, and
    each of them was landing the admin on a dead page.

    Kept as a route rather than a 404 so an old bookmark or a link in a 2013
    template still arrives somewhere real.
    """
    print("home")
    if not validate_save(session, True):
        print("Invalid save game")
        return make_response(redirect('/admin/editor'))  # an unusable save needs fixing
    return make_response(redirect('/juego'))

@app.route("/ruffle.html")
def ruffle():
    print("ruffle")
    if not validate_save(session, True):
        print("Invalid save game")
        return make_response(redirect('/admin/editor')) # an unusable save needs fixing
    saves = get_saves()
    return render_template("ruffle.html", time=datetime.now().timestamp(), zid=str(get_zid()),
                           version=version,
                           allies=json.dumps(get_allies_friend(saves),
                                             default=lambda o: '<not serializable>', sort_keys=False, indent=2),
                           app_friends=json.dumps(get_allies_id(saves)),
                           worldname=session['user_object']["userInfo"]["worldName"] if 'user_object' in session else "Emperor",
                           picture=get_avatar_pic(),
                           dropdown_items=get_sessions_dropdown_info(saves),
                           motd=get_motd()
                           )

@app.route("/snapi.json")
def snapi_bridge():
    """The data the SWF asks the hosting page for through ExternalInterface.

    The client has no social network of its own. During setup it calls three
    global JavaScript functions by name -- getUserInfo(), getFriendData() and
    getAppFriendIds() -- and reads fields off what they return. ``ruffle.html``
    defined them as inline functions; the SvelteKit player fetches this instead.

    If they are missing the client does not degrade, it dies: ``getUser()``
    leaves its user object null, and ``toSocialNetworkUser`` immediately does
    ``new SocialNetworkUser(param1.zid)`` on it, so setup aborts with

        Error #1009: Cannot access a property or method of a null object
        reference. (accessing field: zid)

    before anything is playable. zid has to stay a JSON number, not a string --
    ActionScript has no integers and it is used as an int on the far side.
    """
    saves = get_saves()
    zid = get_zid()
    worldname = session['user_object']["userInfo"]["worldName"] if 'user_object' in session else "Emperor"
    return jsonify({
        "user": {
            "zid": zid,
            "uid": zid,
            "first_name": worldname,
            "name": worldname,
            "sex": "F",
            "pic_square": get_avatar_pic(),
        },
        "friends": get_allies_friend(saves),
        "appFriends": get_allies_id(saves),
    })


# Resource keys, in the order the original editor showed them.
RESOURCE_ORDER = ("coins", "wood", "oil", "aluminum", "copper", "gold", "iron", "uranium")

#: Stand-in for anything the session holds that plain JSON cannot express.
#: Same marker the 2013 editor used when it dumped the save into its textarea.
NOT_SERIALIZABLE = "<not serializable>"


def not_serializable(obj):
    """Render an unencodable value instead of failing the whole response.

    The game engine keeps live objects in the session -- ``BattleContext`` is a
    tagged ``msgspec.Struct`` -- so a save taken during a battle cannot be
    walked by ``json.dumps``. One unencodable value must not take the endpoint
    down with it.
    """
    return NOT_SERIALIZABLE


def _session_snapshot():
    """The save as the 2013 editor's textarea showed it.

    Kept verbatim so the raw editor can round-trip: the web front end posts this
    shape straight back to /editor/save. Changing the keys here changes what a
    paste from an old backup means.
    """
    return {
        'user_object': session.get('user_object'),
        'profilePic': session.get('profilePic'),
        'quests': session.get('quests'),
        'battle': session.get('battle'),
        'last_battle': session.get('last_battle'),
        'fleets': session.get('fleets'),
        'population': session.get('population'),
        'saved': session.get('saved'),
        'save_version': session.get('save_version'),
        'original_save_version': session.get('original_save_version'),
    }


def _backup_chain():
    """The snapshots for this save, newest first.

    A table now, not a chain of nested copies inside the payload. The entries
    are ``save_store.BackupRow`` -- revision, reason, size -- and deliberately
    carry no payload, because the editor only needs the label and the numbers.
    """
    return backup_chain()


def _backup_count():
    """How many snapshots exist, for "revert n steps back"."""
    return len(_backup_chain())


def _backup_summary(node):
    """What one backup holds, flattened to the numbers an admin picks by.

    The 2013 page showed only a timestamp and a reason, which made choosing
    between 128 of them guesswork. Level and coins are what actually differ
    between two saves an hour apart, so they are the summary.
    """
    info = ((node.get('user_object') or {}).get('userInfo') or {})
    player = info.get('player') or {}
    resources = (info.get('world') or {}).get('resources') or {}
    return {
        "level": player.get('level'),
        "empirePoints": player.get('cash'),
        "coins": resources.get('coins'),
    }


def _backup_summary_payload(store_id, revision):
    """The level/coins/empire points a snapshot held, or blanks if it is gone.

    Read one snapshot at a time and only for the handful of entries actually
    listed: selecting every blob to render a menu is the cost this removed.
    """
    store = current_app.session_interface.save_store
    return _backup_summary(store.read_backup(store_id, revision) or {})


@app.route("/editor.json")
def editor_state():
    """Everything the empire editor needs, for the web front end.

    Replaces the 2013 /save-editor page: same numbers, same quest lists, same
    raw JSON, but as JSON the new UI can render instead of a wall of <a> tags.

    Quests come in the three buckets the old page showed, because those are the
    three different things you can do to one: start it, finish it, or take it
    off the save entirely.
    """
    snapshot = _session_snapshot()
    quests = session.get('quests') or []
    incomplete = [q["name"] for q in quests if not q["complete"]]
    complete = [q["name"] for q in quests if q["complete"]]

    info = (snapshot['user_object'] or {}).get('userInfo') or {}
    player = info.get('player') or {}
    resources = (info.get('world') or {}).get('resources') or {}

    # The session is not plain JSON. ``session['battle']`` and ``last_battle``
    # decode back into ``BattleContext`` -- a tagged ``msgspec.Struct`` -- the
    # moment a save carries one, and ``jsonify`` raises on it. The 2013 editor
    # dumped this same snapshot with ``default=lambda o: '<not serializable>'``;
    # losing that when the page was migrated turned "a battle is in progress"
    # into a 500, and a 500 into the front end reporting that the gateway is
    # unreachable. The marker keeps the endpoint answering; the raw editor is
    # for reading and the typed fields are what you actually edit.
    #
    # ``jsonify`` itself cannot take ``default=`` alongside a positional
    # payload, so the response is built through the JSON provider directly.
    payload = {
        "hasSave": validate_save(session, False),
        "zid": get_zid(),
        "level": player.get('level'),
        "xp": player.get('xp'),
        "empirePoints": player.get('cash'),
        "ore": player.get('playerResourceType'),
        "worldName": info.get('worldName'),
        "picture": get_avatar_pic(),
        "resources": {name: resources.get(name) for name in RESOURCE_ORDER},
        "quests": {
            # Not started yet: these are the ones an admin can unlock.
            "locked": {q: v for q, v in quest_titles.items()
                       if q not in complete and q not in incomplete},
            "incomplete": {q: v for q, v in quest_titles.items() if q in incomplete},
            "complete": {q: v for q, v in quest_titles.items() if q in complete},
        },
        "raw": snapshot,
        "backups": _backup_count(),
        # The editor shows the ceiling instead of hard-coding it, so raising
        # MAX_BACKUPS in save_engine is a one-line change.
        "maxBackups": MAX_BACKUPS,
        # The snapshots themselves. Was the chain of nested copies walked into
        # <a> tags by the 2013 page; now it is a table, and an entry is a
        # BackupRow plus the numbers an admin picks between by.
        #
        # ``index`` is kept alongside ``revision`` so the editor UI and any old
        # links keep working, but restore is addressed by revision -- an index
        # shifts whenever the history is trimmed or a write lands between
        # rendering the page and pressing the button.
        "backupList": [
            {
                "index": i,
                "revision": row.revision,
                "label": format_backup_message(row),
                "saveVersion": row.reason,
                "message": row.reason or "",
                "size": row.size,
                "created": row.created_at,
                **_backup_summary_payload(_current_store_id(), row.revision),
            }
            for i, row in enumerate(_backup_chain())
        ],
    }
    return Response(
        current_app.json.dumps(payload, default=not_serializable) + "\n",
        mimetype="application/json",
    )


def _apply_save(save_game):
    """Write a save dict back over the live session.

    The same seven keys the 2013 editor's POST wrote, in the same order. Both
    the raw JSON paste and the backup restore land here so they cannot drift
    apart and leave one of them half-applying a save.
    """
    session['saved'] = str(session.get('saved', "")) + "edit"
    session['user_object'] = save_game.get('user_object')
    if 'profilePic' in session and 'profilePic' in save_game:
        session['profilePic'] = save_game['profilePic']
    session['quests'] = save_game.get('quests')
    session['battle'] = save_game.get('battle')
    session['fleets'] = save_game.get('fleets')
    session['population'] = save_game.get('population')
    session['save_version'] = save_game.get('save_version')

    # `save_game.get('fleets')` is None for a paste that omits the key, and a
    # None registry makes every later `session["fleets"][x] = y` a TypeError --
    # the same 500 this page was called in to fix, one request later.
    ensure_fleets()


@app.route("/editor/save", methods=['POST'])
def editor_save():
    """Replace the save from a raw JSON paste.

    The escape hatch from the 2013 editor, kept because it is the only way to
    change something the typed fields do not cover. Admin-gated at the proxy,
    and the web editor refuses to post here without an admin session.
    """
    try:
        save_game = json.loads(request.form['savegame'])
    except (KeyError, ValueError) as error:
        return jsonify({"ok": False, "message": f"No se pudo leer el JSON: {error}"}), 400

    create_backup("before " + request.form.get("message", "raw edit"))
    _apply_save(save_game)

    return jsonify({"ok": True})


@app.route("/editor/restore", methods=['POST'])
def editor_restore():
    """Roll the save back to one of its snapshots.

    The 2013 editor had this as a row of "Restore this backup" buttons posting
    ``restore<n>``, walking a chain nested inside the save. It is the only way
    back from a bad raw paste or a wipe, so it moves with the editor instead of
    dying with the old page.

    Takes a **revision**, not an index into a chain. An index shifts every time
    the history is trimmed or a write happens between the page being rendered
    and the button being pressed, so it could restore the wrong save; a revision
    names exactly one state. The index is still accepted, and resolved against
    the current listing, so old links keep working.
    """
    form = request.form

    revision = form.get('revision')
    if revision is not None:
        try:
            revision = int(revision)
        except ValueError:
            return jsonify({"ok": False, "message": "Revisión inválida"}), 400
    else:
        try:
            index = int(form['index'])
        except (KeyError, ValueError):
            return jsonify({"ok": False, "message": "Falta el respaldo a restaurar"}), 400

        chain = _backup_chain()
        if not chain:
            return jsonify({"ok": False, "message": "Esta partida no tiene respaldos"}), 400
        if index < 0 or index >= len(chain):
            return jsonify({
                "ok": False,
                "message": f"El respaldo {index} no existe; hay {len(chain)}"
            }), 400
        revision = chain[index].revision

    store = current_app.session_interface.save_store
    payload = store.read_backup(_current_store_id(), revision)
    if payload is None:
        return jsonify({"ok": False, "message": "Ese respaldo ya no existe"}), 400

    row = next((r for r in _backup_chain() if r.revision == revision), None)
    label = format_backup_message(row) if row else f"revision {revision}"
    print("restoring revision", revision, label)

    # store.restore snapshots the current state before replacing it, so the
    # rollback is undoable -- which is what the old chain could not offer once
    # it started trimming.
    create_backup(f'revert to backup "{label}"')
    _apply_save(payload)

    return jsonify({"ok": True, "restored": revision, "label": label})

@app.route("/player.json")
def player_state():
    """The signed-in player's real state, for the web front end.

    The save is the only source of truth for level, XP and resources. The Bun
    service has its own ``progress`` table for the account, but nothing writes
    to it from the game, so reading it produced a level 1 player sitting next to
    a level 85 empire. This endpoint is what the account page now reads.

    Everything here is read from ``session['user_object']``, i.e. the save
    belonging to this browser's game session, and the zid comes from
    ``get_zid()`` so it is the account when the request came through the front
    door. A player who has not started a game yet gets ``hasSave: false``
    rather than an error.
    """
    zid = get_zid()
    user_object = session.get('user_object')

    if not user_object or not validate_save(session):
        return jsonify({
            "hasSave": False,
            "zid": zid,
            "level": None,
            "xp": None,
            "empirePoints": None,
            "worldName": None,
            "picture": get_avatar_pic(),
            "resources": dict.fromkeys(RESOURCE_ORDER),
        })

    info = user_object["userInfo"]
    player = info["player"]
    resources = info["world"]["resources"]

    return jsonify({
        "hasSave": True,
        "zid": zid,
        # 'cash' is what the client has always displayed as Empire Points.
        "level": player.get("level"),
        "xp": player.get("xp"),
        "empirePoints": player.get("cash"),
        "worldName": info.get("worldName"),
        "picture": get_avatar_pic(),
        "resources": {name: resources.get(name) for name in RESOURCE_ORDER},
    })


def get_allies_friend(saves):
    return [ally["friend"] for ally in allies.values()
            if "friend" in ally and ally["friend"] and ally["neighbor"]] + get_sessions_friends(saves)


def get_suggested_friends():
    return [ally["friend"] for ally in allies.values()
            if "friend" in ally and ally["friend"] and not ally["neighbor"]]


def get_allies_id(saves):
    return [ally["appFriendId"] for ally in allies.values()
            if "appFriendId" in ally and ally["appFriendId"] is not None] + get_sessions_id(saves)


def get_allies_info():
    return [ally["info"] for ally in allies.values() if ally["info"] and ally.get("neighbor")]+ get_sessions_info(
        get_saves())


@app.route("/nodebug.html")
def no_debug():
    print("no debug page")
    if not validate_save(session, True):
        print("Invalid save game")
        return make_response(redirect('/admin/editor')) # an unusable save needs fixing
    saves = get_saves()
    return render_template("nodebug.html", time=datetime.now().timestamp(), zid=str(get_zid()),
                           version=version,
                           allies=json.dumps(get_allies_friend(saves),
                                             default=lambda o: '<not serializable>', sort_keys=False, indent=2),
                           app_friends=json.dumps(get_allies_id(saves)),
                           worldname=session['user_object']["userInfo"]["worldName"] if 'user_object' in session else "Emperor",
                           picture=get_avatar_pic(),
                           dropdown_items=get_sessions_dropdown_info(saves),
                           motd=get_motd()
                           )


@app.route("/wipe_session", methods=['GET', 'POST'])
def wipe_session():
    session.clear()
    # Used to land on /login.html, the 2013 session picker. That page is gone;
    # the front door is this service's own landing page, which offers both
    # signing in and starting a new account.
    response = make_response(redirect('/'))
    # response.set_cookie('session', '', expires=0)
    return response


# @app.route("/switch-session/session-id/<session_id>", methods=['GET', 'POST'])
# def switch_session(session_id):
#     response = make_response(redirect('/home.html'))
#     #session.sid = session_id.split(":")[1]
#     #response.set_cookie('sessions3', session_id.split(":")[1], max_age=60*60*24*365*2)
#     return response


@app.route("/list_session", methods=['GET', 'POST'])
def list_session():
    # get_all_sessions() returns raw SQLAlchemy rows; get_sessions_dropdown_info
    # expects decoded save dicts, so passing rows here raised AttributeError
    # ('Session' object has no attribute 'get') as soon as one save existed.
    #
    # Served as JSON rather than as a bare string: the web front end reads this
    # to render /admin/sessions, and text/html for a JSON document means the
    # browser has to guess. The route is admin-gated at the proxy, which is the
    # only layer that knows who is signed in.
    return jsonify(get_sessions_dropdown_info(get_saves()))


def get_sessions_dropdown_info(saves):
    if saves:
        response = [{
            "session_id": save['session_id'],
            "uid": save['user_object']["userInfo"]["player"]["uid"],
            "world_name": save['user_object']["userInfo"]["worldName"],
            "level": save['user_object']["userInfo"]["player"]["level"],
            "xp": save['user_object']["userInfo"]["player"]["xp"],
            "profilePic": "img/avatars/" + (save['profilePic'] if 'profilePic' in save and save['profilePic'] is not None else "blank.png"),
        } for save in saves if validate_save(save)]
    else:
        response = []
    return response

def get_sessions_info(saves):
    if saves:
        response = [{
            "uid": save['user_object']["userInfo"]["player"]["uid"],
            "resource": save['user_object']["userInfo"]["player"]["playerResourceType"],
            "coins": save['user_object']["userInfo"]["world"]['resources']["coins"],
            "xp": save['user_object']["userInfo"]["player"]["xp"],
            "level": save['user_object']["userInfo"]["player"]["level"],
            "socialXpGood": save['user_object']["userInfo"]["player"]["socialXpGood"],
            "socialLevelGood": save['user_object']["userInfo"]["player"]["socialLevelGood"],
            "socialXpBad": save['user_object']["userInfo"]["player"]["socialXpBad"],
            "socialLevelBad": save['user_object']["userInfo"]["player"]["socialLevelBad"],
            "profilePic": "img/avatars/" + (save['profilePic'] if 'profilePic' in save and save['profilePic'] is not None else "blank.png"),
            "dominanceRank": 1,
            "pvpNumOccupiers": len([k for k, v in save['user_object']["pvp"]["invaders"].items() if k != "pve"]),
            "pvpNumOccupiersNotDefended": len([k for k, v in save['user_object']["pvp"]["invaders"].items() if k != "pve"]),
            "pvpInfo": next((v for k, v in save['user_object']["pvp"]["invaders"].items() if k == "u" + str(get_zid())), None),
            "tending": {
                "actions": 3
            }
        } for save in saves if validate_save(save) and save['user_object']["userInfo"]["player"]["level"] >= -6]
    else:
        response = []
    return response


@app.route("/gazillionaire", methods=['GET', 'POST'])
def more_money():
    if 'user_object' in session:
        create_backup("gazillionaire cheat")
        player = session['user_object']["userInfo"]["player"]
        player['cash'] += 10000
        session['saved'] = str(session.get('saved', "")) +  "gazillionaire"
        response = make_response(redirect('/home.html'))
        return response
    return ("Nope! You don't have a game session yet", 403)


@app.route("/deprogress", methods=['GET', 'POST'])
def deprogress_battle_map():
    if 'user_object' in session:
        # player = session['user_object']["userInfo"]["player"]
        campaign = session['user_object']['userInfo']['world']['campaign']
        # if map_name not in campaign['active'].keys():
        #     campaign['active'][map_name] = {"status": 0, "fleets": []}
        list = sorted(campaign['active'].keys())

        map, island = get_active_island_by_map(list[-1])

        create_backup("before deprogress battle map " + str(island+1) + "=>" + str(island))
        session['saved'] = str(session.get('saved', "")) + "deprogress"
        if island <= 0:
            del campaign['active'][map]
            deprogress_battle_map()
        else:
            set_active_island_by_map(map, island - 1)
        response = make_response(redirect('/home.html'))
        return response
    return ("Nope! You don't have a game session yet", 403)


@app.route("/seed/w/<int:w>/z/<int:z>", methods=['GET', 'POST'])
def change_seed(w, z):
    if 'user_object' in session:
        create_backup("seed")
        world = session['user_object']["userInfo"]["world"]
        prev_seed = str(world["randSeedW"]) + ', ' + str(world["randSeedZ"])
        world["randSeedW"] = w
        world["randSeedZ"] = z
        print("Seed change", prev_seed, "=>", str(world["randSeedW"]) + ', ' + str(world["randSeedZ"]))

        session['saved'] = str(session.get('saved', "")) +  "seed"
        response = make_response(redirect('/home.html'))
        return response
    return ("Nope! You don't have a game session yet", 403)


@app.route("/patch/<path:path>/empty-dict", methods=['GET', 'POST'])
def patch_user_empty_dict(path):
    return patch_user(path, {})


@app.route("/patch/<path:path>/empty-list", methods=['GET', 'POST'])
def patch_user_empty_list(path):
    return patch_user(path, [])


@app.route("/patch/<path:path>/none", methods=['GET', 'POST'])
def patch_user_dict(path):
    return patch_user(path, None)


@app.route("/patch/<path:path>/int/<int:value>", methods=['GET', 'POST'])
@app.route("/patch/<path:path>/string/<value>", methods=['GET', 'POST'])
def patch_user(path, value):
    if 'user_object' in session:
        if path.split('/')[0] not in ("saved", "original_save_version"):
            create_backup("patch")
            dictionary = session
            for p in path.split('/')[:-1]:
                dictionary = dictionary[p]

            dictionary[path.split('/')[-1]] = value

            session['saved'] = str(session.get('saved', "")) + "patch"
            response = make_response(redirect('/home.html'))
            return response
        return ("Nope! Disallowed patch root", 403)
    return ("Nope! You don't have a game session yet", 403)


@app.route("/patch/<path:path>/list/index/<int:i>/int/<int:value>", methods=['GET', 'POST'])
@app.route("/patch/<path:path>/list/index/<int:i>/string/<value>", methods=['GET', 'POST'])
def patch_user_list(path, i, value):
    if 'user_object' in session:
        if path.split('/')[0] not in ("saved", "original_save_version"):
            create_backup("patch")
            dictionary = session
            for p in path.split('/'):
                dictionary = dictionary[p]

            dictionary[i] = value

            session['saved'] = str(session.get('saved', "")) + "patch"
            response = make_response(redirect('/home.html'))
            return response
        return ("Nope! Disallowed patch root", 403)
    return ("Nope! You don't have a game session yet", 403)


@app.route("/unlock_quest/<value>", methods=['GET', 'POST'])
def unlock_quest(value):
    if 'user_object' in session:
        create_backup("Unlocked quest " + value)
        new_quests=[]
        meta = {}
        new_quest_with_sequels(value, new_quests, meta, force=True)
        merge_quest_progress(new_quests, session['quests'], "session quest")
        session['saved'] = str(session.get('saved', "")) + "unlock"

        response = make_response(redirect('/home.html'))
        return response
    return ("Nope! You don't have a game session yet", 403)


@app.route("/complete_quest/<value>", methods=['GET', 'POST'])
def complete_quest(value):
    if 'user_object' in session:
        create_backup("Complete quest " + value)
        new_quests=[]
        meta = {}
        handle_quest_progress(meta, progress_quest(value))
        session['saved'] = str(session.get('saved', "")) + "complete"

        response = make_response(redirect('/home.html'))
        return response
    return ("Nope! You don't have a game session yet", 403)


@app.route("/remove_quest/<value>", methods=['GET', 'POST'])
def remove_quest(value):
    if 'user_object' in session:
        create_backup("Remove quest " + value)
        session['quests'] = [e for e in session['quests'] if e["name"] != value]
        session['saved'] = str(session.get('saved', "")) + "remove"

        response = make_response(redirect('/home.html'))
        return response
    return ("Nope! You don't have a game session yet", 403)


@app.route("/save-editor")
def save_editor():
    """The 2013 editor is gone; /admin/editor replaced it.

    Kept as a redirect so an old bookmark, a post on a forum or a muscle-memory
    URL lands on the current page instead of a 404. The proxy still gates this
    path as admin-only, which is what stops anyone discovering the move.
    """
    return redirect('/admin/editor')


def format_backup_message(backup):
    """One line describing a snapshot, for the editor's list.

    Takes a ``save_store.BackupRow``. It used to take the snapshot dict itself
    and dig out ``replaced_on`` / ``message`` / ``save_version``, all of which
    lived on the node because the chain was nested inside the save. The reason
    and the timestamp are columns now, so there is nothing to dig out.
    """
    reason = backup.reason or ""
    return f"{backup.created_at} - rev {backup.revision} - {reason}"


@app.route("/record_stats.php", methods=['GET', 'POST'])
@app.route("/127.0.0.1record_stats.php", methods=['GET', 'POST'])
def record_stats():
    return ('', 204)


@app.route("/files/empire-s.assets.zgncdn.com/assets/109338/ZGame.109338.swf")
def flashFile():
    # return send_from_directory_mod("assets", "ZGame.109338.swf")
    return send_from_directory_mod("assets", "ZGame.109338_tracer2.swf")  # regular one
    # return send_from_directory_mod("assets", "ZGame.109338_tracer2a.swf")  # with extra debug logging


@app.route("/gameSettings.xml")
def game_settings_file():
    # return send_from_directory_mod("assets/32995", "gameSettings.xml")
    # return send_from_directory_mod("assets/32995", "gameSettings.xml")
    # return send_from_directory_mod("assets/29oct2012", "gameSettings.xml")
    # return send_from_directory_mod("assets/29oct2012", "gameSettings_placeholders.xml")
    return send_from_directory_mod("assets/29oct2012", "gameSettings_with_fixes.xml")


@app.route("/en_US.xml")
@app.route("/127.0.0.1en_US.xml")
def en_us_file():
    # return send_from_directory_mod("assets/32995", "en_US.xml")
    return send_from_directory_mod("assets/29oct2012", "en_US.xml")


@app.route("/questSettings.xml")
@app.route("/127.0.0.1questSettings.xml")
def quest_settings_file():
    return send_from_directory_mod("assets/29oct2012", "questSettings_with_fixes.xml")

@app.route("/friends.html")
def friends_page():
    """The 2013 player list, gone. /admin/sessions replaced it.

    It dumped every player's world name, level and xp into the page, which is
    the same data /list_session hands over and for the same reason it is
    admin-only there. ``ruffle.html`` and ``nodebug.html`` linked here as "My
    Neighbors"; they now link to /admin/sessions, which renders the same list
    with the same gate.
    """
    return redirect('/admin/sessions')

def get_avail_avatars():
    # list(set([u for u in fetch_urls() if u.endswith('.png')]))
    # return avatar_file_names in os.walk(os.path.join(my_games_path() ,"templates/img"))
    # TODO
    avatar_list = ["2_PincusCP_100.png",
                    "4_NavyCP_04_100.png",
                    "5_NavyCP_03_100.png",
                    "6_NavyCP_02_100.png",
                    "7_NavyCP_01_100.png",
                    "8_HansCP_100.png",
                    "9_ArtCP_100.png",
                    "10_ArmyCP_04_100.png",
                    "11_ArmyCP_03_100.png",
                    "12_ArmyCP_02_100.png",
                    "13_ArmyCP_01_100.png",
                    "14_AirForceCP_04_100.png",
                    "15_AirForceCP_03_100.png",
                    "16_AirForceCP_02_100.png",
                    "17_AirForceCP_01_100.png"]
    return avatar_list

def get_avail_motds():
    # return avatar_file_names in os.walk(os.path.join(my_games_path() ,"templates/img/motds"))
    # TODO
    motds = [
        "Loading_BattleBlitz.png",
        "MOTD_AssailantAmbush01.png",
        "MOTD_BlazingInferno02.png",
        "MOTD_BlazingInferno03.png",
        "MOTD_BlazingInferno07.png",
        "MOTD_BlueBarrage11.png",
        "MOTD_BlueBarrage3.png",
        "MOTD_BlueBarrage6.png",
        "MOTD_BlueBarrage8.png",
        "MOTD_BlueBarrage9.png",
        "MOTD_BuildableAmityNavalStation.png",
        "MOTD_BuildableCompCenter.png",
        "MOTD_BuildableDeco_01.png",
        "MOTD_BuildableDeco_02.png",
        "MOTD_BuildableFarmCamp.png",
        "MOTD_BuildableLighthouse.png",
        "MOTD_BuildableNeighborhood.png",
        "MOTD_Campaign02Part01.png",
        "MOTD_CommandoDamageAcademy.png",
        "MOTD_DangerousDeployments3.png",
        "MOTD_DecoBuildableCyberWarfare.png",
        "MOTD_DecoDogPark.png",
        "MOTD_DooberDrop.png",
        "MOTD_ElementZCollider.png",
        "MOTD_Espionage_HQ.png",
        "MOTD_FactoryRefresh.png",
        "MOTD_FierceFighters2.png",
        "MOTD_FrenchXMilitaryCenter.png",
        "MOTD_MGS_02.png",
        "MOTD_MGS_03.png",
        "MOTD_MGS_04.png",
        "MOTD_MS_036.png",
        "MOTD_MS_038.png",
        "MOTD_MS_040.png",
        "MOTD_MS_041.png",
        "MOTD_MS_042.png",
        "MOTD_MS_043.png",
        "MOTD_MS_044_03.png",
        "MOTD_MS_045_02.png",
        "MOTD_MS_046_03.png",
        "MOTD_MS_047_03.png",
        "MOTD_MS_050_02.png",
        "MOTD_MenacingMarines01.png",
        "MOTD_MiniGame.png",
        "MOTD_OreMine.png",
        "MOTD_Parliament.png",
        "MOTD_PotOfOre.png",
        "MOTD_QuestBuildableStatue.png",
        "MOTD_Research_1_1.png",
        "MOTD_SovereignSentinels01.png",
        "MOTD_SovereignSentinels04.png",
        "MOTD_SurvivalModeRefresh02.png",
        "MOTD_Tier08.png",
        "MOTD_TierSurfacing.png",
        "MOTD_VRTrainingSimulator.png",
        "MOTD_VeteranWarriors01.png",
        "MOTD_WorldGames.png",
        "MOTD_LightningDeal01.png",
        "MOTD_LightningDeal02.png",
        "MOTD_LightningDeal03.png",
        "MOTD_LightningDeal04.png",
        "MOTD_LightningDeal05.png",
        "MOTD_LightningDeal06.png",
        "MOTD_LightningDeal07.png",
        "MOTD_LightningDeal08.png",
        "MOTD_LightningDeal09.png",
        "MOTD_LightningDeal10.png",
        "MOTD_LightningDeal11.png",
        "MOTD_LightningDeal12.png",
        "MOTD_LightningDeal13.png",
        "MOTD_LightningDeal14.png",
        "MOTD_LightningDeal15.png",
        "MOTD_LightningDeal16.png",
        "MOTD_LightningDeal17.png",
        "MOTD_LightningDeal18.png",
        "MOTD_LightningDeal19.png",
        "MOTD_LightningDeal20.png",
        "MOTD_LightningDeal21.png",
        "MOTD_LightningDeal22.png",
        "MOTD_LightningDeal25.png",
        "MOTD_LightningDeal28.png",
        "MOTD_LightningDeal29.png",
        "MOTD_LightningDeal30.png",
        "MOTD_LightningDeal31.png",
        "MOTD_LightningDeal32.png",
        "MOTD_LightningDeal33.png",
        "MOTD_LightningDeal34.png",
        "MOTD_Agents_of_Terror.png",
        "MOTD_Alcatraz.png",
        "MOTD_Battleship_Bounty.png",
        "MOTD_Black_Gold_Rush.png",
        "MOTD_Blazing_Inferno_1.png",
        "MOTD_Blazing_Inferno_10.png",
        "MOTD_Blazing_Inferno_4.png",
        "MOTD_Blazing_Inferno_5.png",
        "MOTD_Blazing_Inferno_6.png",
        "MOTD_Blazing_Inferno_8.png",
        "MOTD_Blazing_Inferno_9.png",
        "MOTD_BuildableMechResearch.png",
        "MOTD_Crisis_on_Mercadia.png",
        "MOTD_Cyclone_Power.png",
        "MOTD_Deep_Sea_Discord.png",
        "MOTD_Democracy_by_Warfare.png",
        "MOTD_ElementZ.png",
        "MOTD_FightingTitan.png",
        "MOTD_Fissile_Mission.png",
        "MOTD_Furious_Five_1.png",
        "MOTD_Furious_Five_2.png",
        "MOTD_Furious_Five_3.png",
        "MOTD_Furious_Five_4.png",
        "MOTD_Future_Fleet_Week.png",
        "MOTD_Lucky_Shot_Raffle_Mini-Game.png",
        "MOTD_Madman_Menace.png",
        "MOTD_MechLab.png",
        "MOTD_Menacing_Mercenaries_2.png",
        "MOTD_Nuts_and_Bolts.png",
        "MOTD_Operation_Arctic_Blast.png",
        "MOTD_Out_of_Thin_Air.png",
        "MOTD_Pillage_and_Plunder.png",
        "MOTD_Race_against_Time.png",
        "MOTD_Stolen_AI.png",
        "MOTD_The_Missing_Plans.png",
        "MOTD_Tyrants_and_Assassins.png",
        "MOTD_White_Sabres_1.png",
        "MOTD_White_Sabres_2.png",
        "MOTD_White_Sabres_3.png",
        "MOTD_White_Sabres_4.png",
        "MOTD_Wrath_of_the_Titans_II.png",
        "MOTD_AirForceStorage_01.png",
        "MOTD_ArmyStorage_01.png",
        "MOTD_ElementZRegenerator.png",
        "MOTD_GoldUnits.png",
        "MOTD_HeavenlyRulersPalace.png",
        "MOTD_NavalStorage_01.png",
        "MOTD_SurvivalMode.png",
        "MOTD_World_Domination.png"
    ]
    return motds

@app.route("/new.html")
def new_player_page():
    saves = get_saves()
    return render_template("new.html", version=version, release_date=release_date, avatars=get_avail_avatars())

@app.route("/avatar.json")
def avatar_state():
    """The avatar catalogue and the one this player picked, for the web front end.

    The 2013 picker was ``/new.html``, a Jinja page that only the old launcher
    linked to. The player now starts at /juego, so nothing pointed at it and the
    choice became unreachable. This is the same data as JSON so /juego can show
    the grid without a Jinja template in the way.
    """
    return jsonify({
        "avatars": get_avail_avatars(),
        # null means "never chose one", which the picker shows as the default.
        "current": session.get('profilePic'),
        "picture": get_avatar_pic(),
    })


@app.route("/chooseavatar/<path:path>", methods=['GET', 'POST'])
def choose_avatar(path):
    """Pick an avatar, as /new.html's grid did.

    The value used to be stored verbatim. It is a path parameter, so anything
    reaching this route became ``profilePic`` and was handed straight back out
    as ``img/avatars/<that>`` by ``get_avatar_pic`` and the friend lists. The
    serving routes are safe on their own, but a save should never carry a
    caller-supplied path, so it is checked against the catalogue first and the
    request is refused when it is not one of the files we ship.
    """
    if path not in get_avail_avatars():
        print("Rejecting unknown avatar", path)
        return make_response(jsonify({"ok": False, "message": "Ese avatar no existe"}), 400)
    session['profilePic'] = path
    return make_response(redirect('/home.html'))


def get_avatar_pic():
    avatar_pic = "img/avatars/" + (session['profilePic'] if 'profilePic' in session and session['profilePic'] is not None else "blank.png")
    return avatar_pic


@app.route("/motd.json")
def motd_state():
    """The Message of the Day art, for the loading screen.

    The 2013 player drew a random one of 139 and painted it behind the EA frame
    while the game booted. ``templates/ruffle.html`` did it inline; this is the
    same data as JSON so the SvelteKit player can do it without the template.

    Both the catalogue and the pick are sent: the pick so the page has something
    to show on the first paint without asking twice, and the catalogue so the
    front end can offer another without a round trip.
    """
    motds = get_avail_motds()
    return jsonify({
        "motds": motds,
        "current": random.choice(motds),
    })


def get_motd():
    motd = "img/motds/" + random.choice(get_avail_motds())
    return motd

@app.route("/changelog.txt")
def change_log():
    return render_template("changelog.txt")

@app.route("/img/<path:path>")
def template_img(path):
    return send_from_directory_mod("templates/img", path)

@app.route("/js/<path:path>")
def template_js(path):
    return send_from_directory_mod("templates/js", path)

@app.route("/css/<path:path>")
def template_css(path):
    return send_from_directory_mod("templates/css", path)

@app.route('/nullassets/<path:path>')
def send_sol_assets(path):
    return send_from_directory_mod('assets/sol_assets_octdict/assets', path)

@app.route('/assets/<path:path>')
def send_sol_assets_alternate(path):
    return send_from_directory_mod('assets/sol_assets_octdict/assets', path)


def send_from_directory_mod(directory, filename, **options):
    absolute_directory = os.path.join(install_path(), directory)
    path = safe_join(os.fspath(absolute_directory), os.fspath(filename))
    print(path)

    return mod_engine.mod.get(path)() if path in mod_engine.mod else send_from_directory(absolute_directory, filename, **options)


@contextmanager
def _tolerate_batch_failure(call_count):
    """Keep one bad call in an AMF batch from killing the rest of it.

    Every gateway crash this week was the same shape: a handler raised something
    the narrow ``except`` around it did not name, it escaped to Flask, and Flask
    answered 500. Ruffle reads a 500 as an unreachable gateway and retries the
    same batch forever, so one bad call cost the player the whole turn.

    Three of them in a row also showed the cost of fixing that one exception at
    a time -- ``IndexError`` caught but ``TypeError`` not, ``pyamf.DecodeError``
    caught but ``OSError`` not. Enumerating the next one is guesswork, so this
    catches everything at the boundary instead and lets the specific handlers
    above it stay narrow, where they can carry a real recovery.

    The exception is swallowed and logged at ERROR with the full traceback.
    That traceback is how each of these was found in the first place, so it has
    to keep reaching log.txt -- this changes who the client hears from, not
    whether we write it down.

    As a context manager rather than a try/except so the 425-line dispatch chain
    below keeps its indentation.
    """
    try:
        yield
    except Exception:
        logger.error(
            "Gateway batch failed after at least one call; answering the rest",
            exc_info=True,
        )


def _pad_batch_results(resps, call_count):
    """Give every call in a batch an answer, even ones that raised.

    The client matches responses to requests, so a short list is not a shorter
    turn -- it is a mismatched one. Anything that did not get a real answer
    gets the empty result, which is what an unimplemented service returns anyway.
    """
    while len(resps) < call_count:
        resps.append(dummy_response())
    return resps


def _amf_as_list(value):
    """Return ``value`` as a list, decoding dense integer-keyed AMF objects.

    Flash's own NetConnection encodes arrays as dense AMF arrays, which pyamf
    decodes to Python lists. Other AVM2 implementations -- Ruffle among them --
    encode them as objects with numeric keys instead, which pyamf decodes to
    ``{0: ..., 1: ...}``. The game logic expects lists, so accept both shapes.

    Only the two places the client sends arrays are touched: the batch's
    transaction list and each transaction's ``params``. Everything else keeps
    its original type, because pyamf objects are dict subclasses that the
    dispatch loop reads with attribute access (``reqq.functionName``).
    """
    if isinstance(value, dict):
        keys = list(value.keys())
        if keys and all(isinstance(k, int) and not isinstance(k, bool) for k in keys):
            return [value[k] for k in sorted(keys)]
    return value


def _amf_detach(value, _path=None):
    """Rebuild ``value`` so that no object appears twice by identity.

    pyamf's AMF0 encoder writes a reference marker (0x07) whenever the same
    Python object is encountered a second time. Flash resolves those, but
    Ruffle's ``deserialize_value_impl`` does not implement ``AmfValue::Reference``
    and logs an error, yielding ``undefined`` in the client -- which surfaces as
    null objects in the game (e.g. ``TInitRequestFriends/onComplete`` throwing
    #1009).

    Several handlers legitimately reuse one dict in more than one place (for
    example the same ally appears in several friend lists), so the response is
    rebuilt with fresh containers. Scalars are returned untouched: repeating
    ``None`` or an int never produces a reference marker.
    """
    if _path is None:
        _path = set()

    if isinstance(value, (dict, list, tuple)):
        if id(value) in _path:
            # Cyclic payload; AMF has no way to express it anyway.
            print("WARNING: cyclic structure in gateway response, truncating")
            return None
        _path = _path | {id(value)}

        if isinstance(value, dict):
            return {k: _amf_detach(v, _path) for k, v in value.items()}
        return [_amf_detach(item, _path) for item in value]

    return value


# The Flash client builds its endpoint URLs from the app_url FlashVar. When that
# is missing it falls back to the compiled-in default "127.0.0.1", producing a
# scheme-less URL such as "127.0.0.1flashservices/gateway.php". Relative URLs
# are fine for record_stats (plain URLRequest), but Ruffle's
# NetConnection.connect() only accepts URLs starting with http:// or https:// --
# anything else is stubbed out and every call() afterwards throws Error #2126.
# So the absolute variants are registered alongside the legacy relative ones.
@app.route('/flashservices/gateway.php', methods=['POST'])
@app.route('/files/empire-s.assets.zgncdn.com/assets/109338/127.0.0.1flashservices/gateway.php', methods=['POST'])
def post_gateway():
    print("Gateway:")
    print(repr(request))
    # print("Data:")
    # print(request.data)

    # A body pyamf cannot read is a client that spoke wrong, not a broken
    # server. Left uncaught this raised out of the Flask handler and answered
    # 500, which Ruffle reports as an unreachable gateway rather than as a
    # bad request -- so the client retried the same broken body forever.
    #
    # Deliberately wider than pyamf.DecodeError: decoding an empty body raises
    # OSError from the buffer ("Attempted to read 2 bytes ... but only 0
    # remain") and a truncated one raises from the struct decoder, and both were
    # reaching here as 500s as well. This step only parses untrusted input, so
    # any failure in it belongs to the client.
    try:
        resp_msg = remoting.decode(request.data)
    except Exception as error:
        print("Rejecting undecodable AMF body:", type(error).__name__, error)
        return make_response("Bad AMF request", 400)

    # print(resp_msg.headers)
    print(resp_msg.bodies)
    # print(resp_msg.bodies[0])

    batch_body = resp_msg.bodies[0][1].body
    calls = _amf_as_list(batch_body[1])
    resps = []
    with _tolerate_batch_failure(len(calls)):
        for reqq in calls:
            # The batch is a list of calls and the client is free to put anything in
            # it. pyamf decodes a call into an ASObject -- a dict subclass that also
            # answers attribute access, which is why `reqq.functionName` below is
            # not a bug -- but a stray scalar used to reach that line and raise
            # AttributeError, taking every other call in the same batch down with
            # it. Skip it and answer the rest.
            if not isinstance(reqq, dict):
                print("Skipping non-object entry in AMF batch:", repr(reqq))
                continue
            if reqq.get('params') is not None:
                reqq['params'] = _amf_as_list(reqq['params'])
            if reqq.functionName == 'UserService.initUser':
                try:
                    resps.append(user_response())
                except InvalidSaveException as error:
                    print('Handling InvalidSaveException error:', error)
                    # return make_response(redirect('/save-editor')) #can't do it here

            elif reqq.functionName == 'DataServicesService.getRequestFriends':
                resps.append(friend_response())
            elif reqq.functionName == 'PVPService.getUsersInvaderChallenges':
                resps.append(invader_response())
            elif reqq.functionName == 'ZlingshotService.presence':
                resps.append(zlingshot_response())
            elif reqq.functionName == 'DataServicesService.getRecentPlayers':
                resps.append(recent_response())
            elif reqq.functionName == 'DataServicesService.getFriendsInfo':
                resps.append(friend_info_response())
            elif reqq.functionName == 'UserService.tutorialProgress':
                resps.append(tutorial_response(reqq.params[0], reqq.sequence, resp_msg.bodies[0][0]))
            elif reqq.functionName == 'WorldService.performAction':
                wr = perform_world_response(reqq.params)
                resps.append(wr)
                report_world_log(reqq.params[0] + ' id ' + str(reqq.params[1].id) + '@' + reqq.params[1].position,
                                 wr["data"], reqq.params, reqq.sequence, resp_msg.bodies[0][0],
                                 wr["metadata"].get('QuestComponent'), wr["metadata"].get('newPVE'))
            elif reqq.functionName == 'DataServicesService.getSuggestedNeighbors':
                resps.append(neighbor_suggestion_response())
            elif reqq.functionName == 'UserService.setSeenFlag':
                resps.append(seen_flag_response(reqq.params[0]))
            elif reqq.functionName == 'PVPService.createRandomFleetChallenge':
                resps.append(random_fleet_challenge_response(reqq.params[0]))
            elif reqq.functionName == 'WorldService.spawnFleet':
                resps.append(spawn_fleet(reqq.params[0]))
            elif reqq.functionName == 'PVPService.loadChallenge':
                resps.append(load_challenge_response(reqq.params[0]))
            elif reqq.functionName == 'WorldService.resolveBattle':
                try:
                    resps.append(battle_complete_response(reqq.params[0]))
                except (StaleBattleReference, IndexError) as error:
                    print('Ignoring stale or out-of-range resolveBattle request:', error)
                    resps.append(dummy_response())
            elif reqq.functionName == 'WorldService.genericString':
                resps.append(generic_string_response(reqq.params[0]))
            elif reqq.functionName == 'UserService.streakBonus':
                resps.append(streak_bonus_response(reqq.params[0]))
            elif reqq.functionName == 'UserService.setWorldName':
                resps.append(world_name_response(reqq.params[0]))
            elif reqq.functionName == 'WorldService.updateRoads':
                resps.append(update_roads_response(reqq.params[0]))
            elif reqq.functionName == 'UserService.streamPublish':
                resps.append(stream_publish_response(reqq.params))
            elif reqq.functionName == 'WorldService.stopMayhemEvent':
                resps.append(stop_mayhem_response())
            elif reqq.functionName == 'UserService.saveOptions':
                resps.append(save_options_response(reqq.params[0]))
            elif reqq.functionName == 'WorldService.fullScreen':
                resps.append(full_screen_response())
            elif reqq.functionName == 'WorldService.viewZoom':
                resps.append(view_zoom_response(reqq.params[0].get('zoom')))
            elif reqq.functionName == 'WorldService.loadWorld':
                resps.append(load_world_response(reqq.params))
            elif reqq.functionName == 'VisitorService.help':
                resps.append(tend_ally_response(reqq.params))
            elif reqq.functionName == 'WorldService.beginNextCampaign':
                resps.append(next_campaign_response(reqq.params[0]))
            elif reqq.functionName == 'WorldService.addFleet':
                resps.append(add_fleet_response(reqq.params[0]))
            elif reqq.functionName == 'WorldService.assignConsumable':
                try:
                    resps.append(assign_consumable_response(reqq.params[0]))
                except StaleBattleReference as error:
                    print('Ignoring stale assignConsumable request:', error)
                    resps.append(dummy_response())
            elif reqq.functionName == 'UserService.publishUserAction':
                resps.append(dummy_response())
            elif reqq.functionName == 'UserService.sendUserNotification':
                resps.append(dummy_response())
            elif reqq.functionName == 'WorldService.sendZaspReport':
                resps.append(dummy_response())
            elif reqq.functionName == 'ClansService.buyCrest':
                resps.append(dummy_response())
            elif reqq.functionName == 'ClansService.buyHealth':
                resps.append(dummy_response())
            elif reqq.functionName == 'ClansService.buySlots':
                resps.append(dummy_response())
            elif reqq.functionName == 'ClansService.clearNotifications':
                resps.append(dummy_response())
            elif reqq.functionName == 'ClansService.createClan':
                resps.append(dummy_response())
            elif reqq.functionName == 'ClansService.getClanInfo':
                resps.append(dummy_response())
            elif reqq.functionName == 'ClansService.getNeighborClanInfo':
                resps.append(dummy_response())
            elif reqq.functionName == 'ClansService.loadAllianceBattle':
                resps.append(dummy_response())
            elif reqq.functionName == 'ClansService.postGroupFeed':
                resps.append(dummy_response())
            elif reqq.functionName == 'ClansService.processMemberQueue':
                resps.append(dummy_response())
            elif reqq.functionName == 'ClansService.removeMember':
                resps.append(dummy_response())
            elif reqq.functionName == 'ClansService.addTaunt':
                resps.append(dummy_response())
            elif reqq.functionName == 'ClansService.updateName':
                resps.append(dummy_response())
            elif reqq.functionName == 'ClansService.updateCrest':
                resps.append(dummy_response())
            elif reqq.functionName == 'ClansService.updateTauntViewTime':
                resps.append(dummy_response())
            elif reqq.functionName == 'DeathMatchService.fetchOpponents':
                resps.append(dummy_response())
            elif reqq.functionName == 'DeathMatchService.joinRoom':
                resps.append(dummy_response())
            elif reqq.functionName == 'DeathMatchService.processRewardQueue':
                resps.append(dummy_response())
            elif reqq.functionName == 'ClansService.acceptQuest':
                resps.append(dummy_response())
            elif reqq.functionName == 'PVPService.acceptDecoBuildableRepel':
                resps.append(dummy_response())
            elif reqq.functionName == 'PVPService.acceptDefenseTowerRepel':
                resps.append(dummy_response())
            elif reqq.functionName == 'UserService.acceptedGDP':
                resps.append(dummy_response())
            elif reqq.functionName == 'UserService.acceptedTOS':
                resps.append(dummy_response())
            elif reqq.functionName == 'PVPService.acceptFriendRepel':
                resps.append(accept_friend_repel_response(reqq.params[0]))
            elif reqq.functionName == 'CrossPromoService.accepted':
                resps.append(dummy_response())
            elif reqq.functionName == 'UserService.acknowledgeTOSStatus':
                resps.append(dummy_response())
            elif reqq.functionName == 'UserService.reactivateFightMeter':
                resps.append(dummy_response())
            elif reqq.functionName == 'DominationModeService.addDominationChat':
                resps.append(dummy_response())
            elif reqq.functionName == 'UserService.addFriendPublish':
                resps.append(dummy_response())
            elif reqq.functionName == 'ClansService.completeQuest':
                resps.append(dummy_response())
            elif reqq.functionName == 'RequestService.partRequest':
                resps.append(part_request_response(reqq.params))
            elif reqq.functionName == 'WorldService.beginQuestBattle':
                resps.append(dummy_response())
            elif reqq.functionName == 'BlackMarketHelperService.tradeForPart':
                resps.append(dummy_response())
            elif reqq.functionName == 'UserService.bookmarksDailySpin':
                resps.append(dummy_response())
            elif reqq.functionName == 'UserService.buyBack':
                resps.append(dummy_response())
            elif reqq.functionName == 'MiniGameService.buyMiniGameFuel':
                resps.append(dummy_response())
            elif reqq.functionName == 'PVPService.buyCrewRepelPosition':
                resps.append(dummy_response())
            elif reqq.functionName == 'UserService.buyExpansion':
                resps.append(buy_expansion_response(reqq.params[0]))
            elif reqq.functionName == 'UserService.buyFullHeal':
                resps.append(dummy_response())
            elif reqq.functionName == 'UserService.buyItem':
                resps.append(buy_item_response(reqq.params[0]))
            elif reqq.functionName == 'UserService.buyItems':
                resps.append(buy_items_response(reqq.params[0]))
            elif reqq.functionName == 'UserService.useItem':
                resps.append(use_item_response(reqq.params[0]))
            elif reqq.functionName == 'UserService.buyMOTDItem':
                resps.append(dummy_response())
            elif reqq.functionName == 'UserService.buyQuestRestartTask':
                resps.append(dummy_response())
            elif reqq.functionName == 'UserService.buyQuestTask':
                resps.append(buy_quest_task_response(reqq.params[0]))
            elif reqq.functionName == 'UserService.buyRewardItem':
                resps.append(dummy_response())
            elif reqq.functionName == 'WorldService.calculateRansom':
                resps.append(dummy_response())
            elif reqq.functionName == 'PVPService.cancelUnstartedChallenge':
                resps.append(cancel_unstarted_challenge_response())
            elif reqq.functionName == 'UserService.checkForPromoReward':
                resps.append(dummy_response())
            elif reqq.functionName == 'UserService.clearOldFlashTokens':
                resps.append(dummy_response())
            elif reqq.functionName == 'UserService.clearIncentive':
                resps.append(dummy_response())
            elif reqq.functionName == 'UserService.collectLeaderboards':
                resps.append(dummy_response())
            elif reqq.functionName == 'PVPService.completeSocialRepel':
                resps.append(dummy_response())
            elif reqq.functionName == 'UserService.crewNeighborPoll':
                resps.append(dummy_response())
            elif reqq.functionName == 'UserService.crewZMCEvent':
                resps.append(dummy_response())
            elif reqq.functionName == 'MiniGameService.dropBomb':
                resps.append(dummy_response())
            elif reqq.functionName == 'UserService.energizerSetup':
                resps.append(dummy_response())
            elif reqq.functionName == 'UserService.EPGiftSend':
                resps.append(dummy_response())
            elif reqq.functionName == 'UserService.finishSpy':
                resps.append(dummy_response())
            elif reqq.functionName == 'PVPService.setEspionageHQData':
                resps.append(dummy_response())
            elif reqq.functionName == 'WorldService.exitBattle':
                resps.append(exit_battle_response())
            elif reqq.functionName == 'WorldService.expireAQuest':
                resps.append(dummy_response())
            elif reqq.functionName == 'PVPService.getFightList':
                resps.append(dummy_response())
            elif reqq.functionName == 'UserService.flashFeedRedeemItem':
                resps.append(dummy_response())
            elif reqq.functionName == 'UserService.EPGiftThankYou':
                resps.append(dummy_response())
            elif reqq.functionName == 'PVPService.getAllChallenges':
                resps.append(dummy_response())
            elif reqq.functionName == 'DominationModeService.getDominationChat':
                resps.append(dummy_response())
            elif reqq.functionName == 'DominationModeService.getDominationModeOpponentList':
                resps.append(dummy_response())
            elif reqq.functionName == 'UserService.getFBCreditPromoStatus':
                resps.append(dummy_response())
            elif reqq.functionName == 'FeedService.getFeed':
                resps.append(dummy_response())
            elif reqq.functionName == 'UserService.getLeaderboards':
                resps.append(dummy_response())
            elif reqq.functionName == 'PVPService.getNeighborVisitChallenges':
                resps.append(neighbor_invader_response(reqq.params[0]))
            elif reqq.functionName == 'UserService.getPrisonerInfo':
                resps.append(dummy_response())
            elif reqq.functionName == 'DataServicesService.getPromoData':
                resps.append(dummy_response())
            elif reqq.functionName == 'UserService.getTargetingData':
                resps.append(dummy_response())
            elif reqq.functionName == 'UserService.getTargetingGroups':
                resps.append(dummy_response())
            elif reqq.functionName == 'UserService.grantWatchToEarnRewardNew':
                resps.append(dummy_response())
            elif reqq.functionName == 'DominationModeService.loadDominationModeBattle':
                resps.append(dummy_response())
            elif reqq.functionName == 'PVPService.loadEnemyFleetForChallenge':
                resps.append(random_enemy_fleet_challenge_response(reqq.params[0]))
            elif reqq.functionName == 'QuestSurvivalModeService.loadQuestSurvivalMode':
                resps.append(dummy_response())
            elif reqq.functionName == 'SurvivalModeService.loadSurvivalMode':
                resps.append(load_survival_mode_response(reqq.params[0]))
            elif reqq.functionName == 'UserService.lcs':
                resps.append(dummy_response())
            elif reqq.functionName == 'DataServicesService.getMatchmakingUsersData':
                resps.append(dummy_response())
            elif reqq.functionName == 'UserService.matchMakingOptFlag':
                resps.append(dummy_response())
            elif reqq.functionName == 'WorldService.mechlabStatus':
                resps.append(dummy_response())
            elif reqq.functionName == 'UserService.megaSeriesReset':
                resps.append(dummy_response())
            elif reqq.functionName == 'ZlingshotService.fetch':
                resps.append(dummy_response())
            elif reqq.functionName == 'MFSService.collectReward':
                resps.append(dummy_response())
            elif reqq.functionName == 'UserService.motdAction':
                resps.append(dummy_response())
            elif reqq.functionName == 'WorldService.multiHarvest':
                resps.append(dummy_response())
            elif reqq.functionName == 'DataServicesService.getRecommendedNeighbors':
                resps.append(dummy_response())
            elif reqq.functionName == 'WorldService.openDialog':
                resps.append(dummy_response())
            elif reqq.functionName == 'UserService.promoAction':
                resps.append(dummy_response())
            elif reqq.functionName == 'UserService.purchaseAmmoRefill':
                resps.append(dummy_response())
            elif reqq.functionName == 'UserService.purchaseContractUnlock':
                resps.append(purchase_contact_unlock(reqq.params[0]))
            elif reqq.functionName == 'UserService.purchaseEnergyRefill':
                resps.append(purchase_energy_refill_response(reqq.params[0]))
            elif reqq.functionName == 'UserService.purchaseManaRefill':
                resps.append(dummy_response())
            elif reqq.functionName == 'UserService.purchaseUnlock':
                resps.append(dummy_response())
            elif reqq.functionName == 'PVPService.globalPVPOptInOut':
                resps.append(dummy_response())
            elif reqq.functionName == 'PVPService.slotMachineSpin':
                resps.append(dummy_response())
            elif reqq.functionName == 'PVPService.slotMachineSpinBuy':
                resps.append(dummy_response())
            elif reqq.functionName == 'PVPService.immunityExtend':
                resps.append(dummy_response())
            elif reqq.functionName == 'PVPService.immunityStart':
                resps.append(dummy_response())
            elif reqq.functionName == 'PVPService.occupationPlace':
                resps.append(occupation_place_response(reqq.params))
            elif reqq.functionName == 'PVPService.pillage':
                resps.append(pillage_response(reqq.params))
            elif reqq.functionName == 'UserService.doFavQuest':
                resps.append(dummy_response())
            elif reqq.functionName == 'UserService.doSeenQuestNotification':
                resps.append(dummy_response())
            elif reqq.functionName == 'UserService.questTreeReset':
                resps.append(dummy_response())
            elif reqq.functionName == 'UserService.questTreeSetMode':
                resps.append(dummy_response())
            elif reqq.functionName == 'UserService.questTreeStartQuest':
                resps.append(dummy_response())
            elif reqq.functionName == 'UserService.questTreeUnlockQuest':
                resps.append(dummy_response())
            elif reqq.functionName == 'PVPService.rejectDecoBuildableRepel':
                resps.append(dummy_response())
            elif reqq.functionName == 'PVPService.rejectDefenseTowerRepel':
                resps.append(dummy_response())
            elif reqq.functionName == 'PVPService.rejectFriendRepel':
                resps.append(reject_friend_repel_response(reqq.params[0]))
            elif reqq.functionName == 'UserService.removeExpiredInventory':
                resps.append(dummy_response())
            elif reqq.functionName == 'WorldService.removeExtraInventoryBuildings':
                resps.append(dummy_response())
            elif reqq.functionName == 'WorldService.removeExtraWorldBuildings':
                resps.append(dummy_response())
            elif reqq.functionName == 'UserService.setTitanName':
                resps.append(dummy_response())
            elif reqq.functionName == 'RequestService.allianceInviteRequest':
                resps.append(dummy_response())
            elif reqq.functionName == 'RequestService.allianceJoinRequest':
                resps.append(dummy_response())
            elif reqq.functionName == 'RequestService.crewRequest':
                resps.append(crew_request_response(reqq.params))
            elif reqq.functionName == 'RequestService.invasionHelpRequest':
                resps.append(dummy_response())
            elif reqq.functionName == 'RequestService.neighborRequest':
                resps.append(dummy_response())
            elif reqq.functionName == 'RequestService.giftRequest':
                resps.append(dummy_response())
            elif reqq.functionName == 'WorldService.resetParliamentDestroyed':
                resps.append(dummy_response())
            elif reqq.functionName == 'PVPService.retrieveNeighborRepelChallenge':
                resps.append(neighbor_repel_challenge_response(reqq.params))
            elif reqq.functionName == 'PVPService.reviveAllies':
                resps.append(dummy_response())
            elif reqq.functionName == 'WorldService.reviveUnits':
                resps.append(dummy_response())
            elif reqq.functionName == 'WorldService.moveRoad':
                resps.append(update_roads_response(reqq.params[0]))
            elif reqq.functionName == 'WorldService.sellRoad':
                resps.append(update_roads_response(reqq.params[0]))
            elif reqq.functionName == 'PVPService.seenPrisonCampNotification':
                resps.append(dummy_response())
            elif reqq.functionName == 'PVPService.seenStrikeTeamComment':
                resps.append(dummy_response())
            elif reqq.functionName == 'WorldService.select':
                resps.append(select_response(reqq.params[0]))
            elif reqq.functionName == 'UserService.setCommandoAnimationDone':
                resps.append(dummy_response())
            elif reqq.functionName == 'UserService.setCurrentCampaign':
                resps.append(dummy_response())
            elif reqq.functionName == 'PVPService.setDefenderComment':
                resps.append(dummy_response())
            elif reqq.functionName == 'UserService.setEnergiserAnimationDone':
                resps.append(dummy_response())
            elif reqq.functionName == 'UserService.setFBCreditParticipation':
                resps.append(dummy_response())
            elif reqq.functionName == 'PVPService.setInvasionComment':
                resps.append(dummy_response())
            elif reqq.functionName == 'PVPService.setStrikeTeamComment':
                resps.append(dummy_response())
            elif reqq.functionName == 'UserService.setTag':
                resps.append(dummy_response())
            elif reqq.functionName == 'UserService.spend':
                resps.append(dummy_response())
            elif reqq.functionName == 'DeathMatchService.loadBattle':
                resps.append(dummy_response())
            elif reqq.functionName == 'WorldService.startMayhemEvent':
                resps.append(dummy_response())
            elif reqq.functionName == 'MiniGameService.loadGame':
                resps.append(dummy_response())
            elif reqq.functionName == 'MiniGameService.stop':
                resps.append(dummy_response())
            elif reqq.functionName == 'UserService.streamPublishWithComment':
                resps.append(dummy_response())
            elif reqq.functionName == 'UserService.superOreOrder':
                resps.append(dummy_response())
            elif reqq.functionName == 'UserService.setSurvivalModeToaster':
                resps.append(dummy_response())
            elif reqq.functionName == 'UserService.treasureVaultSpin':
                resps.append(dummy_response())
            elif reqq.functionName == 'UserService.unitDropRevealAll':
                resps.append(dummy_response())
            elif reqq.functionName == 'UserService.unitDropSwitchUnit':
                resps.append(dummy_response())
            elif reqq.functionName == 'UserService.unitUnlock':
                resps.append(dummy_response())
            elif reqq.functionName == 'UserService.buyUnlimitedEnergy':
                resps.append(dummy_response())
            elif reqq.functionName == 'UserService.unlockResource':
                resps.append(dummy_response())
            elif reqq.functionName == 'DominationModeService.updateDefenseForce':
                resps.append(dummy_response())
            elif reqq.functionName == 'WorldService.upgradeResearchBuilding':
                resps.append(dummy_response())
            elif reqq.functionName == 'UserService.upgradeState':
                resps.append(dummy_response())
            elif reqq.functionName == 'UserService.useItem':
                resps.append(dummy_response())
            elif reqq.functionName == 'PVPService.useStrikeTeam':
                resps.append(dummy_response())
            elif reqq.functionName == 'UserService.viralSurfacingSeen':
                resps.append(dummy_response())
            elif reqq.functionName == 'VisitorService.accept':
                resps.append(accept_tend_ally_response(reqq.params))
            elif reqq.functionName == 'VisitorService.decline':
                resps.append(decline_tend_ally_response(reqq.params))
            elif reqq.functionName == 'VisitorService.helpedInvalid':
                resps.append(dummy_response())
            elif reqq.functionName == 'UserService.grantWatchToEarnReward':
                resps.append(dummy_response())
            elif reqq.functionName == 'ZlingshotService.zoom':
                resps.append(dummy_response())
            else:
                resps.append(dummy_response())

            if reqq.functionName != 'UserService.tutorialProgress' and reqq.functionName != 'WorldService.performAction':
                report_other_log(reqq.functionName, resps[-1] if resps else None, reqq, resp_msg.bodies[0][0])

    # Anything that raised got no result, and the client matches responses
    # to requests -- so a short list is a mismatched turn, not a shorter one.
    # Hand back an empty result for each, which is what an unimplemented
    # service returns anyway.
    resps = _pad_batch_results(resps, len(calls))

    emsg = _amf_detach({
        "serverTime": datetime.now().timestamp(),
        "errorType": 0,
        "data": resps
    })

    req = remoting.Response(emsg)
    ev = remoting.Envelope(pyamf.AMF0)
    ev[resp_msg.bodies[0][0]] = req
    #  print(ev.headers)
    # print(ev.bodies)

    ret_body = remoting.encode(ev, strict=True, logger=True).getvalue()  # .read()
    # print(ret_body)
    return Response(ret_body, mimetype='application/x-amf')

    # return ('', 204)


def init_user():
    # global game_objects
    unit = "U01,,,,"

    # resources = {"energy": 100, "coins": 100000, "oil": 7000, "wood": 5000, "aluminum": 9000,
    #                                 "copper": 4000, "gold": 3000, "iron": 2000, "uranium": 1000}

    resources = {"energy": 25, "coins": 5000, "oil": 25, "wood": 150, "aluminum": 1000,
                 "copper": 0, "gold": 0, "iron": 0, "uranium": 0}

    # xp = 20000
    # level =100
    # zcash = 1000
    # energy = 200
    # energy_max = 400
    xp = 0
    level = 1
    zcash = 15
    energy = 25
    energy_max = 25

    # user_fleet = {
    #     "type": "army",
    #     "uid": "0",
    #     "name": "FleetName",
    #     "status": 0,
    #     "target": "",
    #     "consumables": [],
    #     "inventory": [],
    #     "playerLevel": 1,
    #     "specialBits": None,
    #     "lost": None,
    #     "lastUnitLost": None,
    #     "lastIndexLost": None,
    #     "allies": None,
    #     "battleTarget": None,
    #     "battleTimestamp": None,
    #     "ransomRandom": None,
    #     "ransomResource": None,
    #     "ransomAmount": None,
    #     "units": [unit],  # only one unit for tutorial [unit, unit, unit],
    #     "store": [0],  # [0, 0, 0],
    #     "fleets": None,
    #     "upgrades": None,
    #     "hp": None
    # }

    user = {
        "userInfo": {
            "player": {
                "uid": get_zid(),
                "lastTrackingTimestamp": 0,
                "viralSurfacing": {"seen": [], "counts": {}},
                "crewNeighbors": [],
                "dm_band": None,
                "dm_endTS": None,
                "tutorialProgress": "",
                "xp_multiplier": 1,
                "cp_static": 1,
                "lightningDeals": {},
                "friendFlashSessionInfo": {},
                "m_friendFlashEPBank": 1000,
                "playerResourceType": 3,  # 0:coins 1:oil 2: wood 3:alum,
                "meetsCriteriaLowWalletOnly": False,
                "newInstallExperiments": None,
                "staticWorkers": 20,
                "staticWorkersCap": 100,
                # "expansions": {
                #     "data": [4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295,
                #              4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295,
                #              4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295,
                #              4294967295, 4294967295]},
                "expansions": {"data": [0,0,0,0,805306368,6291456,49152,0,0,0,0]},
                "questTrees": {},
                "questTreeUnlocks": {},
                "questTreeData": {},
                "starredQuests": [],
                "seenQuests": [],
                "megaseriesList": {},
                "questGatesComplete": False,
                "warpSeconds": 0,
                "worldGamesOver": 0,
                "lastLoginTimestamp": 0,
                "RUXStatus": False,
                "RUXQuest": False,
                "RUXDay": 0,
                "RUXInitShow": False,
                "RUXDelta": 0,
                "MFSRewardPoints": 0,
                "MFSRewardClaimed": False,
                "MFSRewardLap": 0,
                "mana": {"value": 100},
                "cash": zcash,
                "level": level,
                "xp": xp,
                "numCashTransactions": 100,
                "cashPurchasedTotal": 1000,
                "transactionLog": [],
                "combatSpecialBits": None,
                "promos": None,
                "autopromo": None,
                "motdMerchHistory": None,
                "motdMerchUnlockHistory": None,
                "lufCodes": None,
                "lufEndDate": 0,
                "lufZRTData": None,
                "lufCodesLevelUnlocked": None,
                "miniGamePlayedTS": 0,
                "bomberFuel": 1000,
                "bombTierReached": 0,
                "miniGameRewardTier": 0,
                "miniGameRewards": [],
                "miniGameTotalFuel": 1500,
                "mgrsData": "",
                "seenFlags": {},
                # seen "introCine":True otherwise blackscreen but no startepisode then ->  either false (ZGlobal.noIntroCineVariant != ZGlobal.EXPERIMENT_NO_INTRO_CINE && Zlab.getFlashVar("mute") == null)
                "motdsViewed": [],
                "motdsAccepted": [],
                "m_mayhemEvents": None,
                "bountyCenter": {"lastActivated": 0, "bountyBonds": 0},
                "energizerRefill": 1000,
                "energiserEventFinished": False,
                "energiserAnimationInitTime": 0,
                "energyDeduct": 0,
                "energizerMax": 1000,
                "energy": energy,
                "energyMax": energy_max,
                "unlimitedEnergyTS": 0,
                "unlimitedEnergyIndex": 0,
                "lastEnergyCheck": datetime.now().timestamp(),
                "ammo": 1234,
                "ammoMax": 2000,
                "options": {"musicDisabled": False, "sfxDisabled": False},
                "socialLevelGood": 100,
                "socialXpGood": 10000,
                "socialLevelBad": 0,
                "socialXpBad": 0,
                "scrap": None,
                "enableIdlePopup": False,
                "enableInterPage": False,
                "enableOnetimePopup": False,
                "alliesUsed": None,
                "storageData": {},
                "inventory": {"items": {"B01": 20}},
                "neighborVisits": {},
                "unlockedUnits": [],
                "unlockedItems": [],
                "unlockedContracts": [],
                "tags": {},
                "consumableUsedByCode": None,
                "treasureVaultOpenTS": 0,
                "watchToEarn": {"dailyWatchCount": 0, "dailyWatchStartTime": 0},
                "userGroups": None,
                "flashFeedTokens": None,
                "lastSurvialModeToaster": 0,
                "clanStatus": None,
                "allianceStorage": None,
                "acceptedAllianceQuests": None,
                "isCIP": False,
                "acceptedGDP": True,
                "acceptedTOS": True,
                "fightMeter": {"lastActivated": 0, "lastInitWeek": 0, "weekInitTarget": 0},
                "fightsPerDay": 1,
                # "fleets": None,
                "activeVirals": {},
                "sequentialLogins": 1,
                "mechDailyRewardOffset": 0,

                "world": {
                    "deathMatch": None
                }
            },
            "worldName": "Rising Empire",
            "titanName": "Titan",
            "isCIP": False,
            "dominanceDefaultFleets": [],
            "bookmarkReward": 0,
            "iconCodes": None,

            "world": {"fleets": [], "enemies": [], "globalFleetId": 0, "battleStatus": {},  # user_fleet
                      "research": {}, "research2": {"buildingTypesUpgraded": None, "treesUnlocked": None},
                      "resourceOrder": ["aluminum", "copper", "gold", "iron", "uranium"],
                      "globalObjectId": 10000,  # initial id high enough not to overlap with preloaded objects
                      "sizeX": 200,
                      "sizeY": 200,
                      "ownerId": 0,
                      "randSeedW": rand_seed_w,
                      "randSeedZ": rand_seed_z,
                      "unitDropData": {"unclaimedUnits": []},
                      "islands": 1,
                      "roadData": initial_island["roads"],
                      "objects": initial_island["objects"],
                      "rewardRandSeedW": 484584,
                      "rewardRandSeedZ": 7549,
                      "ransomRandSeedW": 456647,
                      "ransomRandSeedZ": 4546,
                      "scrapRandSeedW": 5646,
                      "scrapRandSeedZ": 3567,
                      "resources": resources,
                      "campaign": {"current": "camp001", "active": {}, "mastery": {}}
                      }

        },
        "neighbors": get_allies_info(),
        "unlockedResource": {"aluminum": 3, "copper": 4, "gold": 5, "iron": 6},
        "showBookmark": True,
        "firstDay": True,
        "survivalMode": None,
        "prisonerInfo": [],
        "pvp": {"invaders": {"pve": {"quest": True}}, "gpInv": None, "nAssists": None, "immunity": [],
                "notifications": None, "pcCapturedNotify": None, "pcEscapedNotify": None},
        "autoFilledCrewBuildings": None,
        "numCrewNeighborsDirty": 0,
        "ineligibleGiftRecipients": [],
        "priceTestSettings": {},
        "buyBackSettings": {},
        "DEATHMATCH_FRAG_LIMITS": None,
        "DEATHMATCH_CACHE_TTL": None,
        "DEATHMATCH_OPP_COOLDOWN": None,
        "DEATHMATCH_STANDARD_REWARDS": None,
        "DEATHMATCH_GRAND_REWARDS": None,
        "DEATHMATCH_START_TIME": None,
        "DEATHMATCH_DURATION": None,
        "clansInfo": None,
        "immunityTimeVariant": 0,
        "experiments": {"empire_combataicancritical": 2, "empire_decorations_master": 2, "empire_doober_pickup": 3,
                        "empires_consumable_2": 3, "empire_research_shield_upgrade": 2, "empires_support_units": 5,
                        "empire_buildable_zrig_master": 3, "empire_request2_master": 2, "empire_mfs_uili": 4,
                        "empire_survivalmode3_master": 3, "empire_survivalMode_master": 2,
                        "empire_survivalmode_enhancements": 2, "empire_mech_fight_master": 3, "empire_mech_fight_gate_flat": 5,
                        "empire_mech_lab_master": 3, "empire_titanresearch_master": 2, "empire_tier_8": 4,
                        "empire_campv2_enabled": 2, "empire_campaign_mastery": 2},
        "completedQuests": [],
        "decorationsInfo": None,
        "treasureVaultHighlights": None,
        "crewSlotCostExperiment": 0,
        "combatAllyGatingVarient": 0,
        "cashOnLevelUpVarient": 0,
        "immunityViralVarient": 0,
        "autopublishFeedVarient": 0,
        "autopublishFeedMessageVarient": 0,
        "publishFeedPermissionVarient": 0,
        "autopublishAllFeedVarient": 0,
        "researchPartsVariantArmy": 0,
        "researchPartsVariantNavy": 0,
        "researchPartsVariantAir": 0,
        "noIntroCineVariant": 2,  # disable intro cinematics (we don't have yet)
        "energyRewardVariant_v2": 0,
        "energyRewardVariant_v3": 0,
        "allyTimeoutVariant": 0,
        "speedUpViralVarient": 0,
        "pricetestEarlyUnitUnlockVariant": 0,
        "starterBundleVariant": 0,
        "meetsCriteriaStarterPack": False,
        "energyRewardModVariant": 0,
        "enhancedProgressBarVariant": 0,
        "epSpendConfirmation": 0,
        "leaderboardsVariant": 0,
        "survivalModeMaster": 0,
        "survivalModeContinueCost": 0,
        "survivalModeCardAccess": 0,
        "INTERSTITIAL_GIFTING_REWARDS": "",
        "FREE_GIFT_PARTS_BUILDING_DATA": "",
        "snid": 0,
        "snuid": 0,
        "visitorHelpRequests": {},
        "LE_DISCOUNT_SALE": 0,
        "LOW_EP_POPUP": None,
        "COMBAT_NO_ENERGY": 0,
        "COMBAT_DOUBLE_XP": 2,
        "COMBAT_HALF_RANSOM": 1,
        "overlaySurveyURL": None,
        "friendBarVarient": 0,
        "requestTracker": {"giftRequestSent": {}, "helpRequestSent": {}, "crewRequestSent": {},
                           "neighborRequestSent": {}, "repelInvasionRequestSent": {}, "allianceInviteRequestSent": {}},
        "activeRequests": {"request_speedup": None, "request_buildingpart_send": None, "request_crew": None,
                           "request_gift_request": None, "request_gift_send": None, "request_neighbor": None,
                           "request_repel_invasion": None, "request_alliance_invite": None},
        "activeGiftRequests": [],
        "activeHelpRequests": [],
        "allPendingNeighbors": [],
        "playerAsn": 1,
        "questInitAsn": 1,
        "partsGatherInitAsn": 1,
        "blackmarketItems": None,
        "worldEvents": None,
        "FLASHFEED_EXPIRE_TIME": 0,
        "FB_REQ_PERMS": "gdpr",
    }
    return user


# Q0516 ? start
def user_response():
    new_quests = []
    if 'user_object' in session:
        print("Loading user from save")
        if not validate_save(session):
            print("invalid save file")
            raise InvalidSaveException
        user = session['user_object']
        user["userInfo"]["player"]["uid"] = get_zid()
        if session.get('save_version') != version:
            print("WARNING: Save game was saved with version", session.get('save_version'), "while game is version",
                  version)

        qc = session['quests']

        user["neighbors"] = get_allies_info()

        meta = {"newPVE": 0, "QuestComponent": [e for e in session['quests'] if not e["complete"]]}

    else:
        user = copy.deepcopy(init_user())
        print("initialized new")
        session['user_object'] = user
        # qc = [{"name": "Q0516", "complete":False, "expired":False,"progress":[0],"completedTasks":0}]
        session['quests'] = []

        session['save_version'] = version
        session['original_save_version'] = version
        session['saved_on'] = datetime.now().timestamp()
        meta = {"newPVE": 0, "QuestComponent": [e for e in session['quests'] if not e["complete"]]}
        new_quest_with_sequels("Q0516", new_quests, meta)

    # session['user_object']["userInfo"]["player"]["tutorialProgress"] = "tut_step_krunsch1Battle2Speeech" #'tut_step_inviteFriendsViral'
    # session['user_object']["userInfo"]["player"]["tutorialProgress"] = 'tut_step_remindCombatUIWaitForPreBattleUI'
    # session['user_object']["userInfo"]["player"]["tutorialProgress"] = 'tut_step_remindCombatUIClearCircles'
    # session['user_object']["userInfo"]["player"]["lastEnergyCheck"] = datetime.now().timestamp()
    # save migration only
    # if "lastEnergyCheck" not in session['user_object']["userInfo"]["player"]:
    #     session['user_object']["userInfo"]["player"]["lastEnergyCheck"] = datetime.now().timestamp()

    replenish_energy()

    session["battle"] = None
    session["fleets"] = {}
    session['population'] = lookup_yield()

    if "market" not in session:
        session["market"] = {}
    # #temp migration
    # session['user_object']["experiments"]["empire_store_sorting_rev_enhanced"] = 0
    # session['user_object']["experiments"]["empires_shop_improvements"] = 0
    session['user_object']["experiments"]["empire_combataicancritical"] = 2
    unlock_expansion(156)
    unlock_expansion(157)
    unlock_expansion(181)
    unlock_expansion(182)
    unlock_expansion(206)
    unlock_expansion(207)
    # battle_status = 0
    # island = 2
    # replay_island = 0
    #
    # status_campaign = battle_status | replay_island << 8 | island << 20
    # status_campaign_2 = battle_status | replay_island << 8 | 5 << 20
    # # #
    # user['userInfo']['world']['campaign'] = {"current": "camp001", "active":{'C000': {"status": status_campaign, "fleets":[]},
    #                                                                        'C003': {"status": status_campaign_2, "fleets":[]}}, "mastery": {}}

    # user['userInfo']['world']['campaign'] =  {"current": "camp001", "active": {}, "mastery": {}}
    # user['userInfo']['world']['campaign'] =  {"current": "camp001", "active": {'C000': {"status": 1 << 20, "fleets":[]}}, "mastery": {}}

    # session['campaign'] = {}
    # session['campaign']['C003'] = {'island':4} #will receive a next "island": 1

    # if ""B01": 20"


    item_inventory = session['user_object']["userInfo"]["player"]["inventory"]["items"]
    if item_inventory.get("B01", 0) < 20:
        item_inventory["B01"] = 20
        print("Refilling upgrade blueprints to 20")  # until friend gift mechanisms are working
    if item_inventory.get("B05", 0) < 25:
        item_inventory["B05"] = 25
        print("Refilling advanced hull plating to 25")  # until friend gift mechanisms are working
    if item_inventory.get("B18", 0) < 25:
        item_inventory["B18"] = 25
        print("Refilling propeller to 25")  # until friend gift mechanisms are working
    if item_inventory.get("B04", 0) < 25:
        item_inventory["B04"] = 25
        print("Refilling mission map to 25")  # until friend gift mechanisms are working
    if item_inventory.get("B23", 0) < 25:
        item_inventory["B23"] = 25
        print("Refilling blast shield to 25")  # until friend gift mechanisms are working
    if item_inventory.get("B17", 0) < 25:
        item_inventory["B17"] = 25
        print("Refilling deck turret to 25")  # until friend gift mechanisms are working

    mechLab_inventory_req = session['user_object']["userInfo"]["player"]["xp"]
    # Set level 21 (1881 xp) for all players to get Titan Lab in inventory
    if mechLab_inventory_req > 1880:
        # every session should only get once
        if not any(i["itemName"] == "MechLab" for i in session['user_object']["userInfo"]["world"]["objects"]) and item_inventory.get("TL01", 0) < 1:
            item_inventory["TL01"] = 1
            print("Level 21 has been reached, Titan Lab unlocked at inventory")

    handle_quest_progress(meta, progress_inventory_count())
    handle_quest_progress(meta, progress_neighbor_count())
    handle_quest_progress(meta, progress_upgrades_count())

    activate_unlocked_quests(new_quests, meta)

    for neighbor in user["neighbors"]:
        if neighbor["uid"] in [MIN_ADMIN_ID, MAX_ADMIN_ID]:
            neighbor["level"] =  user["userInfo"]["player"]["level"] + 5

    if session.get('save_version') != version or is_0_08a_preview(version):
        print("Trying migration")
        migrate(meta, session.get('save_version'), version)

    sleep(0.05)  # bugfix required delay for loading entire screen

    # for e in session['user_object']["userInfo"]["world"]["objects"]:
    #     e['lastUpdated'] = 1308211628  #1 minute earlier to test
    user["completedQuests"] = [e["name"] for e in session['quests'] if e["complete"]]

    merge_quest_progress(new_quests, meta['QuestComponent'], "output quest")
    merge_quest_progress(new_quests, session['quests'], "session quest")
    user_response = {"errorType": 0, "userId": get_zid(), "metadata": meta,
                     # {"name": "Q0531", "complete":False, "expired":False,"progress":[0],"completedTasks":0},{"name": "QW120", "complete":False, "expired":False,"progress":[0],"completedTasks":0}
                     "data": user}
    return user_response


def friend_response():
    friend_types = ["recommendedFriends", "zyngaFriends", "empireFriends", "sevenDayFriends", "fourteenDayFriends",
                    "thirtyDayFriends", "payerFriends", "allFriends", "zyngaFriendsByEngagement", "empireFriendsByEngagement"]
    friend = {friend_type: {"data": [ally["friend"] for ally in allies.values() if ally.get("friend") and ally.get(friend_type)]} for friend_type in friend_types}



    #     "recommendedFriends": {"data": [{"zid": 124, "uid":124, "first_name": "MissTery", "sex": 'F',"portrait": "assets/game/GeneralAssetGroup_UI.swf/TheVille_50.png",
    # "pic": "assets/game/GeneralAssetGroup_UI.swf/TheVille_50.png",
    # "pic_square": "assets/game/GeneralAssetGroup_UI.swf/TheVille_50.png"}]},
    #     "zyngaFriends": {"data": [{"zid": 124,"uid":124, "first_name": "MissTery", "sex": 'F', "portrait": "assets/game/GeneralAssetGroup_UI.swf/TheVille_50.png",
    # "pic": "assets/game/GeneralAssetGroup_UI.swf/TheVille_50.png",
    # "pic_square": "assets/game/GeneralAssetGroup_UI.swf/TheVille_50.png"}]},
    #     "empireFriends": {"data": [{"zid": 124,"uid":124, "first_name": "MissTery", "sex": 'F', "portrait": "assets/game/GeneralAssetGroup_UI.swf/TheVille_50.png",
    # "pic": "assets/game/GeneralAssetGroup_UI.swf/TheVille_50.png",
    # "pic_square": "assets/game/GeneralAssetGroup_UI.swf/TheVille_50.png"}]},
    #     "sevenDayFriends": {"data": [{"zid": 124, "uid":124,"first_name": "MissTery", "sex": 'F', "portrait": "assets/game/GeneralAssetGroup_UI.swf/TheVille_50.png",
    # "pic": "assets/game/GeneralAssetGroup_UI.swf/TheVille_50.png",
    # "pic_square": "assets/game/GeneralAssetGroup_UI.swf/TheVille_50.png"}]},
    #     "fourteenDayFriends": {"data": []},
    #     "thirtyDayFriends": {"data": []},
    #     "payerFriends": {"data": []},
    #     "allFriends": {"data": [{"zid": 124,"uid":124, "first_name": "MissTery", "sex": 'F',"portrait": "assets/game/GeneralAssetGroup_UI.swf/TheVille_50.png",
    # "pic": "assets/game/GeneralAssetGroup_UI.swf/TheVille_50.png",
    # "pic_square": "assets/game/GeneralAssetGroup_UI.swf/TheVille_50.png"}]},
    #     "zyngaFriendsByEngagement": {"data": []},
    #     "empireFriendsByEngagement": {"data": []},


    friend_response = {"errorType": 0, "userId": 1, "metadata": {"newPVE": 0},
                       "data": friend}
    return friend_response


def invader_response():
    invader_response = {"errorType": 0, "userId": 1, "metadata": {"newPVE": 0},
                        "data": [invader_entry(k[1:]) for k, v in session['user_object']["pvp"]["invaders"].items() if k != "pve"]}
    return invader_response


def neighbor_invader_response(uid):
    """The invasions aimed at one neighbour, by their uid.

    A miss here is a normal answer, not an anomaly: this is a list of who is
    currently poking at that player, and a player with no save has nobody. So
    ``required`` is off and the empty result stands.
    """
    save = get_save_by_uid(uid)

    if save:
        neigbor_invader_response = {"errorType": 0, "userId": 1, "metadata": {"newPVE": 0},
                            "data": [invader_entry(k[1:]) for k, v in save['user_object']["pvp"]["invaders"].items() if k != "pve"]}
    else:
        neigbor_invader_response = {"errorType": 0, "userId": 1, "metadata": {"newPVE": 0},
                                    "data": []}
    return neigbor_invader_response


def neighbor_repel_challenge_response(params):
    save = get_save_by_uid(params[0], required=True)

    neigbor_invader_response = {"errorType": 0, "userId": 1, "metadata": {"newPVE": 0},
                        "data": next((invader_entry(k[1:] + "_" + str(params[0])) for k, v in save['user_object']["pvp"]["invaders"].items() if k == "u" + str(params[1])), None)}
    return neigbor_invader_response


def accept_friend_repel_response(invader_uid):
    accept_friend_repel_response = {"errorType": 0, "userId": 1, "metadata": {"newPVE": 0},
                        "data": []}

    del session['user_object']["pvp"]["invaders"]["u" + invader_uid]
    return accept_friend_repel_response


def reject_friend_repel_response(invader_uid):
    reject_friend_repel_response = {"errorType": 0, "userId": 1, "metadata": {"newPVE": 0},
                        "data": []}

    del session['user_object']["pvp"]["invaders"]["u" + str(invader_uid)]["dID"]
    return reject_friend_repel_response


def cancel_unstarted_challenge_response():
    cancel_unstarted_invasions()
    cancel_unstarted_challenge_response = {"errorType": 0, "userId": 1, "metadata": {"newPVE": 0},
                        "data": []}

    return cancel_unstarted_challenge_response


def invader_entry(id):
    response = {"state": 0,
                "status": 0,
                "pFID": "",
                "eFID": "fleet1_" + id,
                "eID": id,
                "isAI": False,
                "isPVE": False,
                "isAssist": False
                }
    return response


def zlingshot_response():
    zlingshot_response = {"errorType": 0, "userId": 1, "metadata": {"newPVE": 0},
                          "data": {}}
    return zlingshot_response


def recent_response():
    recent_response = {"errorType": 0, "userId": 1, "metadata": {"newPVE": 0},
                       "data": []}
    return recent_response


def friend_info_response():
    friend_info_response = {"errorType": 0, "userId": 1, "metadata": {"newPVE": 0},
                            "data": {"nonAppFriends": [
                                ]}}
    return friend_info_response


def tutorial_response(step, sequence, endpoint):
    meta = {"newPVE": 0}
    qz = {"name": "Q0516", "complete": True, "expired": False, "progress": [1], "completedTasks": 1}
    qz_cadets_start = {"name": "Q0531", "complete": False, "expired": False, "progress": [0], "completedTasks": 0}
    # complete cadets?
    qz_cadets_start = {"name": "Q0531", "complete": False, "expired": False, "progress": [0], "completedTasks": 0}
    qz_cadets_done = {"name": "Q0531", "complete": True, "expired": False, "progress": [1], "completedTasks": 1}
    qz_invasion_start = {"name": "Q6016", "complete": False, "expired": False, "progress": [0], "completedTasks": 0}
    qz_invasion_done = {"name": "Q6016", "complete": True, "expired": False, "progress": [1], "completedTasks": 1}
    flag_Q1098_start = {"name": "Q1098", "complete": False, "expired": False, "progress": [0], "completedTasks": 0}
    flag_Q1098_done = {"name": "Q1098", "complete": True, "expired": False, "progress": [1], "completedTasks": 1}
    cadets_Q0611_start = {"name": "Q0611", "complete": False, "expired": False, "progress": [0], "completedTasks": 0}
    cadets_Q0611_done = {"name": "Q0611", "complete": True, "expired": False, "progress": [1], "completedTasks": 1}
    flag_Q6011_start = {"name": "Q6011", "complete": False, "expired": False, "progress": [0], "completedTasks": 0}
    flag_Q6011_done = {"name": "Q6011", "complete": True, "expired": False, "progress": [1], "completedTasks": 1}

    sergeant_Q0671_start = {"name": "Q0671", "complete": False, "expired": False, "progress": [0, 0],
                            "completedTasks": 0}  # after 6011
    sergeant_Q0671_done = {"name": "Q0671", "complete": True, "expired": False, "progress": [1, 1], "completedTasks": 2}
    flag_Q0591_start = {"name": "Q0591", "complete": False, "expired": False, "progress": [0], "completedTasks": 0}
    flag_Q0591_done = {"name": "Q0591", "complete": True, "expired": False, "progress": [1], "completedTasks": 1}
    farm_Q0571_start = {"name": "Q0571", "complete": False, "expired": False, "progress": [0, 0], "completedTasks": 0}
    farm_Q0571_done = {"name": "Q0571", "complete": True, "expired": False, "progress": [1, 1], "completedTasks": 2}
    corn_Q0521_start = {"name": "Q0521", "complete": False, "expired": False, "progress": [0], "completedTasks": 0}
    corn_Q0521_done = {"name": "Q0521", "complete": True, "expired": False, "progress": [1], "completedTasks": 1}
    parliament_Q0691_start = {"name": "Q0691", "complete": False, "expired": False, "progress": [0],
                              "completedTasks": 0}
    parliament_Q0691_done = {"name": "Q0691", "complete": True, "expired": False, "progress": [1], "completedTasks": 1}

    # if step == 'tut_step_placeBarracksServer':
    #     meta['QuestComponent'] = [qz, qz_cadets_start]
    # if step == 'tut_step_cadetsComplete':
    #     pass
    # handle_quest_progress(meta, progress_action("build")) build is covered
    # meta['QuestComponent'] = [qz_cadets_done, qz_invasion_start]  #what starts invasion?
    ## meta["newPVE"] = {"status": 2, "pos": "60,63,0", "villain":"v18", "quest":"Q6016"}
    # if step == 'tut_step_firstInvasionEnd':
    # if step == 'tut_step_postFirstInvasionResumeQuests':
    #     handle_quest_progress(meta, progress_action(
    #         "fight"))
    # meta['QuestComponent'] = [qz_invasion_done,flag_Q1098_start,cadets_Q0611_start]
    #  meta["newPVE"] = {"status": 2, "pos": "60,66,0", "villain":"v18", "quest":"Q6016"}  #contineous battle mode experience QT01_05b_2
    # if step == 'tut_step_placeFlagQuestDialog':
    #     meta['QuestComponent'] = [flag_Q1098_done, flag_Q6011_start]

    # if step == 'tut_step_placeFlagWaitForInventoryOpen':   # sometimes one of them is skipped?
    #     meta['QuestComponent'] = [flag_Q1098_done, flag_Q6011_start]
    # if step == 'tut_step_placeFlagEnd':
    #     meta['QuestComponent'] = [flag_Q6011_done, sergeant_Q0671_start, flag_Q0591_start]
    # if step == 'tut_step_buildFarm':  #after cadets placed?
    #     meta['QuestComponent'] = [cadets_Q0611_done, sergeant_Q0671_start] #possibly already done by this point see if it doesn't redo quests already done
    # if step == 'tut_step_placeHouseEnd':  #after cadets placed?
    #     meta['QuestComponent'] = [flag_Q0591_done, farm_Q0571_start]
    # if step == 'tut_step_placeFarmEnd':  #after cadets placed?
    #     meta['QuestComponent'] = [farm_Q0571_done, corn_Q0521_start, parliament_Q0691_start, sergeant_Q0671_start]
    #
    if step == 'tut_step_inviteFriendsEndPauseTutorial':
        handle_quest_progress(meta, progress_neighbor_count())

    merge_quest_progress(meta['QuestComponent'] if 'QuestComponent' in meta else [], session['quests'], "session quest")
    session['user_object']["userInfo"]["player"]["tutorialProgress"] = step  # TODO: revert step when loading if needed

    report_tutorial_step(step, meta['QuestComponent'] if 'QuestComponent' in meta else None, meta['newPVE'], sequence,
                         endpoint)
    tutorial_response = {"errorType": 0, "userId": 1, "metadata": meta,
                         "data": []}
    return tutorial_response


#def perform_world_response(step, supplied_id, position, item_name, reference_item, from_inventory, elapsed, cancel, req2):
def perform_world_response(params):

    step=params[0]
    supplied_id=params[1].id
    position=params[1].position
    item_name=params[1].itemName

    reference_item=params[2][0].get('referenceItem') if len(params[2]) > 0 else None
    from_inventory=params[2][0].get('isGift') if len(params[2]) > 0 else None
    elapsed=params[2][0].get('elapsed') if len(params[2]) > 0 else None
    cancel=params[2][0].get('cancel') if len(params[2]) > 0 else None
    req2=params[2][0] if len(params[2]) > 0 else None
    index_ref=params[2][0] if len(params[2]) > 0 else None

    print("this is step",step, supplied_id, position)

    id = supplied_id
    if step == "place":
        session['user_object']["userInfo"]["world"]["globalObjectId"] += 1  # for place only!
        id = session['user_object']["userInfo"]["world"]["globalObjectId"]
        session['user_object']["userInfo"]["world"]["objects"].append({
            "id": id,
            "itemName": item_name,
            "position": position,
            "referenceItem": reference_item,
            "state": 0
        })

    # cur_object = lookup_object(id)
    # print("cur_object used:"`, repr(cur_object))
    #
    #
    # game_item = lookup_item(item_name)
    # print("item used:", repr(game_item))
    #
    # state_machine = lookup_state_machine(game_item['stateMachineValues']['-stateMachineName'])
    # print("state_machine used:", repr(state_machine))
    # state = lookup_state(state_machine, cur_object['state'])
    # print("cur state:", repr(state))
    # next_click_state = lookup_state(state_machine, state['-clickNext']) # not all states have this!! end states? autostate after time?
    # print("next_click_state:", repr(next_click_state))
    meta = {"newPVE": 0}
    print(step)
    if step in ["place", "setState"]:
        click_next_state(True, id, meta, step, reference_item, cancel=cancel)  # place & setstate only

    if step == "setState":
        if lookup_object(id)["referenceItem"] is None and reference_item is not None:
            ref_item = lookup_item_by_code(reference_item.split(":")[0])
            if item_name == "Mastery Factory 01" and int(ref_item.get("masteryTokenCost","0"))> 0:
                session['user_object']["userInfo"]["player"]["inventory"]["items"]["VTK"] -= int(ref_item["masteryTokenCost"])
            else:
                costs = ref_item.get("cost")
                do_costs({k: v for k, v in costs.items() if k != "-cash"})
        lookup_object(id)["referenceItem"] = reference_item

    if step == "clear":
        session['user_object']["userInfo"]["world"]["objects"].remove(lookup_object(id))
        print("Object", id, "removed")

    if step == "move":
        lookup_object(id)["position"] = position
        print("Object", id, "moved to", position)

    if step == "place":
        if not from_inventory:
            costs = lookup_item_by_name(item_name).get("cost")
            if "-unitClass" in lookup_item_by_name(item_name):
                do_costs({k: v for k, v in costs.items() if k == "-cash"})
            else:
                do_costs(costs)
        else:
            item = lookup_item_by_name(item_name)
            item_inventory = session['user_object']["userInfo"]["player"]["inventory"]["items"]

            if item['-code'] in item_inventory:
                item_inventory[item['-code']] -= 1
                if item_inventory[item['-code']] <= 0:
                    del item_inventory[item['-code']]
                print("Placing", item_name + "(" + item['-code'] + ")", "from inventory")
            else:
                print("ERROR: Placing", item_name + "(" + item['-code'] + ")",
                      "from inventory but not in inventory. Ignoring for now.")

    if step == "speedUp":
        # lookup_object(id)['lastUpdated'] = lookup_object(id).get('lastUpdated', 0) - elapsed * 1000
        click_next_state(False, id, meta, step, reference_item, speed_up=True)
    # TODO: cost of speedup?

    if step == "add":
        market = lookup_object(id)
        refund_market_order(market)
        place_market_order(market, req2, meta)

    perform_world_response = {"errorType": 0, "userId": 1, "metadata": meta,
                              "data": {"id": id}}
    if step == "list":
        market = lookup_object(id)
        # perform_world_response["data"].update(session['market'].get(str(id), {}))
        perform_world_response["data"] = [market]
        # perform_world_response["data"][0]["id"] = id

    if step == "remove":
        market = lookup_object(id)
        perform_world_response["data"] = ["success"]  #  TODO fail if bought
        refund_market_order(market)

    if step == "sell":
        for i in range(len(session['user_object']["userInfo"]["world"]["objects"])):
            if session['user_object']["userInfo"]["world"]["objects"][i]['position'] == position:
                del session['user_object']["userInfo"]["world"]["objects"][i]
                break
        #TODO cost for selling
        # list1 = session['user_object']["userInfo"]["world"]["objects"]
        # session['user_object']["userInfo"]["world"]["objects"] = list(filter(lambda i: i['position'] != position), list1)

    if step == "staffPosition":
        crewTemplate = lookup_crew_template(item_name)
        num_slots = len(crewTemplate["position"])
        decoration = lookup_object(id)

        # TODO Crew index position is given, but not used.
        position_index = index_ref['index']

        current_crew = decoration.get("crewInfo", [])
        new_crew = current_crew + ["-1"]
        decoration["crewInfo"] = new_crew[:num_slots]

        print("staffing")

    if step == "decoCrewBuyOnce":
        crewTemplate = lookup_crew_template(item_name)
        num_slots = len(crewTemplate["position"])
        decoration = lookup_object(id)

        decoration["crewInfo"] = ["-1"] * num_slots
        print("staffing full")

    if step == "randomRewards":
        print(lookup_item_by_name(item_name).get("-code", 0))
        item_info = randomReward(lookup_item_by_name(item_name).get("-code", 0))
        item_code = item_info[0]
        item_amount = item_info[1]
        item_type = item_info[2]
        perform_world_response["data"]["data"] = {}
        perform_world_response["data"]["data"]["type"] = item_type
        perform_world_response["data"]["data"]["item"] = item_code
        perform_world_response["data"]["data"]["count"] = item_amount
        if item_type == "item":
            if item_code not in session['user_object']["userInfo"]["player"]["inventory"]["items"]:
                session['user_object']["userInfo"]["player"]["inventory"]["items"][item_code] = item_amount
            else:
                session['user_object']["userInfo"]["player"]["inventory"]["items"][item_code] += item_amount
        elif item_type == "cash":
            session['user_object']["userInfo"]["player"]["cash"] += item_amount
        else:
            session['user_object']["userInfo"]["world"]['resources']["coins"] += item_amount

    print("perform_world_response", repr(perform_world_response))
    return perform_world_response


def refund_market_order(market):
    world = session['user_object']["userInfo"]["world"]
    resources = world['resources']
    if market.get("type") == "resource":
        standard_resources = ["coins", "oil" , "wood", "aluminum", "copper", "gold", "iron", "uranium"]
        resources[standard_resources[int(market["item"])]] += market["units"]
        print("Market: Refunded", standard_resources[int(market["item"])] + ":", str(market["units"]) +
              "(" + str(resources[standard_resources[int(market["item"])]]) + ")")
    else:
        print("TODO: Can't refund market type", market.get("type"), "yet")
    market["type"] = None
    market["item"] = None
    market["units"] = None


def place_market_order(market, order, meta):
    world = session['user_object']["userInfo"]["world"]
    resources = world['resources']
    if order["type"] == "resource":
        standard_resources = ["coins", "oil", "wood", "aluminum", "copper", "gold", "iron", "uranium"]
        resources[standard_resources[int(order["item"])]] -= order["units"]
        print("Market: Order placed & removed", standard_resources[int(order["item"])] + ":", str(order["units"])
              + "(" + str(resources[standard_resources[int(order["item"])]]) + ")")
        handle_quest_progress(meta, progress_market_added_count(order["units"]))
    else:
        print("TODO: Can't reserve market type", order.get("type"), "yet")
    market["type"] = order["type"]
    market["item"] = order["item"]
    market["units"] = order["units"]


def neighbor_suggestion_response():
    neighbor_suggestion_response = {"errorType": 0, "userId": 1, "metadata": {"newPVE": 0},
                                    "data": get_suggested_friends()}
    return neighbor_suggestion_response


def seen_flag_response(flag):
    seen_flags = session['user_object']["userInfo"]["player"]["seenFlags"]

    seen_flags[flag] = seen_flags.get(flag, 0) + 1

    seen_flag_response = {"errorType": 0, "userId": 1, "metadata": {"newPVE": 0},
                          "data": []}
    return seen_flag_response


def random_fleet_challenge_response(host_uid):
    unit_user = "U01,,,,"
    unit = "U01,,,,"

    # user_fleet = {
    #     "type": "army",
    #     "uid": "0",
    #     "name": "FleetName",
    #     "status": 0,
    #     "target": "",
    #     "consumables": [],
    #     "inventory": [],
    #     "playerLevel": 1,
    #     "specialBits": None,
    #     "lost": None,
    #     "lastUnitLost": None,
    #     "lastIndexLost": None,
    #     "allies": None,
    #     "battleTarget": None,
    #     "battleTimestamp": None,
    #     "ransomRandom": None,
    #     "ransomResource": None,
    #     "ransomAmount": None,
    #     "units": [
    #         unit_user,
    #
    #               ],  # only one unit for tutorial [unit, unit, unit],
    #     "store": [0],  # [0, 0, 0],
    #     "fleets": None,
    #     "upgrades": None,
    #     "hp": None
    # }

    save = get_save_by_uid(host_uid, required=True)
    defender_fleet = save['user_object']["pvp"]["invaders"]["u" + str(get_zid())]["defender_fleet"]

    subtype = lookup_item_by_code(defender_fleet[0].split(',')[0])["-subtype"]

    fleet = {
        "type": subtype,
        "uid": host_uid,
        "name": "FleetName",
        "status": 0,
        "target": "",
        "consumables": [],
        "inventory": [],
        "playerLevel": 1,
        "specialBits": None,
        "lost": None,
        "lastUnitLost": None,
        "lastIndexLost": None,
        "allies": None,
        "battleTarget": None,
        "battleTimestamp": None,
        "ransomRandom": None,
        "ransomResource": None,
        "ransomAmount": None,
        "units": defender_fleet,
        "store": [0],  # [0, 0, 0],
        "fleets": [],
        "upgrades": None,
        "hp": None,
        "invader": False
    }

    register_fleetname_fleet(fleet)

    random_fleet_challenge_response = {"errorType": 0, "userId": 1, "metadata": {"newPVE": 0},
                                       "data": {
                                           "state": 0,
                                           "challengerFleet": fleet,
                                           "challengeInfo": {"status": 0, "state": 1},
                                           "maxUnits": 5
                                       }}
    return random_fleet_challenge_response


def random_enemy_fleet_challenge_response(enemy_fleet_id):
    unit_user = "U01,,,,"
    unit = "U01,,,,"

    # user_fleet = {
    #     "type": "army",
    #     "uid": "0",
    #     "name": "FleetName",
    #     "status": 0,
    #     "target": "",
    #     "consumables": [],
    #     "inventory": [],
    #     "playerLevel": 1,
    #     "specialBits": None,
    #     "lost": None,
    #     "lastUnitLost": None,
    #     "lastIndexLost": None,
    #     "allies": None,
    #     "battleTarget": None,
    #     "battleTimestamp": None,
    #     "ransomRandom": None,
    #     "ransomResource": None,
    #     "ransomAmount": None,
    #     "units": [
    #         unit_user,
    #
    #               ],  # only one unit for tutorial [unit, unit, unit],
    #     "store": [0],  # [0, 0, 0],
    #     "fleets": None,
    #     "upgrades": None,
    #     "hp": None
    # }

    placeholder_fleet = [format_player_fleet("PT24"), format_player_fleet("PT23"), format_player_fleet("PT02"), format_player_fleet("PT22"), format_player_fleet("PT12")]

    if len(enemy_fleet_id.split("_")) <= 2:
        attacker_fleet = session['user_object']["pvp"]["invaders"]["u" + enemy_fleet_id.split("_")[1]].get('attacker_fleet', placeholder_fleet)
    else:
        save = get_save_by_uid(enemy_fleet_id.split("_")[2], required=True)
        attacker_fleet = save['user_object']["pvp"]["invaders"]["u" + enemy_fleet_id.split("_")[1]].get('attacker_fleet', placeholder_fleet)

    subtype = lookup_item_by_code(attacker_fleet[0].split(',')[0])["-subtype"]

    fleet = {
        "type": subtype,
        "uid": enemy_fleet_id.split("_")[1],
        "invaded_uid": enemy_fleet_id.split("_")[2] if len(enemy_fleet_id.split("_")) > 2 else None,
        "name": "FleetName",
        "status": 0,
        "target": "",
        "consumables": [],
        "inventory": [],
        "playerLevel": 1,
        "specialBits": None,
        "lost": None,
        "lastUnitLost": None,
        "lastIndexLost": None,
        "allies": None,
        "battleTarget": None,
        "battleTimestamp": None,
        "ransomRandom": None,
        "ransomResource": None,
        "ransomAmount": None,
        "units": attacker_fleet,  # [unit,unit,unit,unit,unit],  # only one unit for tutorial [unit, unit, unit],
        "store": [0],  # [0, 0, 0],
        "fleets": [],
        "upgrades": None,
        "hp": None,
        "invader": True
    }

    register_fleetname_fleet(fleet)

    random_enemy_fleet_challenge_response = {"errorType": 0, "userId": 1, "metadata": {"newPVE": 0},
                                       "data": {
                                           "state": 0,
                                           "challengerFleet": fleet,
                                           "challengeInfo": {"status": 0, "state": 1},
                                           "maxUnits": 5
                                       }}
    return random_enemy_fleet_challenge_response


def load_challenge_response(param):
    load_challenge_response = {"errorType": 0, "userId": 1, "metadata": {"newPVE": 0},
                               "data": {"eFID": "pve", "state": 1}}  # CHALLENGE_STATE_IN_PROGRESS

    session["fleets"][param['challengeeFleet']['name']] = param['challengeeFleet']['units']
    print("Challenge Player fleet:", param['challengeeFleet']['units'])

    return load_challenge_response


def occupation_place_response(params):
    cancel_unstarted_invasions()

    save = get_save_by_uid(params[0], required=True)
    occupied_objects = lookup_objects_save_by_position(save, params[1], params[2], 5)
    # todo defenders from larger area?
    # occupied_objects_double = lookup_objects_save_by_position(save, params[1] - 3, params[2] - 3, 11)
    occupied_items = [lookup_item_by_name(e["itemName"]) for e in occupied_objects]
    defense_units = [e for e in occupied_items if "unit" in e]
    defense_units.sort(key=lambda e: int(e["unit"].get("-strength", "1000")), reverse=True)

    subtype = defense_units[0]["-subtype"] if defense_units else "army"

    defense_units = [e for e in defense_units if e["-subtype"] == subtype]

    defense_units = defense_units[:5]

    defense_fleet = [format_player_fleet(e["-code"]) for e in defense_units][:5]

    if not defense_fleet:
        defense_fleet = [format_player_fleet("PT24"), format_player_fleet("PT23"), format_player_fleet("PT02"), format_player_fleet("PT22"), format_player_fleet("PT12")]
    else:
        defense_fleet = (defense_fleet + [format_player_fleet("U01" if subtype == "army" else ("U43" if subtype == "navy" else "U66"))] * 2)[:5]

    save['user_object']["pvp"]["invaders"]["u" + str(get_zid())] = {
        "ts": datetime.now().timestamp(),
        "pillTS": datetime.now().timestamp(),
        "status": 1,
        "pos":  str(params[1]) + "," + str(params[2]),
        "size": 5,
        "chID": str(get_zid()),
        "defender_fleet": defense_fleet
    }
    store_session(save)

    occupation_place_response = {"errorType": 0, "userId": 1, "metadata": {"newPVE": 0},
                      "data": []}
    return occupation_place_response


def pillage_response(params):
    save = get_save_by_uid(params[0], required=True)
    # occupied_objects = lookup_objects_save_by_position(save, params[1], params[2], 5)
    # occupied_items = [lookup_item_by_name(e["itemName"]) for e in occupied_objects]
    # defense_units = [e for e in occupied_items if "unit" in e]
    # defense_units.sort(key=lambda e: int(e["unit"].get("-strength", "1000")), reverse=True)
    # defense_units = defense_units[:5]

    save['user_object']["pvp"]["invaders"]["u" + str(get_zid())]["pillTS"] = datetime.now().timestamp()
    store_session(save)

    pillage_response = {"errorType": 0, "userId": 1, "metadata": {"newPVE": 0},
                      "data": []}
    return pillage_response



def generic_string_response(param):
    meta = {"newPVE": 0}
    handle_quest_progress(meta, all_lambda(progress_action("genericString"),
                                           progress_parameter_equals("_string", str(param))))

    generic_string_response = {"errorType": 0, "userId": 1, "metadata": meta,
                               "data": []}
    return generic_string_response


def streak_bonus_response(param):
    meta = {"newPVE": 0}

    do_rewards("Streak", {"_type": "coins", "_count": param["amount"]}, meta)

    streak_bonus_response = {"errorType": 0, "userId": 1, "metadata": meta,
                             "data": []}
    return streak_bonus_response


def world_name_response(name):
    world_name_response = {"errorType": 0, "userId": 1, "metadata": {"newPVE": 0},
                           "data": []}
    session['user_object']["userInfo"]["worldName"] = name

    return world_name_response


def update_roads_response(roads):
    session["user_object"]["userInfo"]["world"]["roadData"] = roads
    update_roads_response = {"errorType": 0, "userId": 1, "metadata": {"newPVE": 0},
                             "data": []}
    return update_roads_response


def stream_publish_response(params):
    meta = {"newPVE": 0}
    handle_quest_progress(meta, progress_feed(params[0]))
    stream_publish_response = {"errorType": 0, "userId": 1, "metadata": meta,
                               "data": []}
    return stream_publish_response


def stop_mayhem_response():
    stop_mayhem_response = {"errorType": 0, "userId": 1, "metadata": {"newPVE": 0},
                            "data": []}
    return stop_mayhem_response


def save_options_response(options):
    save_options_response = {"errorType": 0, "userId": 1, "metadata": {"newPVE": 0},
                             "data": []}
    session['user_object']["userInfo"]["player"]["options"] = options
    return save_options_response


def full_screen_response():
    meta = {"newPVE": 0}
    handle_quest_progress(meta, progress_action("fullscreen"))
    full_screen_response = {"errorType": 0, "userId": 1, "metadata": meta,
                            "data": []}
    return full_screen_response


def view_zoom_response(zoom):
    meta = {"newPVE": 0}
    handle_quest_progress(meta, all_lambda(progress_action("zoom"), progress_parameter_equals("_zoom", str(zoom))))
    view_zoom_response = {"errorType": 0, "userId": 1, "metadata": meta,
                          "data": []}
    return view_zoom_response


def load_world_response(params):
    meta = {"newPVE": 0}
    handle_quest_progress(meta, progress_action("visit"))

    print("world response. requested uid=", int(params[0]), session['user_object']["userInfo"]["player"]["uid"])
    if int(params[0]) == session['user_object']["userInfo"]["player"]["uid"]:
        ally = session['user_object']["userInfo"]
        # qc = session['quests']
        print("reloading user from save")
    else:
        ally = copy.deepcopy(init_user()["userInfo"])
        if int(params[0]) == STEELE_ID:
            ally["world"]["sizeX"] = 100
            ally["world"]["sizeY"] = 100
        ally["player"]["uid"] = int(params[0])
        if str(params[0]) in allies:
            if "objects" in allies[str(params[0])]:
                ally["world"]["objects"] = allies[str(params[0])]["objects"]
            if "roads" in allies[str(params[0])]:
                ally["world"]["roadData"] = allies[str(params[0])]["roads"]
            ##Added
            if "expansions" in allies[str(params[0])]:
                ally["expansions"] = allies[str(params[0])]["expansions"]
            if "worldName" in allies[str(params[0])]:
                ally["worldName"] = allies[str(params[0])]["worldName"]
            if "titanName" in allies[str(params[0])]:
                ally["titanName"] = allies[str(params[0])]["titanName"]
        else:
            save = get_save_by_uid(params[0], required=True)
            ally["world"]["objects"] = save['user_object']["userInfo"]["world"]["objects"]
            ally["world"]["roadData"] = save['user_object']["userInfo"]["world"]["roadData"]
            ally["expansions"] = save['user_object']["userInfo"]["player"]["expansions"]
            ally["worldName"] = save['user_object']["userInfo"]["worldName"]
            ally["titanName"] = save['user_object']["userInfo"]["titanName"]
            ally["pvpInvaders"] = save['user_object']["pvp"]["invaders"]

        # ally["gf"] = False
        # ally["yimf"] = ""
        # ally["novisit"] = False
        # ally["globalPVP"] = {}
        # ally["nonFriendInfo"] = {}
        # ally["untendableObjIDs"] = []

        # ally["world"]["yimf"] = ""
    ally["pvpMode"] = params[2]
    ally["pvpImmunity"] = {"expTS": None}
    ally["visitorEnergy"] = 5

    load_world_response = {"errorType": 0, "userId": 1, "metadata": meta,
                           "data": ally}
    return load_world_response


def tend_ally_response(params):
    meta = {"newPVE": 0}
    handle_quest_progress(meta, progress_action("tending"))

    for save in get_saves():
        if save['user_object']["userInfo"]["player"]["uid"] == int(params[0]):
            if not save['user_object']["visitorHelpRequests"]:
                save['user_object']["visitorHelpRequests"] = {}
            if str(get_zid()) in save['user_object']["visitorHelpRequests"]:
                save['user_object']["visitorHelpRequests"][str(get_zid())] += "," + str(params[1])
            else:
                save['user_object']["visitorHelpRequests"][str(get_zid())] = str(params[1])
            store_session(save)
            click_next_state(False, params[1], meta, None, None, tending=True, save=copy.deepcopy(save), tend_type=params[2])

    tend_ally_response = {"errorType": 0, "userId": 1, "metadata": meta,
                          "data": []}
    return tend_ally_response


def accept_tend_ally_response(params):
    meta = {"newPVE": 0}
    for item in session['user_object']["visitorHelpRequests"][params[0]].split(","):
        click_next_state(False, int(item), meta, None, None, playback_tend=True)

    del session['user_object']["visitorHelpRequests"][params[0]]

    accept_tend_ally_response = {"errorType": 0, "userId": 1, "metadata": meta,
                          "data": []}
    return accept_tend_ally_response


def decline_tend_ally_response(params):
    meta = {"newPVE": 0}

    del session['user_object']["visitorHelpRequests"][params[0]]

    decline_tend_ally_response = {"errorType": 0, "userId": 1, "metadata": meta,
                          "data": []}
    return decline_tend_ally_response


def add_fleet_response(param):
    meta = {"newPVE": 0}

    add_fleet_response = {"errorType": 0, "userId": 1, "metadata": meta,
                          "data": []}

    # ensure_fleets, not `session["fleets"][...]`: the client can call addFleet
    # on a session whose registry was never created (a save restored from a
    # paste, or one that has not run the startup call), and this used to raise
    # KeyError there and take the whole gateway request down with it.
    fleets = ensure_fleets()
    fleets[param['name']] = param['units']
    if "allies" in param:
        fleets["ally_" + param['name']] = param['allies']
    print("Player fleet:", param['units'])
    return add_fleet_response

def buy_item_response(param):
    meta = {"newPVE": 0}
    print(param)
    buy_item(meta, param["code"], param["amount"])
    buy_item_response = {"errorType": 0, "userId": 1, "metadata": meta,
                      "data": []}
    return buy_item_response
    #TODO buy powerup in combact


def buy_item(meta, code, amount):
    item = lookup_item_by_code(code)
    player = session['user_object']["userInfo"]["player"]
    world = session['user_object']["userInfo"]["world"]
    resources = world['resources']
    # standard_resources = ["coins", "oil", "wood", "aluminum", "copper", "gold", "iron", "uranium"]
    # resources[standard_resources[int(market["item"])]] += market["units"]
    if item["-type"] == 'mercenary':
        print("Buying mercenary")
    elif item.get("-subtype") == "expansion":
        print("Buying expansion")
    elif "-resourceType" in item and item["-resourceType"] != "energy":
        resources[item["-resourceType"]] += amount * int(item.get("resourceYield", "1"))

        print("Buy: received", item["-resourceType"] + ":", str(amount) +
              "(" + str(resources[item["-resourceType"]]) + ")")
    else:
        # param["useCash"]
        item_inventory = session['user_object']["userInfo"]["player"]["inventory"]["items"]
        item_inventory[code] = item_inventory.get(code, 0) + 1
    player['cash'] -= get_cash_cost(item, amount)
    handle_quest_progress(meta, progress_buy_consumable(item))


def buy_items_response(param):
    print(repr(param))
    meta = {"newPVE": 0}
    resource_Dict = dict(param["itemData"])
    for Res_code in resource_Dict:
        buy_item(meta, Res_code,resource_Dict[Res_code])
    buy_items_response = {"errorType": 0, "userId": 1, "metadata": {"newPVE": 0},
                      "data": []}
    return buy_items_response


def use_item_response(param):
    print(param)
    item_inventory = session['user_object']["userInfo"]["player"]["inventory"]["items"]
    item_inventory[param] -= 1
    use_item_response = {"errorType": 0, "userId": 1, "metadata": {"newPVE": 0},
                      "data": []}

    return use_item_response



# TODO
def purchase_energy_refill_response(param):
    print(repr(param))

    player = session['user_object']["userInfo"]["player"]
    world = session['user_object']["userInfo"]["world"]
    resources = world['resources']

    player['energy'] += int(player['energyMax']-player['energy'])  # TODO put item in inventory (storable?)

    player['cash'] -= int(player['energyMax']-player['energy'])

    purchase_energy_refill_response = {"errorType": 0, "userId": 1, "metadata": {"newPVE": 0},
                      "data": []}
    return purchase_energy_refill_response


def buy_quest_task_response(param):
    print(param,type(param))
    
    # reqq.params[2][0].get('referenceItem')
    # player = session['user_object']["userInfo"]["player"]
    # world = session['user_object']["userInfo"]["world"]

    meta = {"newPVE": 0}
    handle_quest_progress(meta, progress_quest_task(param["name"], param["taskIndex"]))
    buy_quest_task_response = {"errorType": 0, "userId": 1, "metadata": meta, "data": []}
    return buy_quest_task_response


def buy_expansion_response(param):
    print(repr(param))
    unlock_expansion(param['index'])
    meta = {"newPVE": 0}
    handle_quest_progress(meta, progress_action("expansionsPurchased"))
    buy_expansion_response = {"errorType": 0, "userId": 1, "metadata": meta,
                      "data": []}
    return buy_expansion_response


def purchase_contact_unlock(param):
    print(repr(param))
    item = lookup_item_by_code(param["itemCode"])

    #TODO specops contractMultiple
    unlock_cost = int(game_settings['settings']['gamesettings']['-contractUnlockMultiple']) * get_cash_cost(item, 1)

    player = session['user_object']["userInfo"]["player"]
    player['cash'] -= unlock_cost
    item_inventory = session['user_object']["userInfo"]["player"]["inventory"]["items"]
    item_inventory[param["itemCode"]] = item_inventory.get(param["itemCode"], 0) + 1
    player['unlockedContracts'].append(param["itemCode"])

    meta = {"newPVE": 0}
    purchase_contact_unlock = {"errorType": 0, "userId": 1, "metadata": meta,
                              "data": []}
    return purchase_contact_unlock


def get_cash_cost(item, amount):
    #TODO unit price expirements cost
    #TODO priceTestSettings
    #TODO EXPERIMENT_LE_DISCOUNT_SALE
    cash_cost = float(item["cost"]["-cash"])

    required_level = int(item.get("requiredLevel", "0"))
    player_level = session["user_object"]["userInfo"]["player"]["level"]

    le_discount = 0
    if "requiredDate" in item:
        if required_level >= 25:
            if player_level >= 51:
                le_discount = .25
            elif player_level >= 35:
                le_discount = .15
        elif required_level >= 15:
            if player_level >= 51:
                le_discount = .30
            elif player_level >= 35:
                le_discount = .20
            elif player_level >= 20:
                le_discount = .10

    return math.ceil(cash_cost * amount * (1 - le_discount))


def select_response(param):
    meta = {"newPVE": 0}
    handle_quest_progress(meta, all_lambda(progress_action("select"),
                                           progress_parameter_equals("_item", param['itemCode'])))
    select_response = {"errorType": 0, "userId": 1, "metadata": meta,
                          "data": []}
    return select_response


def part_request_response(params):
    item = lookup_item_by_name(params[0])
    item_inventory = session['user_object']["userInfo"]["player"]["inventory"]["items"]

    item_inventory[item["-code"]] = item_inventory.get(item["-code"], 0) + len(params[3])

    meta = {"newPVE": 0}
    handle_quest_progress(meta, progress_gifted_parts(item, len(params[3])))
    handle_quest_progress(meta, progress_inventory_count())

    part_request_response = {"errorType": 0, "userId": 1, "metadata": meta,
                      "data": []}
    return part_request_response

def crew_request_response(params):
    # 'params': [[124], 10003, 'Parliament', 'crew']
    friends = params[0]
    building_id = params[1]
    building_name = params[2]
    action = params[3]
    
    building = lookup_object(building_id)
    
    if action == 'crew':
        
        current_crew = building.get("crewInfo", [])

        crewTemplate = lookup_crew_template(building_name)
        max_buyable_slots = int(crewTemplate["-numUnbuyableSlots"])
        num_slots = len(crewTemplate["position"])

        # Empty slots are automatically filled.
        auto_accept_friends = [f for f in friends if allies[str(f)]["neighbor"]] # only neighbor allies can be added
        avail_slots = max(min(num_slots - len(current_crew), num_slots), 0)
        new_crew = current_crew + auto_accept_friends[:avail_slots]
        building["crewInfo"] = [str(x) for x in new_crew] # string needed, so that no friend is 'deleted' on display
        
        print(building_name, "new crew (max", num_slots, "slots):", building.get("crewInfo", []))
    
    meta = {"newPVE": 0}
    crew_request_response = {"errorType": 0, "userId": 1, "metadata": meta, 'data': []}
    return crew_request_response


def exit_battle_response():
    exit_battle_response = {"errorType": 0, "userId": 1, "metadata": {"newPVE": 0},
                      "data": []}

    #session["last_battle"] = session["battle"]
    session["battle"] = None

    return exit_battle_response


def load_survival_mode_response(param):
    wave_index = session["fleets"]["FleetName"]["playerLevel"] + 1 if is_continued_survival(param) else 1
    if param.get("continueGame") or "playerFleet" in param or (not is_new_wave_survival(param) and is_resume_survival()):
        wave_index = wave_index - 1
    wave = lookup_wave("set3", wave_index)

    if "playerFleet" not in param and not is_new_wave_survival(param) and is_resume_survival():
        unit_codes = decode_unit_count_list(wave['fleet'])
        #baddies = [encode_unit_string(code, hp=hp) for code, hp in zip(unit_codes, session["battle"][1]) if hp > 0]
        baddies = encode_unit_strings(decode_unit_count_list(wave['fleet']))
    else:
        baddies = encode_unit_strings(decode_unit_count_list(wave['fleet']))

    fleet = {
        "type": wave["-unitType"],
        "uid": 1,
        "name": "FleetName",
        "status": 4096, #survival enemy
        "target": "",
        "consumables": [],
        "inventory": [],
        "playerLevel": wave_index,
        "specialBits": None,
        "lost": None,
        "lastUnitLost": None,
        "lastIndexLost": None,
        "allies": None,
        "battleTarget": None,
        "battleTimestamp": None,
        "ransomRandom": None,
        "ransomResource": None,
        "ransomAmount": None,
        "units": baddies,
        "store": [0],  # [0, 0, 0],
        "fleets": [],
        "upgrades": None,
        "hp": None,
        "invader": True
    }

    if "playerFleet" in param:
        load_survival_mode_resp = {"errorType": 0, "userId": 1, "metadata": {"newPVE": 0},
                                   "data": {'state': 1, 'storage': {"curSet": "set3", "curWave": wave_index, "curLoop": 0,
                                                                    "curPlayerFleet": None,
                                                                    "curEnemyFleet": None, "lastPlayedTime": 0,
                                                                    "rewardRefreshCount": 0, "rewards": {},
                                                                    "rewardChanged": False}}}
        session["fleets"][param['playerFleetName']] = param["playerFleet"]["units"]
    elif is_new_wave_survival(param):
        # load_survival_mode_resp = {"errorType": 0, "userId": 1, "metadata": {"newPVE": 0},
        #                            "data": {}}
        load_survival_mode_resp = {"errorType": 0, "userId": 1, "metadata": {"newPVE": 0},
                                   "data": {'state': 3, 'storage': {"curSet": "set3", "curWave": wave_index, "curLoop": 0,
                                                                    "curPlayerFleet": get_survival_player_fleet(),
                                                                    "curEnemyFleet": fleet, "lastPlayedTime": 0,
                                                                    "rewardRefreshCount": 0, "rewards": {},
                                                                    "rewardChanged": False}, "enemyWaveFleet": fleet, "playerFleet":get_survival_player_fleet()}}
        session["battle"] = session["last_battle"]
        session["battle"] = ([e for e in session["battle"][0] if e != 0], None, session["battle"][2], session["battle"][3])
        register_fleetname_fleet(fleet)
    elif is_resume_survival():
        print("resume paused survival")
        # load_survival_mode_resp = {"errorType": 0, "userId": 1, "metadata": {"newPVE": 0},
        #                            "data": {}}
        load_survival_mode_resp = {"errorType": 0, "userId": 1, "metadata": {"newPVE": 0},
                                   "data": {'state': 3,
                                            'storage': {"curSet": "set3", "curWave": wave_index, "curLoop": 0,
                                                        "curPlayerFleet": get_survival_player_fleet(),
                                                        "curEnemyFleet": fleet, "lastPlayedTime": 0,
                                                        "rewardRefreshCount": 0, "rewards": {},
                                                        "rewardChanged": False}, "enemyWaveFleet": fleet,
                                            "playerFleet": get_survival_player_fleet()}}
        #session["battle"] = session["last_battle"]  # paused # current battle is still in battle  WorldService.exitBattle isn't called on pause only genericString with ExitBattle
        # session["battle"] = ([e for e in session["battle"][0] if e != 0], None, session["battle"][2])
        register_fleetname_fleet(fleet)
    else:
        load_survival_mode_resp = {"errorType": 0, "userId": 1, "metadata": {"newPVE": 0},
                                   "data": {'state': 2, 'storage': {"curSet": "set3", "curWave": wave_index, "curLoop": 0,
                                                                    "curPlayerFleet": None,
                                                                    "curEnemyFleet": None, "lastPlayedTime": 0,
                                                                    "rewardRefreshCount": 0, "rewards": {},
                                                                    "rewardChanged": False}, "enemyWaveFleet": fleet}}
        register_fleetname_fleet(fleet)
        session["last_battle"] = None
    return load_survival_mode_resp


def is_continued_survival(param):
    return "FleetName" in session["fleets"] and \
           session["fleets"]["FleetName"]["status"] == 4096 and \
           (param["set"] is None or is_resume_survival())


def is_new_wave_survival(param):
    return param["set"] is None and not param.get("continueGame")


def is_resume_survival():
    return session.get("last_battle") and "FleetName" in session["fleets"] and session["fleets"]["FleetName"][
        "status"] == 4096


# def unit_encode


def dummy_response():
    dummy_response = {"errorType": 0, "userId": 1, "metadata": {"newPVE": 0},
                      "data": []}
    return dummy_response


@app.route("/language_editor")
def language_editor():
    tree = ET.parse("assets/29oct2012/en_US.xml")
    root = tree.getroot()
    for pkg in root:
        print(pkg.tag, pkg.attrib)
        for text in pkg:
            print("  ",text.tag, text.attrib)

    return '', 204



# @app.after_request
# def add_header(r):
#     """
#     Add headers to both force latest IE rendering engine or Chrome Frame,
#     and also to cache the rendered page for 10 minutes.
#     """
#     # r.headers["Cache-Control"] = "no-cache, no-store, must-revalidate"
#     # r.headers["Pragma"] = "no-cache"
#     # r.headers["Expires"] = "0"
#     # r.headers['Cache-Control'] = 'public, max-age=0'
#     return r

@socketio.on('message')
def handle_message(message):
    print('received message: ' + message)


@socketio.on('my event')
def handle_my_custom_event(json):
    print('received json: ' + str(json))


@socketio.on('delete_save')
def delete_save(message):
    # session.permanent = False
    # session.clear() #unsolved flask-session bug

    # print('deleted save: ' + message)
    print("Save will be deleted after redirect " + message)


@app.errorhandler(500)
def server_error_page(error):
    if settings.crash_log:
        text = editor.edit(filename=os.path.join(log_path(), "log.txt"))
    return 'It went wrong'


def enc_hook(obj):
    if isinstance(obj, BattleContext):
        return {
            "__type__": "BattleContext",
            "__v__": 1,
            "map_name": obj.map_name,
            "island": obj.island,
            "replaying": obj.replaying,
        }
    raise TypeError

def decode_objects(obj):
    if isinstance(obj, dict) and (obj.get("__type__") == "BattleContext" or obj.get("type") == "BattleContext"): #something odd going on
        return BattleContext(
            map_name=obj.get("map_name"),
            island=obj.get("island"),
            replaying=obj.get("replaying", False),
        )

    if isinstance(obj, list):
        return [decode_objects(x) for x in obj]

    if isinstance(obj, dict):
        return {k: decode_objects(v) for k, v in obj.items()}

    return obj


# The literal msgspec writes for a tagged BattleContext (see ``enc_hook`` and the
# ``tag=True`` on the struct). Used to skip the walk entirely.
BATTLE_CONTEXT_MARKER = b"BattleContext"

_original_init = MsgSpecSerializer.__init__

def serializer_init_patch(self, app, format):
    _original_init(self, app, format)

    self.encoder = msgspec.msgpack.Encoder(enc_hook=enc_hook)
    original_decode = self.decode

    def decode_wrapper(data):
        decoded = original_decode(data)

        # Only walk the tree when one is actually in there.
        #
        # decode_objects rebuilds every dict and list it visits, so a save with
        # no battle in progress was paying for a full copy of the whole
        # structure to convert zero objects. Profiling showed 932,700 calls to
        # decode_objects across 20 decodes -- about 46,000 per save -- while
        # msgspec itself took under 5% of the time. That walk was the single
        # largest cost in a gateway request.
        #
        # A BattleContext can only exist in the payload if its tag was written
        # into it, so when the marker is absent there is provably nothing to
        # convert and the decode can be returned as msgspec produced it.
        if BATTLE_CONTEXT_MARKER not in data:
            return decoded

        return decode_objects(decoded)

    self.decode = decode_wrapper

MsgSpecSerializer.__init__ = serializer_init_patch


def configure_app():
    """Wire the extensions that only exist at runtime.

    Kept out of ``__main__`` on purpose. A production server does not run this
    module as ``__main__``: granian imports it by name in each worker, so
    anything set up here would silently not run and the gateway would come up
    with no session store and no database. ``wsgi.py`` calls this; so does the
    ``__main__`` block below.

    ``init_app`` refuses to run twice on one app (the SQLAlchemy and session
    objects are module-level singletons), so this is guarded -- see wsgi.py,
    which imports the module and then calls this exactly once.
    """
    set_crash_log(settings.crash_log)
    if settings.compression:
        compress.init_app(app)
    init_socketio(app)
    db.init_app(app)
    sess.init_app(app)
    return app


def open_browser_when_ready():
    """Open the game in the bundled Chromium, or the default browser."""
    if 'WERKZEUG_RUN_MAIN' in os.environ or not settings.open_browser:
        return
    if os.path.exists(os.path.join("chromium", "chrome.exe")):
        launch = os.path.join("chromium", "chrome.exe")
    elif os.path.exists(os.path.join("chromium", "chrome")):
        launch = os.path.join("chromium", "chrome")
    else:
        threading.Timer(1.25, lambda: webbrowser.open(
            "http://" + settings.http_host + ":" + str(settings.port) + "/" + settings.http_path
        )).start()
        return

    threading.Timer(1.25, lambda: os.system(
        launch + " --user-data-dir=\"" + os.path.join(my_games_path(), "chromium-profile")
        + "\" --allow-outdated-plugins "
        + ("--app=" if settings.app_mode else "")
        + "http://" + settings.http_host + ":" + str(settings.port) + "/" + settings.http_path
    )).start()


if __name__ == '__main__':
    open_browser_when_ready()
    configure_app()
    serve(app, debug=settings.debug)
    # app.run(host='127.0.0.1', port=5005, debug=True)
    # logging.getLogger('socketio').setLevel(logging.ERROR)
    # logging.getLogger('engineio').setLevel(logging.ERROR)
    # logging.getLogger('geventwebsocket.handler').setLevel(logging.ERROR)