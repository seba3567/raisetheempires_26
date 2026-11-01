from __future__ import annotations

from datetime import datetime
from typing import Any

from fastapi_session import session

from game_settings import (
    game_settings,
    lookup_item_by_code,
    lookup_item_by_name,
    lookup_reference_item,
    lookup_state_machine,
    lookup_visitor_reward,
)
from quest_engine import (
    activate_unlocked_quests,
    handle_quest_progress,
    handle_world_state_change,
    merge_quest_progress,
    progress_resource_added_count,
    progress_upgrades_count,
    roll_reward_random_float,
)
from save_engine import create_backup, lookup_object, lookup_object_save


# TODO add new reference item from clicknext step, use old one for first autostep, new one for 2nd autonext,
#  not needed: is handled by checkstates if new one is null then use old reference item in clicknext(harvesting step?)
# TODO checkState?
def click_next_state(
    do_click: bool,
    id: int | str,
    meta: dict[str, Any],
    step: int,
    reference_item: str | None,
    speed_up: bool = False,
    tending: bool = False,
    save: dict[str, Any] | None = None,
    playback_tend: bool = False,
    tend_type: str | None = None,
    cancel: bool = True,
) -> None:
    cur_object = lookup_object(id) if not tending else lookup_object_save(save, id)
    print("cur_object used:", repr(cur_object))
    tend = tending or playback_tend

    if not cur_object or "itemName" not in cur_object:
        print(f"cur_object not found or missing itemName for id={id}")
        return

    try:
        game_item = lookup_item_by_name(cur_object['itemName'])
    except Exception as err:
        print(f"game_item not found for itemName={cur_object.get('itemName')}: {err}")
        return
    print("item used:", repr(game_item))
    if not game_item:
        print(f"game_item not found for itemName={cur_object.get('itemName')}")
        return

    timestamp = datetime.now().timestamp()
    if 'stateMachineValues' in game_item:
        state_machine = lookup_state_machine(game_item['stateMachineValues']['-stateMachineName'],
                                             game_item['stateMachineValues'].get('define', []),
                                             (lookup_reference_item(cur_object) or {}).get('referenceValues',{}).get('define'))

        print("state_machine used:", repr(state_machine))
        state = lookup_state(state_machine, cur_object.get('state', 0), cur_object, True)
        print("cur state:", repr(state))

        visited_states = set()
        while '-autoNext' in state and state['-stateName'] != state['-autoNext']:   # '-clientDuration': '2.0s', '-duration': '0' respect duration for harvest?
            if state['-stateName'] in visited_states:
                # The guard above only catches a state that points at itself.
                # VisitorAvatarStateMachine goes 1 -> 2 -> 1 -> 2, and with a
                # duration of zero the time check never stops it either, so
                # the loop spun forever: the request never returned and no
                # save was committed.
                print("autoNext cycle detected at state", state['-stateName'], "- stopping")
                break
            visited_states.add(state['-stateName'])
            duration =  parse_duration(state.get('-duration', '0'))
            if cur_object.get('lastUpdated', 0) / 1000 +  duration <= timestamp or speed_up or tend:
                if cur_object.get('lastUpdated', 0) / 1000 + duration > timestamp:
                    speed_up = False  # consumes speed up
                    tend = False
                    print("speed up used")
                next_state_id = state['-autoNext']  # not all states have this!! end states? autostate after time?
                previous_state = state
                state = lookup_state(state_machine, next_state_id, cur_object, True)
                check_state(state_machine, state, cur_object, tending)
                if not tending:
                    do_state_rewards(state, cur_object.get('referenceItem'), meta, playback_tend=playback_tend)
                if 'lastUpdated' not in cur_object:
                    cur_object['lastUpdated'] = 0  #init?
                cur_object['lastUpdated'] += duration * 1000
                cur_object['state'] = next_state_id
                print("pre auto_next_state:", repr(state), 'time', cur_object['lastUpdated'], "duration", duration)
                if not tending:
                    handle_world_state_change(meta, state, state_machine, game_item, step, previous_state, cur_object.get('referenceItem'), cur_object.get('referenceItem'))
            else:
                print("state has autoNext, but not enough time was passed")
                break

        if (do_click or tend):
            next_state_id = state.get('-clickNext') if not cancel else state.get('-cancelNext')
            if next_state_id is None:
                # '-cancelNext' is optional in the quest data; fall back to the
                # normal click transition.
                next_state_id = state.get('-clickNext')
            if next_state_id is None:
                # 651 of the 1297 shipped states have no '-clickNext' at all --
                # the auto/harvest/production states. Clicking one does
                # nothing, which is what the sibling branch below already
                # does. The old code read the missing key inside an
                # ``except KeyError`` that then read it again, so the second
                # read raised and the whole request died with it.
                print("state has no clicknext, click does nothing")
                cur_object['lastUpdated'] = timestamp * 1000
                return
            if reference_item != cur_object.get('referenceItem'):
                state_machine = lookup_state_machine(game_item['stateMachineValues']['-stateMachineName'],
                                                     game_item['stateMachineValues'].get('define', []),
                                                     (lookup_item_by_code(reference_item.split(":")[0]) if reference_item else {})
                                                     .get('referenceValues', {}).get('define'))
            next_click_state = lookup_state(state_machine, next_state_id, cur_object, True)
            check_state(state_machine, next_click_state, cur_object, tending)
            print("next_click_state:", repr(next_click_state))
            if cancel:
                print("canceled state")
            if not tending:
                do_state_rewards(next_click_state, cur_object.get('referenceItem'), meta, playback_tend=playback_tend)
                handle_world_state_change(meta, next_click_state, state_machine, game_item, step, state, reference_item, cur_object.get('referenceItem'))
            else:
                if tend_type == "mine":
                    standard_resources = ["coins", "oil", "wood", "aluminum", "copper", "gold", "iron", "uranium"]
                    res_type = 0
                    user_obj = save.get("user_object") if save else session.get("user_object")
                    if isinstance(user_obj, dict):
                        res_type = user_obj.get("userInfo", {}).get("player", {}).get("playerResourceType", 0)
                    res_idx = int(res_type) % len(standard_resources)
                    tend_type = f"{tend_type}_{standard_resources[res_idx]}"
                elif tend_type == "harvest":
                    tend_type += "_" + game_item['stateMachineValues']['-referenceType'] if '-referenceType' in game_item['stateMachineValues'] else ""
                    tend_type += "_" + game_item['stateMachineValues']['-referenceSubtype'] if '-referenceSubtype' in game_item['stateMachineValues'] else ""
                elif tend_type == "clear":
                    tend_type += game_item['-subtype']
                #TODO Crew tax

                reward = lookup_visitor_reward(tend_type)
                do_state_rewards(reward, cur_object.get('referenceItem'), meta)

            visited_click_states = set()
            while '-autoNext' in next_click_state and next_state_id != next_click_state['-autoNext'] and next_click_state.get('-duration', '0') in ['0', '0s']:   #'-clientDuration': '2.0s', '-duration': '0' respect duration for harvest?
                if next_click_state['-stateName'] in visited_click_states:
                    # Same cycle as above: the guard compares the target with
                    # the state it came from, so it catches 1 -> 1 but not
                    # 1 -> 2 -> 1.
                    print("autoNext cycle detected at state", next_click_state['-stateName'], "- stopping")
                    break
                visited_click_states.add(next_click_state['-stateName'])
                next_state_id = next_click_state['-autoNext']
                previous_state = next_click_state
                next_click_state = lookup_state(state_machine, next_state_id, cur_object, True)
                check_state(state_machine, next_click_state, cur_object, tending)
                print("auto_next_state:", repr(next_click_state))
                if not tending:
                    do_state_rewards(next_click_state, reference_item, meta, playback_tend=playback_tend)
                    handle_world_state_change(meta, next_click_state, state_machine, game_item, step, previous_state, reference_item, reference_item)

            cur_object['state'] = next_state_id
            cur_object['lastUpdated'] = timestamp * 1000
        else:
            print("state has no clicknext, click does nothing" if do_click else "not clicking, only autonexts")
            cur_object['lastUpdated'] = timestamp * 1000
    else:
        print("object has no statemachine, click does nothing")
        cur_object['lastUpdated'] = timestamp * 1000
        if not tending:
            handle_world_state_change(meta, {}, None, game_item, step, {}, reference_item, reference_item)


def lookup_state(
    state_machine: dict[str, Any],
    i: int | str,
    cur_object: dict[str, Any],
    check_state: bool,
) -> dict[str, Any]:
    states = state_machine.get('state', [])
    if isinstance(states, dict):
        states = [states]
    matched = [e for e in states if str(e.get('-stateName')) == str(i)]
    if matched:
        state = matched[0]
    elif states:
        state = states[0]
    else:
        state = {}
    if check_state and 'check_state' in cur_object and str(i) in cur_object['check_state']:
        state = cur_object['check_state'][str(i)]
        print("Overridden state used", str(i))
    return state


#use state from current statemachine as replacement state for that state (with values and 2 random numbers
def check_state(
    state_machine: dict[str, Any],
    state: dict[str, Any],
    cur_object: dict[str, Any],
    tending: bool,
) -> None:
    if '-checkState' in state:
        check_state_val = lookup_state(state_machine, state["-checkState"], cur_object, False)
        if 'check_state' not in cur_object:
            cur_object['check_state'] = {}
        cur_object['check_state'][state["-checkState"]] = check_state_val
        print("Future check state overridden", state["-checkState"])
        if "-xp" in check_state_val and not tending:
            roll_reward_random_float() # prison xp
        if "-dooberType" in check_state_val and not tending:
            roll_reward_random_float() # for the platinum pipes


def parse_duration(duration: str | float) -> float:
    # ["ms", "m", "s", "h", "d"];
    if isinstance(duration, (int, float)):
        return float(duration)
    if duration == 'rand:1d,4d':
        return 86400.0 # 1d
    if "ms" in duration:
        return float(duration[:-2]) / 1000.0
    if "s" in duration:
        return float(duration[:-1])
    if "m" in duration:
        return float(duration[:-1]) * 60.0
    if "h" in duration:
        return float(duration[:-1]) * 3600.0
    if "d" in duration:
        return float(duration[:-1]) * 86400.0
    return float(duration)


def do_state_rewards(
    state: dict[str, Any],
    reference_item: str | None,
    meta: dict[str, Any],
    playback_tend: bool = False,
) -> None:
    player = session['user_object']["userInfo"]["player"]
    player['xp'] = player.get('xp', 0) + int(state.get('-xp', 0))
    energy = int(state.get('-energy', 0))
    if playback_tend:
        energy = max(energy, 0)
    # int(): this is the writer that let energy reach 26.0 in a live save.
    # `replenish_energy` casts too, but it only runs on initUser, so it cannot
    # be the only thing guarding the type.
    player['energy'] = int(player.get('energy', 0) + energy)
    player['cash'] = player.get('cash', 0) + int(state.get('-cash', 0))
    player['socialXpGood'] = player.get('socialXpGood', 0) + int(state.get('-socialXpGood', 0))
    player['socialXpBad'] = player.get('socialXpBad', 0) + int(state.get('-socialXpBad', 0))

    if  str(state.get('-elementZ',0)) != '0':
        if state.get('-elementZ',0) not in player["inventory"]["items"]:
            player["inventory"]["items"][state.get('-elementZ',0)] = 1
        else:
            player["inventory"]["items"][state.get('-elementZ', 0)] +=1

    world = session['user_object']["userInfo"]["world"]
    resources = world.setdefault('resources', {})
    resources['coins'] = resources.get('coins', 0) + int(state.get('-coins', 0))
    # Energy stays on the player; it is not mirrored into world['resources'].
    # See quest_engine.do_rewards for why that mirror was a second answer to a
    # question that already had one.
    resources['oil'] = resources.get('oil', 0) + int(state.get('-oil', '0').split('|')[0])
    resources['wood'] = resources.get('wood', 0) + int(state.get('-wood', '0').split('|')[0])

    resource_order = world.get('resourceOrder') or ["aluminum", "copper", "gold", "iron", "uranium"]
    for idx, key in enumerate(['-rare', '-nrare0', '-nrare1', '-nrare2', '-nrare3', '-nrare4']):
        target_idx = 0 if idx <= 1 else idx - 1
        if target_idx < len(resource_order):
            res_name = resource_order[target_idx]
            val = int(state.get(key, '0').split('|')[0])
            resources[res_name] = resources.get(res_name, 0) + val

    for res in ["aluminum", "copper", "gold", "iron", "uranium"]:
        resources[res] = resources.get(res, 0) + int(state.get(f'-{res}', '0').split('|')[0])

    item_inventory = player.setdefault("inventory", {}).setdefault("items", {})
    if int(state.get('-buildable', '0')):
        if reference_item:
            item_inventory[reference_item] = item_inventory.get(reference_item, 0) + 1
            print("Adding", reference_item, "to inventory")
        else:
            print("ERROR: Buildable present but no reference item")

    research = world.setdefault("research", {})
    if int(state.get('-upgrade', '0')):
        if reference_item:
            if reference_item.split(":")[0] not in research.get(reference_item.split(":")[1],[]):
                research[reference_item.split(":")[1]] = research.get(reference_item.split(":")[1],[])  + [reference_item.split(":")[0]]
                print("Adding", reference_item, "to research")
                handle_quest_progress(meta, progress_upgrades_count())
            else:
                print("ERROR: Upgrade already added")
        else:
            print("ERROR: Upgrade present but no reference item")

    level_cash = 0
    levels_count = 0
    cur_level = player.get('level', 1)
    levels = [level for level in game_settings['settings']['levels']['level'] if
              int(level["-num"]) > cur_level and int(level["-requiredXP"]) <= player['xp']]
    for level in levels:
        energy_cap = ([e['-cap'] for e in game_settings['settings']['energycaps']['energycap'] if e['-level'] == level["-num"]] + [46])[0]
        print("Level increased to", level["-num"], "New energy:", energy_cap)
        player['level'] = int(level["-num"])
        player['energy'] = int(energy_cap)
        player['energyMax'] = int(energy_cap)
        levels_count += 1
        if "reward" in level and level["reward"]["-type"] == "cash":
            player['cash'] += int(level["reward"]["-count"])
            level_cash += int(level["reward"]["-count"])
        create_backup("Level " + level["-num"])

    log_rewards = ", ".join(
        [label + " " + ("+" if int(increment) > 0 else "") + str(increment) + " (" + str(total) + ")" for
         (label, increment, total)
         in
         [("xp:", state.get('-xp', '0'), player['xp']),
          ("energy:", str(energy), player['energy']),
          ("coins:", state.get('-coins', '0'), resources['coins']),
          ("oil:", state.get('-oil', '0'), resources['oil']),
          ("wood:", state.get('-wood', '0'), resources['wood']),
          ("cash:", state.get('-cash', '0'), player['cash']),
          ("cash (level):", str(level_cash), player['cash']),
          ("levels:", str(levels_count), player['level']),
          ("socialXpGood:", state.get('-socialXpGood', '0'), player['socialXpGood']),
          ("socialXpBad:", state.get('-socialXpBad', '0'), player['socialXpBad']),
          ("buildable:", state.get('-buildable', '0'), sum(item_inventory.values())),
          (resource_order[0] + ":", state.get('-rare', '0'), resources[resource_order[0]]),
          (resource_order[0] + ":", state.get('-nrare0', '0'), resources[resource_order[0]]),
          (resource_order[1] + ":", state.get('-nrare1', '0'), resources[resource_order[1]]),
          (resource_order[2] + ":", state.get('-nrare2', '0'), resources[resource_order[2]]),
          (resource_order[3] + ":", state.get('-nrare3', '0'), resources[resource_order[3]]),
          (resource_order[4] + ":", state.get('-nrare4', '0'), resources[resource_order[4]]),
          ("aluminum" + ":", state.get('-aluminum', '0'), resources["aluminum"]),
          ("copper" + ":", state.get('-copper', '0'), resources["copper"]),
          ("gold" + ":", state.get('-gold', '0'), resources["gold"]),
          ("iron" + ":", state.get('-iron', '0'), resources["iron"]),
          ("uranium" + ":", state.get('-uranium', '0'), resources["uranium"])
          ] if int(increment.split('|')[0]) != 0])
    if log_rewards:
        print("State rewards:", log_rewards)
    handle_quest_progress(meta, progress_resource_added_count(state, "-"))
    if levels:
        new_quests = []
        if "QuestComponent" not in meta:
            meta['QuestComponent'] = []
        activate_unlocked_quests(new_quests, meta)
        merge_quest_progress(new_quests, meta['QuestComponent'], "output quest")
        merge_quest_progress(new_quests, session['quests'], "session quest")

        
        
def do_costs(costs: dict[str, Any] | None) -> None:
    """Charge the player for something.

    ``costs`` is the catalogue's ``cost`` block, and it may be absent: 774 of
    the 3990 items have no ``cost`` key at all. An item that costs nothing
    charges nothing, so a missing cost is an empty cost -- not ``None`` that
    gets ``.get()`` called on it.
    """
    costs = costs or {}
    player = session['user_object']["userInfo"]["player"]
    player['xp'] -= int(costs.get('-xp', 0))
    player['energy'] -= int(costs.get('-energy', 0))
    player['cash'] -= int(costs.get('-cash', 0))
    player['socialXpGood'] -= int(costs.get('-socialXpGood', 0))
    player['socialXpBad'] -= int(costs.get('-socialXpBad', 0))

    world = session['user_object']["userInfo"]["world"]
    resources = world['resources']
    resources['coins'] = max(0, resources['coins'] - int(costs.get('-coins', 0)))
    # The player's energy is charged just above; the world copy is not touched.
    # See quest_engine.do_rewards for what this mirror used to cost.
    resources['oil'] = max(0, resources['oil'] - int(costs.get('-oil', '0').split('|')[0]))
    resources['wood'] = max(0, resources['wood'] - int(costs.get('-wood', '0').split('|')[0]))

    resource_order = world.get('resourceOrder') or ["aluminum", "copper", "gold", "iron", "uranium"]
    for idx, key in enumerate(['-rare', '-nrare0', '-nrare1', '-nrare2', '-nrare3', '-nrare4']):
        target_idx = 0 if idx <= 1 else idx - 1
        if target_idx < len(resource_order):
            res_name = resource_order[target_idx]
            val = int(costs.get(key, '0').split('|')[0])
            resources[res_name] = max(0, resources.get(res_name, 0) - val)

    log_costs = ", ".join([label + " " + ("+" if int(decrement) < 0 else "") + str(-int(decrement)) + " (" + str(total) + ")" for
                     (label, decrement, total)
                     in
                     [("xp:", costs.get('-xp', '0'), player['xp']),
                      ("energy:", costs.get('-energy', '0'), player['energy']),
                      ("coins:", costs.get('-coins', '0'), resources['coins']),
                      ("oil:", costs.get('-oil', '0'), resources['oil']),
                      ("wood:", costs.get('-wood', '0'), resources['wood']),
                      ("cash:", costs.get('-cash', '0'), player['cash']),
                      ("socialXpGood:", costs.get('-socialXpGood', '0'), player['socialXpGood']),
                      ("socialXpBad:", costs.get('-socialXpBad', '0'), player['socialXpBad']),
                      (resource_order[0] + ":", costs.get('-rare', '0'), resources[resource_order[0]]),
                      (resource_order[0] + ":", costs.get('-nrare0', '0'), resources[resource_order[0]]),
                      (resource_order[1] + ":", costs.get('-nrare1', '0'), resources[resource_order[1]]),
                      (resource_order[2] + ":", costs.get('-nrare2', '0'), resources[resource_order[2]]),
                      (resource_order[3] + ":", costs.get('-nrare3', '0'), resources[resource_order[3]]),
                      (resource_order[4] + ":", costs.get('-nrare4', '0'), resources[resource_order[4]])
                      ] if int(decrement.split('|')[0]) != 0])
    if log_costs:
        print("Costs:", log_costs)