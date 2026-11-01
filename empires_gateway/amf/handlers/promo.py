"""The incentives the game offers, and the rewards they carry.

The catalogue is the game's own: the ``incentives`` section of the game
settings, which the server already loads. Every entry names a type -- the
code the client sends -- the items and the resources it gives, the text key
that describes it, the level the player has to be at and how many times it
may be claimed.

So this is not a table somebody wrote here. It is the same table the client
reads, and the reward that comes back is the reward the game defines: the
welcome energy pack, the daily bonuses, the "COMM_..." codes that handed out
resources, and the cross-promotion prizes.

``UserService.checkForPromoReward`` is the call that cashes one in.
"""
from __future__ import annotations

import logging

from fastapi_session import session

from empires_gateway.amf.handlers.economy import deposit_reward
from game_settings import game_settings

logger = logging.getLogger(__name__)

#: Where the player keeps how many times it has claimed each incentive.
CLAIMS_KEY = "incentiveClaims"

#: Where the player keeps which incentives it has already been given.
GRANTED_KEY = "grantedIncentives"


def incentive_catalogue() -> list[dict]:
    """Every incentive the game settings define."""
    section = game_settings.get("settings", {}).get("incentives", {})
    rewards = section.get("reward") if isinstance(section, dict) else section
    return rewards if isinstance(rewards, list) else []


def lookup_incentive(code: str) -> dict | None:
    """The incentive with that type, or None."""
    if not code:
        return None
    for incentive in incentive_catalogue():
        if incentive.get("-type") == code:
            return incentive
    return None


def _player() -> dict | None:
    save = session.get("user_object")
    if not isinstance(save, dict):
        return None
    user_info = save.get("userInfo")
    if not isinstance(user_info, dict):
        return None
    player = user_info.get("player")
    return player if isinstance(player, dict) else None


def _incentive_code(params) -> str:
    """The code the client asked about.

    The client sends it as an object with an ``incentiveCode`` in it. A bare
    string is accepted too, because a call with one argument is what a
    client that has not learned the shape would send.
    """
    if isinstance(params, dict):
        for key in ("incentiveCode", "code", "type"):
            value = params.get(key)
            if isinstance(value, str) and value:
                return value
        return ""
    if isinstance(params, list):
        for value in params:
            if isinstance(value, dict):
                found = _incentive_code(value)
                if found:
                    return found
            elif isinstance(value, str) and value:
                return value
        return ""
    if isinstance(params, str):
        return params
    return ""


def _claimed(player: dict, code: str) -> int:
    claims = player.get(CLAIMS_KEY)
    if not isinstance(claims, dict):
        return 0
    try:
        return int(claims.get(code, 0))
    except (TypeError, ValueError):
        return 0


def _reward_list(incentive: dict) -> list[dict]:
    """The reward as a list of the ``{type, item, count}`` the game uses.

    The catalogue writes items as one comma-separated string and resources as
    another; this splits both into the pieces that can be handed over.
    """
    rewards: list[dict] = []

    items = incentive.get("-items") or ""
    for code in str(items).split(","):
        code = code.strip()
        if code:
            rewards.append({"type": "item", "item": code, "count": 1})

    resources = incentive.get("-resources") or ""
    for entry in str(resources).split(","):
        entry = entry.strip()
        if not entry or ":" not in entry:
            continue
        name, _, amount = entry.partition(":")
        try:
            count = int(amount)
        except ValueError:
            continue
        rewards.append({"type": "resource", "item": name.strip(), "count": count})

    try:
        ep = int(incentive.get("-ep") or 0)
    except (TypeError, ValueError):
        ep = 0
    if ep:
        rewards.append({"type": "ep", "item": "ep", "count": ep})

    return rewards


def _grant(player: dict, incentive: dict) -> None:
    """Hand the reward over and remember that it was handed over."""
    for reward in _reward_list(incentive):
        if reward["type"] == "ep":
            deposit_reward("cash", "cash", reward["count"])
        else:
            deposit_reward(reward["type"], reward["item"], reward["count"])

    code = incentive.get("-type")
    claims = player.get(CLAIMS_KEY)
    if not isinstance(claims, dict):
        claims = {}
        player[CLAIMS_KEY] = claims
    claims[code] = _claimed(player, code) + 1

    granted = player.get(GRANTED_KEY)
    if not isinstance(granted, list):
        granted = []
        player[GRANTED_KEY] = granted
    if code not in granted:
        granted.append(code)


def _claim_limit(incentive: dict) -> int:
    """How many times this player may claim the incentive.

    The catalogue says it: the community promotions carry a click limit of
    hundreds, and the ones-off -- the welcome energy, the day three pack, the
    cross-promotion prizes -- carry none, or carry zero. Those are granted
    once, which is what they mean: an incentive that could be claimed for
    ever would be a way to print empire points.
    """
    try:
        limit = int(incentive.get("-clickLimit") or 0)
    except (TypeError, ValueError):
        limit = 0
    return limit if limit > 0 else 1


def _is_offerable(incentive: dict, player: dict) -> bool:
    """Whether this player may have this incentive right now.

    Three things can say no. The player may be below the level the incentive
    asks for. The incentive may have been claimed as often as it may be.
    And the ones that carry an ``-inactive`` belong to a campaign with a
    calendar -- "the fourteenth day of the campaign" -- which this server
    does not have; offering them would be offering a promotion whose window
    nobody can tell.
    """
    if incentive.get("-inactive"):
        return False

    try:
        required = int(incentive.get("-xPromoReqLevel") or 0)
    except (TypeError, ValueError):
        required = 0
    if required:
        try:
            level = int(player.get("level", 0))
        except (TypeError, ValueError):
            level = 0
        if level < required:
            return False

    code = incentive.get("-type", "")
    return _claimed(player, code) < _claim_limit(incentive)


def check_for_promo_reward_response(params):
    """`UserService.checkForPromoReward` -- the reward the client asks for.

    The client sends the incentive code it holds and expects the reward
    back: the items, the resources, the empire points and the key of the
    text that describes them. This server answers out of the game's own
    catalogue, so the reward is the one the game defines.

    A code that is not in the catalogue, a player below the level the
    incentive asks for, an incentive already claimed as often as it may be,
    and an incentive whose campaign window this server cannot know are all
    the same answer: nothing. The client reads that as "no promotion", which
    is what it is.
    """
    meta = {"newPVE": 0}
    player = _player()
    if player is None:
        return {"errorType": 0, "userId": 1, "metadata": meta, "data": []}

    code = _incentive_code(params)
    incentive = lookup_incentive(code)
    if incentive is None:
        logger.info("checkForPromoReward: unknown incentive %r", code)
        return {"errorType": 0, "userId": 1, "metadata": meta, "data": []}

    if not _is_offerable(incentive, player):
        return {"errorType": 0, "userId": 1, "metadata": meta, "data": []}

    _grant(player, incentive)

    rewards = _reward_list(incentive)
    items = [reward["item"] for reward in rewards if reward["type"] == "item"]
    resources = {
        reward["item"]: reward["count"]
        for reward in rewards
        if reward["type"] == "resource"
    }
    ep = sum(reward["count"] for reward in rewards if reward["type"] == "ep")

    return {
        "errorType": 0,
        "userId": 1,
        "metadata": meta,
        "data": [{
            "code": code,
            "items": items,
            "resources": resources,
            "ep": ep,
            "rewardText": incentive.get("-rewardText") or "",
            "rewards": rewards,
        }],
    }


def promo_data_response(params):
    """`DataServicesService.getPromoData` -- the promotions on offer.

    The sibling of ``checkForPromoReward``: the client asks what there is
    before it asks for one. The answer is the catalogue, filtered down to
    what this player may have, so that the two calls cannot disagree.
    """
    meta = {"newPVE": 0}
    player = _player()
    if player is None:
        return {"errorType": 0, "userId": 1, "metadata": meta, "data": {}}

    available = [
        incentive.get("-type")
        for incentive in incentive_catalogue()
        if _is_offerable(incentive, player)
    ]

    return {
        "errorType": 0,
        "userId": 1,
        "metadata": meta,
        "data": {"incentives": available},
    }
