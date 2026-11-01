from __future__ import annotations

import contextlib
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

import copy
import json
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
    cancel_unstarted_invasions,
    decode_unit_count_list,
    encode_unit_strings,
    format_player_fleet,
    get_survival_player_fleet,
    next_campaign_response,
    register_fleetname_fleet,
    spawn_fleet,
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
from game_settings import (
    game_settings,
    get_zid,
    initial_island,
    lookup_crew_template,
    lookup_wave,
    randomReward,
    unlock_expansion,
)
from logger import init_socketio, report_other_log, report_tutorial_step, report_world_log, socketio
from quest_engine import *
from save_engine import (
    InvalidSaveException,
    _crash_editor_allowed,
    base_path,
    db,
    ensure_fleets,
    fetch_all_commanders,
    get_save_by_uid,
    log_path,
    logger,
    lookup_objects_save_by_position,
    my_games_path,
    save_store_url,
    set_crash_log,
    store_session,
    validate_save,
)
from save_migration import is_0_08a_preview, migrate

# save_invaders reads the invasion map out of a save without raising on one that
# never had it. It lives with the other save-shape readers in save_store, which
# imports no Flask, so pulling it from there cannot cycle.
from save_store import save_invaders
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

MIN_ADMIN_ID = -1
STEELE_ID = -1
MAX_ADMIN_ID = 123

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


def _tolerate_call_failure(fn_name, handler, *args):
    """Run one gateway call, keeping its failure from killing the batch.

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

    This guards *one* call. It used to wrap the whole dispatch loop, so the
    first handler that raised abandoned every call after it -- the log line
    claimed the rest were answered, and they were not.
    """
    try:
        return handler(*args)
    except Exception:
        logger.error("Gateway call %s failed", fn_name, exc_info=True)
        return None

def _call_args_summary(params):
    """What the client actually sent, short enough to read in a log line.

    Knowing *which* method a batch called is half the diagnosis; knowing what
    it passed is the other half. Truncated hard, because a world payload can be
    thousands of characters and this line exists to be skimmed.
    """
    if params is None:
        return "-"
    try:
        rendered = json.dumps(params, default=lambda o: "<no serializable>")
    except (TypeError, ValueError):
        rendered = repr(params)
    return rendered if len(rendered) <= 160 else rendered[:157] + "..."

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
    encode them as objects with numeric keys instead (either int or str), which
    pyamf decodes to ``{0: ..., 1: ...}`` or ``{"0": ..., "1": ...}``. The game
    logic expects lists, so accept both shapes and normalize child dicts.

    Normalising must not change the *type* of a child object. pyamf decodes an
    AMF object to ``ASObject``, a dict subclass that also answers attribute
    access; rebuilding it as a plain ``dict`` threw that away, and the game
    code reads these payloads both ways -- ``params[1].id`` and
    ``params[1].get('id')``. Rebuilding as ``ASObject`` keeps both spellings
    working, and it also restores the attribute access the call envelope
    relies on (``reqq.sequence``).
    """
    if isinstance(value, dict):
        keys = list(value.keys())
        if keys and all(
            (isinstance(k, int) and not isinstance(k, bool)) or (isinstance(k, str) and k.isdigit())
            for k in keys
        ):
            sorted_keys = sorted(keys, key=lambda k: int(k))
            return [_amf_as_list(value[k]) for k in sorted_keys]
        return pyamf.ASObject({k: _amf_as_list(v) for k, v in value.items()})
    if isinstance(value, list):
        return [_amf_as_list(item) for item in value]
    return value

def _amf_field(obj, name, default=None):
    """Read one field out of an AMF payload, whatever shape it arrived in.

    The gateway hands the handlers ``ASObject`` children, which answer both
    ``obj["id"]`` and ``obj.id``. A caller that builds its own payload -- a
    test, or a handler that reshapes one -- may well have a plain ``dict``
    instead, and reading it by attribute then raises ``AttributeError``. This
    reads the field either way.
    """
    if isinstance(obj, dict):
        return obj.get(name, default)
    return getattr(obj, name, default)

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
                        "empire_campv2_enabled": 2, "empire_campaign_mastery": 2,
                        "empire_domination_master": 4, "empire_domination_warchest": 2,
                        "empire_globalpvp_master": 2, "empire_globalpvp_strangerbar_enable": 2,
                        "empire_alliances_master": 3, "empire_alliances_phase_4": 3,
                        "empire_alliances_quest_connections": 3, "empire_alliances_quest_power": 3,
                        "empire_leaderboard_summary": 1, "empire_blackmarket_master": 2},
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
        "leaderboardsVariant": 3,
        "survivalModeMaster": 1,
        "survivalModeContinueCost": 1,
        "survivalModeCardAccess": 1,
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
    # The fleet registry survives a re-login.
    #
    # It used to be reset here, and that was the quiet half of a battle bug:
    # the client's troops only ever reach the server through `addFleet`, so
    # wiping the registry left it simulating units it did not have. When the
    # next fight started, `init_battle` found nothing and fell back to the
    # quest's troops -- which the client, already drawing its own, refused to
    # accept ("TResolveBattle: unit strength out of sync"). A login in the
    # middle of a session is normal; losing the troops because of it was not.
    ensure_fleets()
    session['population'] = lookup_yield()

    if "market" not in session:
        session["market"] = {}
    # #temp migration
    # session['user_object']["experiments"]["empire_store_sorting_rev_enhanced"] = 0
    # session['user_object']["experiments"]["empires_shop_improvements"] = 0
    session['user_object']["experiments"]["empire_combataicancritical"] = 2
    # Ensure leaderboards and competition modes are fully unlocked for existing sessions
    session['user_object']["leaderboardsVariant"] = 3
    session['user_object']["survivalModeMaster"] = 1
    session['user_object']["survivalModeContinueCost"] = 1
    session['user_object']["survivalModeCardAccess"] = 1
    exp = session['user_object'].setdefault("experiments", {})
    exp["empire_domination_master"] = 4
    exp["empire_domination_warchest"] = 2
    exp["empire_globalpvp_master"] = 2
    exp["empire_globalpvp_strangerbar_enable"] = 2
    exp["empire_alliances_master"] = 3
    exp["empire_alliances_phase_4"] = 3
    exp["empire_alliances_quest_connections"] = 3
    exp["empire_alliances_quest_power"] = 3
    exp["empire_survivalmode3_master"] = 3
    exp["empire_survivalMode_master"] = 2
    exp["empire_survivalmode_enhancements"] = 2
    exp["empire_leaderboard_summary"] = 1
    exp["empire_blackmarket_master"] = 2
    unlock_expansion(156)
    unlock_expansion(157)
    unlock_expansion(181)
    unlock_expansion(182)
    unlock_expansion(206)
    unlock_expansion(207)

    # Ensure quest gates and resource counters (wood, oil, rare ores) are unlocked and visible
    player_data = session['user_object']["userInfo"]["player"]
    player_data["questGatesComplete"] = True
    default_unlocked_res = {"wood": 1, "oil": 1, "aluminum": 3, "copper": 4, "gold": 5, "iron": 6, "uranium": 7}
    if not player_data.get("unlockedResource"):
        player_data["unlockedResource"] = default_unlocked_res.copy()
    if not session['user_object'].get("unlockedResource"):
        session['user_object']["unlockedResource"] = default_unlocked_res.copy()

    # Ensure player has starting oil if depleted
    world_res = session['user_object']["userInfo"]["world"].setdefault("resources", {})
    if world_res.get("oil", 0) <= 0:
        world_res["oil"] = 50
    if world_res.get("copper", 0) <= 0:
        world_res["copper"] = 250
    if world_res.get("gold", 0) <= 0:
        world_res["gold"] = 250
    if world_res.get("iron", 0) <= 0:
        world_res["iron"] = 250
    if world_res.get("uranium", 0) <= 0:
        world_res["uranium"] = 100
    # battle_status = 0
    # island = 2
    # replay_island = 0
    #
    # status_campaign = battle_status | replay_island << 8 | island << 20
    # status_campaign_2 = battle_status | replay_island << 8 | 5 << 20
    # # #
    # user['userInfo']['world']['campaign'] = {"current": "camp001", "active":{'C000': {"status": status_campaign, "fleets":[]},
    #                                                                        'C003': {"status": status_campaign_2, "fleets":[]}}, "mastery": {}}

    camp = user['userInfo']['world'].setdefault('campaign', {"current": "camp001", "active": {}, "mastery": {}})
    if not camp.get('current'):
        camp['current'] = 'camp001'
    if 'C000' not in camp.setdefault('active', {}):
        camp['active']['C000'] = {"status": 0, "fleets": []}
    completed_quests = user.setdefault('completedQuests', [])
    if 'Q1061' not in completed_quests:
        completed_quests.append('Q1061')

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

    # sleep(0.05)  # Legacy delay no longer needed with PostgreSQL & Granian

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

    invaders = session.get('user_object', {}).get("pvp", {}).get("invaders", {})
    invaders.pop("u" + str(invader_uid), None)
    return accept_friend_repel_response


def reject_friend_repel_response(invader_uid):
    reject_friend_repel_response = {"errorType": 0, "userId": 1, "metadata": {"newPVE": 0},
                        "data": []}

    invaders = session.get('user_object', {}).get("pvp", {}).get("invaders", {})
    invader = invaders.get("u" + str(invader_uid))
    if isinstance(invader, dict):
        invader.pop("dID", None)
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

    merge_quest_progress(meta.get('QuestComponent', []), session['quests'], "session quest")
    session['user_object']["userInfo"]["player"]["tutorialProgress"] = step  # TODO: revert step when loading if needed

    report_tutorial_step(step, meta.get('QuestComponent'), meta['newPVE'], sequence,
                         endpoint)
    tutorial_response = {"errorType": 0, "userId": 1, "metadata": meta,
                         "data": []}
    return tutorial_response


#def perform_world_response(step, supplied_id, position, item_name, reference_item, from_inventory, elapsed, cancel, req2):
def perform_world_response(params):

    step=params[0]
    supplied_id=_amf_field(params[1], 'id')
    position=_amf_field(params[1], 'position')
    item_name=_amf_field(params[1], 'itemName')

    # The third parameter carries the action context. A batch may omit it
    # entirely, so it is read defensively: indexing ``params[2]`` on a
    # two-parameter call raised IndexError and took the whole batch with it.
    context = params[2] if len(params) > 2 else None
    context = context[0] if isinstance(context, list) and len(context) > 0 else None

    reference_item=context.get('referenceItem') if context else None
    from_inventory=context.get('isGift') if context else None
    elapsed=context.get('elapsed') if context else None
    cancel=context.get('cancel') if context else None
    req2=context
    index_ref=context

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
            # 774 of the 3990 catalogue items have no `cost` key at all --
            # "Super Ore Mine" (S01), "SurveillanceTower" (BB10) and the
            # Alien_Spate units among them. An item that costs nothing has an
            # empty cost, not a missing one, and reading the missing key gave
            # `None` and then called `.items()` on it. That raised, ended the
            # gateway batch, and left the client with an empty answer for the
            # placement it had asked for.
            item = lookup_item_by_name(item_name)
            costs = item.get("cost") or {}
            if "-unitClass" in item:
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

    wr: dict[str, Any] = {"errorType": 0, "userId": 1, "metadata": meta,
                           "data": {"id": id}}
    if step == "list":
        market = lookup_object(id)
        # wr["data"].update(session['market'].get(str(id), {}))
        wr["data"] = [market]
        # wr["data"][0]["id"] = id

    if step == "remove":
        market = lookup_object(id)
        wr["data"] = ["success"]  #  TODO fail if bought
        refund_market_order(market)

    if step == "sell":
        objects = session['user_object']["userInfo"]["world"].get("objects", [])
        deleted = False
        if id is not None:
            for i, obj in enumerate(objects):
                if isinstance(obj, dict) and (obj.get('id') == id or str(obj.get('id')) == str(id)):
                    del objects[i]
                    deleted = True
                    break
        if not deleted and position is not None:
            for i, obj in enumerate(objects):
                if isinstance(obj, dict) and obj.get('position') == position:
                    del objects[i]
                    break
        #TODO cost for selling
        # list1 = session['user_object']["userInfo"]["world"]["objects"]
        # session['user_object']["userInfo"]["world"]["objects"] = list(filter(lambda i: i['position'] != position), list1)

    if step == "staffPosition":
        crewTemplate = lookup_crew_template(item_name)
        num_slots = len(crewTemplate["position"])
        decoration = lookup_object(id)

        # Crew index position is given, but not used.
        position_index = index_ref.get('index') if isinstance(index_ref, dict) else None

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
        if not isinstance(wr["data"], dict):
            wr["data"] = {"id": id}
        wr["data"]["data"] = {
            "type": item_type,
            "item": item_code,
            "count": item_amount
        }
        if item_type == "item":
            if item_code not in session['user_object']["userInfo"]["player"]["inventory"]["items"]:
                session['user_object']["userInfo"]["player"]["inventory"]["items"][item_code] = item_amount
            else:
                session['user_object']["userInfo"]["player"]["inventory"]["items"][item_code] += item_amount
        elif item_type == "cash":
            session['user_object']["userInfo"]["player"]["cash"] += item_amount
        else:
            session['user_object']["userInfo"]["world"]['resources']["coins"] += item_amount

    print("perform_world_response", repr(wr))
    return wr


def refund_market_order(market):
    world = session['user_object']["userInfo"]["world"]
    resources = world['resources']
    if market.get("type") == "resource":
        standard_resources = ["coins", "oil" , "wood", "aluminum", "copper", "gold", "iron", "uranium"]
        item_idx = market.get("item")
        if item_idx is not None:
            try:
                item_idx = int(item_idx)
                if 0 <= item_idx < len(standard_resources):
                    res_name = standard_resources[item_idx]
                    units = market.get("units", 0) or 0
                    resources[res_name] = resources.get(res_name, 0) + units
                    print(f"Market: Refunded {res_name}: {units} ({resources[res_name]})")
            except (ValueError, TypeError) as e:
                print(f"Market refund error: {e}")
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

    fleet_str = str(enemy_fleet_id) if enemy_fleet_id is not None else ""
    parts = fleet_str.split("_")
    invader_key = "u" + parts[1] if len(parts) > 1 else "u0"
    challenger_uid = parts[1] if len(parts) > 1 else "0"
    invaded_uid = parts[2] if len(parts) > 2 else None

    if len(parts) <= 2:
        invaders = session.get('user_object', {}).get("pvp", {}).get("invaders", {})
        attacker_fleet = invaders.get(invader_key, {}).get('attacker_fleet', placeholder_fleet)
    else:
        try:
            save = get_save_by_uid(parts[2], required=True)
            invaders = save.get('user_object', {}).get("pvp", {}).get("invaders", {})
            attacker_fleet = invaders.get(invader_key, {}).get('attacker_fleet', placeholder_fleet)
        except Exception:
            attacker_fleet = placeholder_fleet

    subtype = lookup_item_by_code(attacker_fleet[0].split(',')[0])["-subtype"]

    fleet = {
        "type": subtype,
        "uid": challenger_uid,
        "invaded_uid": invaded_uid,
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
    occupied_items = []
    for e in occupied_objects:
        name = e.get("itemName") if isinstance(e, dict) else None
        if not name:
            continue
        with contextlib.suppress(ValueError, KeyError):
            occupied_items.append(lookup_item_by_name(name))
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

    pvp = save.setdefault('user_object', {}).setdefault("pvp", {})
    invaders = pvp.setdefault("invaders", {})
    invaders["u" + str(get_zid())] = {
        "ts": datetime.now().timestamp(),
        "pillTS": datetime.now().timestamp(),
        "status": 1,
        "pos":  str(params[1]) + "," + str(params[2]),
        "size": 5,
        "chID": str(get_zid()),
        "defender_fleet": defense_fleet
    }
    if not store_session(save):
        # This writes the *attacker's* fleet into the *defender's* save, so a
        # refusal here is the sharpest version of the silent loss: the invasion
        # never appears next to the island it is attacking, while the attacker's
        # own screen says it is underway. `store_session` has already logged the
        # row it refused; say which act it was.
        logger.error("invasion of %s was not saved: the defender's save moved under us",
                     params[0])

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

    pvp = save.setdefault('user_object', {}).setdefault("pvp", {})
    invaders = pvp.setdefault("invaders", {})
    invader = invaders.setdefault("u" + str(get_zid()), {})
    invader["pillTS"] = datetime.now().timestamp()
    if not store_session(save):
        # This writes the *attacker's* action into the *defender's* save, so a
        # refusal here is the sharpest version of the silent loss: the pillage
        # never lands and the attacker is told it did. `store_session` has
        # already logged the row it refused; say which act it was.
        logger.error("pillage against %s was not saved: the defender's save moved under us",
                     params[0])

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


def _known_campaigns():
    """The campaign catalogue, as ``{name: entry}``.

    Read from gameSettings rather than hardcoded: the client's campaign list is
    data, and a server that disagrees with it about which campaigns exist is a
    server that eventually hands the client a map it cannot load.
    """
    campaigns = game_settings.get("settings", {}).get("campaigns", {}).get("campaign", [])
    return {entry["-name"]: entry for entry in campaigns if entry.get("-name")}


def set_current_campaign_response(params):
    """The client naming the PvE campaign it is playing.

    Sent once, right after ``initUser``, with the campaign id as its only
    argument -- ``["camp001"]``, read off the wire rather than guessed.

    Until this was implemented the call fell through to ``dummy_response()``:
    ``errorType: 0`` and no data, which the client reads as "fine, nothing to
    do". So the server kept whatever ``campaign.current`` happened to say in the
    save, the client moved on with its own idea of the campaign, and nothing on
    the server ever registered which campaign was actually being played.

    ``init_user`` already seeds ``campaign.current`` with the first campaign, so
    on a fresh account this is a confirmation rather than a change. It earns its
    keep on a save that came from the editor or an old backup, where
    ``current`` is whatever was stored.

    The name is checked against the catalogue instead of trusted: a typo, or a
    hand-edited save, must not be able to write a campaign id that no map lookup
    will ever match. An unknown name is refused the way an unimplemented
    service is -- success, no change -- because the client's own fallback is to
    keep playing the campaign it already had, and silently moving it somewhere
    else would be worse than ignoring it.
    """
    set_current_campaign_response = {"errorType": 0, "userId": 1,
                                     "metadata": {"newPVE": 0}, "data": []}

    requested = params[0] if isinstance(params, (list, tuple)) and params else None
    entry = _known_campaigns().get(requested)
    if entry is None:
        # The client asks for campaigns this server does not know. It is
        # answered by keeping the campaign the player already had, which is
        # the whole point of the branch, so it is expected traffic rather than
        # a warning.
        logger.info("setCurrentCampaign: unknown campaign %r; ignoring", requested)
        return set_current_campaign_response

    campaign = session['user_object']["userInfo"]["world"]["campaign"]
    campaign["current"] = requested

    # Register the opening chapter. `get_active_island_by_map` would create this
    # entry the same way on first read; doing it here means the campaign is
    # already there in the save rather than appearing as a side effect of the
    # next PvE call.
    start = entry.get("-startChapter")
    if start and start not in campaign["active"]:
        campaign["active"][start] = {"status": 0, "fleets": []}

    return set_current_campaign_response


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


def _extract_world_uid(params) -> int:
    if not params:
        return 0
    param = params[0]
    if isinstance(param, dict):
        for k in ("uid", 0, "0", "id"):
            if k in param:
                return _extract_world_uid([param[k]])
        if param:
            return _extract_world_uid([next(iter(param.values()))])
    try:
        return int(param)
    except (TypeError, ValueError):
        return 0


def load_world_response(params):
    meta = {"newPVE": 0}
    handle_quest_progress(meta, progress_action("visit"))

    target_uid = _extract_world_uid(params)
    current_uid = session.get("user_object", {}).get("userInfo", {}).get("player", {}).get("uid")
    print(f"world response. requested uid={target_uid} {current_uid}")
    if current_uid is not None and target_uid == current_uid:
        ally = session["user_object"]["userInfo"]
        print("reloading user from save")
    else:
        ally = copy.deepcopy(init_user()["userInfo"])
        if target_uid == STEELE_ID:
            ally["world"]["sizeX"] = 100
            ally["world"]["sizeY"] = 100
        ally["player"]["uid"] = target_uid
        if str(target_uid) in allies:
            if "objects" in allies[str(target_uid)]:
                ally["world"]["objects"] = allies[str(target_uid)]["objects"]
            if "roads" in allies[str(target_uid)]:
                ally["world"]["roadData"] = allies[str(target_uid)]["roads"]
            if "expansions" in allies[str(target_uid)]:
                ally["expansions"] = allies[str(target_uid)]["expansions"]
            if "worldName" in allies[str(target_uid)]:
                ally["worldName"] = allies[str(target_uid)]["worldName"]
            if "titanName" in allies[str(target_uid)]:
                ally["titanName"] = allies[str(target_uid)]["titanName"]
        else:
            save = get_save_by_uid(target_uid, required=True)
            ally["world"]["objects"] = save["user_object"]["userInfo"]["world"]["objects"]
            ally["world"]["roadData"] = save["user_object"]["userInfo"]["world"]["roadData"]
            ally["expansions"] = save["user_object"]["userInfo"]["player"]["expansions"]
            ally["worldName"] = save["user_object"]["userInfo"]["worldName"]
            ally["titanName"] = save["user_object"]["userInfo"]["titanName"]
            ally["pvpInvaders"] = save_invaders(save)

        # ally["gf"] = False
        # ally["yimf"] = ""
        # ally["novisit"] = False
        # ally["globalPVP"] = {}
        # ally["nonFriendInfo"] = {}
        # ally["untendableObjIDs"] = []

        # ally["world"]["yimf"] = ""
    ally["pvpMode"] = params[2] if len(params) > 2 else False
    ally["pvpImmunity"] = {"expTS": None}
    ally["visitorEnergy"] = 5

    load_world_response = {"errorType": 0, "userId": 1, "metadata": meta,
                           "data": ally}
    return load_world_response


def tend_ally_response(params):
    meta = {"newPVE": 0}
    handle_quest_progress(meta, progress_action("tending"))

    target_uid = int(params[0]) if params else 0
    target_building_id = int(params[1]) if len(params) > 1 else 0
    tend_type = params[2] if len(params) > 2 else None

    target_save = get_save_by_uid(target_uid)
    saves_to_try = [target_save] if target_save else get_saves()

    for save in saves_to_try:
        if not save:
            continue
        user_obj = save.get('user_object', {})
        if user_obj.get("userInfo", {}).get("player", {}).get("uid") == target_uid:
            if "visitorHelpRequests" not in user_obj or not isinstance(user_obj["visitorHelpRequests"], dict):
                user_obj["visitorHelpRequests"] = {}
            zid_str = str(get_zid())
            if zid_str in user_obj["visitorHelpRequests"]:
                user_obj["visitorHelpRequests"][zid_str] += "," + str(target_building_id)
            else:
                user_obj["visitorHelpRequests"][zid_str] = str(target_building_id)
            click_next_state(False, target_building_id, meta, None, None, tending=True, save=save, tend_type=tend_type)
            store_session(save)
            break

    tend_ally_response = {"errorType": 0, "userId": 1, "metadata": meta,
                          "data": []}
    return tend_ally_response


def accept_tend_ally_response(params):
    meta = {"newPVE": 0}
    visitor_reqs = session.get('user_object', {}).setdefault("visitorHelpRequests", {})
    if params and str(params[0]) in visitor_reqs:
        for item in str(visitor_reqs[str(params[0])]).split(","):
            if item.strip():
                click_next_state(False, int(item.strip()), meta, None, None, playback_tend=True)
        visitor_reqs.pop(str(params[0]), None)

    accept_tend_ally_response = {"errorType": 0, "userId": 1, "metadata": meta,
                          "data": []}
    return accept_tend_ally_response


def decline_tend_ally_response(params):
    meta = {"newPVE": 0}
    visitor_reqs = session.get('user_object', {}).get("visitorHelpRequests", {})
    if params and str(params[0]) in visitor_reqs:
        visitor_reqs.pop(str(params[0]), None)

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

def _economy_session():
    """The player's save, or None if there is no session to charge.

    A purchase that arrives before `initUser` has no player to charge, and
    `session['user_object']` raises KeyError when it is not there -- a KeyError
    that took the whole call, and with it the rest of the batch, down. There
    is nothing to buy and nobody to buy it for, so the answer is the same
    empty one an unimplemented service gives.
    """
    save = session.get('user_object')
    if not save:
        # Nothing to charge and nobody to charge it to. The answer is the
        # empty one an unimplemented service gives, so this is expected
        # traffic from a client that bought before it logged in.
        logger.info("Purchase without a session to charge")
        return None
    return save


def buy_item_response(param):
    """`UserService.buyItem` -- comprar un item suelto del mercado."""
    meta = {"newPVE": 0}
    if not isinstance(param, dict) or _economy_session() is None:
        if not isinstance(param, dict):
            logger.info("buyItem without a parameter object: %r", param)
        return {"errorType": 0, "userId": 1, "metadata": meta, "data": []}

    buy_item(meta, param.get("code"), param.get("amount"))
    return {"errorType": 0, "userId": 1, "metadata": meta, "data": []}


def buy_item(meta, code, amount):
    """Compra un item del mercado y lo entrega.

    El precio sale del catalogo (`cost` e `itemcost`), nunca de una cuenta
    hecha aqui: el servidor cobra lo que el juego dice que cuesta, y lo cobra
    en la moneda que el item declara.

    Antes se cobraba siempre `cost["-cash"]`, que hacia tres cosas mal a la
    vez: reventaba con los items que no cuestan cash (una KeyError que se
    llevaba la llamada entera), cobraba cash a items que cuestan coins, y
    cobraba de mas a los que no tienen `cost` (774 de los 3990 items del
    catalogo no lo tienen, y son los que el juego regala).
    """
    item = _catalogue_item(code)
    if item is None:
        return False

    amount = _purchase_amount(amount)
    player = session['user_object']["userInfo"]["player"]
    world = session['user_object']["userInfo"]["world"]
    resources = world['resources']
    inventory = player["inventory"]["items"]

    price = _item_price(item, amount)
    key_costs = _item_key_costs(item, amount)
    if not _can_afford(player, resources, inventory, price, key_costs):
        logger.info("Purchase refused, cannot afford %r x%s (price %s, keys %s)",
                    code, amount, price, key_costs)
        return False

    # Entrega: un item que da un recurso lo da; el resto es un objeto que
    # acaba en el inventario.
    #
    # El `-resourceType` de un item no es siempre un recurso del mundo: los
    # contratos de mina son `rare`, el fuel es `fuel` y la fabrica de powerups
    # es `powerup`. Esos no se pueden sumar a `resources` (KeyError), y un
    # contrato de mina no da 8 de rare al comprarlo: da el contrato.
    resource_type = item.get("-resourceType")
    resource_yield = item.get("resourceYield")
    if resource_type in WORLD_RESOURCES and resource_yield is not None:
        resources[resource_type] += amount * int(resource_yield)
        print("Buy: received", resource_type + ":", str(amount) +
              "(" + str(resources[resource_type]) + ")")
    else:
        inventory[code] = inventory.get(code, 0) + amount

    _charge(player, resources, inventory, price, key_costs)
    handle_quest_progress(meta, progress_buy_consumable(item))
    return True


def buy_items_response(param):
    """`UserService.buyItems` -- comprar varios items de una vez."""
    meta = {"newPVE": 0}
    if not isinstance(param, dict) or _economy_session() is None:
        if not isinstance(param, dict):
            logger.info("buyItems without a parameter object: %r", param)
        return {"errorType": 0, "userId": 1, "metadata": meta, "data": []}

    for code, amount in _purchase_batch(param.get("itemData")):
        buy_item(meta, code, amount)

    return {"errorType": 0, "userId": 1, "metadata": meta, "data": []}


def use_item_response(param):
    """`UserService.useItem` -- gastar un item del inventario.

    Antes: `item_inventory[param] -= 1`, sin mirar si el item existia. Gastar
    un item que el jugador no tiene reventaba con KeyError, y gastar el
    ultimo dejaba el contador en -1: un item que el jugador no tiene pero que
    el cliente cuenta.
    """
    code = param
    if isinstance(param, dict):
        code = param.get("code") or param.get("itemCode") or param.get("item")

    save = _economy_session()
    if save is None:
        return {"errorType": 0, "userId": 1, "metadata": {"newPVE": 0}, "data": []}

    item_inventory = save["userInfo"]["player"]["inventory"]["items"]
    if isinstance(code, str) and item_inventory.get(code, 0) > 0:
        item_inventory[code] -= 1
    else:
        logger.info("Use of an item the player does not have: %r", code)

    return {"errorType": 0, "userId": 1, "metadata": {"newPVE": 0}, "data": []}


def purchase_energy_refill_response(param):
    """`UserService.purchaseEnergyRefill` -- rellenar la energia.

    El coste se calcula con la energia *antes* del refill. Antes se rellenaba
    primero y luego se hacia `energyMax - energy`, con la energia ya llena:
    el coste salia cero y el refill era gratis.

    El precio por punto de energia es el del catalogo: el consumible EN4
    cuesta 5 de cash y da 5 de energia, o sea 1 de cash por punto.
    """
    save = _economy_session()
    if save is None:
        return {"errorType": 0, "userId": 1, "metadata": {"newPVE": 0}, "data": []}

    player = save["userInfo"]["player"]

    energy_max = int(player.get('energyMax', 0))
    energy = int(player.get('energy', 0))
    missing = energy_max - energy

    if missing > 0:
        player['energy'] = energy_max
        player['cash'] = int(player.get('cash', 0)) - missing
    else:
        # Nada que rellenar: no se cobra y no se toca la energia. Un jugador
        # por encima del tope (un item de energia de mas) no pierde lo que
        # tiene por pedir un refill.
        logger.info("Energy refill with nothing to refill: %s/%s", energy, energy_max)

    return {"errorType": 0, "userId": 1, "metadata": {"newPVE": 0}, "data": []}


def buy_quest_task_response(param):
    """`UserService.buyQuestTask` -- comprar un task de quest."""
    meta = {"newPVE": 0}
    save = _economy_session()
    if not isinstance(param, dict) or save is None:
        if not isinstance(param, dict):
            logger.info("buyQuestTask without a parameter object: %r", param)
        return {"errorType": 0, "userId": 1, "metadata": meta, "data": []}

    name = param.get("name")
    task_index = param.get("taskIndex")
    if name is None or task_index is None:
        logger.info("buyQuestTask without a name or a task index: %r", param)
        return {"errorType": 0, "userId": 1, "metadata": meta, "data": []}

    player = save["userInfo"]["player"]
    q = lookup_quest(name)
    if q is not None:
        tasks = get_tasks(q)
        if isinstance(task_index, int) and 0 <= task_index < len(tasks):
            cost_info = tasks[task_index].get('cost')
            if isinstance(cost_info, dict) and '_amount' in cost_info:
                try:
                    amount = int(cost_info['_amount'])
                except (ValueError, TypeError):
                    amount = 0
                if amount > 0:
                    current_cash = int(player.get('cash', 0))
                    if current_cash < amount:
                        logger.info("buyQuestTask refused, cannot afford %r task %s (cost %d, cash %d)", name, task_index, amount, current_cash)
                        return {"errorType": 0, "userId": 1, "metadata": meta, "data": []}
                    player['cash'] = current_cash - amount

    handle_quest_progress(meta, progress_quest_task(name, task_index))
    return {"errorType": 0, "userId": 1, "metadata": meta, "data": []}


def buy_expansion_response(param):
    """`UserService.buyExpansion` -- encender una expansion de la isla.

    Las expansiones se guardan como un mapa de bits: `index >> 5` es la
    palabra y `index & 31` es el bit dentro de esa palabra. El precio lo cobra
    la compra del item de expansion (`x01` y hermanos), no esta llamada: esta
    enciende el bit que el jugador ya pagado.
    """
    meta = {"newPVE": 0}
    if not isinstance(param, dict) or _economy_session() is None:
        if not isinstance(param, dict):
            logger.info("buyExpansion without a parameter object: %r", param)
        return {"errorType": 0, "userId": 1, "metadata": meta, "data": []}

    index = param.get('index')
    if not isinstance(index, int) or isinstance(index, bool) or index < 0:
        logger.info("buyExpansion without a usable index: %r", param)
        return {"errorType": 0, "userId": 1, "metadata": meta, "data": []}

    unlock_expansion(index)
    handle_quest_progress(meta, progress_action("expansionsPurchased"))
    return {"errorType": 0, "userId": 1, "metadata": meta, "data": []}


def purchase_contact_unlock(param):
    """`UserService.purchaseContractUnlock` -- desbloquear un contrato.

    El precio sale del catalogo: el item que se desbloquea mas el multiplicador
    que el propio juego dice (`-contractUnlockMultiple`).
    """
    meta = {"newPVE": 0}
    if not isinstance(param, dict) or _economy_session() is None:
        if not isinstance(param, dict):
            logger.info("purchaseContractUnlock without a parameter object: %r", param)
        return {"errorType": 0, "userId": 1, "metadata": meta, "data": []}

    item_code = param.get("itemCode")
    item = _catalogue_item(item_code)
    if item is None:
        return {"errorType": 0, "userId": 1, "metadata": meta, "data": []}

    # Un unlock abre varios contratos a la vez, y se paga por cada uno.
    multiple = int(game_settings['settings']['gamesettings'].get('-contractUnlockMultiple', 1))
    price = {resource: units * multiple
             for resource, units in _item_price(item, 1).items()}
    key_costs = _item_key_costs(item, 1)

    player = session['user_object']["userInfo"]["player"]
    resources = session['user_object']["userInfo"]["world"]['resources']
    inventory = player["inventory"]["items"]
    if not _can_afford(player, resources, inventory, price, key_costs):
        logger.info("Contract unlock refused, cannot afford %r (price %s)",
                       item_code, price)
        return {"errorType": 0, "userId": 1, "metadata": meta, "data": []}

    _charge(player, resources, inventory, price, key_costs)

    unlocked = player.setdefault("unlockedContracts", [])
    if item_code not in unlocked:
        unlocked.append(item_code)
    inventory[item_code] = inventory.get(item_code, 0) + 1

    return {"errorType": 0, "userId": 1, "metadata": meta, "data": []}


def _catalogue_item(code):
    """El item del catalogo con ese codigo, o None si no existe.

    `lookup_item_by_code` levanta ValueError cuando no encuentra el codigo, y
    un ValueError a mitad de una compra se lleva por delante la llamada
    entera: el cliente se queda sin respuesta y el turno se descuadra.
    """
    if not isinstance(code, str) or not code:
        logger.info("Purchase of an item without a code: %r", code)
        return None
    try:
        return lookup_item_by_code(code)
    except ValueError:
        # The client asks for items this catalogue does not carry. It happens
        # on every load, it is answered by not buying anything, and the player
        # carries on -- so it is not a warning, it is the log telling you the
        # two content sets drifted apart.
        logger.info("Purchase of an item code the catalogue does not know: %r", code)
        return None


def _purchase_amount(amount):
    """La cantidad que pidio el cliente, como un entero positivo."""
    try:
        value = int(amount)
    except (TypeError, ValueError):
        return 1
    return value if value > 0 else 1


def _purchase_batch(item_data):
    """Los pares (codigo, cantidad) de un `buyItems`, sea como llegue.

    El cliente manda esto como un mapa. Se acepta tambien como lista de pares
    y como lista de objetos, porque el juego tiene mas de un sitio desde el
    que se compra y no todas mandan lo mismo.
    """
    if isinstance(item_data, dict):
        return list(item_data.items())
    if isinstance(item_data, list):
        batch = []
        for entry in item_data:
            if isinstance(entry, dict):
                code = entry.get("code") or entry.get("itemCode")
                batch.append((code, entry.get("amount", 1)))
            elif isinstance(entry, (list, tuple)) and len(entry) == 2:
                batch.append((entry[0], entry[1]))
        return batch
    return []


def _level_discount(item):
    """El descuento por nivel que el propio catalogo implica."""
    required_level = int(item.get("requiredLevel", "0"))
    player_level = session["user_object"]["userInfo"]["player"].get("level", 1)

    if "requiredDate" not in item:
        return 0

    if required_level >= 25:
        if player_level >= 51:
            return .25
        if player_level >= 35:
            return .15
    elif required_level >= 15:
        if player_level >= 51:
            return .30
        if player_level >= 35:
            return .20
        if player_level >= 20:
            return .10
    return 0


def _item_price(item, amount):
    """Lo que cuesta un item, por moneda.

    `cost` es un mapa de `-<recurso>` a cantidad: cash es del jugador, el
    resto son recursos del mundo. Un item sin `cost` es gratis, que es
    exactamente lo que dice el catalogo (los regalos de recursos lo tienen
    vacio).
    """
    cost = item.get("cost") or {}
    price = {}
    for key, value in cost.items():
        resource = str(key).lstrip("-")
        try:
            units = float(value)
        except (TypeError, ValueError):
            continue
        price[resource] = price.get(resource, 0.0) + units

    discount = _level_discount(item)
    for resource in list(price):
        units = price[resource] * amount
        if resource == "cash":
            units *= (1 - discount)
        price[resource] = math.ceil(units)
    return price


def _item_key_costs(item, amount):
    """Las llaves que un item exige (`itemcost`), por codigo de item.

    Una expansion cuesta coins *y* llaves de expansion (`xk01`), y las llaves
    se llevan del inventario: son un item mas, y se gastan.
    """
    item_cost = item.get("itemcost") or {}
    keys = {}
    for key, value in item_cost.items():
        code = str(key).lstrip("-")
        try:
            units = int(value)
        except (TypeError, ValueError):
            continue
        keys[code] = units * amount
    return keys


def _can_afford(player, resources, inventory, price, key_costs):
    """Se puede pagar este precio con lo que el jugador tiene."""
    for resource, units in price.items():
        if resource == "cash":
            if player.get("cash", 0) < units:
                return False
        elif resource in WORLD_RESOURCES:
            if resources.get(resource, 0) < units:
                return False
        else:
            # Una moneda que ni el jugador ni el mundo llevan: no se puede
            # pagar, y cobrar de mas no es una opcion.
            return False

    return all(inventory.get(code, 0) >= units for code, units in key_costs.items())


def _charge(player, resources, inventory, price, key_costs):
    """Cobra el precio, que ya se ha comprobado que se puede pagar."""
    for resource, units in price.items():
        if resource == "cash":
            player["cash"] = int(player.get("cash", 0)) - units
        else:
            resources[resource] = resources.get(resource, 0) - units

    for code, units in key_costs.items():
        inventory[code] = inventory.get(code, 0) - units


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
        auto_accept_friends = [f for f in friends if allies.get(str(f), {}).get("neighbor", False)] # only neighbor allies can be added
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