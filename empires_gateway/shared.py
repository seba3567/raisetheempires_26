"""The pieces the Flask surface and the AMF core both need.

They used to live in the middle of ``empires-server.py``, which meant the
AMF protocol and the HTTP surface had to live in the same file for the
helpers to be reachable from both. They are here now so that neither half has
to import the other.

The neighbour list is here for the same reason: ``initUser`` -- the first
thing every new account does -- builds it, and so does the page that shows it.
"""
from __future__ import annotations

from flask import current_app, request, session

import contract
import init_settings as settings
from game_settings import allies, get_sessions_friends, get_sessions_id, get_zid
from save_engine import backup_chain, get_saves, validate_save
from save_store import save_invaders

#: The resources the world keeps in ``world["resources"]``.
#:
#: A catalogue item's ``-resourceType`` is not always one of these: the ore
#: contracts are ``rare``, the minigame fuel is ``fuel`` and the powerup
#: factory is ``powerup``. Those are not resources the world counts, so they
#: cannot be added to it -- an item that carries one is an object the player
#: gets, not a pile of a resource that does not exist.
#:
#: The order comes from the contract; the set is what the code asks about.
#: It used to be spelled out in three modules, which meant a resource added to
#: the contract was only counted by the one that happened to be asked.
WORLD_RESOURCES = frozenset(contract.RESOURCE_ORDER)

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


def format_backup_message(backup):
    """One line describing a snapshot, for the editor's list.

    Takes a ``save_store.BackupRow``. It used to take the snapshot dict itself
    and dig out ``replaced_on`` / ``message`` / ``save_version``, all of which
    lived on the node because the chain was nested inside the save. The reason
    and the timestamp are columns now, so there is nothing to dig out.
    """
    reason = backup.reason or ""
    return f"{backup.created_at} - rev {backup.revision} - {reason}"


def get_avatar_pic():
    avatar_pic = "img/avatars/" + (session['profilePic'] if 'profilePic' in session and session['profilePic'] is not None else "blank.png")
    return avatar_pic

def get_allies_friend(saves):
    return [ally["friend"] for ally in allies.values()
            if "friend" in ally and ally["friend"] and ally["neighbor"]] + get_sessions_friends(saves)


def get_allies_id(saves):
    return [ally["appFriendId"] for ally in allies.values()
            if "appFriendId" in ally and ally["appFriendId"] is not None] + get_sessions_id(saves)


def get_allies_info():
    return [ally["info"] for ally in allies.values() if ally["info"] and ally.get("neighbor")]+ get_sessions_info(
        get_saves())


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
            "pvpNumOccupiers": len([k for k in save_invaders(save) if k != "pve"]),
            "pvpNumOccupiersNotDefended": len([k for k in save_invaders(save) if k != "pve"]),
            "pvpInfo": save_invaders(save).get("u" + str(get_zid())),
            "tending": {
                "actions": 3
            }
        } for save in saves if validate_save(save) and save['user_object']["userInfo"]["player"]["level"] >= -6]
    else:
        response = []
    return response

def player_url():
    """Where the player actually lives, when this request names it directly.

    There is no ``/juego`` here: that route belongs to the SvelteKit front door.
    Everything real arrives through it, which is also what puts the *public*
    host in the Host header -- the reason ``app_url`` can be built server-side
    at all.

    So a request whose Host names this service's own port never came through
    the front door, and redirecting it to ``/juego`` would walk it into a 404 on
    this very server. ``PUBLIC_ORIGIN`` names the front door when it is known; with
    nothing to redirect to, that route says where to go instead of pretending.
    """
    if serving_port() != int(settings.port):
        return None
    configured = (contract.env_value(contract.ENV_PUBLIC_ORIGIN) or "").strip().rstrip("/")
    return configured + "/juego" if configured else None

def dummy_response():
    dummy_response = {"errorType": 0, "userId": 1, "metadata": {"newPVE": 0},
                      "data": []}
    return dummy_response


def serving_port():
    """The port this request's Host header names, or ``None`` if it names none.

    Flask's ``Request`` has ``host`` and ``host_url`` but no ``host_port``, and
    the port rides along inside ``host`` as a string -- ``"localhost:8080"``,
    or ``"[::1]:5005"`` when the host is an IPv6 literal, which is why this
    splits on the last colon rather than the first.
    """
    host = request.host or ""
    if ":" not in host:
        return None
    try:
        return int(host.rsplit(":", 1)[1])
    except ValueError:
        return None


def get_suggested_friends():
    return [ally["friend"] for ally in allies.values()
            if "friend" in ally and ally["friend"] and not ally["neighbor"]]


#: Who the neighbours are.
#:
#: The game has one real enemy and a couple of empty slots that the world
#: fills with whatever it has. These are their ids.
MIN_ADMIN_ID = -1

STEELE_ID = -1

MAX_ADMIN_ID = 123


rand_seed_w = 5445  # very random


rand_seed_z = 844


version = "0.08a.2026_08_13"
