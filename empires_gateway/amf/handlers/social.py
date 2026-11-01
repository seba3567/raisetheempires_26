"""The people.

The friends list, the neighbours who are invading you, the ones you have just
seen, the ones the game suggests, the allies you tend, and the parts somebody
gifts you. It is the one domain the front door also has a word in: the social
tables are the front door's, and the gateway reads and writes them.
"""
from __future__ import annotations

import logging

from flask import session

from empires_gateway.amf.handlers.battle import invader_entry
from empires_gateway.shared import get_suggested_friends
from game_settings import (
    allies,
    get_zid,
    lookup_item_by_name,
)
from quest_engine import (
    handle_quest_progress,
    progress_action,
    progress_feed,
    progress_gifted_parts,
    progress_inventory_count,
)
from save_engine import get_save_by_uid, get_saves, store_session
from state_machine import click_next_state

logger = logging.getLogger(__name__)


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


def neighbor_suggestion_response():
    neighbor_suggestion_response = {"errorType": 0, "userId": 1, "metadata": {"newPVE": 0},
                                    "data": get_suggested_friends()}
    return neighbor_suggestion_response


def stream_publish_response(params):
    meta = {"newPVE": 0}
    handle_quest_progress(meta, progress_feed(params[0]))
    stream_publish_response = {"errorType": 0, "userId": 1, "metadata": meta,
                               "data": []}
    return stream_publish_response


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
