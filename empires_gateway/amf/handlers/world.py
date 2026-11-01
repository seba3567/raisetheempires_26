"""The world.

The island and the roads on it, the campaigns, the mayhem event, the name
above the map, and the actions the client performs on it. This is the domain
that knows about the map; the fights know about the armies.
"""
from __future__ import annotations

import copy
import logging
from typing import Any

from flask import session

from empires_gateway.amf.handlers.economy import (
    place_market_order,
    refund_market_order,
)
from empires_gateway.amf.handlers.player import init_user
from empires_gateway.amf.protocol import _amf_field
from empires_gateway.shared import STEELE_ID
from game_settings import (
    allies,
    game_settings,
    lookup_crew_template,
    lookup_item_by_code,
    lookup_item_by_name,
    randomReward,
)
from quest_engine import (
    handle_quest_progress,
    progress_action,
)
from save_engine import get_save_by_uid, get_saves, world_objects
from save_store import save_invaders
from state_machine import click_next_state, do_costs, lookup_object

logger = logging.getLogger(__name__)


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


def _staff_position(params) -> str:
    """The crew slot the client is asking about.

    A slot is a key of a crew template -- "parliament1", "immunity3" -- and
    the client sends it as a plain string or inside an object. Both are read
    the same way, because which one arrives is the client's business.
    """
    if isinstance(params, str):
        return params
    if isinstance(params, dict):
        for key in ("staffPosition", "position", "slot"):
            value = params.get(key)
            if isinstance(value, str) and value:
                return value
            if isinstance(value, dict):
                inner = value.get("-key") or value.get("key")
                if isinstance(inner, str) and inner:
                    return inner
        return ""
    if isinstance(params, list):
        for value in params:
            found = _staff_position(value)
            if found:
                return found
    return ""


def _free_crew_positions(save) -> set[str]:
    """The crew slots a save has empty.

    A crewable building holds a list of crew, one per slot of its template.
    The slots it does not fill are the ones it could lend.
    """
    free: set[str] = set()
    for obj in world_objects(save):
        if not isinstance(obj, dict):
            continue
        name = obj.get("itemName")
        if not name:
            continue
        try:
            template = lookup_crew_template(name)
        except Exception:
            # An object the catalogue does not know has no crew slots. The
            # catalogue prints the reason and keeps going; so does this.
            logger.info("no crew template for %r", name)
            continue
        crew = obj.get("crewInfo")
        if not isinstance(crew, list):
            crew = []
        for index, slot in enumerate(template.get("position", [])):
            if not isinstance(slot, dict):
                continue
            key = slot.get("-key")
            if key and index >= len(crew):
                free.add(key)
    return free


def crew_neighbor_poll_response(params):
    """`UserService.crewNeighborPoll` -- who could lend a crew member.

    The client asks, for one crew slot, which of the neighbours have
    somebody to spare. The answer is the list of their uids, which is
    exactly what `RequestService.crewRequest` takes next: the two calls fit
    together, and the client does not have to know who is next door.

    A neighbour can lend when one of its own crewable buildings has that
    slot empty. The neighbours are the other empires on this server, the
    ones the neighbour list already knows about.
    """
    meta = {"newPVE": 0}
    position = _staff_position(params)
    if not position:
        return {"errorType": 0, "userId": 1, "metadata": meta, "data": []}

    mine = None
    user_obj = session.get("user_object")
    if isinstance(user_obj, dict):
        mine = user_obj.get("userInfo", {}).get("player", {}).get("uid")

    candidates = []
    for save in get_saves():
        if not isinstance(save, dict):
            continue
        player = save.get("user_object", {}).get("userInfo", {}).get("player", {})
        uid = player.get("uid")
        if uid is None or uid == mine:
            continue
        if position in _free_crew_positions(save):
            candidates.append(uid)

    return {"errorType": 0, "userId": 1, "metadata": meta, "data": candidates}
