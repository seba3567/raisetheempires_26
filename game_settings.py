from pathlib import Path
import copy
import json
import os
import random
from datetime import datetime

from flask import has_request_context, request, session

import mod_engine
from crc64_go_iso import zid_from_sid
from save_engine import my_games_path, validate_save

game_settings_path = str(Path(my_games_path()) / "gamesettings-converted.json")
initial_island_path = str(Path(my_games_path()) / "allies" / "initial-island.json")

# Header used by the SvelteKit front door to hand over the signed-in account's
# identity. See get_zid().
PLAYER_ZID_HEADER = "x-player-zid"

# ActionScript 3 has no integer type: every Number is a double, so the client
# represents integers exactly only up to 2^53-1. That bound is why zid divides
# the 64-bit checksum down by 2048 in the first place, so it is also the bound a
# header-supplied zid has to respect.
MAX_SAFE_ZID = 2**53 - 1

def read_games_settings():
    with open(game_settings_path) as f:
        return json.load(f)


def read_initial_island():
    with open(initial_island_path) as f:
        return json.load(f)


game_settings = json.loads(mod_engine.mod.get(game_settings_path)()) if game_settings_path in mod_engine.mod else read_games_settings()
print("Gamesettings loaded: ",  len(game_settings['settings']), " setting sections loaded")

initial_island = json.loads(mod_engine.mod.get(initial_island_path)()) if initial_island_path in mod_engine.mod else read_initial_island()
print("Initial island template", len(initial_island["objects"]), "objects loaded", len(initial_island["roads"]),
      "roads loaded")
# game_objects = [o for o in game_objects_2 if int(o["position"].split(",")[0]) > 62 and int(o["position"].split(",")[1]) > 58]

def read_island_file(file_path):
    with open(file_path) as island_file:
        return json.load(island_file)


allies = {str(e["info"]["uid"] if e["info"] else e["friend"]["uid"]): e for e in
          [read_island_file(os.path.join(root, file_name)) for root, _, file_names in
           os.walk(os.path.join(my_games_path(), "allies")) for
           file_name in
           file_names if 'island.json' in file_name and file_name != "initial-island.json"]}
print("Ally islands")
print("-", len(allies.keys()), "allies loaded")
for key in allies:
    ally = allies[key]
    try:
        wName = ally["worldName"]
    except KeyError as e:
        wName = "<no world Name>"
    print(" * ", key, ":", wName, " --> ", str(len(ally["objects"]) if ally["objects"] else 0), "objects, ", str(len(ally["roads"]) if ally["roads"] else 0), "roads")


def lookup_item_by_name(item_name):
    try:
        [item] = [e for e in game_settings['settings']['items']['item'] if e['-name'] == item_name]
        return item
    except ValueError as e:
        print("ERROR: Could not look up item by name", item_name)
        raise e


def lookup_item_by_code(code):
    try:
        [item] = [e for e in game_settings['settings']['items']['item'] if e['-code'] == code]
        return item
    except ValueError as e:
        print("ERROR: Could not look up item by code", code)
        raise e


def lookup_reference_item(cur_object):
    return lookup_item_by_code(cur_object['referenceItem'].split(":")[0]) if cur_object and 'referenceItem' in cur_object and cur_object['referenceItem'] else None


def lookup_items_with_workers_yield():
    items = [e for e in game_settings['settings']['items']['item'] if 'yield' in e and '-workers' in e['yield']]
    return items


def lookup_items_by_type(type):
    items = [e for e in game_settings['settings']['items']['item'] if e['-type'] == type]
    return items


def lookup_items_by_type_and_subtype(type, subtype):
    items = [e for e in game_settings['settings']['items']['item'] if e['-type'] == type and e.get("-subtype") == subtype]
    return items


def lookup_items_by_unit_class(unit_class):
    items = [e for e in game_settings['settings']['items']['item'] if e.get('-unitClass') == unit_class]
    return items


def lookup_yield():  #TODO buildstate
    yields = {e['-name']: int(e['yield']['-workers']) for e in lookup_items_with_workers_yield()}
    return sum([yields[e['itemName']] for e in session['user_object']["userInfo"]["world"]["objects"] if e['itemName'] in yields])


def lookup_visitor_reward(reward_name):
    [reward] = [reward for reward in game_settings['settings']['visitorRewards']["reward"] if reward["-name"] == reward_name]
    return reward

def randomReward(item_name):
    casino = game_settings["settings"]
    given_item = item_name
    item_list = []
    building_list = []
    weight_list = []
    ammount = []
    rewardstypes =[]
    for building in casino["casino"]["rewards"]:
        building_list.append(building["-item"])

    reward_list = [e for e in casino["casino"]["rewards"] if e['-item'] == given_item]
    reward_list = reward_list[0]["reward"]

    for item in range(len(reward_list)):
        if reward_list[item].get("-type") != "item" and reward_list[item].get("-item") is None:
            item_list.append(reward_list[item].get("-type"))
        if reward_list[item].get("-item") is not None and reward_list[item].get("-type") == "item":
            item_list.append(reward_list[item].get("-item"))
        weight_list.append(reward_list[item].get("-weight"))
        ammount.append(reward_list[item].get("-count"))
        rewardstypes.append(reward_list[item].get("-type"))

    weight_list = [int(i) for i in weight_list]
    ammount = [int(i) for i in ammount]
    print(item_list)
    print(weight_list)
    finelitem = str(random.choices(item_list,weight_list,k=1)[0])
    return finelitem ,ammount[item_list.index(finelitem)], rewardstypes[item_list.index(finelitem)]


# def lookup_built_yield(placed_objects):
#     built_objects = [e for e in objects if
#                      int(e.get('state', 0)) >= (int(state_machine['-builtState']) if state_machine else 0)]
#
#     yields = {e['-name']: int(e['yield']['-workers']) for e in lookup_items_with_workers_yield()}
#     return sum([yields[e['itemName']] for e in session['user_object']["userInfo"]["world"]["objects"] if
#                 e['itemName'] in yields.keys()])

def lookup_state_machine(state_machine_name, custom_values, custom_reference_values=None):
    if custom_reference_values is None:
        custom_reference_values = []
    state_machine = copy.deepcopy(lookup_raw_state_machine(state_machine_name))
    replacements = {e['-name']: e['-value'] for e in custom_values}
    reference_replacements = {e['-name']: e['-value'] for e in simple_list(custom_reference_values)}
    print('replacements', repr(replacements))
    if reference_replacements:
        print('reference item replacements', repr(replacements))
        replacements = {**replacements, **reference_replacements}
        print('combined reference item replacements', repr(replacements))

    repl_dict(state_machine, replacements)
    return state_machine


def lookup_raw_state_machine(state_machine_name):
    try:
        [state_machine] = [e for e in game_settings['settings']['stateMachines']['stateMachine'] if e['-name'] == state_machine_name]
        return state_machine
    except ValueError as e:
        print("ERROR: Could not look up state machine by name", state_machine_name)
        raise e

def lookup_crew_template(building_name):
    item = lookup_item_by_name(building_name)
    crew_template_name = item["-crewTemplate"]
    return next(x for x in game_settings['settings']['crewTemplates']['crewTemplate'] if x['-crew'] == crew_template_name)

def repl_dict(d, replacements):
    for k, v in d.items():
        if isinstance(v, dict):
            repl_dict(v, replacements)
        elif isinstance(v, list):
            for e in v:
                repl_dict(e, replacements)
        else:
            if "$" in v:
                # print('r1', v)
                for s, r in replacements.items():
                    d[k] = d[k].replace(s, r)
                # print('r2', d[k])
                if ":" in v:
                    d[k] = d[k].split(':', 1)[1 if "$" in d[k] else 0]
                    # print('r3', d[k])


def lookup_wave(set_name, wave_index):
    [wave_set] = [e for e in game_settings['settings']['survivalModeSets']['set'] if e.get('-name') == set_name]
    [wave] = [e for e in wave_set["wave"] if e.get('-index') == str(wave_index)]
    return wave


def replenish_energy():
    player = session['user_object']["userInfo"]["player"]
    current_energy_max = max(player["energy"], player["energyMax"])  # overfill possible
    now = datetime.now().timestamp()
    energy_replenished = (now - player["lastEnergyCheck"]) // 300
    player["energy"] = min(player["energy"] + energy_replenished, current_energy_max)
    # print("Energy now:", now, "lastEnergyCheck", player["lastEnergyCheck"], "inc", (now - player["lastEnergyCheck"]), "till300", (now - player["lastEnergyCheck"]) % 300, "newec",  now - (now - player["lastEnergyCheck"]) % 300  )
    player["lastEnergyCheck"] = now - (now - player["lastEnergyCheck"] + 1) % 300
    if energy_replenished != 0:
        print("Energy replenished:", energy_replenished)


def unlock_expansion(index):
    expansions = session['user_object']["userInfo"]["player"]["expansions"]["data"]

    i = index >> 5
    #expansions = expansions + [0 for t in range(i + 1 - len(expansions))]
    e = index - (i << 5)
    expansions[i] = expansions[i] | 1 << e


def simple_list(raw_list):
    return (raw_list if isinstance(raw_list, list) else [raw_list]) if raw_list != '' else []


def supplied_zid():
    """The account id the front door claimed for this request, or None.

    The header half of :func:`get_zid`, with no cookie fallback, because the two
    callers want different things: ``get_zid`` needs *an* id to file a world
    under, while the session store needs to know whether the request is
    *bound to an account at all* before it files anything.

    Same trust rule as ``get_zid``: the header is only as trustworthy as the
    front door in front of it.
    """
    if has_request_context():
        supplied = request.headers.get(PLAYER_ZID_HEADER)
        if supplied is not None:
            try:
                value = int(supplied)
            except ValueError:
                value = None
            if value is not None and 0 < value <= MAX_SAFE_ZID:
                return value
    return None


def get_zid():
    """The id the rest of the game files a player under.

    Two sources, in order:

    1. ``x-player-zid``, set by the SvelteKit service in ``web/`` only when the
       request carries a session it has verified itself. This is what makes a
       login stick in the game: the account owns the save instead of a cookie.
    2. The Flask session cookie, the original behaviour.

    The header is trusted because the gateway is loopback-only and this service
    is its only door -- the same reason the admin gate lives in Bun. **If Flask
    is ever exposed on 0.0.0.0, a client can claim any player id by setting this
    header by hand.**

    Anything malformed, out of range or absent falls back to the cookie, so
    anonymous play and direct requests to the gateway keep working unchanged.

    ``has_request_context()`` is belt and braces: ``session`` is request-bound
    too, so in practice this is only ever reached inside a request. It keeps the
    header dependency explicit rather than assuming it.
    """
    if has_request_context():
        supplied = request.headers.get(PLAYER_ZID_HEADER)
        if supplied is not None:
            try:
                value = int(supplied)
            except ValueError:
                value = None
            if value is not None and 0 < value <= MAX_SAFE_ZID:
                return value
    return zid_from_sid(session.sid)


def get_sessions_friends(saves):
    if saves:
        response = [{
                "zid":  save['user_object']["userInfo"]["player"]["uid"],
                "uid":  save['user_object']["userInfo"]["player"]["uid"],
                "first_name": save['user_object']["userInfo"]["worldName"],
                "name": save['user_object']["userInfo"]["worldName"],
                "sex": "F",
                "portrait": "img/avatars/" + (save['profilePic'] if 'profilePic' in save and save['profilePic'] is not None else "blank.png"),
                "pic": "",
                "pic_square": ""
        } for save in saves if validate_save(save) and save['user_object']["userInfo"]["player"]["level"] >= -6]
        for item in response:
            item["pic"] = item["portrait"]
            item["pic_square"] = item["portrait"]
    else:
        response = []
    return response


def get_sessions_id(saves):
    if saves:
        response = [save['user_object']["userInfo"]["player"]["uid"] for save in saves if validate_save(save) and save['user_object']["userInfo"]["player"]["level"] >= -6]
    else:
        response = []
    return response
