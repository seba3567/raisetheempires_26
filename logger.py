"""Live game logging, over socket.io.

What this is for
----------------
The four ``report_*`` functions build a diagnostic view of what the player just
did -- the tutorial step, the world action, the battle damage line -- and push
it to any browser watching. It was the admin "live log" of the 2012 build.

Why it is gated
---------------
Nothing connects. The 2013 pages that listened were deleted, and the SvelteKit
front end has no socket.io client -- the only references to it are two comments
saying the transport is long-polling. So these functions were building a
payload, encoding it and writing it to zero sockets on every world action and
every battle turn.

The expensive part is not ``emit``, it is building the argument: ``describe_step``
walks the tutorial table, the quest names are looked up and filtered, and two of
the functions round-trip the request through ``json.dumps``/``json.loads``. All of
that ran unconditionally to hand it to nobody. So the guard is at the top of
each function, before the payload is built, rather than around the emit.

Gating on the listener count rather than removing the module keeps the feature:
if a live log page is ever added back, it works with no change here.
"""
from __future__ import annotations

import json
from typing import Any

from flask_socketio import SocketIO

from game_settings import game_settings
from quest_settings import quest_settings

socketio = SocketIO()

#: True once ``init_socketio`` has mounted this on an app. Before that, and on
#: any test app that never mounted it, ``socketio.server`` has nothing to ask.
_mounted: bool = False


def init_socketio(app: Any) -> None:
    """Mount socket.io on ``app`` and mark it live.

    Called by the server entry point. Until it runs, every ``report_*`` below
    returns immediately.
    """
    global _mounted
    socketio.init_app(app)
    _mounted = True


def has_listeners() -> bool:
    """Whether anyone is connected and worth building a payload for.

    ``eio.sockets`` is the engine.io connection table; it is empty until a
    client opens a transport.
    """
    if not _mounted:
        return False
    try:
        return len(socketio.server.eio.sockets) > 0
    except AttributeError:
        # Mounted, but no engine.io server bound to this thread.
        return False


def report_tutorial_step(step: str, response: Any, new_pve: Any, sequence: Any, endpoint: str) -> None:
    if not has_listeners():
        return
    quest_names = [r['name'] for r in response] if response else []
    quests = [r for r in quest_settings['quests']['quest'] if r['_name'] in quest_names]
    socketio.emit('tutorial_step', [step, response, new_pve, describe_step(step), quests, sequence, endpoint])


def describe_step(step: str) -> dict[str, Any]:
    steps = [e for e in game_settings['settings']['tutorial']['step'] if e.get('-id') == step]
    return steps[0] if steps else {}


def report_world_log(operation: str, response: Any, req: Any, sequence: Any, endpoint: str, response2: Any, new_pve: Any) -> None:
    if not has_listeners():
        return
    quest_names = [r['name'] for r in response2] if response2 else []
    quests = [r for r in quest_settings['quests']['quest'] if r['_name'] in quest_names]
    req2 = json.loads(json.dumps(req, default=lambda o: '<not serializable>'))
    res = response[0] if isinstance(response, list) else response
    socketio.emit('world_log', [operation, res.get("id", "response") if not isinstance(res, str) else res, req2, sequence, endpoint, response2, new_pve, quests, response])


def report_other_log(service: str, response: Any, req: Any, endpoint: str) -> None:
    if not has_listeners():
        return
    req2 = json.loads(json.dumps(req, default=lambda o: '<not serializable>'))
    seq = getattr(req, 'sequence', req.get('sequence', 0) if isinstance(req, dict) else 0)
    socketio.emit('other_log', [service, response, req2, seq, endpoint])


def report_battle_log(friendly_strengths: list[Any], baddie_strengths: list[Any], player_turn: bool, player_unit_id: int | None, enemy_unit_id: int | None, active_consumables: list[Any]) -> None:
    if not has_listeners():
        return
    friendly_strengths_ = [str(s) for s in friendly_strengths]
    baddie_strengths_ = [str(s) for s in baddie_strengths]
    if player_unit_id is not None:
        mark_array_element(friendly_strengths_, player_unit_id)
    if enemy_unit_id is not None:
        mark_array_element(baddie_strengths_, enemy_unit_id)
    for _consumable, consumable_target, tries in active_consumables:
        if consumable_target[1] is None:
            for i in range(len(baddie_strengths_ if consumable_target[0] == "enemy" else friendly_strengths_)):
                mark_consumable_array_element(baddie_strengths_ if consumable_target[0] == "enemy" else friendly_strengths_, i, tries)
        else:
            mark_consumable_array_element(baddie_strengths_ if consumable_target[0] == "enemy" else friendly_strengths_, consumable_target[1], tries)

    socketio.emit('battle_log', ', '.join(friendly_strengths_) + (' => ' if player_turn else ' <= ') + ', '.join(baddie_strengths_))


def mark_array_element(strengths: list[str], unit_id: int) -> None:
    strengths[unit_id] = "[" + strengths[unit_id] + "]"


def mark_consumable_array_element(strengths: list[str], unit_id: int, tries: int) -> None:
    superscript = str.maketrans("-0123456789", "⁻⁰¹²³⁴⁵⁶⁷⁸⁹")
    strengths[unit_id] = strengths[unit_id] + "💣" + str(tries).translate(superscript)
