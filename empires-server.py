from __future__ import annotations

import os
import webbrowser

import msgspec
from flask_session.base import MsgSpecSerializer

os.environ["PBR_VERSION"] = '5.4.3'
import init_settings as settings
from single_instance import SingleInstance

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
    me = SingleInstance(flavor_id=str(settings.port))

if os.name == 'nt':
    os.system('color')

import random
import threading  #, webbrowaser
import time
import xml.etree.ElementTree as ET
from builtins import print
from collections.abc import Callable
from datetime import timedelta

# Named explicitly rather than inherited through a star import: the asset routes
# build paths with it, and a `from quest_engine import *` that happens to
# re-export Path is not something to rely on when that import list changes.
from pathlib import Path
from typing import Any

import pyamf
import pyamf.amf0
from flask import (
    Flask,
    Response,
    g,
    jsonify,
    make_response,
    request,
)
from pyamf import remoting

import admin_gate
import contract
from account_saves import AccountBoundSession
from battle_engine import (
    BattleContext,
    StaleBattleReference,
    assign_consumable_response,
    battle_complete_response,
    next_campaign_response,
    spawn_fleet,
)
from empires_gateway.amf.handlers.battle import (
    accept_friend_repel_response,
    add_fleet_response,
    cancel_unstarted_challenge_response,
    exit_battle_response,
    load_challenge_response,
    load_survival_mode_response,
    neighbor_repel_challenge_response,
    occupation_place_response,
    pillage_response,
    random_enemy_fleet_challenge_response,
    random_fleet_challenge_response,
    reject_friend_repel_response,
)
from empires_gateway.amf.handlers.economy import (
    _economy_session,
    buy_expansion_response,
    buy_item_response,
    buy_items_response,
    buy_quest_task_response,
    purchase_contact_unlock,
    purchase_energy_refill_response,
    use_item_response,
)
from empires_gateway.amf.handlers.player import (
    full_screen_response,
    generic_string_response,
    save_options_response,
    seen_flag_response,
    streak_bonus_response,
    tutorial_response,
    user_response,
    view_zoom_response,
)
from empires_gateway.amf.handlers.social import (
    accept_tend_ally_response,
    decline_tend_ally_response,
    friend_info_response,
    friend_response,
    invader_response,
    neighbor_invader_response,
    neighbor_suggestion_response,
    part_request_response,
    recent_response,
    stream_publish_response,
    tend_ally_response,
    zlingshot_response,
)
from empires_gateway.amf.handlers.world import (
    crew_request_response,
    load_world_response,
    perform_world_response,
    set_current_campaign_response,
    stop_mayhem_response,
    update_roads_response,
    world_name_response,
)
from empires_gateway.amf.protocol import (
    _amf_as_list,
    _amf_detach,
    _amf_field,
    _call_args_summary,
    _pad_batch_results,
    _tolerate_call_failure,
)

# The HTTP surface moved into the package. These are re-exported because the
# tests and the operator tools still reach for them through this module.
from empires_gateway.routes.catalog import (
    get_avail_avatars,  # noqa: F401
    get_avail_motds,
)
from empires_gateway.shared import (  # noqa: F401  (re-exported for the tools)
    dummy_response,
    get_allies_info,
    get_sessions_info,
)

#: The resources the world keeps in `world["resources"]`.
#:
#: A catalogue item's ``-resourceType`` is not always one of these: the ore
#: contracts are ``rare``, the minigame fuel is ``fuel`` and the powerup
#: factory is ``powerup``. Those are not resources the world counts, so they
#: cannot be added to it -- an item that carries one is an object the player
#: gets, not a pile of a resource that does not exist.
WORLD_RESOURCES = frozenset(contract.RESOURCE_ORDER)
from logger import init_socketio, report_other_log, report_world_log, socketio
from quest_engine import *
from save_engine import (
    InvalidSaveException,
    _crash_editor_allowed,
    base_path,
    db,
    fetch_all_commanders,
    log_path,
    logger,
    my_games_path,
    save_store_url,
    set_crash_log,
)

# save_invaders reads the invasion map out of a save without raising on one that
# never had it. It lives with the other save-shape readers in save_store, which
# imports no Flask, so pulling it from there cannot cycle.
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
# Both keys get the same URL, and both point at PostgreSQL 18. The sessions table
# belongs to flask-session and is never written to -- SaveStoreSessionInterface
# overrides every read and write -- but Flask-SQLAlchemy still needs a valid URI
# to attach to. Pointing it at PostgreSQL rather than a save.db on disk means there
# is no second store left on the machine that can quietly disagree with the real
# one, which is exactly what a 10 MB save.db nobody remembered was.
app.config['SAVE_STORE_PATH'] = save_store_url()
app.config['SQLALCHEMY_DATABASE_URI'] = save_store_url()


@app.before_request
def mark_request_start():
    """Flask's Request has no start time, so one is taken here."""
    g.rte_started = time.perf_counter()


@app.after_request
def log_request(response):
    """One line per request, the way Werkzeug used to do it by itself.

    Werkzeug only logs requests while *it* is the server: ``log_request`` is
    called by its own WSGI request handler, so the moment the gateway moved to
    Granian or Waitress -- both of which serve the WSGI app directly -- every
    access line stopped. Nothing was lost from the application log; what was
    lost was the traffic. ``log.txt`` went quiet at the last request of the old
    Werkzeug run and then just sat there holding that day's errors, which reads
    exactly like a server that is still crashing and has been for twenty hours.

    Application errors were never affected -- they go through ``logger.error``
    and still land in the file. This restores the other half.
    """
    elapsed = (time.perf_counter() - g.get("rte_started", time.perf_counter())) * 1000
    logger.info("%s %s -> %s in %.1fms",
                request.method, request.full_path.rstrip("?"),
                response.status_code, elapsed)
    return response
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False # Flask-SQLAlchemy has its own event notification system that gets layered on top of SQLAlchemy. To do this, it tracks modifications to the SQLAlchemy session. This option disables the modification tracking system.
app.config['SESSION_SQLALCHEMY'] = db
app.config['SESSION_COOKIE_HTTPONLY'] = False
#app.config['SESSION_SERIALIZATION_FORMAT '] = 'json' # flask-session uses msgspec by default now which makes it undepickleable
app.config['MAX_FORM_MEMORY_SIZE'] = 5 * 1024 * 1024  # 5 MB
# MAX_FORM_MEMORY_SIZE only bounds the parts of a *form* body that Flask parses
# into memory. The AMF0 gateway posts `application/x-amf`, which is not a form
# content type, so that limit never applied to it: the proxy's own limit was the
# only one, and the two were set in different files with different values.
# MAX_CONTENT_LENGTH bounds the body as it arrives, whatever its type, so the
# gateway's limit is the one that holds.
# The HTTP surface lives in the package now.
from empires_gateway import assets as _asset_routes
from empires_gateway.routes import catalog as _catalog_routes
from empires_gateway.routes import editor as _editor_routes
from empires_gateway.routes import tools as _tools_routes

app.register_blueprint(_catalog_routes.bp)
app.register_blueprint(_editor_routes.bp)
app.register_blueprint(_tools_routes.bp)
app.register_blueprint(_asset_routes.bp)

app.config['MAX_CONTENT_LENGTH'] = 5 * 1024 * 1024  # 5 MB
app.permanent_session_lifetime = timedelta(weeks=520)


@app.before_request
def admin_tools_need_an_admin():
    """The second lock on the admin tools.

    The front door gates these paths too (see ``web/src/lib/access.ts``), but
    that gate lives in another runtime, and the gateway used to have no lock of
    its own at all: ``/list_session`` handed over every player's session id,
    ``DELETE /save`` deleted any empire, and ``/patch/...`` granted any
    resource to whoever asked.

    The list of paths is written down once, in ``contract/runtime.json``, and
    both runtimes read it. This side is the one that matters: the lock on the
    data, rather than only on the door.
    """
    if not admin_gate.is_admin_tool(request.path):
        return None
    if admin_gate.caller_is_admin():
        return None
    return jsonify({"success": False, "error": "Admin only"}), 403

# MIN_ADMIN_ID = -1
# STEELE_ID = -1
# MAX_ADMIN_ID = 123

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

    # The envelope decoded, but it may still not be the shape the client meant:
    # no bodies at all, or a body that is not the three-part batch. Both raise
    # here, and an uncaught raise is a 500 -- which Ruffle reads as an
    # unreachable gateway and retries the same broken batch forever. Only the
    # parse of untrusted input is guarded, so a failure in it is the client's.
    try:
        batch_body = resp_msg.bodies[0][1].body
        calls = _amf_as_list(batch_body[1])
    except Exception as error:
        print("Rejecting malformed AMF batch:", type(error).__name__, error)
        return make_response("Bad AMF batch", 400)
    resps = []
    for reqq in calls:
        # The client matches responses to requests by index, so every call gets
        # exactly one answer, in its own slot. A call that produced no result
        # -- because it raised, or because the handler returned None -- used to
        # shift every later answer one slot to the left, and the client read
        # the next call's payload as this call's answer.
        if not isinstance(reqq, dict):
            print("Skipping non-object entry in AMF batch:", repr(reqq))
            resps.append(dummy_response())
            continue
        if reqq.get('params') is not None:
            reqq['params'] = _amf_as_list(reqq['params'])
        fn_name = getattr(reqq, 'functionName', None) or reqq.get('functionName')
        handler = AMF_HANDLERS.get(fn_name)
        called_at = time.perf_counter()
        if handler is not None:
            resp = _tolerate_call_failure(
                fn_name, handler, reqq.get('params'), reqq, resp_msg)
        else:
            resp = dummy_response()
        resps.append(resp if resp is not None else dummy_response())
        # Which method the client actually asked for, and what it cost.
        #
        # The access log only ever showed `POST /flashservices/gateway.php`,
        # so a batch that hung or answered the wrong shape was invisible: the
        # log could not tell you what the client was waiting on. When the
        # tab stops talking to the server entirely, the last line here is
        # the call it was processing.
        logger.info("  AMF %-46s %s (%.1fms)  args=%s",
                    (fn_name or "<sin nombre>")[:46],
                    "atendido" if handler is not None else "SIN IMPLEMENTAR",
                    (time.perf_counter() - called_at) * 1000,
                    _call_args_summary(reqq.get('params')))

        if fn_name != 'UserService.tutorialProgress' and fn_name != 'WorldService.performAction':
            report_other_log(fn_name, resps[-1], reqq, resp_msg.bodies[0][0])

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




# Q0516 ? start


























#def perform_world_response(step, supplied_id, position, item_name, reference_item, from_inventory, elapsed, cancel, req2):






















































def select_response(param):
    meta = {"newPVE": 0}
    handle_quest_progress(meta, all_lambda(progress_action("select"),
                                           progress_parameter_equals("_item", param['itemCode'])))
    select_response = {"errorType": 0, "userId": 1, "metadata": meta,
                          "data": []}
    return select_response















# def unit_encode


# ----------------------------------------------------------------------
# AMF Gateway Declarative Dispatch Table
# ----------------------------------------------------------------------

def _handle_init_user(params, reqq, msg):
    try:
        return user_response()
    except InvalidSaveException as error:
        print('Handling InvalidSaveException error:', error)
        # A corrupt save used to answer with None, and a handler that returns
        # None produced no result at all -- which shifted every later answer
        # in the batch one slot to the left. The client then read the next
        # call's payload as its login response.
        return dummy_response()


def _handle_tutorial_progress(params, reqq, msg):
    if not params:
        return dummy_response()
    return tutorial_response(params[0], reqq.get('sequence', 0), msg.bodies[0][0])


def _handle_perform_action(params, reqq, msg):
    if not params or len(params) < 2:
        return dummy_response()
    raw_id = _amf_field(params[1], 'id', None)
    try:
        item_id: Any = int(raw_id) if raw_id is not None else None
    except (ValueError, TypeError):
        item_id = raw_id
    item_pos = _amf_field(params[1], 'position', '?')

    try:
        wr = perform_world_response(params)
    except Exception as error:
        logger.exception("Error in perform_world_response for id=%s pos=%s: %s", item_id, item_pos, error)
        wr = {"errorType": 0, "userId": 1, "metadata": {"newPVE": 0}, "data": {"id": item_id}}

    if isinstance(wr, dict) and isinstance(wr.get("data"), dict) and wr["data"].get("id") is None and item_id is not None:
        wr["data"]["id"] = item_id

    report_world_log(
        str(params[0]) + " id " + str(item_id) + "@" + str(item_pos),
        wr.get("data", []), params, reqq.get("sequence", 0), msg.bodies[0][0],
        wr.get("metadata", {}).get("QuestComponent"), wr.get("metadata", {}).get("newPVE")
    )
    return wr
def _handle_resolve_battle(params, reqq, msg):
    if not params:
        return dummy_response()
    try:
        return battle_complete_response(params[0])
    except (StaleBattleReference, IndexError, KeyError, TypeError, ValueError) as error:
        # A stale or out-of-range battle reference is the client asking about
        # a battle this server has already moved past. It is caught on purpose
        # and answered with the dummy result, so it is expected traffic.
        logger.info('Ignoring stale or out-of-range resolveBattle request: %s', error)
        return dummy_response()


def _handle_assign_consumable(params, reqq, msg):
    if not params:
        return dummy_response()
    try:
        return assign_consumable_response(params[0])
    except (StaleBattleReference, IndexError, KeyError, TypeError, ValueError, Exception) as error:
        logger.info('Ignoring stale or invalid assignConsumable request: %s', error)
        return dummy_response()


def open_dialog_response(param=None):
    return {"errorType": 0, "userId": 1, "metadata": {"newPVE": 0}, "data": []}


def calculate_ransom_response(param=None):
    return {"errorType": 0, "userId": 1, "metadata": {"newPVE": 0}, "data": {"ransom": 100, "resource": "coins"}}


def feed_response(param=None):
    return {"errorType": 0, "userId": 1, "metadata": {"newPVE": 0}, "data": []}


def targeting_data_response(param=None):
    return {"errorType": 0, "userId": 1, "metadata": {"newPVE": 0}, "data": {}}


def leaderboards_response(param=None):
    """Genera las tablas de clasificacion esperadas por UserService.getLeaderboards conectadas a PostgreSQL."""
    user_obj = session.get('user_object', {})
    player = user_obj.get('userInfo', {}).get('player') if isinstance(user_obj, dict) else None
    if not isinstance(player, dict):
        player = {}
    my_uid = player.get('uid', 1)
    my_level = player.get('level', 1)
    my_xp = player.get('xp', 0)

    my_campaign_score = my_xp * 10 + my_level * 50
    my_pvp_score = my_level * 100 + 500
    my_domination_score = max(100, my_level * 25)

    commanders = fetch_all_commanders()

    # 1. Campaign Leaderboard
    campaign_entries = [
        {"uid": my_uid, "value": my_campaign_score, "level": my_level, "name": player.get("name") or "Commander"}
    ]
    seen_campaign = {str(my_uid)}
    for c in commanders:
        uid_str = str(c["uid"])
        if uid_str not in seen_campaign:
            seen_campaign.add(uid_str)
            score = c["xp"] * 10 + c["level"] * 50
            campaign_entries.append({
                "uid": c["uid"],
                "value": score,
                "level": c["level"],
                "name": c["name"]
            })

    bots = [
        {"uid": 111, "value": 2500, "level": 15, "name": "AcidCaos Empire"},
        {"uid": 123, "value": 1800, "level": 12, "name": "Natalie's Fleet"},
        {"uid": -1, "value": 1200, "level": 20, "name": "Steele's Armada"},
        {"uid": 131, "value": 800, "level": 8, "name": "The Devs"},
    ]
    for b in bots:
        if str(b["uid"]) not in seen_campaign:
            campaign_entries.append(b)

    campaign_entries.sort(key=lambda x: x["value"], reverse=True)
    for idx, entry in enumerate(campaign_entries, start=1):
        entry["rank"] = idx

    # 2. PvP Leaderboard
    pvp_entries = [
        {"uid": my_uid, "value": my_pvp_score, "level": my_level, "name": player.get("name") or "Commander"}
    ]
    seen_pvp = {str(my_uid)}
    for c in commanders:
        uid_str = str(c["uid"])
        if uid_str not in seen_pvp:
            seen_pvp.add(uid_str)
            score = c["level"] * 120 + 400
            pvp_entries.append({
                "uid": c["uid"],
                "value": score,
                "level": c["level"],
                "name": c["name"]
            })
    pvp_bots = [
        {"uid": -1, "value": 3000, "level": 25, "name": "Steele's Armada"},
        {"uid": 111, "value": 2200, "level": 15, "name": "AcidCaos Empire"},
        {"uid": 123, "value": 1400, "level": 12, "name": "Natalie's Fleet"},
    ]
    for b in pvp_bots:
        if str(b["uid"]) not in seen_pvp:
            pvp_entries.append(b)

    pvp_entries.sort(key=lambda x: x["value"], reverse=True)
    for idx, entry in enumerate(pvp_entries, start=1):
        entry["rank"] = idx

    # 3. Domination Leaderboard
    domination_entries = [
        {"uid": my_uid, "value": my_domination_score, "level": my_level, "name": player.get("name") or "Commander"}
    ]
    seen_dom = {str(my_uid)}
    for c in commanders:
        uid_str = str(c["uid"])
        if uid_str not in seen_dom:
            seen_dom.add(uid_str)
            score = max(100, c["level"] * 25)
            domination_entries.append({
                "uid": c["uid"],
                "value": score,
                "level": c["level"],
                "name": c["name"]
            })
    dom_bots = [
        {"uid": 111, "value": 350, "level": 15, "name": "AcidCaos Empire"},
        {"uid": -1, "value": 280, "level": 20, "name": "Steele's Armada"},
        {"uid": 123, "value": 150, "level": 12, "name": "Natalie's Fleet"},
    ]
    for b in dom_bots:
        if str(b["uid"]) not in seen_dom:
            domination_entries.append(b)

    domination_entries.sort(key=lambda x: x["value"], reverse=True)
    for idx, entry in enumerate(domination_entries, start=1):
        entry["rank"] = idx

    data = {
        "campaign": campaign_entries,
        "Week52": campaign_entries,
        "pvp": pvp_entries,
        "domination": domination_entries,
    }
    return {"errorType": 0, "userId": 1, "metadata": {"newPVE": 0}, "data": data}


def collect_leaderboard_response(param=None):
    """UserService.collectLeaderboards -- cobra recompensa del leaderboard."""
    player = session.get('user_object', {}).get('userInfo', {}).get('player')
    world = session.get('user_object', {}).get('userInfo', {}).get('world')
    if player and world:
        resources = world.setdefault('resources', {})
        resources['coins'] = int(resources.get('coins', 0)) + 2500
        player['xp'] = int(player.get('xp', 0)) + 200
        session['saved'] = str(session.get('saved', "")) + "collect_leaderboard"

    return {
        "errorType": 0,
        "userId": 1,
        "metadata": {"newPVE": 0},
        "data": {
            "status": 1,
            "rewards": [
                {"type": "coins", "count": 2500},
                {"type": "xp", "count": 200},
            ]
        }
    }


def targeting_groups_response(param=None):
    return {"errorType": 0, "userId": 1, "metadata": {"newPVE": 0}, "data": []}


def matchmaking_users_response():
    """`DataServicesService.getMatchmakingUsersData` -- candidatos para matchmaking desde PostgreSQL y aliados."""
    commanders = fetch_all_commanders()
    seen = set()
    candidates = []
    for c in commanders:
        uid = c["uid"]
        seen.add(str(uid))
        candidates.append({
            "uid": uid,
            "zid": uid,
            "name": c["name"],
            "first_name": c["first_name"],
            "pic": c.get("pic", "assets/game/GeneralAssetGroup_UI.swf/TheVille_50.png"),
            "picture_url": c.get("pic", "assets/game/GeneralAssetGroup_UI.swf/TheVille_50.png"),
            "pic_square": c.get("pic", "assets/game/GeneralAssetGroup_UI.swf/TheVille_50.png"),
            "country": "ES",
            "level": c["level"],
            "engagement_7day": 1,
        })

    for ally in allies.values():
        friend = ally.get("friend")
        info = ally.get("info")
        if friend or info:
            uid = ally.get("appFriendId") or (friend.get("uid") if friend else 100)
            if str(uid) not in seen:
                seen.add(str(uid))
                candidates.append({
                    "uid": uid,
                    "zid": uid,
                    "name": friend.get("first_name", "Commander") if friend else "Commander",
                    "first_name": friend.get("first_name", "Commander") if friend else "Commander",
                    "pic": friend.get("pic_square", "assets/game/GeneralAssetGroup_UI.swf/TheVille_50.png") if friend else "assets/game/GeneralAssetGroup_UI.swf/TheVille_50.png",
                    "picture_url": friend.get("pic_square", "assets/game/GeneralAssetGroup_UI.swf/TheVille_50.png") if friend else "assets/game/GeneralAssetGroup_UI.swf/TheVille_50.png",
                    "pic_square": friend.get("pic_square", "assets/game/GeneralAssetGroup_UI.swf/TheVille_50.png") if friend else "assets/game/GeneralAssetGroup_UI.swf/TheVille_50.png",
                    "country": "US",
                    "level": info.get("level", 10) if info else 10,
                    "engagement_7day": 1,
                })
    return {"errorType": 0, "userId": 1, "metadata": {"newPVE": 0}, "data": candidates}


def clear_incentive_response(param):
    """`UserService.clearIncentive` -- marcar un incentivo/promo como limpio."""
    meta = {"newPVE": 0}
    if isinstance(param, dict) and _economy_session():
        player = session['user_object']["userInfo"]["player"]
        inc_id = param.get("incentiveId") or param.get("id") or param.get("name")
        if inc_id:
            cleared = player.setdefault("clearedIncentives", [])
            if inc_id not in cleared:
                cleared.append(inc_id)
    return {"errorType": 0, "userId": 1, "metadata": meta, "data": []}


def do_seen_quest_notification_response(param):
    """`UserService.doSeenQuestNotification` -- marcar notificacion de quest como vista."""
    meta = {"newPVE": 0}
    if isinstance(param, dict) and _economy_session():
        player = session['user_object']["userInfo"]["player"]
        quest_name = param.get("quest") or param.get("name")
        task_id = param.get("task", 0)
        if quest_name:
            seen_flags = player.setdefault("seenFlags", {})
            seen_flags[f"quest_seen_{quest_name}_{task_id}"] = 1
    return {"errorType": 0, "userId": 1, "metadata": meta, "data": []}


def motd_action_response(param):
    """`UserService.motdAction` -- registrar acciones del MOTD."""
    meta = {"newPVE": 0}
    if isinstance(param, dict) and _economy_session():
        player = session['user_object']["userInfo"]["player"]
        motd_id = param.get("motdId") or param.get("id") or param.get("name")
        action = param.get("action", "viewed")
        if motd_id:
            if action == "accepted":
                accepted = player.setdefault("motdsAccepted", [])
                if motd_id not in accepted:
                    accepted.append(motd_id)
            else:
                viewed = player.setdefault("motdsViewed", [])
                if motd_id not in viewed:
                    viewed.append(motd_id)
    return {"errorType": 0, "userId": 1, "metadata": meta, "data": []}


def unit_unlock_response(param):
    """`UserService.unitUnlock` -- desbloquear una unidad anticipadamente."""
    meta = {"newPVE": 0}
    if not isinstance(param, dict) or _economy_session() is None:
        return {"errorType": 0, "userId": 1, "metadata": meta, "data": []}

    player = session['user_object']["userInfo"]["player"]
    code = param.get("unitCode") or param.get("itemCode") or param.get("code") or param.get("unit")
    if code:
        unlocked = player.setdefault("unlockedUnits", [])
        if code not in unlocked:
            unlocked.append(code)
        logger.info("Unit unlocked: %s", code)
    return {"errorType": 0, "userId": 1, "metadata": meta, "data": []}


def unit_drop_reveal_all_response(param):
    """`UserService.unitDropRevealAll` -- revelar todas las unidades misteriosas."""
    meta = {"newPVE": 0}
    if _economy_session() is None:
        return {"errorType": 0, "userId": 1, "metadata": meta, "data": []}

    world = session['user_object']["userInfo"]["world"]
    player = session['user_object']["userInfo"]["player"]
    inventory = player.setdefault("inventory", {}).setdefault("items", {})
    drop_data = world.setdefault("unitDropData", {})
    unclaimed = drop_data.get("unclaimedUnits", [])
    for unit_code in unclaimed:
        inventory[unit_code] = inventory.get(unit_code, 0) + 1
    drop_data["unclaimedUnits"] = []
    return {"errorType": 0, "userId": 1, "metadata": meta, "data": []}


def unit_drop_switch_unit_response(param):
    """`UserService.unitDropSwitchUnit` -- cambiar/rerollear unidad del mystery drop."""
    meta = {"newPVE": 0}
    return {"errorType": 0, "userId": 1, "metadata": meta, "data": []}


def upgrade_state_response(param):
    """`UserService.upgradeState` -- avanzar de estado al completar crew/upgrade."""
    meta = {"newPVE": 0}
    if not isinstance(param, dict):
        if isinstance(param, (int, str)):
            obj_id = int(param)
        else:
            return {"errorType": 0, "userId": 1, "metadata": meta, "data": []}
    else:
        obj_id = param.get("id") or param.get("objectId")

    if obj_id is not None:
        try:
            click_next_state(True, int(obj_id), meta, "upgradeState", None)
        except ValueError as e:
            # The object is not in the catalogue, so there is nothing to
            # upgrade. That is what the client asks for when the two content
            # sets have drifted apart, and it is answered by not upgrading.
            logger.info("Error in upgrade_state_response: %s", e)
        except Exception as e:
            logger.warning("Error in upgrade_state_response: %s", e)
    return {"errorType": 0, "userId": 1, "metadata": meta, "data": []}


def matchmaking_opt_flag_response(param):
    """`UserService.matchMakingOptFlag` -- toggle matchmaking participation."""
    if isinstance(param, dict) and _economy_session():
        player = session['user_object']["userInfo"]["player"]
        opt_flag = param.get("optOut") or param.get("flag") or param.get("value")
        player["matchmakingOptOut"] = opt_flag
    return {"errorType": 0, "userId": 1, "metadata": {"newPVE": 0}, "data": []}


AMF_HANDLERS: dict[str, Callable[[Any, Any, Any], Any]] = {
    # Custom / multi-step handlers
    'UserService.initUser': _handle_init_user,
    'UserService.tutorialProgress': _handle_tutorial_progress,
    'WorldService.performAction': _handle_perform_action,
    'WorldService.resolveBattle': _handle_resolve_battle,
    'WorldService.assignConsumable': _handle_assign_consumable,

    # No-arg handlers
    'DataServicesService.getRequestFriends': lambda *_: friend_response(),
    'PVPService.getUsersInvaderChallenges': lambda *_: invader_response(),
    'ZlingshotService.presence': lambda *_: zlingshot_response(),
    'DataServicesService.getRecentPlayers': lambda *_: recent_response(),
    'DataServicesService.getFriendsInfo': lambda *_: friend_info_response(),
    'DataServicesService.getSuggestedNeighbors': lambda *_: neighbor_suggestion_response(),
    'DataServicesService.getRecommendedNeighbors': lambda *_: neighbor_suggestion_response(),
    'DataServicesService.getMatchmakingUsersData': lambda *_: matchmaking_users_response(),
    'WorldService.stopMayhemEvent': lambda *_: stop_mayhem_response(),
    'WorldService.fullScreen': lambda *_: full_screen_response(),
    'PVPService.cancelUnstartedChallenge': lambda *_: cancel_unstarted_challenge_response(),
    'WorldService.exitBattle': lambda *_: exit_battle_response(),
    'FeedService.getFeed': lambda *_: feed_response(),
    'UserService.getTargetingData': lambda *_: targeting_data_response(),
    'UserService.getTargetingGroups': lambda *_: targeting_groups_response(),
    'UserService.getLeaderboards': lambda *_: leaderboards_response(),
    'UserService.collectLeaderboards': lambda *_: collect_leaderboard_response(),
    'WorldService.sendZaspReport': lambda *_: dummy_response(),

    # Full params handlers
    'UserService.streamPublish': lambda p, *_: stream_publish_response(p),
    'WorldService.loadWorld': lambda p, *_: load_world_response(p),
    'VisitorService.help': lambda p, *_: tend_ally_response(p),
    'RequestService.partRequest': lambda p, *_: part_request_response(p),
    'PVPService.occupationPlace': lambda p, *_: occupation_place_response(p),
    'PVPService.pillage': lambda p, *_: pillage_response(p),
    'RequestService.crewRequest': lambda p, *_: crew_request_response(p),
    'PVPService.retrieveNeighborRepelChallenge': lambda p, *_: neighbor_repel_challenge_response(p),
    'VisitorService.accept': lambda p, *_: accept_tend_ally_response(p),
    'VisitorService.decline': lambda p, *_: decline_tend_ally_response(p),

    # Single-param (params[0]) handlers
    'UserService.setSeenFlag': lambda p, *_: seen_flag_response(p[0] if p else {}),
    'PVPService.createRandomFleetChallenge': lambda p, *_: random_fleet_challenge_response(p[0] if p else {}),
    'WorldService.spawnFleet': lambda p, *_: spawn_fleet(p[0] if p else {}),
    'PVPService.loadChallenge': lambda p, *_: load_challenge_response(p[0] if p else {}),
    'WorldService.genericString': lambda p, *_: generic_string_response(p[0] if p else {}),
    'UserService.streakBonus': lambda p, *_: streak_bonus_response(p[0] if p else {}),
    'UserService.setWorldName': lambda p, *_: world_name_response(p[0] if p else {}),
    'WorldService.updateRoads': lambda p, *_: update_roads_response(p[0] if p else {}),
    'UserService.saveOptions': lambda p, *_: save_options_response(p[0] if p else {}),
    'UserService.setCurrentCampaign': lambda p, *_: set_current_campaign_response(p or []),
    'WorldService.viewZoom': lambda p, *_: view_zoom_response(p[0].get('zoom') if p and isinstance(p[0], dict) else 1.0),
    'WorldService.beginNextCampaign': lambda p, *_: next_campaign_response(p[0] if p else {}),
    'WorldService.addFleet': lambda p, *_: add_fleet_response(p[0] if p else {}),
    'PVPService.acceptFriendRepel': lambda p, *_: accept_friend_repel_response(p[0] if p else {}),
    'UserService.buyExpansion': lambda p, *_: buy_expansion_response(p[0] if p else {}),
    'UserService.buyItem': lambda p, *_: buy_item_response(p[0] if p else {}),
    'UserService.buyItems': lambda p, *_: buy_items_response(p[0] if p else {}),
    'UserService.useItem': lambda p, *_: use_item_response(p[0] if p else {}),
    'UserService.buyQuestTask': lambda p, *_: buy_quest_task_response(p[0] if p else {}),
    'PVPService.getNeighborVisitChallenges': lambda p, *_: neighbor_invader_response(p[0] if p else {}),
    'PVPService.loadEnemyFleetForChallenge': lambda p, *_: random_enemy_fleet_challenge_response(p[0] if p else {}),
    'SurvivalModeService.loadSurvivalMode': lambda p, *_: load_survival_mode_response(p[0] if p else {}),
    'UserService.purchaseContractUnlock': lambda p, *_: purchase_contact_unlock(p[0] if p else {}),
    'UserService.purchaseEnergyRefill': lambda p, *_: purchase_energy_refill_response(p[0] if p else {}),
    'PVPService.rejectFriendRepel': lambda p, *_: reject_friend_repel_response(p[0] if p else {}),
    'WorldService.moveRoad': lambda p, *_: update_roads_response(p[0] if p else {}),
    'WorldService.sellRoad': lambda p, *_: update_roads_response(p[0] if p else {}),
    'WorldService.select': lambda p, *_: select_response(p[0] if p else {}),
    'WorldService.openDialog': lambda p, *_: open_dialog_response(p[0] if p else None),
    'WorldService.calculateRansom': lambda p, *_: calculate_ransom_response(p[0] if p else None),
    'UserService.clearIncentive': lambda p, *_: clear_incentive_response(p[0] if p else {}),
    'UserService.doSeenQuestNotification': lambda p, *_: do_seen_quest_notification_response(p[0] if p else {}),
    'UserService.motdAction': lambda p, *_: motd_action_response(p[0] if p else {}),
    'UserService.unitUnlock': lambda p, *_: unit_unlock_response(p[0] if p else {}),
    'UserService.unitDropRevealAll': lambda p, *_: unit_drop_reveal_all_response(p[0] if p else {}),
    'UserService.unitDropSwitchUnit': lambda p, *_: unit_drop_switch_unit_response(p[0] if p else {}),
    'UserService.upgradeState': lambda p, *_: upgrade_state_response(p[0] if p else {}),
    'UserService.matchMakingOptFlag': lambda p, *_: matchmaking_opt_flag_response(p[0] if p else {}),
}


from service_handlers import EXTENDED_AMF_HANDLERS

AMF_HANDLERS.update(EXTENDED_AMF_HANDLERS)



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
def on_delete_save_socket(message):
    print("Save will be deleted after redirect " + message)


@app.errorhandler(500)
def server_error_page(error):
    """The last resort: something escaped that nothing else handled.

    Two things were wrong here and both of them hid failures rather than
    causing them.

    **It opened a text editor.** This is the 2012 desktop build's crash flow,
    inherited verbatim: `settings.crash_log` came from a command-line flag
    meant for a windowed app, so on the server every unhandled exception popped
    a Notepad on whoever's machine happened to be running it. Ninety-eight of
    them, in one session, from a single typo in this file.

    **It answered 200.** Returning a bare string from an error handler is a 200
    with `text/plain`, and thirteen characters of it. A client parsing AMF got
    `Unexpected token 'I'` and a browser got the word "wrong" on a blank page,
    neither of which says "the gateway failed". The status has to be the truth.

    The traceback goes to the log, which is the part that can actually be read
    after the fact.
    """
    logger.error("Unhandled server error", exc_info=getattr(error, "original_exc_info", None))

    if settings.crash_log and _crash_editor_allowed():
        log_file = str(Path(log_path()) / "log.txt")
        try:
            import subprocess
            subprocess.Popen(["notepad", log_file] if os.name == "nt" else ["xdg-open", log_file])
        except Exception as e:
            logger.error("Could not launch log editor: %s", e)

    # 500, not 200: the front end reads this as "the gateway is unreachable"
    # and stops, rather than trying to parse an apology as game data.
    return make_response("Internal Server Error", 500)


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
    bundled = Path("chromium") / "chrome.exe"
    posix_bundled = Path("chromium") / "chrome"
    if bundled.exists():
        launch = str(bundled)
    elif posix_bundled.exists():
        launch = str(posix_bundled)
    else:
        threading.Timer(1.25, lambda: webbrowser.open(
            "http://" + settings.http_host + ":" + str(settings.port) + "/" + settings.http_path
        )).start()
        return

    threading.Timer(1.25, lambda: os.system(
        launch + " --user-data-dir=\"" + str(Path(my_games_path()) / "chromium-profile")
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