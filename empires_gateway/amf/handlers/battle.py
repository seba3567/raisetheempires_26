"""The fights.

What the player does to somebody else: the challenges, the invasions, the
occupation of a neighbour's island, the pillage, the survival mode. The
client asks for these by name and the answers are the shape it expects --
which is why the shape is the hard part, and the reason the wire rules live
in their own module.
"""
from __future__ import annotations

import contextlib
import logging
from datetime import datetime

from flask import session

from battle_engine import (
    cancel_unstarted_invasions,
    decode_unit_count_list,
    encode_unit_strings,
    format_player_fleet,
    get_survival_player_fleet,
    register_fleetname_fleet,
)
from game_settings import get_zid, lookup_item_by_code, lookup_item_by_name, lookup_wave
from save_engine import get_save_by_uid, lookup_objects_save_by_position, store_session

logger = logging.getLogger(__name__)


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
