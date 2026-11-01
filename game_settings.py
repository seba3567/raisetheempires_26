from __future__ import annotations

import copy
import json
import random
from datetime import datetime
from pathlib import Path
from typing import Any

from fastapi_session import has_request_context, request, session

import contract
import mod_engine
from crc64_go_iso import zid_from_sid
from save_engine import my_games_path, validate_save

game_settings_path = str(Path(my_games_path()) / "gamesettings-converted.json")
initial_island_path = str(Path(my_games_path()) / "allies" / "initial-island.json")

# Header used by the SvelteKit front door to hand over the signed-in account's
# identity. See get_zid(). The name lives in contract/runtime.json because the
# front door sets it and this side reads it: two spellings would mean the
# account's id never arrives, and the game falls back to filing the player
# under a hash of its own cookie.
PLAYER_ZID_HEADER = contract.PLAYER_ZID_HEADER

# ActionScript 3 has no integer type: every Number is a double, so the client
# represents integers exactly only up to 2^53-1. That bound is why zid divides
# the 64-bit checksum down by 2048 in the first place, so it is also the bound a
# header-supplied zid has to respect.
MAX_SAFE_ZID = contract.MAX_SAFE_ZID

def read_games_settings() -> dict[str, Any]:
    return json.loads(Path(game_settings_path).read_text(encoding="utf-8"))


def read_initial_island() -> dict[str, Any]:
    return json.loads(Path(initial_island_path).read_text(encoding="utf-8"))


game_settings = json.loads(mod_engine.mod.get(game_settings_path)()) if game_settings_path in mod_engine.mod else read_games_settings()
print("Gamesettings loaded: ",  len(game_settings['settings']), " setting sections loaded")

initial_island = json.loads(mod_engine.mod.get(initial_island_path)()) if initial_island_path in mod_engine.mod else read_initial_island()
print("Initial island template", len(initial_island["objects"]), "objects loaded", len(initial_island["roads"]),
      "roads loaded")
# game_objects = [o for o in game_objects_2 if int(o["position"].split(",")[0]) > 62 and int(o["position"].split(",")[1]) > 58]

def read_island_file(file_path: str | Path) -> dict[str, Any]:
    return json.loads(Path(file_path).read_text(encoding="utf-8"))


# Every ally island, and only those. The files are named after the empire that
# owns them (``AcidCaos-island.json``, ``TheDevs-island.json``), so the match is
# on the name containing ``island.json`` -- not on the name being exactly that,
# which would match none of them. ``initial-island.json`` is the blank template
# the game starts from, not a player, so it stays out.
_island_files = [
    path
    for path in sorted(Path(my_games_path(), "allies").rglob("*"))
    if path.is_file() and "island.json" in path.name and path.name != "initial-island.json"
]

allies = {str(e["info"]["uid"] if e["info"] else e["friend"]["uid"]): e for e in
          [read_island_file(island) for island in _island_files]}
print("Ally islands")
print("-", len(allies.keys()), "allies loaded")
for key in allies:
    ally = allies[key]
    try:
        wName = ally["worldName"]
    except KeyError as e:
        wName = "<no world Name>"
    print(" * ", key, ":", wName, " --> ", str(len(ally["objects"]) if ally["objects"] else 0), "objects, ", str(len(ally["roads"]) if ally["roads"] else 0), "roads")


def lookup_item_by_name(item_name: str) -> dict[str, Any]:
    """The catalogue entry with this name.

    The catalogue is not a set. 36 item names are listed twice, and every one
    of those pairs is a byte-for-byte copy of the same row -- so "exactly one
    match" was never a property of the data, only an assumption. Unwrapping it
    raised ``ValueError: too many values to unpack`` the first time the player
    placed a ``BuildingPart124``, which ended the gateway batch and left the
    client with an empty answer. The first match is the answer.
    """
    for item in game_settings['settings']['items']['item']:
        if item.get('-name') == item_name:
            return item
    print("ERROR: Could not look up item by name", item_name)
    raise ValueError(f"No item named {item_name!r} in the catalogue")


def lookup_item_by_code(code: str) -> dict[str, Any]:
    """The catalogue entry with this code.

    34 codes are listed twice, each pair an identical copy of the same row,
    for the same reason as :func:`lookup_item_by_name`.
    """
    for item in game_settings['settings']['items']['item']:
        if item.get('-code') == code:
            return item
    print("ERROR: Could not look up item by code", code)
    raise ValueError(f"No item with code {code!r} in the catalogue")


def lookup_reference_item(cur_object: dict[str, Any] | None) -> dict[str, Any] | None:
    return lookup_item_by_code(cur_object['referenceItem'].split(":")[0]) if cur_object and 'referenceItem' in cur_object and cur_object['referenceItem'] else None


def lookup_items_with_workers_yield() -> list[dict[str, Any]]:
    items = [e for e in game_settings['settings']['items']['item'] if 'yield' in e and '-workers' in e['yield']]
    return items


def lookup_items_by_type(type: str) -> list[dict[str, Any]]:
    items = [e for e in game_settings['settings']['items']['item'] if e['-type'] == type]
    return items


def lookup_items_by_type_and_subtype(type: str, subtype: str) -> list[dict[str, Any]]:
    items = [e for e in game_settings['settings']['items']['item'] if e['-type'] == type and e.get("-subtype") == subtype]
    return items


def lookup_items_by_unit_class(unit_class: str) -> list[dict[str, Any]]:
    items = [e for e in game_settings['settings']['items']['item'] if e.get('-unitClass') == unit_class]
    return items


def lookup_yield() -> int:  #TODO buildstate
    yields = {e['-name']: int(e['yield']['-workers']) for e in lookup_items_with_workers_yield()}
    return sum([yields[e['itemName']] for e in session['user_object']["userInfo"]["world"]["objects"] if e['itemName'] in yields])


def lookup_visitor_reward(reward_name: str) -> dict[str, Any]:
    [reward] = [reward for reward in game_settings['settings']['visitorRewards']["reward"] if reward["-name"] == reward_name]
    return reward

def randomReward(item_name: str) -> tuple[str, int, str]:
    casino = game_settings["settings"]
    given_item = item_name
    item_list = []
    building_list = []
    weight_list = []
    ammount = []
    rewardstypes =[]
    for building in casino["casino"]["rewards"]:
        building_list.append(building["-item"])

    rewards_for_item = [e for e in casino["casino"]["rewards"] if e['-item'] == given_item]
    # The casino has four reward entries (QR01, QR02, ZR01, DB14). An item
    # outside them used to raise IndexError on the empty list -- and with it
    # the whole gateway batch. Such an item simply has no casino reward.
    if not rewards_for_item:
        return "", 0, ""
    reward_list = rewards_for_item[0]["reward"]

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

def lookup_state_machine(state_machine_name: str, custom_values: list[dict[str, Any]], custom_reference_values: list[dict[str, Any]] | None = None) -> dict[str, Any]:
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


def lookup_raw_state_machine(state_machine_name: str) -> dict[str, Any]:
    """The state machine with this name.

    ``WorldGamesStadiumStateMachine`` is listed twice, so the single-match
    unwrapping raised for the one building that uses it.
    """
    for state_machine in game_settings['settings']['stateMachines']['stateMachine']:
        if state_machine.get('-name') == state_machine_name:
            return state_machine
    print("ERROR: Could not look up state machine by name", state_machine_name)
    raise ValueError(f"No state machine named {state_machine_name!r} in the catalogue")

def lookup_crew_template(building_name: str) -> dict[str, Any]:
    """The crew template of a decoration.

    3938 of the 3990 catalogue items carry no '-crewTemplate' key at all --
    only the 52 'CrewableDecoration*' items do. Reading it unconditionally
    raised KeyError, and the caller staffs a decoration, so the request died
    with it. An item with no template simply has no crew slots.
    """
    item = lookup_item_by_name(building_name)
    crew_template_name = item.get("-crewTemplate")
    if not crew_template_name:
        return {"-crew": "", "position": []}
    template = next((x for x in game_settings['settings']['crewTemplates']['crewTemplate']
                     if x['-crew'] == crew_template_name), None)
    if template is None:
        print("ERROR: Could not look up crew template", crew_template_name)
        return {"-crew": crew_template_name, "position": []}
    return template

def repl_dict(d: dict[str, Any] | list[Any], replacements: dict[str, str]) -> None:
    if isinstance(d, dict):
        for k, v in d.items():
            if isinstance(v, dict):
                repl_dict(v, replacements)
            elif isinstance(v, list):
                for e in v:
                    repl_dict(e, replacements)
            elif isinstance(v, str) and "$" in v:
                new_v = v
                for s, r in replacements.items():
                    new_v = new_v.replace(s, r)
                if ":" in new_v:
                    new_v = new_v.split(':', 1)[1 if "$" in new_v else 0]
                d[k] = new_v
    elif isinstance(d, list):
        for e in d:
            repl_dict(e, replacements)


def lookup_wave(set_name: str, wave_index: int | str) -> dict[str, Any]:
    """The wave of a survival set.

    ``set1`` and ``set2`` each appear twice: the two rows are *experiment
    variants* of the same set (they differ in ``-variants`` and in the wave
    roster), not copies. The first row is the variant this server plays.
    """
    wave_set = None
    for candidate in game_settings['settings']['survivalModeSets']['set']:
        if candidate.get('-name') == set_name:
            wave_set = candidate
            break
    if wave_set is None:
        print("ERROR: Could not look up survival set by name", set_name)
        raise ValueError(f"No survival set named {set_name!r} in the catalogue")

    for wave in wave_set["wave"]:
        if wave.get('-index') == str(wave_index):
            return wave
    print("ERROR: Could not look up wave by index", wave_index, "in", set_name)
    raise ValueError(f"No wave {wave_index!r} in survival set {set_name!r}")


def replenish_energy() -> None:
    player = session['user_object']["userInfo"]["player"]
    # Energy is a count and it is stored as one. It had drifted to 27.0 in a
    # live save, which is what a resource that arrives through a float stops
    # being. The cast is here as well as on the awards because this runs on
    # every initUser, which is what puts a drifted save right again -- but the
    # awards cast too, since this is not the only writer.
    player["energy"] = int(player["energy"])
    player["energyMax"] = int(player["energyMax"])
    current_energy_max = max(player["energy"], player["energyMax"])  # overfill possible
    now = datetime.now().timestamp()
    energy_replenished = (now - player["lastEnergyCheck"]) // 300
    player["energy"] = min(player["energy"] + energy_replenished, current_energy_max)
    # print("Energy now:", now, "lastEnergyCheck", player["lastEnergyCheck"], "inc", (now - player["lastEnergyCheck"]), "till300", (now - player["lastEnergyCheck"]) % 300, "newec",  now - (now - player["lastEnergyCheck"]) % 300  )
    player["lastEnergyCheck"] = now - (now - player["lastEnergyCheck"] + 1) % 300
    if energy_replenished != 0:
        print("Energy replenished:", energy_replenished)


def unlock_expansion(index: int) -> None:
    """Set one expansion bit in the player's expansion map.

    The map is a list of 32-bit words: ``index >> 5`` is the word and
    ``index & 31`` is the bit inside it.

    The list grew when the player bought an expansion past the end of it, which
    used to raise IndexError and take the whole ``buyExpansion`` call with it.
    The line that used to do the growing is back, commented out in the source
    it came from.
    """
    expansions = session['user_object']["userInfo"]["player"]["expansions"]["data"]

    i = index >> 5
    if i >= len(expansions):
        expansions.extend([0 for _ in range(i + 1 - len(expansions))])
    e = index - (i << 5)
    expansions[i] = expansions[i] | 1 << e


def simple_list(raw_list: Any) -> list[Any]:
    return (raw_list if isinstance(raw_list, list) else [raw_list]) if raw_list != '' else []


def supplied_zid() -> int | None:
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


def get_zid() -> int:
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


def get_sessions_friends(saves: list[dict[str, Any]]) -> list[dict[str, Any]]:
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


def get_sessions_id(saves: list[dict[str, Any]]) -> list[int]:
    if saves:
        response = [save['user_object']["userInfo"]["player"]["uid"] for save in saves if validate_save(save) and save['user_object']["userInfo"]["player"]["level"] >= -6]
    else:
        response = []
    return response
