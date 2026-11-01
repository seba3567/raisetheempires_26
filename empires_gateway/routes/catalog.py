"""What the client and the front door read over HTTP.

The catalogue the game loads during its setup, the player's own state, the
neighbour list, and the old 2013 pages that are still answered with a
redirect.
"""
from __future__ import annotations

import logging
import random
import time

from flask import Blueprint, jsonify, make_response, redirect, request, session

import contract
import init_settings as settings
from empires_gateway.assets import send_from_directory_mod
from empires_gateway.shared import (
    get_allies_friend,
    get_allies_id,
    get_avatar_pic,
    player_url,
    serving_port,
)
from game_settings import allies, get_zid
from save_engine import (
    get_save_by_uid,
    get_saves,
    store_session,
    validate_save,
)

logger = logging.getLogger(__name__)

bp = Blueprint("catalog", __name__)


@bp.route("/")
@bp.route("/game")
@bp.route("/play")
def index():
    player = player_url()
    if player:
        return make_response(redirect(player))

    if serving_port() == int(settings.port):
        return make_response(WHERE_THE_GAME_IS, 200)

    # Came through the front door, so /juego exists -- on the other service.
    return make_response(redirect("/juego"))


#: Shown only when the gateway is opened directly instead of through the web
#: front door. Short on purpose: this is a wrong-port landing page, not docs.
WHERE_THE_GAME_IS = """<!doctype html>
<meta charset="utf-8">
<title>Raise the Empires — gateway</title>
<style>
  body { background:#11151c; color:#d8dee9; font:16px/1.6 system-ui,sans-serif;
         margin:0; display:grid; place-items:center; min-height:100vh; }
  main { max-width:34rem; padding:2rem; }
  h1 { font-size:1.4rem; margin:0 0 .5rem; color:#e6b104; }
  code { background:#1b212c; padding:.15rem .4rem; border-radius:.25rem; }
  p { margin:.6rem 0; }
  ul { color:#8b98a9; }
</style>
<main>
  <h1>Esto es el gateway, no el juego</h1>
  <p>El juego lo sirve la web, no este servicio. Esta redirección daba a
     <code>/juego</code>, que aquí no existe: por eso salía un 404.</p>
  <p>Abre la web en el puerto que tengas configurado
     (<code>http://localhost:8080</code> en desarrollo), o pon
     <code>PUBLIC_ORIGIN</code> en el entorno para que esta página te mande allí
     sola.</p>
  <ul>
    <li>El cliente necesita <code>localhost</code>, no <code>127.0.0.1</code>:
        el servicio web escucha en IPv6.</li>
    <li>Este puerto es interno. En producción hay un proxy delante y
        <code>/juego</code> sí existe ahí.</li>
  </ul>
</main>
"""


@bp.route("/home.html")
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

@bp.route("/ruffle.html")
def ruffle():
    """The 2013 launcher URL, kept so old links still land on the game.

    It no longer renders anything: `/juego` (web/src/routes/juego) is the only
    player, and it was the one under test. The template that used to be served
    here -- with its own copy of the FlashVars and a CDN-pinned Ruffle -- is
    gone, which is also why `/ruffle.html?raw=1` now redirects here as well.
    """
    return make_response(redirect('/juego'))

@bp.route("/snapi.json")
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
#
# The order lives in the runtime contract, which is where the front door reads
# it from too: two copies of the list used to be expected to line up.
RESOURCE_ORDER = contract.RESOURCE_ORDER

#: The resources the world keeps in `world["resources"]`.
#:
#: A catalogue item's ``-resourceType`` is not always one of these: the ore
#: contracts are ``rare``, the minigame fuel is ``fuel`` and the powerup
#: factory is ``powerup``. Those are not resources the world counts, so they
#: cannot be added to it -- an item that carries one is an object the player
#: gets, not a pile of a resource that does not exist.
WORLD_RESOURCES = frozenset(RESOURCE_ORDER)

@bp.route("/player.json")
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


@bp.route("/api/gift/claim", methods=['POST'])
def api_gift_claim():
    """Reclama un regalo y añade el recurso/ítem al imperio del jugador."""
    data = request.get_json(silent=True) or request.form.to_dict()
    gift_type = data.get("giftType", "energy")
    gift_id = data.get("giftId")

    zid = get_zid()
    user_obj = session.get("user_object")
    save = None

    if not user_obj:
        save = get_save_by_uid(zid)
        if save and "user_object" in save:
            user_obj = save["user_object"]
            session["user_object"] = user_obj

    if not user_obj:
        return jsonify({"success": False, "error": "No user session"}), 400

    player = user_obj.get("userInfo", {}).get("player", {})
    resources = user_obj.get("userInfo", {}).get("world", {}).get("resources", {})
    inv = player.setdefault("inventory", {}).setdefault("items", {})

    if gift_type == "energy":
        player["energy"] = int(player.get("energy", 0)) + 1
    elif gift_type == "coins":
        resources["coins"] = int(resources.get("coins", 0)) + 2500
    elif gift_type == "oil":
        resources["oil"] = int(resources.get("oil", 0)) + 1000
    elif gift_type == "wood":
        resources["wood"] = int(resources.get("wood", 0)) + 1000
    elif gift_type == "blueprint":
        inv["B01"] = int(inv.get("B01", 0)) + 1

    inbox = user_obj.get("activeGiftRequests", [])
    if isinstance(inbox, list) and gift_id:
        user_obj["activeGiftRequests"] = [g for g in inbox if str(g.get("id")) != str(gift_id)]

    # The `gifts` row is not marked here: that table belongs to the web front
    # door, which is what claimed it under a row lock and checked that the
    # gift really belonged to the player. Marking it a second time from here
    # was a second writer on a table with a single owner, and it marked rows
    # the player was not even entitled to claim.

    session.modified = True
    session['saved'] = False

    if save:
        store_session(save)

    return jsonify({
        "success": True,
        "giftType": gift_type,
        "energy": player.get("energy"),
        "coins": resources.get("coins"),
    })


@bp.route("/api/pvp/reward", methods=['POST'])
def api_pvp_reward():
    """Deposita XP y monedas obtenidas en combate PvP dentro de la partida viva del jugador."""
    data = request.get_json(silent=True) or request.form.to_dict()
    try:
        xp = int(data.get("xp", 0))
    except (TypeError, ValueError):
        xp = 0
    try:
        coins = int(data.get("coins", 0))
    except (TypeError, ValueError):
        coins = 0

    zid = get_zid()
    user_obj = session.get("user_object")
    save = None

    if not user_obj:
        save = get_save_by_uid(zid)
        if save and "user_object" in save:
            user_obj = save["user_object"]
            session["user_object"] = user_obj

    if not user_obj:
        return jsonify({"success": False, "error": "No user session"}), 400

    player = user_obj.setdefault("userInfo", {}).setdefault("player", {})
    resources = user_obj.setdefault("userInfo", {}).setdefault("world", {}).setdefault("resources", {})

    if xp > 0:
        player["xp"] = int(player.get("xp", 0)) + xp
    if coins > 0:
        resources["coins"] = int(resources.get("coins", 0)) + coins

    session.modified = True
    session['saved'] = False

    if save:
        store_session(save)

    return jsonify({
        "success": True,
        "xp": player.get("xp"),
        "coins": resources.get("coins"),
        "level": player.get("level"),
    })


@bp.route("/api/gift/send", methods=['POST'])
def api_gift_send():
    """Deposita un paquete de regalo en la partida del destinatario.

    **La tabla ``gifts`` es de la puerta web, no de este gateway.** La web
    valida el tipo, aplica el límite diario y escribe la fila; este endpoint
    solo tiene que dejar el regalo en la bandeja *dentro del juego*.

    Antes esta función insertaba también en ``gifts``, y como la web ya lo
    hacía, cada regalo enviado desde la interfaz dejaba **dos filas**: la
    bandeja del destinatario mostraba el regalo duplicado, la fila huérfana
    quedaba reclamable y el gateway acreditaba los recursos una segunda vez
    (un regalo, doble premio), y el límite diario de 10 se agotaba a los 5
    regalos de verdad.
    """
    data = request.get_json(silent=True) or request.form.to_dict()
    target_zid = data.get("targetZid")
    sender_zid = data.get("senderZid") or get_zid()
    sender_name = data.get("senderName") or session.get("user_object", {}).get("userInfo", {}).get("worldName", "Comandante")
    gift_type = data.get("giftType", "energy")

    if not target_zid:
        return jsonify({"success": False, "error": "Missing targetZid"}), 400

    try:
        target_save = get_save_by_uid(int(target_zid))
        if target_save and "user_object" in target_save:
            inbox = target_save["user_object"].setdefault("activeGiftRequests", [])
            inbox.append({
                "id": f"gift_{sender_zid}_{int(time.time())}_{random.randint(100, 999)}",
                "sender": int(sender_zid),
                "senderName": sender_name,
                "item": gift_type,
                "type": "gift",
                "timestamp": int(time.time()),
            })
            store_session(target_save)
    except Exception as e:
        logger.warning("api_gift_send error: %s", e)

    return jsonify({"success": True})


def get_suggested_friends():
    return [ally["friend"] for ally in allies.values()
            if "friend" in ally and ally["friend"] and not ally["neighbor"]]


@bp.route("/nodebug.html")
def no_debug():
    """NPAPI Flash container is obsolete; redirect to modern player."""
    return make_response(redirect('/juego'))

@bp.route("/friends.html")
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
    # return avatar_file_names in os.walk(os.path.join(my_games_path() ,"web/static/img/avatars"))
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
    # return avatar_file_names in os.walk(os.path.join(my_games_path() ,"web/static/img/motds"))
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

@bp.route("/new.html")
def new_player_page():
    return make_response(redirect('/juego'))

@bp.route("/avatar.json")
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


@bp.route("/chooseavatar/<path:path>", methods=['GET', 'POST'])
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




@bp.route("/motd.json")
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

@bp.route("/changelog.txt")
def change_log():
    return send_from_directory_mod("web/static", "changelog.txt", mimetype="text/plain")

#: How long the browser may reuse an archived game asset without asking again.
#:
#: These files are named after what they are (``Island3_Tileset_ENV.swf``), not
#: after a hash of their contents, so a year-long immutable cache would survive
#: an edit to the archive and players would keep seeing the old art. A week is
#: the compromise: it removes the revalidation in every normal session, and the
#: worst case if the archive changes is that the change takes a week to reach
#: players who already loaded one of those files.
#:
#: What it buys is not small. The game asks for the same assets on every visit,
#: and with Werkzeug's default of ``no-cache`` the browser stored them but still
#: had to revalidate each one: 1133 of 1328 asset requests in ``log.txt`` were
#: 304s that carried no body and existed only to be told nothing had changed.
#: Each one still cost a full hop through the proxy and back to the disk.
ASSET_MAX_AGE = 60 * 60 * 24 * 7
