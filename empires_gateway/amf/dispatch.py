"""The dispatch table and the route that carries the batch.

The client asks for a method by name; this is what answers it. The table is
the whole vocabulary of the protocol in one place, and the route is the
envelope: decode the body, walk the calls, give every one of them an answer in
its own slot, and encode the answers back.

The rules the table names live in ``handlers/``, one module per domain.
"""
from __future__ import annotations

import logging
import time
from collections.abc import Callable
from datetime import datetime
from typing import Any

import pyamf
from flask import Blueprint, Response, make_response, request
from pyamf import remoting

from battle_engine import (
    StaleBattleReference,
    assign_consumable_response,
    battle_complete_response,
    next_campaign_response,
    spawn_fleet,
)
from empires_gateway.amf.handlers.battle import (
    accept_friend_repel_response,
    add_fleet_response,
    cancel_unstarted_challenge_response,
    exit_battle_response,
    load_challenge_response,
    load_survival_mode_response,
    neighbor_repel_challenge_response,
    occupation_place_response,
    pillage_response,
    random_enemy_fleet_challenge_response,
    random_fleet_challenge_response,
    reject_friend_repel_response,
)
from empires_gateway.amf.handlers.economy import (
    buy_expansion_response,
    buy_item_response,
    buy_items_response,
    buy_quest_task_response,
    purchase_contact_unlock,
    purchase_energy_refill_response,
    use_item_response,
)
from empires_gateway.amf.handlers.player import (
    calculate_ransom_response,
    clear_incentive_response,
    do_seen_quest_notification_response,
    feed_response,
    full_screen_response,
    generic_string_response,
    motd_action_response,
    open_dialog_response,
    save_options_response,
    seen_flag_response,
    select_response,
    streak_bonus_response,
    tutorial_response,
    user_response,
    view_zoom_response,
)
from empires_gateway.amf.handlers.ranking import (
    collect_leaderboard_response,
    leaderboards_response,
    matchmaking_opt_flag_response,
    matchmaking_users_response,
    targeting_data_response,
    targeting_groups_response,
)
from empires_gateway.amf.handlers.social import (
    accept_tend_ally_response,
    decline_tend_ally_response,
    friend_info_response,
    friend_response,
    invader_response,
    neighbor_invader_response,
    neighbor_suggestion_response,
    part_request_response,
    recent_response,
    stream_publish_response,
    tend_ally_response,
    zlingshot_response,
)
from empires_gateway.amf.handlers.units import (
    unit_drop_reveal_all_response,
    unit_drop_switch_unit_response,
    unit_unlock_response,
    upgrade_state_response,
)
from empires_gateway.amf.handlers.world import (
    crew_request_response,
    load_world_response,
    perform_world_response,
    set_current_campaign_response,
    stop_mayhem_response,
    update_roads_response,
    world_name_response,
)
from empires_gateway.amf.protocol import (
    _amf_as_list,
    _amf_detach,
    _amf_field,
    _call_args_summary,
    _pad_batch_results,
    _tolerate_call_failure,
)
from empires_gateway.shared import dummy_response
from logger import (
    report_other_log,
    report_world_log,
)
from save_engine import (
    InvalidSaveException,
)

bp = Blueprint("amf", __name__)

logger = logging.getLogger(__name__)


def _handle_init_user(params, reqq, msg):
    try:
        return user_response()
    except InvalidSaveException as error:
        print('Handling InvalidSaveException error:', error)
        # A corrupt save used to answer with None, and a handler that returns
        # None produced no result at all -- which shifted every later answer
        # in the batch one slot to the left. The client then read the next
        # call's payload as its login response.
        return dummy_response()


def _handle_tutorial_progress(params, reqq, msg):
    if not params:
        return dummy_response()
    return tutorial_response(params[0], reqq.get('sequence', 0), msg.bodies[0][0])


def _handle_perform_action(params, reqq, msg):
    if not params or len(params) < 2:
        return dummy_response()
    raw_id = _amf_field(params[1], 'id', None)
    try:
        item_id: Any = int(raw_id) if raw_id is not None else None
    except (ValueError, TypeError):
        item_id = raw_id
    item_pos = _amf_field(params[1], 'position', '?')

    try:
        wr = perform_world_response(params)
    except Exception as error:
        logger.exception("Error in perform_world_response for id=%s pos=%s", item_id, item_pos)
        wr = {"errorType": 0, "userId": 1, "metadata": {"newPVE": 0}, "data": {"id": item_id}}

    if isinstance(wr, dict) and isinstance(wr.get("data"), dict) and wr["data"].get("id") is None and item_id is not None:
        wr["data"]["id"] = item_id

    report_world_log(
        str(params[0]) + " id " + str(item_id) + "@" + str(item_pos),
        wr.get("data", []), params, reqq.get("sequence", 0), msg.bodies[0][0],
        wr.get("metadata", {}).get("QuestComponent"), wr.get("metadata", {}).get("newPVE")
    )
    return wr


def _handle_resolve_battle(params, reqq, msg):
    if not params:
        return dummy_response()
    try:
        return battle_complete_response(params[0])
    except (StaleBattleReference, IndexError, KeyError, TypeError, ValueError) as error:
        # A stale or out-of-range battle reference is the client asking about
        # a battle this server has already moved past. It is caught on purpose
        # and answered with the dummy result, so it is expected traffic.
        logger.info('Ignoring stale or out-of-range resolveBattle request: %s', error)
        return dummy_response()


def _handle_assign_consumable(params, reqq, msg):
    if not params:
        return dummy_response()
    try:
        return assign_consumable_response(params[0])
    except (StaleBattleReference, IndexError, KeyError, TypeError, ValueError, Exception) as error:
        logger.info('Ignoring stale or invalid assignConsumable request: %s', error)
        return dummy_response()


AMF_HANDLERS: dict[str, Callable[[Any, Any, Any], Any]] = {
    # Custom / multi-step handlers
    'UserService.initUser': _handle_init_user,
    'UserService.tutorialProgress': _handle_tutorial_progress,
    'WorldService.performAction': _handle_perform_action,
    'WorldService.resolveBattle': _handle_resolve_battle,
    'WorldService.assignConsumable': _handle_assign_consumable,

    # No-arg handlers
    'DataServicesService.getRequestFriends': lambda *_: friend_response(),
    'PVPService.getUsersInvaderChallenges': lambda *_: invader_response(),
    'ZlingshotService.presence': lambda *_: zlingshot_response(),
    'DataServicesService.getRecentPlayers': lambda *_: recent_response(),
    'DataServicesService.getFriendsInfo': lambda *_: friend_info_response(),
    'DataServicesService.getSuggestedNeighbors': lambda *_: neighbor_suggestion_response(),
    'DataServicesService.getRecommendedNeighbors': lambda *_: neighbor_suggestion_response(),
    'DataServicesService.getMatchmakingUsersData': lambda *_: matchmaking_users_response(),
    'WorldService.stopMayhemEvent': lambda *_: stop_mayhem_response(),
    'WorldService.fullScreen': lambda *_: full_screen_response(),
    'PVPService.cancelUnstartedChallenge': lambda *_: cancel_unstarted_challenge_response(),
    'WorldService.exitBattle': lambda *_: exit_battle_response(),
    'FeedService.getFeed': lambda *_: feed_response(),
    'UserService.getTargetingData': lambda *_: targeting_data_response(),
    'UserService.getTargetingGroups': lambda *_: targeting_groups_response(),
    'UserService.getLeaderboards': lambda *_: leaderboards_response(),
    'UserService.collectLeaderboards': lambda *_: collect_leaderboard_response(),
    'WorldService.sendZaspReport': lambda *_: dummy_response(),

    # Full params handlers
    'UserService.streamPublish': lambda p, *_: stream_publish_response(p),
    'WorldService.loadWorld': lambda p, *_: load_world_response(p),
    'VisitorService.help': lambda p, *_: tend_ally_response(p),
    'RequestService.partRequest': lambda p, *_: part_request_response(p),
    'PVPService.occupationPlace': lambda p, *_: occupation_place_response(p),
    'PVPService.pillage': lambda p, *_: pillage_response(p),
    'RequestService.crewRequest': lambda p, *_: crew_request_response(p),
    'PVPService.retrieveNeighborRepelChallenge': lambda p, *_: neighbor_repel_challenge_response(p),
    'VisitorService.accept': lambda p, *_: accept_tend_ally_response(p),
    'VisitorService.decline': lambda p, *_: decline_tend_ally_response(p),

    # Single-param (params[0]) handlers
    'UserService.setSeenFlag': lambda p, *_: seen_flag_response(p[0] if p else {}),
    'PVPService.createRandomFleetChallenge': lambda p, *_: random_fleet_challenge_response(p[0] if p else {}),
    'WorldService.spawnFleet': lambda p, *_: spawn_fleet(p[0] if p else {}),
    'PVPService.loadChallenge': lambda p, *_: load_challenge_response(p[0] if p else {}),
    'WorldService.genericString': lambda p, *_: generic_string_response(p[0] if p else {}),
    'UserService.streakBonus': lambda p, *_: streak_bonus_response(p[0] if p else {}),
    'UserService.setWorldName': lambda p, *_: world_name_response(p[0] if p else {}),
    'WorldService.updateRoads': lambda p, *_: update_roads_response(p[0] if p else {}),
    'UserService.saveOptions': lambda p, *_: save_options_response(p[0] if p else {}),
    'UserService.setCurrentCampaign': lambda p, *_: set_current_campaign_response(p or []),
    'WorldService.viewZoom': lambda p, *_: view_zoom_response(p[0].get('zoom') if p and isinstance(p[0], dict) else 1.0),
    'WorldService.beginNextCampaign': lambda p, *_: next_campaign_response(p[0] if p else {}),
    'WorldService.addFleet': lambda p, *_: add_fleet_response(p[0] if p else {}),
    'PVPService.acceptFriendRepel': lambda p, *_: accept_friend_repel_response(p[0] if p else {}),
    'UserService.buyExpansion': lambda p, *_: buy_expansion_response(p[0] if p else {}),
    'UserService.buyItem': lambda p, *_: buy_item_response(p[0] if p else {}),
    'UserService.buyItems': lambda p, *_: buy_items_response(p[0] if p else {}),
    'UserService.useItem': lambda p, *_: use_item_response(p[0] if p else {}),
    'UserService.buyQuestTask': lambda p, *_: buy_quest_task_response(p[0] if p else {}),
    'PVPService.getNeighborVisitChallenges': lambda p, *_: neighbor_invader_response(p[0] if p else {}),
    'PVPService.loadEnemyFleetForChallenge': lambda p, *_: random_enemy_fleet_challenge_response(p[0] if p else {}),
    'SurvivalModeService.loadSurvivalMode': lambda p, *_: load_survival_mode_response(p[0] if p else {}),
    'UserService.purchaseContractUnlock': lambda p, *_: purchase_contact_unlock(p[0] if p else {}),
    'UserService.purchaseEnergyRefill': lambda p, *_: purchase_energy_refill_response(p[0] if p else {}),
    'PVPService.rejectFriendRepel': lambda p, *_: reject_friend_repel_response(p[0] if p else {}),
    'WorldService.moveRoad': lambda p, *_: update_roads_response(p[0] if p else {}),
    'WorldService.sellRoad': lambda p, *_: update_roads_response(p[0] if p else {}),
    'WorldService.select': lambda p, *_: select_response(p[0] if p else {}),
    'WorldService.openDialog': lambda p, *_: open_dialog_response(p[0] if p else None),
    'WorldService.calculateRansom': lambda p, *_: calculate_ransom_response(p[0] if p else None),
    'UserService.clearIncentive': lambda p, *_: clear_incentive_response(p[0] if p else {}),
    'UserService.doSeenQuestNotification': lambda p, *_: do_seen_quest_notification_response(p[0] if p else {}),
    'UserService.motdAction': lambda p, *_: motd_action_response(p[0] if p else {}),
    'UserService.unitUnlock': lambda p, *_: unit_unlock_response(p[0] if p else {}),
    'UserService.unitDropRevealAll': lambda p, *_: unit_drop_reveal_all_response(p[0] if p else {}),
    'UserService.unitDropSwitchUnit': lambda p, *_: unit_drop_switch_unit_response(p[0] if p else {}),
    'UserService.upgradeState': lambda p, *_: upgrade_state_response(p[0] if p else {}),
    'UserService.matchMakingOptFlag': lambda p, *_: matchmaking_opt_flag_response(p[0] if p else {}),
}


from service_handlers import EXTENDED_AMF_HANDLERS

AMF_HANDLERS.update(EXTENDED_AMF_HANDLERS)


@bp.route('/flashservices/gateway.php', methods=['POST'])
@bp.route('/files/empire-s.assets.zgncdn.com/assets/109338/127.0.0.1flashservices/gateway.php', methods=['POST'])
def post_gateway():
    print("Gateway:")
    print(repr(request))
    # print("Data:")
    # print(request.data)

    # A body pyamf cannot read is a client that spoke wrong, not a broken
    # server. Left uncaught this raised out of the Flask handler and answered
    # 500, which Ruffle reports as an unreachable gateway rather than as a
    # bad request -- so the client retried the same broken body forever.
    #
    # Deliberately wider than pyamf.DecodeError: decoding an empty body raises
    # OSError from the buffer ("Attempted to read 2 bytes ... but only 0
    # remain") and a truncated one raises from the struct decoder, and both were
    # reaching here as 500s as well. This step only parses untrusted input, so
    # any failure in it belongs to the client.
    try:
        resp_msg = remoting.decode(request.data)
    except Exception as error:
        print("Rejecting undecodable AMF body:", type(error).__name__, error)
        return make_response("Bad AMF request", 400)

    # print(resp_msg.headers)
    print(resp_msg.bodies)
    # print(resp_msg.bodies[0])

    # The envelope decoded, but it may still not be the shape the client meant:
    # no bodies at all, or a body that is not the three-part batch. Both raise
    # here, and an uncaught raise is a 500 -- which Ruffle reads as an
    # unreachable gateway and retries the same broken batch forever. Only the
    # parse of untrusted input is guarded, so a failure in it is the client's.
    try:
        batch_body = resp_msg.bodies[0][1].body
        calls = _amf_as_list(batch_body[1])
    except Exception as error:
        print("Rejecting malformed AMF batch:", type(error).__name__, error)
        return make_response("Bad AMF batch", 400)
    resps = []
    for reqq in calls:
        # The client matches responses to requests by index, so every call gets
        # exactly one answer, in its own slot. A call that produced no result
        # -- because it raised, or because the handler returned None -- used to
        # shift every later answer one slot to the left, and the client read
        # the next call's payload as this call's answer.
        if not isinstance(reqq, dict):
            print("Skipping non-object entry in AMF batch:", repr(reqq))
            resps.append(dummy_response())
            continue
        if reqq.get('params') is not None:
            reqq['params'] = _amf_as_list(reqq['params'])
        fn_name = getattr(reqq, 'functionName', None) or reqq.get('functionName')
        handler = AMF_HANDLERS.get(fn_name)
        called_at = time.perf_counter()
        if handler is not None:
            resp = _tolerate_call_failure(
                fn_name, handler, reqq.get('params'), reqq, resp_msg)
        else:
            resp = dummy_response()
        resps.append(resp if resp is not None else dummy_response())
        # Which method the client actually asked for, and what it cost.
        #
        # The access log only ever showed `POST /flashservices/gateway.php`,
        # so a batch that hung or answered the wrong shape was invisible: the
        # log could not tell you what the client was waiting on. When the
        # tab stops talking to the server entirely, the last line here is
        # the call it was processing.
        logger.info("  AMF %-46s %s (%.1fms)  args=%s",
                    (fn_name or "<sin nombre>")[:46],
                    "atendido" if handler is not None else "SIN IMPLEMENTAR",
                    (time.perf_counter() - called_at) * 1000,
                    _call_args_summary(reqq.get('params')))

        if fn_name != 'UserService.tutorialProgress' and fn_name != 'WorldService.performAction':
            report_other_log(fn_name, resps[-1], reqq, resp_msg.bodies[0][0])

    # Anything that raised got no result, and the client matches responses
    # to requests -- so a short list is a mismatched turn, not a shorter one.
    # Hand back an empty result for each, which is what an unimplemented
    # service returns anyway.
    resps = _pad_batch_results(resps, len(calls))

    emsg = _amf_detach({
        "serverTime": datetime.now().timestamp(),
        "errorType": 0,
        "data": resps
    })

    req = remoting.Response(emsg)
    ev = remoting.Envelope(pyamf.AMF0)
    ev[resp_msg.bodies[0][0]] = req
    #  print(ev.headers)
    # print(ev.bodies)

    ret_body = remoting.encode(ev, strict=True, logger=True).getvalue()  # .read()
    # print(ret_body)
    return Response(ret_body, mimetype='application/x-amf')

