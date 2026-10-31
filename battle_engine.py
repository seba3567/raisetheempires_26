from __future__ import annotations

import math
from typing import Any

import msgspec
from flask import session

from game_settings import game_settings, get_zid, lookup_item_by_code, lookup_items_by_type_and_subtype
from logger import report_battle_log
from quest_engine import (
    all_lambda,
    do_rewards,
    get_seed_w,
    get_seed_z,
    get_tasks,
    handle_quest_progress,
    lookup_quest,
    progress_action,
    progress_battle_damage_count,
    progress_parameter_equals,
    progress_parameter_implies,
    progress_useAOA_consumable,
    progress_useGeneral_consumable,
    roll_random_between,
    roll_random_float,
    roll_reward_random_float,
    simple_list,
)
from save_engine import ensure_fleets, get_save_by_uid, get_saves, logger, store_session
from save_store import save_invaders


class StaleBattleReference(Exception):
    """Raised when a request references a fleet/battle the server no longer has
    (e.g. a queued client request replayed after the battle/session was reset)."""


def battle_complete_response(params: dict[str, Any]) -> dict[str, Any]:
    friendlies, friendly_strengths, baddies, baddie_strengths, active_consumables = init_battle(params)
    meta = {"newPVE": 0}

    raw_id = params.get('id')
    target_ids: list[int] = []
    if isinstance(raw_id, (list, tuple)):
        try:
            target_ids = [int(x) for x in raw_id if x is not None]
        except (ValueError, TypeError):
            target_ids = []
    elif isinstance(raw_id, dict):
        try:
            sorted_keys = sorted(
                raw_id.keys(),
                key=lambda k: int(k) if str(k).isdigit() else 999
            )
            target_ids = [
                int(raw_id[k]) for k in sorted_keys
                if raw_id[k] is not None and str(k).isdigit()
            ]
        except (ValueError, TypeError):
            target_ids = []

    if len(target_ids) >= 2:
        player_unit_id, enemy_unit_id = target_ids[0], target_ids[1]
        player_turn = True
    else:
        player_turn = False
        attack_res = ai_best_attack(friendlies, friendly_strengths, baddies, baddie_strengths, active_consumables)
        enemy_unit_id, _, player_unit_id = attack_res if attack_res else (None, 0, None)

    if (
        enemy_unit_id is not None
        and player_unit_id is not None
        and 0 <= enemy_unit_id < len(baddies)
        and 0 <= player_unit_id < len(friendlies)
        # These two bounds are the ones that were missing, and they are why
        # log.txt carried 26 IndexErrors out of this function.
        #
        # ``init_battle`` rebuilds the unit lists from the fleet on every turn,
        # but the strength lists come out of ``session["battle"]``, which survives
        # between turns. So a reinforcement landing, an allied fleet joining, or
        # an admin editing the save mid-battle leaves the two disagreeing -- and
        # the client then sends a unit id that is perfectly valid against
        # ``friendlies`` and out of range for ``friendly_strengths``.
        #
        # The check further down that does look at the strength lists runs after
        # the damage has been computed, so it never saw this: the body below
        # indexes the strengths with the very id the bounds above just approved
        # against a different list. Failing the guard here instead sends the turn
        # down the re-pick branch, which is the same graceful answer the stale
        # unit id gets.
        and 0 <= enemy_unit_id < len(baddie_strengths)
        and 0 <= player_unit_id < len(friendly_strengths)
    ):
        ally_target = ("ally", player_unit_id)
        enemy_target = ("enemy", enemy_unit_id)
        first_target = ally_target if player_turn else enemy_target
        second_target = enemy_target if player_turn else ally_target

        # print("repr baddies", baddies)
        baddie_max_strength = get_unit_max_strength(baddies[enemy_unit_id], False, params)
        baddie_weak = get_unit_weak(baddies[enemy_unit_id])
        baddie_unit_type = get_unit_type(baddies[enemy_unit_id])

        friendly_max_strength = get_unit_max_strength(friendlies[player_unit_id], True)
        friendly_weak = get_unit_weak(friendlies[player_unit_id])
        friendly_unit_type = get_unit_type(friendlies[player_unit_id])

        friendly_strength = friendly_strengths[player_unit_id]
        baddie_strength = baddie_strengths[enemy_unit_id]

        init_seed = ["init seed", get_seed_w(), get_seed_z()]
        roll = unit_roll(friendly_weak if player_turn else baddie_weak, baddie_weak if player_turn else friendly_weak)

        crit, direct = get_hit_value(friendly_unit_type if player_turn else baddie_unit_type, baddie_unit_type if player_turn else friendly_unit_type)
        if player_turn:
            crit, direct = handle_accurancy_upgrades(crit, direct, friendlies, player_unit_id)

        accuracy = (get_consumable_accuracy(first_target, active_consumables) - get_consumable_evasion(second_target, active_consumables)) * 0.01
        crit -= accuracy
        direct -= accuracy

        hit = roll >= direct

        base_damage = 25 # TODO tier difference & increments

        if player_turn:
            damage = base_damage * (3 * friendly_max_strength + baddie_strength) / (3 * baddie_strength + friendly_max_strength)
            damage = damage / 100 * baddie_max_strength
        else:
            damage = base_damage * (3 * baddie_max_strength + friendly_strength) / (3 * friendly_strength + baddie_max_strength)
            damage = damage / 100 * friendly_max_strength


        consumable_extra_damage = \
            get_consumable_damage(first_target, active_consumables) - \
            get_consumable_shield(second_target, active_consumables)
        damage += max(consumable_extra_damage, -damage) # can't get negative damage by shield

        if consumable_extra_damage:
            print("Consumable extra damage", max(consumable_extra_damage, -damage))

        if player_turn:
            damage = handle_damage_upgrades(damage, friendlies, player_unit_id)

        damage = math.floor(damage * 10 ** 3) / 10 ** 3

        glance = 0.10
        critter = 1.5

        hit_type = "directhit"

        if not hit:
            damage *= glance
            hit_type = "glancinghit"
        elif roll != 2 and roll >= crit:
            damage *= critter
            hit_type = "criticalhit"

        damage = math.ceil(damage)

        if player_turn:
            baddie_strengths[enemy_unit_id] -= damage
            if baddie_strengths[enemy_unit_id] == 1:
                damage +=1
                baddie_strengths[enemy_unit_id] -= 1
                print("Enemy inced to prevent 1 strength")
            if baddie_strengths[enemy_unit_id] <= 0:
                baddie_strengths[enemy_unit_id] = 0 #dead
                print("Enemy unit", enemy_unit_id, "down")
                hit_type = "kill" if hit_type != "criticalhit" else "criticalkill"
                handle_quest_progress(meta, progress_battle_damage_count("battleKill", 1, friendlies[player_unit_id], baddies[enemy_unit_id]))
                # session["battle"] = None
            print("Attacking for", damage , "damage, enemy hp:", baddie_strengths[enemy_unit_id], roll, "after seed", get_seed_w(),get_seed_z(), repr(init_seed))
            doBattleRewards(hit_type, baddie_max_strength, damage, friendly_max_strength)
            handle_quest_progress(meta, progress_battle_damage_count("battleDamage", damage, friendlies[player_unit_id], baddies[enemy_unit_id]))

        elif damage > 0 and is_shielded(ally_target, active_consumables):
            consume_shield(ally_target, active_consumables)

        else:
            friendly_strengths[player_unit_id] -= damage
            if friendly_strengths[player_unit_id] <= 0:
                friendly_strengths[player_unit_id] = 0  # dead
                print("Player unit", player_unit_id, "down")
                # session["battle"] = None
            print("Taken", damage, "damage, player hp:", friendly_strengths[player_unit_id], roll, "after seed", get_seed_w(),get_seed_z(), repr(init_seed))
    else:
        print("Stun skipped turn")
        player_unit_id = next((i for strength, i in zip(friendly_strengths,range(len(friendly_strengths))) if strength > 0), None)
        enemy_unit_id = next((i for strength, i in zip(baddie_strengths,range(len(baddie_strengths))) if strength > 0), None)
        ally_target = ("ally", player_unit_id)
        roll = 0

    # The re-pick above is the second way to end up without a usable unit, and
    # it is the one that used to crash: `next(...)` yields None when nothing is
    # left standing, and the `result` dict indexes both strength lists with
    # whatever came back. That raised TypeError rather than IndexError, and the
    # gateway only catches (StaleBattleReference, IndexError) -- so a finished
    # battle took the request down instead of answering it.
    if (
        player_unit_id is None
        or enemy_unit_id is None
        or not (0 <= enemy_unit_id < len(baddie_strengths))
        or not (0 <= player_unit_id < len(friendly_strengths))
    ):
        print("Battle has no units left to resolve:", player_unit_id, enemy_unit_id)
        raise StaleBattleReference("resolveBattle with no live units")

    result = {"attackerStunned": None, "psh": 1 if is_shielded(ally_target, active_consumables) else 0, "esh": 0, "ps": friendly_strengths[player_unit_id], "es": baddie_strengths[enemy_unit_id], "hv": None, "ur": roll,
     "playerUnit": player_unit_id, "enemyUnit": enemy_unit_id, "seeds": {"w": get_seed_w(), "z": get_seed_z()},
     "energy": None}

    process_consumable_end_turn(active_consumables, baddie_strengths, friendly_strengths, player_turn)
    handle_win(baddie_strengths, meta, params, friendlies, friendly_strengths)
    handle_loss(friendly_strengths)

    report_battle_log(friendly_strengths, baddie_strengths, player_turn, player_unit_id, enemy_unit_id, active_consumables)
    if not player_turn:
        consume_consumables(active_consumables)
    battle_complete_response = {"errorType": 0, "userId": 1, "metadata": meta, "data": result}
    return battle_complete_response

#             "-disable": "stun",
# "-attack": "-99", accurancy debuff
# "-attack": "99",  buff accurancy
# "-shield": "5", BuffHunkerDown
#              "-defend": "99", BuffEvasive
# "-dot": "5" , PoisonGas

def process_consumable_end_turn(active_consumables, baddie_strengths, friendly_strengths, player_turn):
    for consumable_tuple in active_consumables:
        (consumable, target, _tries) = consumable_tuple

        if not player_turn: # enemy dot after enemy turn
            if target[0] == "enemy" and target[1] is None:
                # apply to all baddies
                for selected_baddie in range(len(baddie_strengths)):
                    apply_dot_damage(consumable, selected_baddie, baddie_strengths, "Baddie")
            elif target[0] == "enemy":
                # apply to target[1]
                apply_dot_damage(consumable, target[1], baddie_strengths, "Baddie")
        else: # player dot after player turn
            if target[0] == "ally" and target[1] is None:
                for selected_friendly in range(len(friendly_strengths)):
                    apply_dot_damage(consumable, selected_friendly, friendly_strengths, "Friendly")
            elif target[0] == "ally":  #if  target[0] == "ally":
                apply_dot_damage(consumable, target[1], friendly_strengths, "Friendly")

    # active_consumables[:] = [(consumable, target, tries - (1 if is_consumable_for_turn(target, player_turn) else 0)) for consumable, target, tries
    #                          in active_consumables if tries > (1 if is_consumable_for_turn(target, player_turn) else 0)]


def consume_consumables(active_consumables):
    active_consumables[:] = [(consumable, target, tries - 1) for consumable, target, tries
                             in active_consumables if tries > 1]



def is_consumable_for_turn(target, player_turn):
    return (target[0] == "ally" and player_turn) or (target[0] in ["enemy", "AI"] and not player_turn)


def apply_dot_damage(consumable: dict[str, Any], selected_unit: int | None, strengths: list[int], target_description: str) -> None:
    if selected_unit is None or not (0 <= selected_unit < len(strengths)):
        return
    dot_damage = int(consumable.get("consumable", {}).get("-dot", "0"))
    if dot_damage:
        print("Applying", dot_damage, "damage over time")
        if strengths[selected_unit] > 0:
            strengths[selected_unit] = max(0, strengths[selected_unit] - dot_damage)
            print(target_description, selected_unit, "strength", strengths[selected_unit])
            if strengths[selected_unit] == 0:
                print(target_description, selected_unit, "down by consumable")


def handle_loss(friendly_strengths):
    if sum(friendly_strengths) == 0:
        print("Player defeated")
        session["battle"] = None


def handle_win(baddie_strengths, meta, params, friendlies, friendly_strengths):
    if sum(baddie_strengths) == 0:
        print("Enemy defeated")
        battle_ctx = session.get("battle")
        session["last_battle"] = battle_ctx

        replaying = False
        battle_island = None
        if isinstance(battle_ctx, (list, tuple)) and len(battle_ctx) > 3 and battle_ctx[3] is not None:
            replaying = bool(getattr(battle_ctx[3], "replaying", False))
            battle_island = getattr(battle_ctx[3], "island", None)

        handle_quest_progress(meta, all_lambda(progress_action("fight"),
                                               progress_parameter_implies("_fleetname", params.get("target"))))
        map_name, current_island, map_item = get_current_island(params)

        if replaying:
            current_island = battle_island
        if current_island is not None:
            handle_quest_progress(meta, all_lambda(progress_action("islandWin"),
                                                   progress_parameter_equals("_island", str(current_island))))
            reward_multiplier = get_reward_multiplier()
            combat_replay_reward_minimum = 100# combatReplayRewardMinimum

            modifier = (lambda a: math.ceil(
                a * reward_multiplier if a <= combat_replay_reward_minimum else max(a * reward_multiplier,
                                                                                    combat_replay_reward_minimum))) if replaying else lambda a: a
            item_modifier = (lambda a: 0) if replaying else lambda a: a
            if map_item and 'island' in map_item and current_island < len(map_item['island']):
                do_rewards("Campaign", map_item['island'][current_island].get("reward"), meta, inc_modifier=modifier, item_modifier=item_modifier)
            if not replaying:
                do_rewards("Liberty Bond", {"_type": "item", "_item": "xk01", "_count": "1"}, meta)

            if not replaying:
                if map_item and 'island' in map_item and current_island < len(map_item['island']):
                    next_island_id = map_item['island'][current_island].get('-unlocks')
                    if next_island_id is not None:
                        print("Activating next island", map_name, next_island_id)
                        set_active_island_by_map(map_name, int(next_island_id))
                    else:
                        print("Current island group finished", map_name)
                        set_active_island_by_map(map_name, len(map_item['island']))
                        next_map_code = map_item.get('-unlocks') or map_item.get('unlocks')
                        if next_map_code:
                            world = session.get('user_object', {}).get('userInfo', {}).get('world', {})
                            campaign = world.setdefault('campaign', {})
                            active_maps = campaign.setdefault('active', {})
                            if next_map_code not in active_maps:
                                print("Unlocking next campaign map:", next_map_code)
                                active_maps[next_map_code] = {"status": 0, "fleets": []}
            else:
                print("Currently replaying no island activation needed")
            tokens_before = get_min_island_mastery_from_battle()
            increment_mastery()
            tokens_after = get_min_island_mastery_from_battle()
            if tokens_after > tokens_before:
                do_rewards("Mastery Token", {"_type": "item", "_item": "VTK", "_count": "1"}, meta)

        elif "attackHostId" in params:
            print("challenge won")
            invasion_complete(params["attackHostId"], params, friendlies, friendly_strengths)
        elif params.get('target') == "FleetName":
            fleets = session.get("fleets", {})
            if "FleetName" in fleets and isinstance(fleets["FleetName"], dict):
                if fleets["FleetName"].get("invaded_uid"):
                    print("neighbor repel won")
                    neighbor_repelled(fleets["FleetName"])
                elif fleets["FleetName"].get("status") == 4096:
                    print("survival won")
                else:
                    print("repel won")
                    pvp_invaders = session.get('user_object', {}).get("pvp", {}).get("invaders", {})
                    invader_key = "u" + str(fleets["FleetName"].get("uid", ""))
                    pvp_invaders.pop(invader_key, None)
        elif params.get('name') == "FleetName":
            fleets = session.get("fleets", {})
            fleet_matches = [(k, v) for k, v in fleets.items() if isinstance(v, dict) and v.get('name') == "FleetName"]
            if fleet_matches:
                _fleet_name, enemy_fleet = fleet_matches[0]
                if enemy_fleet.get("invader"):
                    if enemy_fleet.get("invaded_uid"):
                        print("neighbor repel with consumable won")
                        neighbor_repelled(enemy_fleet)
                    elif fleets.get("FleetName", {}).get("status") == 4096:
                        print("survival with consumable won")
                    else:
                        print("repel with consumable won")
                        pvp_invaders = session.get('user_object', {}).get("pvp", {}).get("invaders", {})
                        pvp_invaders.pop("u" + str(enemy_fleet.get('uid', "")), None)
                else:
                    print("challenge with consumable won")
                    invasion_complete(enemy_fleet.get('uid'), params, friendlies, friendly_strengths)
        session["battle"] = None


def neighbor_repelled(enemy_fleet):
    """The defender learns somebody knocked the invader off their island.

    Looks the defender up by uid, which is an indexed column. It used to read
    every save in the database and compare the uid in each -- deserialising
    every empire on the server to find one.
    """
    save = get_save_by_uid(enemy_fleet.get("invaded_uid"))
    if save is None:
        print("WARNING: no save for the repelled defender",
              enemy_fleet.get("invaded_uid"))
        return
    # The invader's entry is created when the invasion starts, but it can be
    # gone: the invasion was withdrawn, the save was restored from a backup,
    # or the save has no pvp section at all. Indexing it unconditionally
    # raised KeyError -- after the battle was already decided -- and the
    # gateway turned that into a dummy response, so the client never learned
    # it had won.
    invaders = save['user_object'].setdefault("pvp", {}).setdefault("invaders", {})
    invader = invaders.setdefault("u" + str(enemy_fleet.get("uid")), {})
    invader["dID"] = get_zid()
    store_session(save)


def invasion_complete(enemy_fleet_uid, params, friendlies, friendly_strengths):
    """The defender's save records that the invasion is over."""
    save = get_save_by_uid(enemy_fleet_uid)
    if save is None:
        print("WARNING: no save to mark the invasion complete for", enemy_fleet_uid)
        return
    # As above: the record can be missing, and the battle has already been
    # won by the time this runs. A KeyError here voided the whole turn.
    invaders = save['user_object'].setdefault("pvp", {}).setdefault("invaders", {})
    invader = invaders.setdefault("u" + str(get_zid()), {})
    invader["status"] = 2
    invader["attacker_fleet"] = [format_player_fleet(friendlies[i]["-code"]) for i in get_alive_unit_index(friendly_strengths)]
    store_session(save)


def cancel_unstarted_invasions():
    """Withdraw any invasion the defender has not answered yet.

    This one is a sweep over every player by nature -- there is no "this one
    uid" to look up, it is "whoever has me pending" -- so it keeps reading them
    all. It does get the guarded write from store_session now.
    """
    for save in get_saves():
        invaders = save_invaders(save)
        if invaders.get("u" + str(get_zid()), {}).get("status") == 1:
            del invaders["u" + str(get_zid())]
            store_session(save)


def get_next_fleet(fleet_name):
    return session['fleets'][get_next_fleet_name(fleet_name)]


def handle_damage_upgrades(damage, friendlies, player_unit_id):
    research = session.get('user_object', {}).get("userInfo", {}).get("world", {}).get("research", {})
    upgrades = research.get(friendlies[player_unit_id]["-code"], [])
    for upgrade in upgrades:
        upgrade_item = lookup_item_by_code(upgrade)
        mod_damage = upgrade_item.get("modifier", {}).get("-damage")
        if mod_damage:
            if upgrade_item["modifier"].get("-percent"):
                damage *= 1 + float(mod_damage) / 100
                print("Applying damage upgrade for", mod_damage, "percent")
            else:
                damage += int(mod_damage)
                print("Applying damage upgrade for", mod_damage, "more")
    return damage


def handle_accurancy_upgrades(crit, direct, friendlies, player_unit_id):
    research = session.get('user_object', {}).get("userInfo", {}).get("world", {}).get("research", {})
    upgrades = research.get(friendlies[player_unit_id]["-code"], [])
    for upgrade in upgrades:
        upgrade_item = lookup_item_by_code(upgrade)
        mod_accuracy = upgrade_item.get("modifier", {}).get("-accuracy")
        if mod_accuracy:
            crit -= float(mod_accuracy) / 100
            direct -= float(mod_accuracy) / 100
            print("Applying hit chance upgrade for", mod_accuracy, "percent")

    return crit, direct


def handle_strength_upgrades(strength, unit):
    research = session.get('user_object', {}).get("userInfo", {}).get("world", {}).get("research", {})
    upgrades = research.get(unit["-code"], [])
    for upgrade in upgrades:
        upgrade_item = lookup_item_by_code(upgrade)
        mod_damage = upgrade_item.get("modifier", {}).get("-strength")
        if mod_damage:
            if upgrade_item["modifier"].get("-percent"):
                strength *= 1 + float(mod_damage) / 100
                print("Applying strength upgrade for", mod_damage, "percent")
            else:
                strength += int(mod_damage)
                print("Applying strength upgrade for", mod_damage, "more")
    return strength


def handle_shield_upgrades(friendlies, player_unit_id):
    research = session.get('user_object', {}).get("userInfo", {}).get("world", {}).get("research", {})
    upgrades = research.get(friendlies[player_unit_id]["-code"], [])
    for upgrade in upgrades:
        upgrade_item = lookup_item_by_code(upgrade)
        mod_shield = upgrade_item.get("modifier", {}).get("-shields")
        if mod_shield:
            return True
    return False


def init_battle(params):
    try:
        if 'target' not in params:
            fleet_or_name = params['fleet'] if params['fleet'] else params['name']
            if params.get("name") == "AI":
                if params['map'] is not None:
                    future_enemy_fleet = get_new_enemy_fleet_name()
                    friendlies_fleet_name = get_previous_fleet_name(get_previous_fleet_name(get_previous_fleet_name(future_enemy_fleet)))
                    baddies_fleet_name = get_previous_fleet_name(get_previous_fleet_name(future_enemy_fleet))
                    if friendlies_fleet_name not in session['fleets'] or baddies_fleet_name not in session['fleets']:
                        raise StaleBattleReference(
                            f"AI consumable cast: computed fleet names {friendlies_fleet_name!r}/"
                            f"{baddies_fleet_name!r} not in session (fleet-numbering mismatch, "
                            f"e.g. battle fleet {params.get('fleet')!r} uses a different sequence)")
                    friendlies = [lookup_item_by_code(friendly.split(',')[0]) for friendly in
                                  session['fleets'][friendlies_fleet_name]]
                    baddies = [lookup_item_by_code(baddy[1:]) for sub_fleet in
                               simple_list(session['fleets'][baddies_fleet_name])
                               for baddy, count in sub_fleet.items()
                               for i in range(int(count))]
                else:
                    [(_fleet_name, enemy_fleet)] = [(k, v) for k, v in session['fleets'].items() if
                                                   isinstance(v, dict) and v.get('name') == "FleetName"]
                    print("Survival AI fleet" if enemy_fleet["status"] == 4096 else "Invader AI fleet")
                    baddies = [lookup_item_by_code(baddy.split(',')[0])
                               for baddy in enemy_fleet["units"]]
                    friendlies = [lookup_item_by_code(friendly.split(',')[0]) for friendly in
                                  session['fleets'][get_last_fleet_name()]]
            elif params['name'] == "FleetName":
                print("Invader target consumable")
                [(_fleet_name, enemy_fleet)] = [(k, v) for k, v in session['fleets'].items() if isinstance(v, dict) and v.get('name') == "FleetName"]
                baddies = [lookup_item_by_code(baddy.split(',')[0])
                           for baddy in enemy_fleet["units"]]
                friendlies = [lookup_item_by_code(friendly.split(',')[0]) for friendly in
                              session['fleets'][get_last_fleet_name()]]
            elif fleet_or_name in session['fleets'] and isinstance(simple_list(session['fleets'][fleet_or_name])[0], str):
                print("Ally direct target")
                friendlies = [lookup_item_by_code(friendly.split(',')[0]) for friendly in
                              session['fleets'][fleet_or_name]]
                if get_next_fleet_name(fleet_or_name) not in session['fleets']:
                    baddies = [lookup_item_by_code(baddy.split(',')[0]) for sub_fleet in
                               simple_list(session['fleets']['FleetName'])
                               for baddy in sub_fleet["units"]]
                else:
                    baddies = [lookup_item_by_code(baddy[1:]) for sub_fleet in
                               simple_list(session['fleets'][get_next_fleet_name(fleet_or_name)])
                               for baddy, count in sub_fleet.items()
                               for i in range(int(count))]
            elif fleet_or_name in session['fleets']:
                baddies = [lookup_item_by_code(baddy[1:]) for sub_fleet in simple_list(session['fleets'][fleet_or_name])
                           for baddy, count in sub_fleet.items()
                           for i in range(int(count))]
                friendlies = [lookup_item_by_code(friendly.split(',')[0]) for friendly in
                              session['fleets'][get_previous_fleet_name(fleet_or_name)]]
            else:
                open_quests = [e["name"] for e in session["quests"] if not e["complete"]]
                task = None
                friendlies = None
                for q in open_quests:
                    quest = lookup_quest(q)
                    tasks = get_tasks(quest)
                    matching_tasks = [t for t in tasks if t["_action"] == "fight" and t.get("_fleetname") == params['fleet']]
                    if matching_tasks:
                        task = matching_tasks[0]
                        friendlies = [lookup_item_by_code(friendly.split(',')[0]) for friendly in
                                      session['fleets'][get_friendly_by_ally_fleet(params['name'])]]
                        break

                if task is None:
                    raise StaleBattleReference(
                        f"No open quest fight-task matches fleet {params.get('fleet')!r}")

                enemy_fleet = lookup_item_by_code(task["_item"])
                baddies = [lookup_item_by_code(baddie_slot["-item"]) for baddie_slot in simple_list(enemy_fleet["baddie"])]
                if not friendlies:
                    friendlies = [lookup_item_by_code(friendly[1:]) for friendly, count in task["fleet"].items() for i in
                                  range(int(count))]
        elif params['target'].startswith('fleet'):
            if params['target'] not in session['fleets'] or params['fleet'] not in session['fleets']:
                raise StaleBattleReference(
                    f"Fleet {params.get('target')!r} or {params.get('fleet')!r} no longer in session")
            baddies = [lookup_item_by_code(baddy[1:]) for sub_fleet in simple_list(session['fleets'][params['target']])
                       for baddy, count in sub_fleet.items()
                       for i in range(int(count))]
            friendlies = [lookup_item_by_code(friendly.split(',')[0]) for friendly in
                          session['fleets'][params['fleet']]]
        elif params['target'] == "FleetName":
            print("Invader target")
            baddies = [lookup_item_by_code(baddy.split(',')[0]) for sub_fleet in
                       simple_list(session['fleets']['FleetName'])
                       for baddy in sub_fleet["units"]]
            friendlies = [lookup_item_by_code(friendly.split(',')[0]) for friendly in
                          session['fleets'][params['fleet']]]
        else:
            open_quests = [e["name"] for e in session["quests"] if not e["complete"]]
            task = None
            friendlies = None
            for q in open_quests:
                quest = lookup_quest(q)
                tasks = get_tasks(quest)
                task = [t for t in tasks if t["_action"] == "fight" and t.get("_fleetname") == params['target']]
                if task:
                    task = task[0]
                    friendlies = [lookup_item_by_code(friendly.split(',')[0]) for friendly in
                                  session['fleets'][params['fleet']]]
                    break

            if not task:
                quest = lookup_quest(params['target'])
                tasks = get_tasks(quest)
                [task] = [t for t in tasks if t["_action"] == "fight"]

            enemy_fleet = lookup_item_by_code(task["_item"])
            baddies = [lookup_item_by_code(baddie_slot["-item"]) for baddie_slot in simple_list(enemy_fleet["baddie"])]
            if not friendlies:
                # The fleet the client named is the army it is drawing. If it
                # is in the registry, that is the fight.
                #
                # This used to ask only whether the registry was *not empty*,
                # and refuse the fight if it was. The fleet the client named
                # was right there in the registry -- the log said so, in the
                # same breath: "session has ['fleet1_2361750976462848']" --
                # and the fight was refused anyway, because nothing ever
                # looked the name up.
                #
                # The client got an empty answer instead of the battle, had no
                # `ps` to compare its own units against, and stopped with
                # "TResolveBattle: unit strength out of sync". The army was
                # there the whole time; it just was not the one being asked
                # for.
                #
                # `ensure_fleets`, not `session['fleets']`: a session can
                # arrive without the key at all, and the old direct index
                # raised KeyError on exactly the path this guard is about.
                known_fleets = ensure_fleets()
                named = known_fleets.get(params.get('fleet')) if params.get('fleet') else None
                if named and isinstance(simple_list(named)[0], str):
                    friendlies = [lookup_item_by_code(friendly.split(',')[0]) for friendly in
                                  named]
                elif known_fleets:
                    # The session knows about fleets, and this is not one of
                    # them. That is the state fault, not a loan: the client
                    # named a fleet it is drawing and we do not have it, so
                    # whatever we put here is a different army.
                    #
                    # The quest's troops are the right answer when the player
                    # has brought nobody -- `session['fleets']` empty means
                    # exactly that. When it is not empty, they brought someone
                    # and we lost them.
                    logger.error(
                        "Battle named fleet %r, which is not registered; "
                        "session has %s. The client is fighting units this "
                        "server does not have.",
                        params.get('fleet'), sorted(known_fleets))
                    raise StaleBattleReference(
                        f"fleet {params.get('fleet')!r} is not registered")
                else:
                    friendlies = [lookup_item_by_code(friendly[1:]) for friendly, count in task["fleet"].items() for i in
                                  range(int(count))]

        if not has_battle() or (session["battle"][0] is None and session["battle"][1] is None and session["battle"][2] is None):
            baddie_strengths = [get_unit_max_strength(baddie, False, params) for baddie in baddies]
            friendly_strengths = [get_unit_max_strength(friendly, True) for friendly in friendlies]
            active_consumables = []
            defenseshield_upgrade_activate(friendlies, active_consumables)
            session["battle"] = (friendly_strengths, baddie_strengths, active_consumables,
                                 BattleContext() if not has_battle() else session["battle"][3])
        else:
            (friendly_strengths, baddie_strengths, active_consumables, battle_context) = session["battle"]
            if baddie_strengths is None:  # survival mode
                baddie_strengths = [get_unit_max_strength(baddie, False, params) for baddie in baddies]
                active_consumables[:] = [(consumable, target, tries) for consumable, target, tries
                                         in active_consumables if target[0] == "ally"]
                session["battle"] = (friendly_strengths, baddie_strengths, active_consumables, battle_context)
            elif (len(friendly_strengths) != len(friendlies)
                    or len(baddie_strengths) != len(baddies)):
                # The stored strengths do not describe these units.
                #
                # The unit lists are rebuilt from the fleet on every call, but
                # the strengths come out of `session["battle"]`, which is
                # written once when the battle opens. A battle the player
                # walked away from leaves that entry behind, and the next one
                # -- with a different fleet -- picks it up and answers with
                # strengths for units that are no longer there. The client
                # compares the two and halts with "unit strength out of sync".
                #
                # Rebuilding is the honest answer: a strength belongs to the
                # unit it was measured for, so a unit that is not in this
                # battle cannot inherit one's strength.
                print("Battle strengths do not match the fleets; starting fresh:",
                      len(friendly_strengths), "!=", len(friendlies), "/",
                      len(baddie_strengths), "!=", len(baddies))
                baddie_strengths = [get_unit_max_strength(baddie, False, params)
                                    for baddie in baddies]
                friendly_strengths = [get_unit_max_strength(friendly, True)
                                      for friendly in friendlies]
                active_consumables = []
                defenseshield_upgrade_activate(friendlies, active_consumables)
                session["battle"] = (friendly_strengths, baddie_strengths,
                                     active_consumables, battle_context)
        return friendlies, friendly_strengths, baddies, baddie_strengths, active_consumables
    except Exception as ex:
        # requires python >=3.11
        # ex.add_note(f"Registered fleets: { repr(session.get('fleets')) }")
        # ex.add_note(f"Battle: { repr(session.get('battle')) }")
        # ex.add_note(f"Params: { repr(params) }")

        print(f"Registered fleets: { session.get('fleets') !r}")
        print(f"Battle: { session.get('battle') !r}")
        print(f"Params: { params !r}")
        raise

def get_previous_fleet_name(name):
    print("Using previous fleet as friendlies for ally consumables")
    return name[:5] + str(int(name[5:name.index('_')]) - 1) + name[name.index('_'):]


def get_next_fleet_name(name):
    print("Using next fleet as baddies for ally targeted consumables")
    return name[:5] + str(int(name[5:name.index('_')]) + 1) + name[name.index('_'):]


def get_last_fleet_name():
    i = 0
    fleet_name = "fleet1_" + str(get_zid())
    while fleet_name in session["fleets"] or "fleet" + str(i+1) + "_" + str(get_zid()) in session["fleets"]:
        i += 1
        fleet_name = "fleet" + str(i) + "_" + str(get_zid())
    return "fleet" + str(i-1) + "_" + str(get_zid())


def get_friendly_by_ally_fleet(name):
    print("Using corresponding friendly fleet for ally consumable")
    return [fleet[5:] for fleet in session["fleets"] if fleet.startswith('ally_') and name in session["fleets"][fleet]][0]


def decode_unit_count_list(raw_units):
    return [baddy[1:] for sub_fleet in
            simple_list(raw_units)
            for baddy, count in sub_fleet.items()
            for i in range(int(count))]


def encode_unit_string(code, hp='', shield=''):
    return f'{code},{hp},{shield},,'


def encode_unit_strings(codes):
    return [encode_unit_string(code) for code in codes]


def decode_unit_string(unit_string):
    return unit_string.split(',')[0]


def decode_unit_strings(unit_strings):
    return [decode_unit_string(unit_string) for unit_string in unit_strings]


def unit_roll(attacker_weak, defender_weak):
    if attacker_weak:
        return -2
    if defender_weak:
        return 2
    return roll_random_between(0, 1)


def get_hit_value(type, defender_type):
    grade = get_combat_chain_grade(type, defender_type)

    [value] = [e for e in game_settings['settings']['combatHitValues']['value'] if e['-type'] == grade]

    return (float(value["-critical"]), float(value["-direct"]))


def get_combat_chain_grade(type, defender_type):
    # print("chain grade", type, defender_type)
    [chain] = [e for e in game_settings['settings']['combatChain']['chain'] if e['-type'] == type]
    if defender_type in chain.get('-great', '').split(','):
        grade = 'great'
    elif defender_type in chain.get('-poor', '').split(','):
        grade = 'poor'
    else:
        grade = 'good'
    return grade


def get_hit_chance(attacker, defender):
    return {
        'poor':0,
        'good':1,
        'great':2,
    }[get_combat_chain_grade(get_unit_type(attacker), get_unit_type(defender))]


def spawn_fleet(params):
    meta = {}

    # params['code']
    # params['fleet']

    quest = lookup_quest(params['code'])
    tasks = get_tasks(quest)

    [task] = [t for t in tasks if t["_action"] == "fight" and ("_fleetname" not in t or t["_fleetname"] == params["fleet"])]

    # meta["newPVE"] = {"status": 2, "pos": "58,60,0", "villain": "v18"}
    #  meta["newPVE"] = {"status": 2, "pos": "60,63,0", "villain": "v18", "quest": "Q6016"}
    print("q", repr(quest))

    location = task.get("_spawnLocation")
    if not location:
        print("Non PVE, fleet by fight button on quest screen")
        register_random_fleet(None)  # reserves fleet names
        # for i in range(10):
        #     x = random.randrange(10, 90)
        #     y = random.randrange(10, 90)
        #     occupied_objects = lookup_objects_save_by_position(session, x, y, 5)
        #     print(params['code'], "Attempt", i + 1, "placing fleet", params["fleet"], "at", x, y, "has", len(occupied_objects), "objects aroumd")
        #     location = str(x) + "," + str(y)
        #     if occupied_objects:
        #         break
    else:
        meta["newPVE"] = {"status": 2, "pos": location, "villain": task["_pveVillain"], "quest": params['code']}
    spawn_fleet = {"errorType": 0, "userId": 1, "metadata": meta,
                          "data": []}
    return spawn_fleet


def next_campaign_response(params):
    meta = {"newPVE": 0}

    # map_item = lookup_item_by_code(map["map"])
    #
    # if map["map"] not in session['campaign'] or not session['campaign'][map["map"]]:
    #     session['campaign'][map["map"]] = {"island": -1}
    #
    # session['campaign'][map["map"]]["island"] += 1
    #
    # island = session['campaign'][map["map"]]["island"]
    #

    _map_name, island, map_item = get_current_island(params)

    if island is None:
        island = 0

    next_campaign_response = {"errorType": 0, "userId": 1, "metadata": meta,
                              "data": {"map": params["map"], "island": island}}

    # ensure_fleets, not the `if 'fleets' not in session` this replaced: that
    # check missed a save whose 'fleets' was present but None, which is what a
    # raw paste through /editor/save leaves behind.
    ensure_fleets()

    if map_item and "island" in map_item and 0 <= island < len(map_item["island"]):
        enemy_fleet = map_item["island"][island].get('fleet', {})
    else:
        enemy_fleet = {}
    #TODO what if defeated?
    fleet_name = get_new_enemy_fleet_name()

    replaying = "index" in params and params["index"] > -1

    mastery = get_island_mastery(params["map"], island)
    if mastery > 0:
        enemy_fleet = get_mastery_units(enemy_fleet, mastery)

    session["fleets"][fleet_name] = enemy_fleet
    print(f"Enemy fleet { fleet_name }:", enemy_fleet)

    battle_context = BattleContext(map_name=params["map"], island=island, replaying=replaying)

    #lookup_items_by_type_and_subtype("Buildable", "air")

    if not has_battle():
        session["battle"] = (None, None, None, battle_context)
    else:
        session["battle"][3] = battle_context

    return next_campaign_response


def get_mastery_units(enemy_fleet, mastery):

    # fleet can be complex!!
    # "fleet": [
    #     {
    #         "-U43": "2",
    #         "-PCK": "1"
    #     },
    #     {"-U43": "2"}
    # ],

    initial_units = [lookup_item_by_code(baddy[1:]) for sub_fleet in simple_list(enemy_fleet)
                     for baddy, count in sub_fleet.items()
                     for i in range(int(count))]

    new_units = []
    for unit in initial_units:
        proposed_units = [e for i in range(int(unit["unit"].get("-tier", "1")) + min(mastery, 2), 0, -1) for e in
                  lookup_items_by_type_and_subtype("Buildable", unit["-subtype"]) if
                  "unit" in e and "villain" not in e["unit"]["-type"] and "mega" not in e["unit"][
                      "-type"] and int(e["unit"].get("-tier", "1")) == i and unit["-unitClass"] == e[
                      "-unitClass"]]
        proposed_units.sort(key=lambda x: (-int(x["unit"].get("-tier", "1")), x['-code']))
        new_units.append(proposed_units[0])

    return recompress_unit_fleet(new_units)
    #for each unit
    #lookup_items_by_type_and_subtype("Buildable", "air")  <<subtype
    # tier = unit iter + mastery level, BUT fallback to lower tier if no unit
    # some units have no tier = tier 1
    # match unit class (e.g,airsupport)
    # can't be villain


def increment_mastery():
    if not has_battle_context():
        return
    user_obj = session.get('user_object')
    if not user_obj or "userInfo" not in user_obj:
        return
    campaign = user_obj['userInfo'].get('world', {}).get('campaign', {})
    if "mastery" not in campaign:
        campaign["mastery"] = {}
    battle_context = session["battle"][3]
    if not battle_context or battle_context.map_name is None or battle_context.island is None:
        return

    if battle_context.map_name not in campaign["mastery"]:
        campaign["mastery"][battle_context.map_name] = 0

    if campaign["mastery"][battle_context.map_name] >> battle_context.island * 2 & 0b11 != 0b11:
        campaign["mastery"][battle_context.map_name] += (1 << battle_context.island * 2)


def get_island_mastery_from_battle():
    if not has_battle_context() or not session["battle"][3].replaying:
        return 0

    battle_context = session["battle"][3]
    return get_island_mastery(battle_context.map_name, battle_context.island)


def get_island_mastery(map_name, island):
    if island is None:
        return 0
    user_obj = session.get('user_object', {})
    campaign = user_obj.get('userInfo', {}).get('world', {}).get('campaign', {})
    island_mastery = campaign.get("mastery", {}).get(map_name, 0)

    return island_mastery >> island * 2 & 0b11

    #return island_mastery[island] if island < len(island_mastery) else 0


def get_min_island_mastery_from_battle():
    if not has_battle_context() or not session["battle"][3].replaying:
        return 0

    battle_context = session["battle"][3]
    return get_min_island_mastery(battle_context.map_name)


def get_min_island_mastery(map_name):
    item = lookup_item_by_code(map_name) if map_name else None
    islands = item.get('island', []) if item else []
    return min((get_island_mastery(map_name, i) for i in range(len(islands))), default=0)


def get_mastery_scalar():
    mastery = get_island_mastery_from_battle()
    #return 0.5 ** mastery if mastery < 3 else 0
    return 1 + 0.5 * (mastery - 1) if mastery > 0 else 1 #with mastery experiment campaignMasteryScalars


def recompress_unit_fleet(units):
    unit_codes = [e["-code"] for e in units]
    prev_unit = None
    fleet = [{}]
    for e in unit_codes:
        if "-" + e in fleet[len(fleet)-1] and e != prev_unit:
            fleet.append({})
        fleet[len(fleet) - 1]["-" + e] = str(int(fleet[len(fleet) - 1].get("-" + e, '0')) + 1)
        prev_unit = e
    return fleet if len(fleet) > 1 else fleet[0] if len(fleet[0]) > 0 else ''


def get_reward_multiplier():
    if not has_battle_context() or not session["battle"][3].replaying:
        return 1

    combat_replay_reward_span = 10 #combatReplayRewardSpan

    battle_context = session["battle"][3]

    lead_map = get_lead_map()
    lead_map_item = lookup_item_by_code(lead_map)
    _, lead_island_id = get_active_island_by_map(lead_map)

    current_map_item = lookup_item_by_code(battle_context.map_name)

    if lead_map != battle_context.map_name or lead_island_id != battle_context.island:
        # overleveled distance till current island
        try:
            lead_islands = lead_map_item.get("island", []) if lead_map_item else []
            curr_islands = current_map_item.get("island", []) if current_map_item else []
            if lead_island_id is not None and 0 <= lead_island_id < len(lead_islands) and \
               battle_context.island is not None and 0 <= battle_context.island < len(curr_islands):
                lead_idx = int(lead_islands[lead_island_id].get("-globalIslandIndex", "0"))
                curr_idx = int(curr_islands[battle_context.island].get("-globalIslandIndex", "0"))
                factor = combat_replay_reward_span - min(lead_idx - curr_idx, combat_replay_reward_span)
                return factor * (1 / combat_replay_reward_span) if factor > 0 else 0.01
        except (KeyError, IndexError, TypeError, ValueError, ZeroDivisionError):
            return 1.0
    return 1

def get_lead_map():
    initial_map = "C001"

    user_obj = session.get('user_object', {})
    campaign = user_obj.get('userInfo', {}).get('world', {}).get('campaign', {})
    active = campaign.get('active', {})
    lead_map = initial_map
    visited = set()

    while lead_map and lead_map not in visited:
        visited.add(lead_map)
        map_item = lookup_item_by_code(lead_map)
        if not map_item:
            return initial_map
        _, island = get_active_island_by_map(lead_map) if lead_map in active else (None, 0)
        islands = map_item.get("island", [])
        if island is not None and island < len(islands):
            return lead_map
        if "-unlocks" not in map_item:
            return initial_map
        lead_map = map_item["-unlocks"]
    return initial_map


def register_fleetname_fleet(enemy_fleet):
    # This one indexed session["fleets"] with no guard at all, so it was the
    # third way in from the same missing-registry state.
    ensure_fleets()["FleetName"] = enemy_fleet
    print("FleetName Enemy fleet:", enemy_fleet)


def register_random_fleet(fleet):
    # See the note on the other guard: a missing key and a None value are two
    # different failures, and only ensure_fleets covers both.
    fleets = ensure_fleets()

    enemy_fleet = fleet
    fleet_name = get_new_enemy_fleet_name()

    fleets[fleet_name] = enemy_fleet
    print("Random Enemy fleet:", enemy_fleet)


def get_new_enemy_fleet_name():
    i = 1
    fleet_name = "fleet1_" + str(get_zid())
    while fleet_name in session["fleets"]:
        i += 2
        fleet_name = "fleet" + str(i) + "_" + str(get_zid())
    return fleet_name


def get_survival_player_fleet():
    player_units = session.get("fleets", {}).get(get_last_fleet_name(), [])
    subtype = lookup_item_by_code(player_units[0].split(',')[0])["-subtype"] if player_units else "infantry"
    research = session.get('user_object', {}).get("userInfo", {}).get("world", {}).get("research", {})

    last_battle = session.get("last_battle")
    last_strengths = last_battle[0] if last_battle and len(last_battle) > 0 and last_battle[0] is not None else []
    last_consumables = last_battle[2] if last_battle and len(last_battle) > 2 and last_battle[2] is not None else []

    def get_unit_strength(i):
        return last_strengths[i] if i < len(last_strengths) else 100

    fleet = {
    "type": subtype,
    "uid": get_zid(),
    "name": get_last_fleet_name(),
    "status": 2048,  # survival player
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
    "units": [f"{p.split(',')[0]},{get_unit_strength(i)},{int(is_shielded(('ally', i), last_consumables))},," for i, p in enumerate(player_units) if get_unit_strength(i) != 0],
    "store": [0],  # [0, 0, 0],
    "fleets": [],
    "upgrades": {p.split(',')[0]: ",".join(research.get(p.split(',')[0], [])) for i, p in enumerate(player_units) if get_unit_strength(i) != 0 and research.get(p.split(',')[0])},
    "hp": None,
    "invader": False
    }
    return fleet


# new TAssignConsumable("AI",null,0,0,null) 2nd ability
#getRandomConsumableForMercenary=merc getRandomConsumableForPlayer=ally steele?
# getRandomConsumableForLevel(param1:int, param2:String, param3:String, param4:String) : ConsumableItem
#new TAssignConsumable(param2,MERC_CONSUMABLE_ITEM_CODE,_loc5_,param1,param3),true)  A0A
def assign_consumable_response(params):
    friendlies, friendly_strengths, baddies, baddie_strengths, active_consumables = init_battle(params)
    meta = {"newPVE": 0}
    targeted = False
    enemy_turn = False
    casting_ai = False

    consumables = lookup_items_by_type_and_subtype("consumable", "consumable")
    if params["code"] == "A0A":   # Ally / merc
        damaged = any(strength < get_unit_max_strength(unit, True) for unit, strength in zip(friendlies, friendly_strengths))
        if params.get('name') == "-1":
            level = session["user_object"]["userInfo"]["player"]["level"] + 5  #steele = player level + 5
        else:
            level = 6
            if params.get('name', '0')[0].isalpha():
                merc = lookup_item_by_code(params["name"])
                level = int(merc["level"])
            else:
                for neighbor in session['user_object']["neighbors"]:
                    if neighbor["uid"] == int(params.get('name', '0')):
                        level = neighbor["level"]
        valid_consumables = [c for c in consumables if "-secondary" not in c and \
                             int(c.get("requiredLevel", "0")) <= level and \
                             (damaged or c["consumable"].get("-target") == 'enemy' or c["consumable"].get("-target") == 'enemy' or int(c["consumable"].get("-di","0")) >= 0) and \
                             'requiredDate' not in c and \
                             c["consumable"].get("-allypower", "true") != "false"]

        if session['user_object']["userInfo"]["player"]["tutorialProgress"] == 'tut_step_krunsch1AllyUsed':
            print("During tut_step_krunsch1AllyUsed: fixed N04 Air Strike")
            # only one occurrence of fixed allyConsumable uses an N04
            valid_consumables = [lookup_item_by_code("N04")]

        selected_random_consumable_roll = roll_random_between(0, len(valid_consumables) - 1)

        selected_random_consumable = round(selected_random_consumable_roll) # required roll fixed allyconsumable in tutorialstep
        selected_consumable = valid_consumables[selected_random_consumable]
        handle_quest_progress(meta, progress_useAOA_consumable(selected_consumable))
    elif params.get("name") == "AI":
        secondaries = [get_unit_secondary(b) for b, i in zip(baddies, range(len(baddies))) if get_unit_secondary(b) is not None and not is_stunned(("enemy", i), active_consumables)]
        if len(secondaries) > 1:
            print("WARN: more that one secondary", repr(secondaries))
        if not secondaries:
            print("INFO: no secondary available to cast", repr(secondaries))
            raise StaleBattleReference("No secondary ability available to cast for AI units")

        selected_consumable = lookup_item_by_code(secondaries[0])
        enemy_turn = True

        cast_chance = roll_random_float()
        cast_percent = float(selected_consumable["consumable"]["-castpercent"])

        print(("Not c" if cast_chance >= cast_percent else "C") + "asting secondary power", cast_chance, ">=", cast_percent)
        selected_consumable = None #second targeted call will be made

        casting_ai = cast_chance < cast_percent

        #selected_consumable = None
    else:
        selected_consumable = lookup_item_by_code(params["code"])
        targeted = True
        enemy_turn = is_affected_by_consumable(("AI", None), {"consumable":{}}, active_consumables)
        handle_quest_progress(meta, progress_useGeneral_consumable(selected_consumable,enemy_turn))



    # TODO: AI secondary abily Z-units
    if selected_consumable is not None:
        if selected_consumable["consumable"].get("-type") != "all":
            if (selected_consumable["consumable"].get("-target") == 'enemy') ^ enemy_turn:
                live_baddies_index = get_alive_unit_index(baddie_strengths)
                if targeted:
                    raw_pid = params["id"]
                    if isinstance(raw_pid, (list, tuple)) and raw_pid:
                        targeted_baddie = int(raw_pid[0])
                    elif isinstance(raw_pid, dict):
                        first_k = min(raw_pid.keys()) if raw_pid else 0
                        targeted_baddie = int(raw_pid[first_k])
                    else:
                        targeted_baddie = int(raw_pid)
                #TODO enemy support heals, accuracy,...
                else:
                    targeted_baddie = live_baddies_index[round(roll_random_between(0, round(len(live_baddies_index) - 1)))] if len(live_baddies_index) > 1 else (live_baddies_index[0] if live_baddies_index else 0)
                apply_consumable_direct_impact(meta, selected_consumable, targeted_baddie, baddies, baddie_strengths, params, False, active_consumables)
                    # session["battle"] = None`
                # handle_win(baddie_strengths, meta, {})  #TODO next map?
                # handle_loss()

                target = ('enemy', targeted_baddie)
            else:
                live_friendly_index = get_alive_unit_index(friendly_strengths)
                if targeted:
                    raw_pid = params["id"]
                    if isinstance(raw_pid, (list, tuple)) and raw_pid:
                        targeted_friendly = int(raw_pid[0])
                    elif isinstance(raw_pid, dict):
                        first_k = min(raw_pid.keys()) if raw_pid else 0
                        targeted_friendly = int(raw_pid[first_k])
                    else:
                        targeted_friendly = int(raw_pid)
                elif enemy_turn:
                    targeted_friendly = next(
                        (i for s, i in zip(friendly_strengths, range(len(friendly_strengths))) if
                        s > 0 and not is_affected_by_consumable(("ally", i), selected_consumable, active_consumables)),
                        live_friendly_index[0] if live_friendly_index else 0
                    )
                else:
                    targeted_friendly = live_friendly_index[
                        round(roll_random_between(0, round(len(live_friendly_index) - 1)))] if len(
                        live_friendly_index) > 1 else live_friendly_index[0]
                apply_consumable_direct_impact(meta, selected_consumable, targeted_friendly, friendlies, friendly_strengths,
                                               params, True, active_consumables)
                target = ('ally', targeted_friendly)
        else:

            # TODO: more consumables




            print("Consumable", selected_consumable["-code"], selected_consumable["consumable"].get("-diweapon", ""), "affects all")

            if (selected_consumable["consumable"].get("-target") == 'enemy') ^ enemy_turn:
                for i in range(len(baddies)):
                    apply_consumable_direct_impact(meta, selected_consumable, i, baddies, baddie_strengths, params, False, active_consumables)
                if not targeted and not enemy_turn and len(get_alive_unit_index(baddie_strengths)) > 1:
                    roll_random_float() #required roll
                target = ('enemy', None)
            else:
                print("target allies")
                for i in range(len(friendlies)):
                    apply_consumable_direct_impact(meta, selected_consumable, i, friendlies, friendly_strengths, params, True, active_consumables)
                if not targeted and not enemy_turn and len(get_alive_unit_index(friendly_strengths)) > 1:
                    roll_random_float()
                target = ('ally', None)

            # for i in range(len(baddie_strengths)):
                # baddie_strengths[i] -= 15
                # print("Baddie", i, "strength", baddie_strengths[i])
                # if baddie_strengths[i] <= 0:
                #     baddie_strengths[i] = 0
                #     print("Baddie", i, "down by consumable")


        if int(selected_consumable["consumable"].get("-duration", "0")) > 0:
            active_consumables.append((selected_consumable, target, int(selected_consumable["consumable"].get("-duration", "0"))))

        if selected_consumable["-name"] == "consumable75":
            print(selected_consumable)
            defenseshield_activate(friendlies, active_consumables, selected_consumable)

        if targeted and enemy_turn:
            print("Consumable use ends enemy turn")
            process_consumable_end_turn(active_consumables, baddie_strengths, friendly_strengths, False)
        elif not enemy_turn:
            process_consumable_end_turn(active_consumables, baddie_strengths, friendly_strengths, True)

        handle_win(baddie_strengths, meta, params, friendlies, friendly_strengths)
        handle_loss(friendly_strengths)

        report_battle_log(friendly_strengths, baddie_strengths, not enemy_turn, None, None,
                          active_consumables)

        if targeted and enemy_turn:
            consume_consumables(active_consumables)
    if casting_ai:
        active_consumables.append(({"consumable": {}}, ("AI", None), -1))

    assign_consumable_response = {"errorType": 0, "userId": 1, "metadata": meta,
                          "data": []}
    return assign_consumable_response


def get_alive_unit_index(strengths):
    return [i for s, i in zip(strengths, range(len(strengths))) if s > 0]


def apply_consumable_direct_impact(meta, selected_consumable, targeted_unit, units, units_strengths, params, ally, active_consumables):
    unit_current_strength = units_strengths[targeted_unit]
    direct_impact = int(selected_consumable["consumable"].get("-di", 0))
    damage = direct_impact
    against = simple_list(selected_consumable["consumable"].get("against", ''))
    live_index = get_alive_unit_index(units_strengths)
    # TODO: also units have against mod damage: Man_O_War_Battleship, Spec_Ops_Man_O_War_Battleship, LE_Elite_ManOWar_Battleship,
    # pirateship04(npc), pirateship03(npc), pirateinfantry02 PU2(npc), pirateInfantry02 PU4(npc), pirateAntiAir02(npc), pirateAntiAir03(npc),
    # pirateBalloon01(npc), pirateFighter01, pirateBomber01, pirateFighter02, pirateBomber02, pirateFighter03,pirateBomber03, pirateFighter05, pirateBomber05,
    # pirateUBoat03, pirateCaptainKrunsch and many more
    for a in against:
        if a['-type'] in (get_unit_type(units[targeted_unit]), get_unit_terrain(units[targeted_unit])):
            damage *= float(a['-mod'])
    if damage > 0 and is_shielded(("ally" if ally else "enemy",targeted_unit), active_consumables):
        consume_shield(("ally" if ally else "enemy",targeted_unit), active_consumables)

    elif units_strengths[targeted_unit] > 0: #can't damage/heal dead units

        if selected_consumable["consumable"].get("-type") == "all" and selected_consumable["-subtype"] == "secondary" and "-percent" in selected_consumable["consumable"] and roll_random_float() > int(selected_consumable["consumable"]["-percent"])/100:
            damage = 0

        units_strengths[targeted_unit] -= damage
        if not ally and 1 >= units_strengths[targeted_unit] > 0:
            units_strengths[targeted_unit] = 0
            print("Enemy inced to prevent 1 strength")
        if units_strengths[targeted_unit] <= 0:
            units_strengths[targeted_unit] = 0  # dead
            print("Enemy unit" if not ally else "Friendly unit", targeted_unit, "down")
            if ally:
                handle_quest_progress(meta, progress_battle_damage_count("battleKill", 1, {},
                                                                         units[targeted_unit]))
                doBattleRewards("kill", unit_current_strength, unit_current_strength, 0)

        if units_strengths[targeted_unit] > get_unit_max_strength(units[targeted_unit], ally, params):
            print("Limiting heal to max strength")
            units_strengths[targeted_unit] = get_unit_max_strength(units[targeted_unit], ally, params)
        print("Consumable", selected_consumable["-code"], selected_consumable["consumable"].get("-diweapon", ""), "used to " + ("friendly" if ally else "baddie:"), targeted_unit, "di", direct_impact, "damage", damage)
    else:
        print("Consumable", selected_consumable["-code"], selected_consumable["consumable"].get("-diweapon", ""), "not used to dead " + ("friendly" if ally else "baddie:"), targeted_unit, "di", direct_impact, "damage", damage)

    if "-chipFactor" in selected_consumable["consumable"]:
        # dead units are removed from battle side so units adjacent to the dead unit are now counted as adjacent to
        # each other for collateral damage
        #
        # The formation is the one that was alive when the cast was aimed --
        # the epicenter stays in it even when the direct impact kills it,
        # because it is still the centre of the blast. (test/battle_test.py
        # pins the numbers for that case.)
        if targeted_unit not in live_index:
            # The target was already dead: the direct impact did nothing (see
            # the branch above), and it is not in the formation, so there is
            # no epicenter to spread collateral damage from. Indexing the list
            # with a unit that is not in it raised ValueError, which the
            # gateway swallowed -- the player lost the consumable and the
            # damage with it.
            print("Consumable", selected_consumable["-code"], "not used to dead unit, no collateral damage")
            return
        epicenter = live_index.index(targeted_unit)
        for i in range(len(live_index)):
            collateral_unit_current_strength = units_strengths[live_index[i]]
            colateral_damage = math.ceil(get_adjacent_factor(epicenter, i, len(live_index)) *
                                         int(selected_consumable["consumable"]["-chipFactor"]) *
                                         int(selected_consumable["consumable"].get("-di", 0)) / 100)
            for a in against:
                if a['-type'] in (get_unit_type(units[live_index[i]]), get_unit_terrain(units[live_index[i]])):
                    colateral_damage *= float(a['-mod'])
            units_strengths[live_index[i]] -= colateral_damage
            if not ally and 1 >= units_strengths[live_index[i]] > 0:
                units_strengths[live_index[i]] = 0
                print("Enemy inced to prevent 1 strength")
            print("Enemy unit" if not ally else "Friendly unit suffered", collateral_unit_current_strength - units_strengths[live_index[i]], "collateral damage")
            if units_strengths[live_index[i]] <= 0:
                units_strengths[live_index[i]] = 0  # dead
                print("Enemy unit" if not ally else "Friendly unit", live_index[i], "down by collateral damage")
                if ally:
                    handle_quest_progress(meta, progress_battle_damage_count("battleKill", 1, {},
                                                                             units[live_index[i]]))
                    doBattleRewards("kill", collateral_unit_current_strength, collateral_unit_current_strength, 0)


def get_adjacent_factor(unit_1, unit_2, count):
    print(type(unit_1))
    print(type(unit_2))
    if unit_1 == unit_2 or count == 1:
        return 0
    if count == 2:
        return 4
    if count == 3:
        return [[0,4,3],[4,0,3],[3,4,0]][unit_1][unit_2]
    if count == 4:
        return [[0,4,0,0],[4,0,3,0],[0,4,0,3],[0,0,4,0]][unit_1][unit_2]
    if count == 5:
        return [[0,4,3,0,0],[4,0,3,2,0],[4,3,0,2,1],[0,4,3,0,2],[0,0,4,3,0]][unit_1][unit_2]
    # No matrix for a larger board. The single caller multiplies the result, so an
    # implicit None would surface as a TypeError deep inside the battle loop.
    return 0


def consumable_target_matches(consumable_target, target):
    # consumable_target/target are (side, index) pairs, index None meaning "all".
    # active_consumables round-trips through the Flask session via msgpack, which has
    # no tuple type -- tuples silently become lists across a session save/reload, so a
    # plain `consumable_target == target` tuple-identity check can spuriously fail for
    # data that survived a request boundary. Compare elements instead.
    return consumable_target[0] == target[0] and (consumable_target[1] == target[1] or consumable_target[1] is None)


def is_stunned(target, active_consumables):
    for consumable, consumable_target, _tries in active_consumables:
        if consumable_target_matches(consumable_target, target) and consumable["consumable"].get("-disable") == "stun":
            return True
    return False

def is_affected_by_consumable(target, used_consumable, active_consumables):
    for consumable, consumable_target, _tries in active_consumables:
        if consumable_target_matches(consumable_target, target) and consumable == used_consumable:
            return True
    return False

def get_consumable_damage(target, active_consumables):
    return get_consumable_int(target, active_consumables, "-damage")


def get_consumable_shield(target, active_consumables):
    return get_consumable_int(target, active_consumables, "-shield")


def get_consumable_accuracy(target, active_consumables):
    return get_consumable_int(target, active_consumables, "-attack")


def get_consumable_evasion(target, active_consumables):
    return get_consumable_int(target, active_consumables, "-defend")


def get_consumable_int(target, active_consumables, field):
    damage = 0
    for consumable, consumable_target, _tries in active_consumables:
        if consumable_target_matches(consumable_target, target):
            damage += int(consumable["consumable"].get(field, "0"))
    return damage


# state_UseSecondaryAbility  item has secondaryAbility => consumable TAssignConsumable

# TODO ai rolls FindBestDefendingUnit  required roll
# FindBestDefendingUnitAgainstAttackers  optional roll
# all alive attackers select defender with best value and select attacker for that value if more attackers with same value (and not m_shouldFocusFire) then conditionally roll between len of those attackers
# when m_shouldFocusFire(and a defender was found) then it's found and returns
# FindBestDefendingUnitAgainstBestAttacker
# FindBestDefendingUnit and FindBestDefendingUnitAgainstAttackers
def ai_best_attack(player_units, player_units_strengths, baddies, baddies_strengths, active_consumables):
    """Replicates Flash BattleAI.FindBestDefendingUnit and FindBestDefendingUnitAgainstAttackers.

    In Flash (BattleAI.as):
    1. rand_float = ZGameRandom.instance.float()
    2. res = FindBestDefendingUnitAgainstAttackers(rand_float)
       - Iterates each alive, non-stunned baddie in m_attackers
       - For that baddie, evaluates get_hit_chance(baddie, defender) against all alive, non-stunned friendlies
       - Finds best defending friendly (ties broken by int(round(rand_float * (len(ties) - 1))))
       - Among all baddies, finds the best baddie(s) with max hit value
       - If multiple best baddies tie: rolls ONE random float to pick: int(round(float * (len - 1)))
       - If only 1 best baddie: NO extra random float rolled!
    3. If not m_shouldFocusFire (player level < combatAIFocusFireMinLevel=25):
       Returns (chosen_baddie, max_grade, chosen_defender) directly without further rolls.
    """
    first_random = roll_random_float()

    best_attackers = []
    best_value = -1

    baddies_alive = [
        (b_idx, baddie) for b_idx, (baddie, strength) in enumerate(zip(baddies, baddies_strengths))
        if strength > 0 and not is_stunned(("enemy", b_idx), active_consumables)
    ]
    friendlies_alive = [
        (p_idx, friendly) for p_idx, (friendly, strength) in enumerate(zip(player_units, player_units_strengths))
        if strength > 0 and not is_stunned(("ally", p_idx), active_consumables)
    ]

    if not baddies_alive or not friendlies_alive:
        return None, 0, None

    for b_idx, baddie in baddies_alive:
        cand_grades = [(p_idx, get_hit_chance(baddie, friendly)) for p_idx, friendly in friendlies_alive]
        max_grade = max(g for _, g in cand_grades)
        best_cand_defenders = [p_idx for p_idx, g in cand_grades if g == max_grade]

        if len(best_cand_defenders) > 1:
            chosen_def = best_cand_defenders[round(first_random * (len(best_cand_defenders) - 1))]
        else:
            chosen_def = best_cand_defenders[0]

        if max_grade > best_value:
            best_value = max_grade
            best_attackers = [(b_idx, chosen_def)]
        elif max_grade == best_value:
            best_attackers.append((b_idx, chosen_def))

    if not best_attackers:
        return None, 0, None

    if len(best_attackers) > 1:
        f = roll_random_float()
        idx = round(f * (len(best_attackers) - 1))
        chosen_baddie, chosen_player = best_attackers[idx]
    else:
        chosen_baddie, chosen_player = best_attackers[0]

    return chosen_baddie, best_value, chosen_player


def ai_best_unit(first_units, first_units_strengths, second_unit, random, active_consumables, target_group):
    first_units_tuple = list(zip(first_units, first_units_strengths, range(len(first_units))))
    best_grade = max([get_hit_chance(first_unit, second_unit) for first_unit, strength, i in first_units_tuple if strength > 0 and not is_stunned((target_group, i), active_consumables)] + [-1])
    best_units = [i for first_unit, strength, i in first_units_tuple if strength > 0 and not is_stunned((target_group, i), active_consumables) and get_hit_chance(first_unit, second_unit) == best_grade]
    # print("AI best unit" ,repr((first_units, first_units_strengths, second_unit, random)),best_grade, repr(best_units))
    if best_units:
        random_roll = round(random * (len(best_units) - 1))
        print(best_units[random_roll])
        return best_units[random_roll], best_grade
    return None, -1


def get_unit_type(unit):
    raw_type = unit.get("unit", {}).get("-type", ",") if isinstance(unit, dict) else ","
    parts = raw_type.split(',')
    return parts[0] if parts else ""


def get_unit_terrain(unit):
    raw_type = unit.get("unit", {}).get("-type", ",") if isinstance(unit, dict) else ","
    parts = raw_type.split(',')
    return parts[1] if len(parts) > 1 else ""


def get_unit_secondary(unit):
    return unit["unit"].get("-secondary")


def get_unit_max_strength(unit, ally, params=None):
    strength = int(unit["unit"].get("-strength", "0"))
    _, island, map_item = get_current_island(params)
    if has_battle_context() and session["battle"][3].replaying:
        island = session["battle"][3].island
    if (
        not ally
        and island is not None
        and map_item
        and "island" in map_item
        and 0 <= island < len(map_item["island"])
        and "strength" in map_item["island"][island]
    ):
        strengths = simple_list(map_item["island"][island]["strength"])
        strength = apply_map_mod_strength(unit, strength, strengths)
        # print("Mod strenghts",repr(strengths))
    elif ally:
        strength = handle_strength_upgrades(strength, unit)
    return strength


# def get_current_island(params):
#     if params and 'map' in params and params['map'] and params['map'][0] == 'C':
#         if 'campaign' in session and params['map'] in session['campaign']:
#             map_item = lookup_item_by_code(params["map"])
#             return session['campaign'][params['map']]["island"], map_item
#     return None, None

def get_current_island(params):
    # Campaign 01
    if params and 'map' in params and params['map'] and params['map'][0] == 'C':
        map_item = lookup_item_by_code(params["map"])
        return get_active_island_by_map(params['map'], params.get('index')) + (map_item,)
    # Campaign 02
    if params and 'map' in params and params['map'] and params['map'][0] == 'D':
        map_item = lookup_item_by_code(params["map"])
        return get_active_island_by_map(params['map'], params.get('index')) + (map_item,)
    return None, None, None


def get_active_island_by_map(map_name: str, index: Any = -1) -> tuple[str, int]:
    world = session.get('user_object', {}).get('userInfo', {}).get('world', {})
    if 'campaign' not in world:
        world['campaign'] = {'current': 'camp001', 'active': {}}
    campaign = world['campaign']
    if 'active' not in campaign:
        campaign['active'] = {}
    if map_name not in campaign['active']:
        campaign['active'][map_name] = {"status": 0, "fleets": []}

    status = campaign['active'][map_name].get("status", 0)
    island_id = (status & 4293918720) >> 20
    try:
        idx_val = int(index) if index is not None else -1
    except (ValueError, TypeError):
        idx_val = -1
    return map_name, island_id if idx_val < 0 else idx_val

def set_active_island_by_map(map_name, island_id):
    world = session.get('user_object', {}).get('userInfo', {}).get('world', {})
    if 'campaign' not in world:
        world['campaign'] = {'current': 'camp001', 'active': {}}
    campaign = world['campaign']
    if 'active' not in campaign:
        campaign['active'] = {}
    if map_name not in campaign['active']:
        campaign['active'][map_name] = {"status": island_id << 20, "fleets": []}
    else:
        status = campaign['active'][map_name].get("status", 0)
        status = (status & 1048575) | (island_id << 20)
        campaign['active'][map_name]["status"] = status


#
# def get_current_island_from_session():
#     campaign = session['user_object']['userInfo']['world']['campaign']
#     if 'current' in campaign:
#         return get_active_island_by_map()
#     return None, None


def apply_map_mod_strength(unit, strength, strengths):
    for e in strengths:
        if e["-code"] == unit["-code"]:
            strength *= float(e["-mult"])
            print("Mod strength", e["-code"], unit["-name"], "has strength", strength, "instead of", int(unit["unit"].get("-strength", "0")))
    return strength


def get_unit_weak(unit):
    return int(unit["unit"].get("-weak", "0"))

# unused?
# def getAbsolute(baddie_strength):
#     base_damage = 25  # TODO tier difference & increments
#
#     # if player_turn:
#     damage = base_damage * (3 * friendly_max_strength + baddie_strength) / (
#                 3 * baddie_strength + friendly_max_strength)
#     damage = damage / 100 * baddie_max_strength
#     # else:
#     #     damage = base_damage * (3 * baddie_max_strength + friendly_strength) / (
#     #                 3 * friendly_strength + baddie_max_strength)
#     #     damage = damage / 100 * friendly_max_strength
#
#     damage = math.floor(damage * 10 ** 3) / 10 ** 3



#TODO: fix kill has more coins?
def doBattleRewards(hit_type, max_strength, damage, friendly_max_strength):
    #mod strength?
    coin_amount = math.ceil(max_strength * damage * 0.01)  # * unit mult * ammo experiment
    rare_amount = math.ceil(max_strength * damage * 0.0001)  # * unit mult * ammo experiment
    rare_count = 0
    xp = 1
    energy = 0
    # TODO: energyRewardModVariant
    # TODO combat losses

    rare_type = int(friendly_max_strength % 5)

    if hit_type == "glancinghit":
        coin_amount = 0
    elif hit_type == "criticalkill":
        coin_amount *= 3
        rare_count = 3
        xp = 3
        energy = 1 if roll_reward_random_float() <= 0.8 else 0
        energy += 1 if roll_reward_random_float() <= 0.2 else 0

    elif hit_type == "criticalhit":
        rare_count = 1
        energy = 1 if roll_reward_random_float() <= 0.25 else 0

    rare_amount *= rare_count

    mastery_scalar = get_mastery_scalar()
    coin_amount *= mastery_scalar
    xp *= mastery_scalar
    rare_amount *= mastery_scalar
    #oil ?

    if mastery_scalar != 1:
        energy = 0

    user_obj = session.get('user_object')
    if not user_obj or "userInfo" not in user_obj:
        return

    world = user_obj["userInfo"].get("world", {})
    resources = world.get('resources', {})
    # The mastery scalar is a float, so these became floats too -- and a
    # float balance stays a float through every later battle. Coins, XP and
    # rare resources are counts; the int() is the same fix that was already
    # applied to the energy below.
    if 'coins' in resources:
        resources['coins'] += int(coin_amount)

    player = user_obj["userInfo"].get("player", {})
    if 'xp' in player:
        player['xp'] += int(xp)

    print("Combat rewards", hit_type ,  "coins:", coin_amount, "(" + str(resources.get('coins', 0)) + ")")
    if rare_amount and 'resourceOrder' in world and rare_type < len(world['resourceOrder']):
        resource_order = world['resourceOrder']
        rare_resource = resource_order[rare_type]
        if rare_resource in resources:
            resources[rare_resource] += int(rare_amount)
        print("Combat rewards", hit_type ,  "rare" + str(rare_type) + ":", rare_amount, "(" + str(resources.get(rare_resource, 0)) + ")")
        #Todo quest added

    print("Combat rewards", hit_type ,  "xp:", xp, "(" + str(player['xp']) + ")")

    if energy:
        # `player['energy']` only. This mirrored into world['resources'] too,
        # marked `# needed?` and never answered -- and it was not needed: the
        # client reads the player's energy and RESOURCE_ORDER does not carry
        # it, so a second counter was written in six places and read by nobody.
        # It had already drifted: a save read 27 here and 10 there.
        #
        # The int() is the other half. Energy is a count, and letting it
        # drift to 27.0 through repeated += is how a resource stops being one.
        player['energy'] = int(player['energy'] + energy)
        print("Combat rewards", hit_type ,  "energy:", energy, "(" + str(player['energy']) + ")")


def defenseshield_activate(friendlies, active_consumables, selected_consumable):
    for i in range(len(friendlies)):
        active_consumables.append((selected_consumable, ('ally',i), 9999999))
        print('ally: ' , i)


def defenseshield_upgrade_activate(friendlies, active_consumables):
    for i in range(len(friendlies)):
        if handle_shield_upgrades(friendlies, i):
            selected_consumable = lookup_item_by_code('N75')
            active_consumables.append((selected_consumable, ('ally',i), 9999999))
            print('ally shielded: ' , i)



def consume_shield(hit_target, active_consumables):
    active_consumables[:] = [(consumable, target, tries) for consumable, target, tries
                             in active_consumables if consumable.get("consumable",{}).get("-givesAbility") != "shield" or not consumable_target_matches(target, hit_target)]



def is_shielded(target, active_consumables):
    for consumable, consumable_target, _tries in active_consumables:
        if consumable_target_matches(consumable_target, target) and consumable.get("consumable",{}).get("-givesAbility") == "shield":
            return True
    return False


def format_player_fleet(code):
    return code + ",,,,"


def has_battle_context():
    return has_battle() and len(session["battle"]) > 3 and session["battle"][3] is not None \
           and isinstance(session["battle"][3], BattleContext)


def has_battle():
    return "battle" in session and session["battle"] is not None


class BattleContext(msgspec.Struct, tag=True):
    map_name: str | None = None
    island: int | None = None
    replaying: bool = False

    def __str__(self):
        return f"BattleContext(map_name={self.map_name}, island={self.island}, replaying={self.replaying})"

    __repr__ = __str__
