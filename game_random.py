"""The game's random numbers, and the one place that owns them.

The client simulates the battle, so both sides have to draw the same number
of values in the same order. When they do not, the client stops the fight
with "ZGameRandom fatally out of sync" and asks for a refresh: the numbers
it holds are not the numbers the server holds, and everything the client
shows from that point on is fiction.

That makes the *count* of the draws part of the contract, not an
implementation detail. This module owns the seeds, the step and the count, so
that "how many have we drawn" has one answer, and the server can say it out
loud in the answer to the turn.

The generator is the one the 2012 client shipped with: two 16-bit halves,
each multiplied and carried, and the number drawn is the two of them joined.
The client reads the halves out of the player's world -- ``randSeedW`` and
``randSeedZ`` -- so those are the names they keep here.

There is a second pair of seeds, ``rewardRandSeedW`` and
``rewardRandSeedZ``, for the rewards. They are a stream of their own: a
reward is not a battle, and paying one out must not move the battle's
numbers.
"""
from __future__ import annotations

from typing import Any

from flask import session

MASK = 0xFFFFFFFF

#: The multipliers of the two halves.
W_MULTIPLIER = 18000
Z_MULTIPLIER = 36969

#: The seeds a new empire starts with.
START_W = 5445
START_Z = 844

#: Where the seeds live in the world, and where the count of the draws goes.
SEED_W = "randSeedW"
SEED_Z = "randSeedZ"
DRAWS = "randDraws"
REWARD_SEED_W = "rewardRandSeedW"
REWARD_SEED_Z = "rewardRandSeedZ"
REWARD_DRAWS = "rewardRandDraws"


def world() -> dict[str, Any]:
    """The world of the empire in the session.

    It is the same world the client is told about, and it is where the seeds
    live: they are part of the save, so a fight that is resumed keeps the
    numbers it started with.
    """
    save = session["user_object"]
    return save["userInfo"]["world"]


def seeds() -> tuple[int, int]:
    """The two halves of the battle's stream, as they are right now."""
    the_world = world()
    return (
        int(the_world.get(SEED_W, START_W)),
        int(the_world.get(SEED_Z, START_Z)),
    )


def get_seed_w() -> int:
    return seeds()[0]


def get_seed_z() -> int:
    return seeds()[1]


def draws() -> int:
    """How many values have been drawn from the battle's stream.

    The client counts them too, and the two counts have to agree: that is
    what "out of sync" means. The count is in the save so that it survives
    a fight that is resumed.
    """
    return int(world().get(DRAWS, 0))


def _step(value: int, multiplier: int) -> int:
    """One step of the generator: multiply the low half, carry the high one."""
    return (multiplier * (value & 0xFFFF) + ((value >> 16) & 0xFFFF)) & MASK


def _draw(w_key: str, z_key: str, count_key: str, start_w: int, start_z: int) -> int:
    """Draw one value from a stream of seeds, and count the draw."""
    the_world = world()
    the_world.setdefault(w_key, start_w)
    the_world.setdefault(z_key, start_z)

    before = (int(the_world[w_key]), int(the_world[z_key]))
    w = _step(before[0], W_MULTIPLIER)
    z = _step(before[1], Z_MULTIPLIER)

    the_world[w_key] = w
    the_world[z_key] = z
    the_world[count_key] = int(the_world.get(count_key, 0)) + 1

    # This line is how a desync is found: the client's complaint quotes the
    # seeds it holds, and this quotes the ones the server holds.
    print(
        f"Seed {before[0]}, {before[1]} => {w}, {z}",
        f"(draw {the_world[count_key]})",
    )

    return ((z << 16) + w) & MASK


def roll_random() -> int:
    """Draw a number from the battle's stream."""
    return _draw(SEED_W, SEED_Z, DRAWS, START_W, START_Z)


def roll_random_float() -> float:
    number = roll_random() / (2 ** 32 - 1)
    return (number * 10 ** 3) // 10 ** 3


def roll_random_between(a: float, b: float) -> float:
    return roll_random_float() * (b - a) + a


def roll_reward_random() -> int:
    """Draw a number from the rewards' stream, which is its own."""
    return _draw(REWARD_SEED_W, REWARD_SEED_Z, REWARD_DRAWS, 484584, 7549)


def roll_reward_random_float() -> float:
    number = roll_reward_random() / (2 ** 32 - 1)
    return (number * 10 ** 3) // 10 ** 3


def roll_reward_random_between(a: float, b: float) -> float:
    return roll_reward_random_float() * (b - a) + a
