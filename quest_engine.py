from __future__ import annotations

import contextlib
import math
from collections.abc import Callable
from functools import reduce
from typing import Any

Predicate = Callable[..., Any]

from flask import session

from game_settings import (
    allies,
    game_settings,
    get_sessions_friends,
    lookup_item_by_code,
    lookup_items_by_unit_class,
    lookup_state_machine,
    lookup_yield,
    replenish_energy,
)
from quest_settings import prequels, quest_settings, simple_list
from save_engine import create_backup, get_saves, lookup_objects_by_item_name


def merge_quest_progress(qc: list[dict[str, Any]], output_list: list[dict[str, Any]], label: str) -> None:
    if qc:
        print("new q before merge " + repr(qc))
        print(label + " list before merge " + repr (output_list))
        output_list[:] = qc + [e for e in output_list if e['name'] not in [q['name'] for q in qc]]
        print(label + " list after merge " + repr (output_list))


def lookup_quest(name: str) -> dict[str, Any] | None:
    quests = [r for r in quest_settings['quests']['quest'] if r.get('_name') == name]
    return quests[0] if len(quests) == 1 else None


def new_quest(quest: dict[str, Any]) -> dict[str, Any]:
    tasks = get_tasks(quest)
    if not tasks:
        return {"name": quest['_name'], "complete": True, "expired": False, "progress": [], "completedTasks": 0}
    pairs = [prepopulate_task(e) for e in tasks]
    progress = [p[0] for p in pairs]
    completes = [p[1] for p in pairs]
    return {
        "name": quest['_name'],
        "complete": all(completes),
        "expired": False,
        "progress": progress,
        "completedTasks": reduce((lambda x, y: int(x) << 1 | int(y)), [0] + [int(ci) for ci in completes[::-1]])
    }


def progress_quest_task(name: str, index: int) -> Predicate:
    return lambda task, progress, i, extra, quest_name, *args: \
        quest_name == name and \
        i == index and \
        progress_total_amount(task["_total"], task["_total"], extra, progress)


def progress_quest(name: str) -> Predicate:
    return lambda task, progress, i, extra, quest_name, *args: \
        quest_name == name and \
        progress_total_amount(task["_total"], task["_total"], extra, progress)


def progress_feed(feed_name: str) -> Predicate:
    return lambda task, progress, i, extra, quest_name, *args: \
        task["_action"] == "feedReceived" and \
        task["_feed"] == feed_name and \
        progress_total_amount(task["_total"], task["_total"], extra, progress)


def prepopulate_task(task: dict[str, Any]) -> tuple[int, bool]:
    if task["_action"] == 'countPlaced' and "_item" in task:
        # A task can name more than one item ("QMU00_Gate" counts
        # "PU10,PU11,PU12"). The whole string used to be handed to the code
        # lookup, which raised ValueError on the comma.
        number_built = 0
        for code in [c.strip() for c in str(task["_item"]).split(",") if c.strip()]:
            item = lookup_item_by_code(code)
            if 'stateMachineValues' in item:
                state_machine = lookup_state_machine(item['stateMachineValues']['-stateMachineName'],
                                                     item['stateMachineValues'].get('define', []))
            else:
                state_machine = None
            objects = lookup_objects_by_item_name(item['-name'])
            # 13 of the shipped state machines have no '-builtState'; for
            # those, nothing can be "built" yet.
            built_state = int(state_machine.get('-builtState', 0)) if state_machine else 0
            built_objects = [e for e in objects if int(e.get('state', 0)) >= built_state]
            number_built += len(built_objects)
        return min(number_built, int(task["_total"])), number_built >= int(task["_total"])
    if task["_action"] == 'countPlaced' and "_unitClass" in task:
        items = lookup_items_by_unit_class(task["_unitClass"])
        number_placed = 0
        for item in items:
            objects = lookup_objects_by_item_name(item['-name'])
            number_placed += len(objects)
        return min(number_placed, int(task["_total"])), number_placed >= int(task["_total"])
    if task["_action"] == 'countPlacements':
        item = lookup_item_by_code(task.get("_item", task.get('_code')))
        objects = lookup_objects_by_item_name(item['-name'])
        number_placed = len(objects)
        return min(number_placed, int(task["_total"])), number_placed >= int(task["_total"])
    if task["_action"] == 'inventoryCount':
        item_inventory = session['user_object']["userInfo"]["player"]["inventory"]["items"]
        return min(item_inventory.get(task["_item"], 0), int(task["_total"])), item_inventory.get(task["_item"], 0) >= int(task["_total"])
    if task["_action"] == 'population':
        return min(session['population'], int(task["_total"])), session['population'] >= int(task["_total"])
    if task["_action"] == 'neighborsAdded':
        if task["_desc"] == "quest_1140_task_01":
            return 0, False
        neighbor_count = len([ally for ally in allies.values() if ally.get("friend") and ally.get("neighbor")])
        return min(neighbor_count, int(task["_total"])), neighbor_count >= int(task["_total"])
    if task["_action"] == 'countUpgrades':
        research = session['user_object']["userInfo"]["world"]["research"]
        total = 0
        unit = task["unit"]
        for k, v in research.items():
            if "_item" in unit:
                if k == unit["_item"]:
                    total += len(v)
            elif "_unitClass" in unit:
                item = lookup_item_by_code(k)
                if item["-unitClass"] == unit["_unitClass"]:
                    total += len(v)
            elif "_subtype" in unit:
                item = lookup_item_by_code(k)
                if item["-subtype"] == unit["_subtype"]:
                    total += len(v)

        return min(total, int(task["_total"])), total >= int(task["_total"])
    if task["_action"] == 'autoComplete':
        return 1, True
    return 0, False


# "autoComplete","battleDamage","battleKill","build","buyExpansion","challengeCreate","clear","countPlaced","expandIsland","fight","finishBuilding","fullscreen","genericString","harvest","inventoryAdded","islandWin","marketAdd","marketBuy","move","neighborsAdded","openDialog","ownObjects","ownResource","place","population","pillage","pvpCombat","resourceAdded","seenFlag","select","socialXPAdded","startImmunity","state","tending","tendingRewardDropped","unlockTutorial","useConsumable","visit","zoom"
def handle_world_state_change(meta: dict[str, Any], *state_args: Any) -> None:
    handle_quest_progress(meta, world_state_change(*state_args))


def world_state_change(*state_args: Any) -> Predicate:
    return lambda *args: \
        any([progress_finish_building_count_placed(*state_args)(*args),
             progress_auto_complete()(*args),
             progress_place(*state_args)(*args),
             progress_place_unit(*state_args)(*args),
             progress_build(*state_args)(*args),
             progress_harvest(*state_args)(*args),
             progress_state(*state_args)(*args),
             progress_inventory_count()(*args),
             progress_harvest_consumable(*state_args)(*args)
             ])


def progress_finish_building_count_placed(state: Any, state_machine: Any, game_item: dict[str, Any], step: str, previous_state: Any, *state_args: Any) -> Predicate:
    return lambda task, progress, i, *args: \
        task["_action"] in ["finishBuilding", "countPlaced"] and progress_match_filters(game_item)(task, progress, i, *args) and \
        progress < int(task["_total"]) and _just_reached_built_state(state, state_machine, previous_state)


def _just_reached_built_state(state: Any, state_machine: Any, previous_state: Any) -> bool:
    """Whether the object has just entered its "built" state.

    Three of the four values read here can legitimately be absent:

    * An object with no state machine at all is dispatched with ``state={}``
      and ``state_machine=None`` (``state_machine.click_next_state``), so
      ``state['-stateName']`` raised ``KeyError: '-stateName'``.
    * 13 of the shipped state machines have no ``-builtState`` key.
    * The previous state is ``{}`` on the same no-state-machine path.

    Any one of them raised, and because the whole predicate list is built
    eagerly, the raise took the request down with it -- a player clicking
    their own infantry unit got a 500.
    """
    state_name = state.get('-stateName') if isinstance(state, dict) else None
    built_state = state_machine.get('-builtState') if isinstance(state_machine, dict) else None
    previous_state_name = previous_state.get('-stateName') if isinstance(previous_state, dict) else None

    if state_name is None or built_state is None or previous_state_name is None:
        return False

    try:
        return state_name == built_state and int(previous_state_name) < int(state_name)
    except (TypeError, ValueError):
        return False


def progress_match_filters(game_item: dict[str, Any]) -> Predicate:
    return all_lambda(
        progress_parameter_implies("_item", game_item.get("-code", "")),
        progress_parameter_implies("_type", game_item.get("-type", "")),
        progress_parameter_implies("_subtype", game_item.get("-subtype", "")),
        progress_parameter_implies("_unitClass", game_item.get("-unitClass", "")),
        progress_parameter_implies("_warehouseType", game_item.get("-warehouseType", "")),
        progress_parameter_implies("_superore", game_item.get("-superore", "")),
        progress_parameter_implies("_resourceType", game_item.get("-resourceType", "")),
        progress_parameter_implies("_villain", game_item.get("-villain", ""))
    )


def progress_inventory_count() -> Predicate:
    return lambda task, progress, i, extra, *args: \
        task["_action"] == "inventoryCount" and  progress_inventory(task["_item"], task["_total"], extra, progress) \
        and progress < int(task["_total"])


def progress_inventory(item: str, maximum_total: int | str, extra: dict[str, Any], progress: int) -> bool:
    item_inventory = session['user_object']["userInfo"]["player"]["inventory"]["items"]
    total = min(item_inventory.get(item, 0), int(maximum_total))
    extra["total"] = total
    return total != progress


def progress_neighbor_count() -> Predicate:
    return lambda task, progress, i, extra, *args: \
        task["_action"] == "neighborsAdded" and  progress_neighbors(task["_total"], extra, progress) \
        and progress < int(task["_total"])


def progress_neighbors(maximum_total: int | str, extra: dict[str, Any], progress: int) -> bool:
    neighbor_count = len([ally for ally in allies.values() if ally.get("friend") and ally.get("neighbor")] + get_sessions_friends(get_saves()))
    total = min(neighbor_count, int(maximum_total))
    extra["total"] = total
    return total != progress


def progress_upgrades_count() -> Predicate:
    return lambda task, progress, i, extra, *args: \
        task["_action"] == "countUpgrades" and progress_upgrades(task["unit"], task["_total"], extra, progress) \
        and progress < int(task["_total"])


def progress_upgrades(unit: dict[str, Any], maximum_total: int | str, extra: dict[str, Any], progress: int) -> bool:
    research = session['user_object']["userInfo"]["world"]["research"]
    total = 0
    for k, v in research.items():
        if "_item" in unit:
            if k == unit["_item"]:
                total += len(v)
        elif "_unitClass" in unit:
            item = lookup_item_by_code(k)
            if item["-unitClass"] == unit["_unitClass"]:
                total += len(v)
        elif "_subtype" in unit:
            item = lookup_item_by_code(k)
            if item["-subtype"] == unit["_subtype"]:
                total += len(v)

    extra["total"] = min(total, int(maximum_total))
    return total != progress


def progress_battle_damage_count(action: str, damage: int, ally_unit: dict[str, Any], baddy_unit: dict[str, Any]) -> Predicate:
    return lambda task, progress, i, extra, *args: \
        task["_action"] == action and \
    all_lambda(
        progress_parameter_implies("_subtype", ally_unit.get("-subtype", "")),
        progress_parameter_implies("_unitClass", ally_unit.get("-unitClass", "")),
        progress_parameter_implies("_item", ally_unit.get("-code", "")),
        progress_nested_parameter_implies("targetInfo", "_unitClass", baddy_unit.get("-unitClass", "")),
        progress_nested_parameter_implies_contains("targetInfo", "_unitType",
                                                   baddy_unit.get("unit", {}).get("-type", ""))
    )(task, progress, i, extra, *args) \
        and progress_battle_damage(damage, task["_total"], extra, progress) \
        and progress < int(task["_total"])


def progress_battle_damage(damage: int, maximum_total: int | str, extra: dict[str, Any], progress: int) -> bool:
    extra["yield"] = min(damage, int(maximum_total))
    return True


def progress_resource_added_count(rewards: dict[str, Any], prefix: str) -> Predicate:
    standard_resources = ["coins", "oil", "wood", "aluminum", "copper", "gold", "iron", "uranium"]
    ores = ["aluminum", "copper", "gold", "iron", "uranium"]
    rares = {"rare": 0, "nrare0": 0, "nrare1": 1, "nrare2": 2, "nrare3": 3, "nrare4": 4}
    resource_type = session['user_object']["userInfo"]["player"]["playerResourceType"]
    sorted_ores = ores[resource_type - 3:] + ores[:resource_type - 3]
    # resources[standard_resources[int(market["item"])]]
    return lambda task, progress, i, extra, *args: \
        task["_action"] == "resourceAdded" and ((rewards.get(prefix + task["_type"]) \
        and progress_yield_amount(str(rewards[prefix + task["_type"]]).split('|')[0], task["_total"], extra, progress)) \
        or (task["_type"] in rares and rewards.get(prefix + sorted_ores[rares[task["_type"]]]) \
        and progress_yield_amount(str(rewards[prefix + sorted_ores[rares[task["_type"]]]]).split('|')[0], task["_total"], extra, progress)))


def progress_market_added_count(amount: int | str) -> Predicate:
    return lambda task, progress, i, extra, *args: \
        task["_action"] == "marketAdd" and \
        progress_parameter_implies("_item", "rare")(task, progress, i, extra, *args) and \
        progress_total_amount(amount,task["_total"], extra, progress)


def progress_total_amount(amount: int | str, maximum_total: int | str, extra: dict[str, Any], progress: int) -> bool:
    extra["total"] = min(int(amount), int(maximum_total))
    # Every '_total' in the shipped quest data is a JSON string, and the
    # progress that is compared against it is an int. Comparing the two as
    # they came out of the data made the "nothing changed" short-circuit
    # always true, so a satisfied task reported itself as newly progressed
    # on every evaluation.
    return int(amount) != int(progress)


def progress_yield_amount(amount: int | str, maximum_total: int | str, extra: dict[str, Any], progress: int) -> bool:
    extra["yield"] = min(int(amount), int(maximum_total))
    return int(amount) != int(progress)


        #cancels?
def progress_build(state: Any, state_machine: Any, game_item: dict[str, Any], step: str, previous_state: Any, reference_item: str | None, previous_reference_item: str | None, *state_args: Any) -> Predicate:
    return lambda task, progress, i, *args: \
        task["_action"] == "build" and reference_item is not None and (
                reference_item.split(":")[0] in task.get("_item", "").split(',') or
                progress_parameter_equals("_resourceType",
                                          lookup_item_by_code(reference_item.split(":")[0]).get("-resourceType", ""))(task, progress, i, *args)
                or all_lambda(progress_parameter_equals("_isUpgrade", "true"),
                              lambda *args: lookup_item_by_code(reference_item.split(":")[0]).get("-type","upgrade"),
                              progress_nested_parameter_implies("unit", "_subtype", lookup_item_by_code(
                                  reference_item.split(":")[1]).get("-subtype", "") if len(
                                  reference_item.split(":")) > 1 else "")
                              )(task, progress, i, *args)
        ) \
        and previous_reference_item is None


def progress_harvest(state: Any, state_machine: Any, game_item: dict[str, Any], step: str, previous_state: Any, reference_item: str | None, previous_reference_item: str | None, *state_args: Any) -> Predicate:
    return lambda task, progress, i, *args: \
        task["_action"] == "harvest" and previous_reference_item is not None and (
                previous_reference_item.split(":")[0] in  task.get("_item", "").split(',') or
                   progress_parameter_equals("_subtype", lookup_item_by_code(previous_reference_item.split(":")[0]).get("-subtype",""))(task, progress, i, *args)
                   or all_lambda(progress_parameter_equals("_isUpgrade", "true"),
                                 lambda *args: lookup_item_by_code(previous_reference_item.split(":")[0]).get("-type","upgrade"),
                                 progress_nested_parameter_implies("unit", "_subtype", lookup_item_by_code(previous_reference_item.split(":")[1]).get("-subtype","") if len(previous_reference_item.split(":")) > 1 else "")
                                 )(task, progress, i, *args)
                        ) \
        and reference_item is None


def progress_auto_complete() -> Predicate:
    return lambda task, *args: task["_action"] in ["autoComplete", "population"]


def progress_place(state: Any, state_machine: Any, game_item: dict[str, Any], step: str, *state_args: Any) -> Predicate:
    return lambda task, progress, i, *args: \
        task["_action"] in ["place", "countPlacements"] and task.get("_item", task.get('_code')) == game_item['-code'] and progress < int(task["_total"]) and step == "place"


def progress_place_unit(state: Any, state_machine: Any, game_item: dict[str, Any], step: str, *state_args: Any) -> Predicate:
    return lambda task, progress, i, *args: \
        task["_action"] in ["countPlaced"] and task.get("_unitClass", "NONE") == game_item.get('-unitClass', "OTHER") and progress < int(task["_total"]) and step == "place"


def progress_state(state: Any, state_machine: Any, game_item: dict[str, Any], step: str, *state_args: Any) -> Predicate:
    return lambda task, progress, i, *args: \
        task["_action"] in ["state", "countState"] and '-stateName' in state and state['-stateName'] in task["_state"].split(',')  and ("_item" not in task or task["_item"] == game_item['-code'])\
        and ("_subtype" not in task or task["_subtype"] == game_item['-subtype']) and progress < int(task["_total"])


# def all_lambda(lambdas, *initializer):
#     return lambda *args: all([l(*initializer)(*args) for l in lambdas])


def all_lambda(*lambdas: Predicate) -> Predicate:
    return lambda *args: all(fn(*args) for fn in lambdas)


def progress_action(action: str) -> Predicate:
    return lambda task, *args: task["_action"] == action


def progress_parameter_equals(key: str, value: Any) -> Predicate:
    return lambda task, *args: task.get(key, "_NO_MATCH_") == value


def progress_parameter_implies(key: str, value: Any) -> Predicate:
    return lambda task, *args: task.get(key) is None or task.get(key, "_NO_MATCH_") == value


def progress_nested_parameter_implies(key: str, key2: str, value: Any) -> Predicate:
    return lambda task, *args: task.get(key) == '' or task.get(key, {}).get(key2) is None or task.get(key, {}).get(key2, "_NO_MATCH_") == value


def progress_nested_parameter_implies_contains(key: str, key2: str, value: str) -> Predicate:
    return lambda task, *args: task.get(key) == '' or task.get(key, {}).get(key2) is None or any(i in task.get(key, {}).get(key2, "_NO_MATCH_").split(",") for i in value.split(","))


def progress_parameter_implies_contains(key: str, value: str) -> Predicate:
    return lambda task, *args: task.get(key) is None or any(
        i in task.get(key, "_NO_MATCH_").split(",") for i in value.split(","))


# deprogress functions?
def handle_quest_progress(meta: dict[str, Any], progress_function: Predicate) -> None:
    replenish_energy()
    incomplete_quests = [e for e in session['quests'] if not e["complete"]]
    for session_quest in incomplete_quests:
        new_quests = []
        report_quest = False
        quest = lookup_quest(session_quest['name'])
        if quest is None:
            # A quest the catalogue no longer knows -- an updated quest
            # settings file, or a save written by a different build. The name
            # used to be looked up twice and handed straight to get_tasks(),
            # so one stale entry raised AttributeError here and poisoned every
            # later quest update for this player.
            print("unknown quest in the session, skipping:", session_quest['name'])
            continue
        tasks = get_tasks(quest)

        # The stored progress list and the task list have to agree. `zip`
        # truncates to the shorter of the two, so a quest whose definition grew
        # since the save was written never evaluated its new tasks -- while
        # the completion threshold still asked for all of them, which made the
        # quest impossible to finish (3 >= 7 is never true). Give the new tasks
        # their zero progress, and drop the entries whose task is gone.
        stored_progress = session_quest['progress']
        if len(stored_progress) < len(tasks):
            stored_progress.extend([0] * (len(tasks) - len(stored_progress)))
            session_quest['progress'] = stored_progress
        elif len(stored_progress) > len(tasks):
            del stored_progress[len(tasks):]
            session_quest['progress'] = stored_progress

        for task, progress, i in zip(tasks, session_quest['progress'], range(len(session_quest['progress']))):
            extra = {"yield": 1}
            if progress_function(task, progress, i, extra, session_quest['name']):  #countPlaced tasks should be prepopulated with already placed items, however removed ones? precomplete autoComplete?
                    print("Task", repr(task), "progress", repr(progress), "i", i, "quest_name", session_quest['name'])
                    report_quest = True
                    if task['_action'] == 'population':
                        session_quest['progress'][i] = min(lookup_yield(), int(task["_total"]))  # session['population']
                    else:
                        session_quest['progress'][i] = extra.get("total", session_quest['progress'][i] + extra["yield"])
                    print("Task progress", task["_action"])
                    if session_quest['progress'][i] >= int(task["_total"]):
                        session_quest["completedTasks"] = session_quest["completedTasks"] | 1 << i
                        print("Task complete", task["_action"])

        all_tasks = 2 ** len(tasks) - 1
        if report_quest:
            print("completedTasks", session_quest["completedTasks"], "len(tasks)", len(tasks), "calc", all_tasks)
        # Only the bits of the tasks that still exist count. A bit left over
        # from a task the catalogue no longer has must not complete the quest
        # on its own, and the tasks that are still there must all be done.
        if (session_quest["completedTasks"] & all_tasks) == all_tasks:
            session_quest["complete"] = True
            print("Quest complete", session_quest['name'])
            do_quest_rewards(quest, meta)
            activate_sequels(session_quest, new_quests, meta)
        if report_quest:
            if "QuestComponent" not in meta:
                meta['QuestComponent'] = []
            merge_quest_progress([session_quest] + new_quests, meta['QuestComponent'], "output quest")
            merge_quest_progress(new_quests, session['quests'], "session quest")
            #meta['QuestComponent'].append(session_quest) ### merge if already in it?
                    # progress = [0 for e in quest['tasks']]


def get_tasks(quest: dict[str, Any]) -> list[dict[str, Any]]:
    raw_tasks = quest.get('tasks', {}).get('task', [])
    tasks = raw_tasks if isinstance(raw_tasks, list) else [raw_tasks]
    return tasks


def activate_sequels(session_quest: dict[str, Any], new_quests: list[dict[str, Any]], meta: dict[str, Any]) -> None:
    q = lookup_quest(session_quest['name'])
    if not q:
        return
    raw_sequels = q.get('sequels')
    if not isinstance(raw_sequels, dict):
        return
    sequels = (raw_sequels["sequel"] if isinstance(raw_sequels["sequel"], list) else [
        raw_sequels["sequel"]]) if "sequel" in raw_sequels else []
    for sequel in sequels:
        if isinstance(sequel, dict) and "_name" in sequel:
            new_quest_with_sequels(sequel["_name"], new_quests, meta)


def new_quest_with_sequels(name: str, new_quests: list[dict[str, Any]], meta: dict[str, Any], force: bool = False) -> None:
    if name in [e['name'] for e in session['quests']]:
        print("sequel", name, "already in session quests")
    elif new_quests is not None and name in [e['name'] for e in new_quests]:
        print("sequel", name, "already in new quests")
    else:
        q = lookup_quest(name)
        if q is not None and (matches_requirement(q) or force):
            print("Activating sequel", name)
            new_sequel_quest = new_quest(q)
            new_quests.append(new_sequel_quest)
            if new_sequel_quest["complete"]:
                print("Sequel quest precompleted", name)
                do_quest_rewards(q, meta)
                activate_sequels(new_sequel_quest, new_quests, meta)
                activate_unlocked_quests(new_quests, meta)
        else:
            print("Deferring sequel", name, "due to requirements")


def _quest_date_key(q: dict[str, Any]) -> tuple[int, int, int]:
    req = q.get("requiredDate")
    start = req.get("_start", "0/0/0") if isinstance(req, dict) else "0/0/0"
    parts = start.split("/")
    try:
        month = int(parts[0]) if len(parts) > 0 else 0
        day = int(parts[1]) if len(parts) > 1 else 0
        year = int(parts[2]) if len(parts) > 2 else 0
        return (year, month, day)
    except (ValueError, IndexError):
        return (0, 0, 0)


def activate_unlocked_quests(new_quests: list[dict[str, Any]], meta: dict[str, Any]) -> None:
    open_quests = [e["name"] for e in session["quests"] if not e["complete"]]
    if len(open_quests) <= 20:
        completed_quests = [e["name"] for e in session["quests"] if e["complete"]]
        quests = [e["name"] for e in session["quests"]]
        sc = 0
        quest_selection: list[dict[str, Any]] = []
        for s, p in prequels.items():
            if s not in quests and (not p or any(v in completed_quests for v in p)):
                quest = lookup_quest(s)
                if quest is not None and matches_requirement(quest):
                    print(repr(quest))
                    quest_selection.append(quest)

        quest_selection.sort(key=lambda q: (int(q.get("_priority", "1000") or 1000), _quest_date_key(q)))
        for quest in quest_selection:
            if len(open_quests) + sc > 20:  # todo make selection?
                print("Skipping " + quest["_name"] + " too many open quests")
            else:
                new_quest_with_sequels(quest["_name"], new_quests, meta)
                sc += 1
        print('Unlocked new quests', sc)
    else:
        print("No unlock quests because there are too many open quests")


def matches_requirement(quest: dict[str, Any] | None) -> bool:
    if quest is None:
        return False
    user_info = session.get('user_object', {}).get("userInfo", {})
    player = user_info.get("player", {})
    level = player.get("level", 1)
    experiments = session.get('user_object', {}).get("experiments", {})

    requires = quest.get("requires")
    if requires is not None:
        if requires.get('_type') != 'level':
            return False
        try:
            if int(requires.get('_count', 0)) > level:
                return False
        except (ValueError, TypeError):
            return False

    exp_needed = quest.get("_activateExperimentNeeded")
    if exp_needed:
        if exp_needed not in experiments:
            return False
        variants = quest.get("_activateExperimentVariants", "").split(",")
        if str(experiments[exp_needed]) not in variants:
            return False

    return not quest.get("_name", "").startswith("QFD")

#TODO or (quest['_questTree'] =='level' and quest['_questTree'] ???


# def autoclick_next_state(state_machine, next_click_state):
#     while '-autoNext' in next_click_state and next_click_state['-stateName'] != next_click_state[
#         '-autoNext']:  # '-clientDuration': '2.0s', '-duration': '0' respect duration for harvest?
#         next_state_id = next_click_state['-autoNext']  # not all states have this!! end states? autostate after time?
#         next_click_state = lookup_state(state_machine, next_state_id)
#         print("auto_next_state:", repr(next_click_state))


def do_quest_rewards(quest: dict[str, Any], meta: dict[str, Any]) -> None:
    # TODO: rewardModifier
    # 22 of the shipped quests carry no 'reward' key at all. Reading it
    # unconditionally raised KeyError('reward') -- after the quest had already
    # been marked complete, so the player got a 500 and kept the quest.
    raw_rewards = quest.get('reward') or []
    do_rewards("Quest", raw_rewards, meta)


def do_rewards(label: str, raw_rewards: Any, meta: dict[str, Any], inc_modifier: Callable[[int], int] = lambda a: a, item_modifier: Callable[[int], int] = lambda a: a) -> None:
    rewards = simple_list(raw_rewards)
    inc = {r.get("_type", r.get("-type")): inc_modifier(int(r.get('_count', r.get('-count', 1)))) for r in rewards if r.get("_type") != "item" and r.get("-type") != "item"}
    items = {r.get("_item", r.get("-item")): item_modifier(int(r.get('_count', r.get('-count', 1)))) for r in rewards if r.get("_type") == "item" or r.get("-type") == "item"}

    player = session['user_object']["userInfo"]["player"]
    player['energy'] += int(inc.get('energy', 0))
    player['xp'] += int(inc.get('xp', 0))


    player['cash'] += int(inc.get('cash', 0))
    player['socialXpGood'] += int(inc.get('socialXpGood', 0))
    player['socialXpBad'] += int(inc.get('socialXpBad', 0))

    world = session['user_object']["userInfo"]["world"]
    resources = world['resources']
    resources['coins'] += int(inc.get('coins', 0))
    # Energy is *not* mirrored into world['resources'].
    #
    # It used to be, here and in five other places, each carrying a question
    # nobody had answered -- `#which one?`, `# needed?`. The two counters
    # diverged (a save read 27 on the player and 10 in the world) and the
    # client only ever reads the player's: `init_user` sends `player["energy"]`
    # and `RESOURCE_ORDER` does not include energy, so nothing shows the other
    # one to anyone. Maintaining it was duplicated state -- a second answer to a
    # question that already had one, free to drift.
    #
    # `player['energy']` is the number of record, and it is an integer: a
    # resource that accumulates by `+=` must not end up as 27.0.
    resources['oil'] += int(inc.get('oil', 0))
    resources['wood'] += int(inc.get('wood', 0))

    resource_order = world['resourceOrder']
    resources[resource_order[0]] += int(inc.get('rare', 0))
    resources[resource_order[0]] += int(inc.get('nrare0', 0))
    resources[resource_order[1]] += int(inc.get('nrare1', 0))
    resources[resource_order[2]] += int(inc.get('nrare2', 0))
    resources[resource_order[3]] += int(inc.get('nrare3', 0))
    resources[resource_order[4]] += int(inc.get('nrare4', 0))

    level_cash = 0
    levels_count = 0
    levels = [level for level in game_settings['settings']['levels']['level'] if int(level["-num"]) > player['level'] and int(level["-requiredXP"]) <= player['xp']    ]
    for level in levels:
        matching_caps = [e.get('-cap') for e in game_settings.get('settings', {}).get('energycaps', {}).get('energycap', []) if e.get('-level') == level.get("-num")]
        energy_cap = matching_caps[0] if matching_caps else player.get('energyMax', 50)
        print("Level increased to", level["-num"], "New energy:", energy_cap)
        player['level'] = int(level["-num"])
        player['energy'] = int(energy_cap)
        player['energyMax'] = int(energy_cap)
        levels_count += 1
        if "reward" in level and level["reward"]["-type"] == "cash":
            player['cash'] += int(level["reward"]["-count"])
            level_cash += int(level["reward"]["-count"])
        create_backup("Level " + level["-num"])

    if inc:
        print(label, "rewards:", ", ".join(
            [label + " " + ("+" if int(increment) > 0 else "") + str(increment) + " (" + str(total) + ")" for
             (label, increment, total)
             in
             [("xp:", inc.get('xp', 0), player['xp']),
              ("energy:", inc.get('energy', 0), player['energy']),
              ("coins:", inc.get('coins', 0), resources['coins']),
              ("oil:", inc.get('oil', 0), resources['oil']),
              ("wood:", inc.get('wood', 0), resources['wood']),
              ("cash:", inc.get('cash', 0), player['cash']),
              ("cash (level):", level_cash, player['cash']),
              ("levels:", levels_count, player['level']),
              ("socialXpGood:", inc.get('socialXpGood', 0), player['socialXpGood']),
              ("socialXpBad:", inc.get('socialXpBad', 0), player['socialXpBad']),
              (resource_order[0] + ":", inc.get('rare', 0), resources[resource_order[0]]),
              (resource_order[0] + ":", inc.get('nrare0', 0), resources[resource_order[0]]),
              (resource_order[1] + ":", inc.get('nrare1', 0), resources[resource_order[1]]),
              (resource_order[2] + ":", inc.get('nrare2', 0), resources[resource_order[2]]),
              (resource_order[3] + ":", inc.get('nrare3', 0), resources[resource_order[3]]),
              (resource_order[4] + ":", inc.get('nrare4', 0), resources[resource_order[4]])
              ] if int(increment) != 0]))

    if items:
        item_inventory = session['user_object']["userInfo"]["player"]["inventory"]["items"]
        for k,v in items.items():
            item_inventory[k] = item_inventory.get(k, 0) + v
        print(label, "item rewards:", ", ".join([ k + ": " + str(v) for k,v in items.items()]))
    handle_quest_progress(meta, progress_resource_added_count(inc, ""))
    if levels:
        new_quests = []
        if "QuestComponent" not in meta:
            meta['QuestComponent'] = []
        activate_unlocked_quests(new_quests, meta)
        merge_quest_progress(new_quests, meta['QuestComponent'], "output quest")
        merge_quest_progress(new_quests, session['quests'], "session quest")


def roll_random() -> int:
    world = session['user_object']["userInfo"]["world"]
    world.setdefault("randSeedZ", 7549)
    world.setdefault("randSeedW", 484584)
    prev_seed = str(world["randSeedW"]) + ', ' +  str(world["randSeedZ"])
    world["randSeedZ"] = 36969 * (world["randSeedZ"] & 65535)  + (world["randSeedZ"] >> 16 & 65535) & 4294967295
    world["randSeedW"] = 18000 * (world["randSeedW"] & 65535)  + (world["randSeedW"] >> 16 & 65535) & 4294967295
    print("Seed", prev_seed, "=>", str(world["randSeedW"]) + ', ' + str(world["randSeedZ"]))
    return (world["randSeedZ"] << 16) +  world["randSeedW"] & 4294967295


def roll_random_float() -> float:
    number = roll_random() / (2 ** 32 - 1)
    number_ = math.floor(number * 10 ** 3) / 10 ** 3
    print("random float", number_)
    return number_


def roll_random_between(a: float, b: float) -> float:
    f = roll_random_float() * (b - a) + a
    print("random between", a ,"and", b, "=", f)
    return f


def get_seed_w() -> int:
    world = session.get('user_object', {}).get("userInfo", {}).get("world", {})
    return world.get("randSeedW", 484584)


def get_seed_z() -> int:
    world = session.get('user_object', {}).get("userInfo", {}).get("world", {})
    return world.get("randSeedZ", 7549)



def roll_reward_random() -> int:
    world = session['user_object']["userInfo"]["world"]
    world.setdefault("rewardRandSeedZ", 7549)
    world.setdefault("rewardRandSeedW", 484584)
    world["rewardRandSeedZ"] = 36969 * (world["rewardRandSeedZ"] & 65535)  + (world["rewardRandSeedZ"] >> 16 & 65535) & 4294967295
    world["rewardRandSeedW"] = 18000 * (world["rewardRandSeedW"] & 65535)  + (world["rewardRandSeedW"] >> 16 & 65535) & 4294967295
    print( (world["rewardRandSeedZ"] << 16) +  world["rewardRandSeedW"] & 4294967295)
    return (world["rewardRandSeedZ"] << 16) +  world["rewardRandSeedW"] & 4294967295


def roll_reward_random_float() -> float:
    number = roll_reward_random() / (2 ** 32 - 1)
    return math.floor(number * 10 ** 3) / 10 ** 3


def roll_reward_random_between(a: float, b: float) -> float:
    return roll_reward_random_float() * (b - a) + a



def progress_harvest_consumable(state: Any, state_machine: Any, game_item: dict[str, Any], step: str, previous_state: Any, reference_item: str | None, previous_reference_item: str | None, *state_args: Any) -> Predicate:
    return lambda task, progress, i, *args: \
        task["_action"] == "inventoryAdded" and state.get("-harvestingState") == "1" and reference_item is not None and (
                progress_parameter_implies("_type", lookup_item_by_code(reference_item.split(":")[0]).get("-type",""))(task, progress, i, *args) and \
                progress_parameter_implies("_subtype", lookup_item_by_code(reference_item.split(":")[0]).get("-subtype",""))(task, progress, i, *args) and \
                progress_parameter_implies_contains("_item", reference_item.split(":")[0])(task, progress, i, *args)) \



def progress_buy_consumable(item: dict[str, Any] | None) -> Predicate:
    return lambda task, progress, i, *args: \
        task["_action"] == "inventoryAdded" and item is not None and \
        progress_parameter_implies("_type", item.get("-type", ""))(task, progress, i, *args) and \
        progress_parameter_implies("_subtype", item.get("-subtype", ""))(task, progress, i, *args) and \
        progress_parameter_implies_contains("_item", item["-code"])(task, progress, i, *args)


def progress_gifted_parts(item: dict[str, Any] | None, count: int | str) -> Predicate:
    return lambda task, progress, i, extra, *args: \
        task["_action"] == "inventoryAdded" and item is not None and \
        progress_parameter_implies("_type", item.get("-type", ""))(task, progress, i, *args) and \
        progress_parameter_implies("_subtype", item.get("-subtype", ""))(task, progress, i, *args) and \
        progress_parameter_implies_contains("_item", item["-code"])(task, progress, i, *args) and \
        progress_yield_amount(count, task["_total"], extra, progress)


def progress_useAOA_consumable(item: dict[str, Any] | None) -> Predicate:
    return lambda task, progress, i, *args: \
        task["_action"] == "useConsumable" and task.get("_neighbor") == "true" and item is not None and \
        progress_parameter_implies("_type", item.get("-type", ""))(task, progress, i, *args) and \
        progress_parameter_implies("_subtype", item.get("-subtype", ""))(task, progress, i, *args) and \
        progress_parameter_implies_contains("_item", item["-code"])(task, progress, i, *args)



def progress_useGeneral_consumable(item: dict[str, Any] | None, enemy_turn: bool) -> Callable[..., bool]: #DONT USE THIS FUNCTION FOR SOMETHING ELSE
    if not enemy_turn and item is not None:
        user_info = session.get('user_object', {}).get("userInfo", {})
        player = user_info.get("player", {})
        inventory = player.get("inventory", {})
        item_inventory = inventory.get("items", {}) if isinstance(inventory, dict) else {}
        if item.get("-subtype") == "secondary":
            mana = player.get("mana")
            if isinstance(mana, dict) and "consumable" in item and "-mana" in item["consumable"]:
                with contextlib.suppress(ValueError, TypeError):
                    mana["value"] = max(0, int(mana.get("value", 0)) - int(item["consumable"]["-mana"]))
        elif player.get("tutorialProgress") not in ("tut_step_powerUpPowerUsed", "tut_step_powerUpPowerSelected"):
            code = item.get("-code")
            if code and isinstance(item_inventory, dict):
                item_inventory[code] = max(0, item_inventory.get(code, 0) - 1)
    return lambda task, progress, i, *args: \
        task["_action"] == "useConsumable"  and item is not None and not enemy_turn and \
        progress_parameter_implies("_type", item.get("-type", ""))(task, progress, i, *args) and \
        progress_parameter_implies("_subtype", item.get("-subtype", ""))(task, progress, i, *args) and \
        progress_parameter_implies_contains("_item", item["-code"])(task, progress, i, *args)

