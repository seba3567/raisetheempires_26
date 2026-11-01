"""The army.

Which units you have unlocked, the ones you have not opened yet, and the
state of the upgrades.
"""
from __future__ import annotations

import logging

from flask import session

from empires_gateway.amf.handlers.economy import (
    _economy_session,
)
from state_machine import (
    click_next_state,
)

logger = logging.getLogger(__name__)


def unit_unlock_response(param):
    """`UserService.unitUnlock` -- desbloquear una unidad anticipadamente."""
    meta = {"newPVE": 0}
    if not isinstance(param, dict) or _economy_session() is None:
        return {"errorType": 0, "userId": 1, "metadata": meta, "data": []}

    player = session['user_object']["userInfo"]["player"]
    code = param.get("unitCode") or param.get("itemCode") or param.get("code") or param.get("unit")
    if code:
        unlocked = player.setdefault("unlockedUnits", [])
        if code not in unlocked:
            unlocked.append(code)
        logger.info("Unit unlocked: %s", code)
    return {"errorType": 0, "userId": 1, "metadata": meta, "data": []}


def unit_drop_reveal_all_response(param):
    """`UserService.unitDropRevealAll` -- revelar todas las unidades misteriosas."""
    meta = {"newPVE": 0}
    if _economy_session() is None:
        return {"errorType": 0, "userId": 1, "metadata": meta, "data": []}

    world = session['user_object']["userInfo"]["world"]
    player = session['user_object']["userInfo"]["player"]
    inventory = player.setdefault("inventory", {}).setdefault("items", {})
    drop_data = world.setdefault("unitDropData", {})
    unclaimed = drop_data.get("unclaimedUnits", [])
    for unit_code in unclaimed:
        inventory[unit_code] = inventory.get(unit_code, 0) + 1
    drop_data["unclaimedUnits"] = []
    return {"errorType": 0, "userId": 1, "metadata": meta, "data": []}


def unit_drop_switch_unit_response(param):
    """`UserService.unitDropSwitchUnit` -- cambiar/rerollear unidad del mystery drop."""
    meta = {"newPVE": 0}
    return {"errorType": 0, "userId": 1, "metadata": meta, "data": []}


def upgrade_state_response(param):
    """`UserService.upgradeState` -- avanzar de estado al completar crew/upgrade."""
    meta = {"newPVE": 0}
    if not isinstance(param, dict):
        if isinstance(param, (int, str)):
            obj_id = int(param)
        else:
            return {"errorType": 0, "userId": 1, "metadata": meta, "data": []}
    else:
        obj_id = param.get("id") or param.get("objectId")

    if obj_id is not None:
        try:
            click_next_state(True, int(obj_id), meta, "upgradeState", None)
        except ValueError as e:
            # The object is not in the catalogue, so there is nothing to
            # upgrade. That is what the client asks for when the two content
            # sets have drifted apart, and it is answered by not upgrading.
            logger.info("Error in upgrade_state_response: %s", e)
        except Exception as e:
            logger.warning("Error in upgrade_state_response: %s", e)
    return {"errorType": 0, "userId": 1, "metadata": meta, "data": []}

