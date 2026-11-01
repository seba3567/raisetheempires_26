"""The rankings and the matchmaking.

Where the leaderboards come from, who you can be matched against, and the
targeting the client needs to aim at one of them.
"""
from __future__ import annotations

import logging

from fastapi_session import session

from empires_gateway.amf.handlers.economy import (
    _economy_session,
)
from game_settings import (
    allies,
)
from save_engine import (
    fetch_all_commanders,
)

logger = logging.getLogger(__name__)


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


def targeting_data_response(param=None):
    return {"errorType": 0, "userId": 1, "metadata": {"newPVE": 0}, "data": {}}


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


def matchmaking_opt_flag_response(param):
    """`UserService.matchMakingOptFlag` -- toggle matchmaking participation."""
    if isinstance(param, dict) and _economy_session():
        player = session['user_object']["userInfo"]["player"]
        opt_flag = param.get("optOut") or param.get("flag") or param.get("value")
        player["matchmakingOptOut"] = opt_flag
    return {"errorType": 0, "userId": 1, "metadata": {"newPVE": 0}, "data": []}

