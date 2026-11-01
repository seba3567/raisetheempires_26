"""The random numbers, and the count of them.

The client simulates the battle, so the two sides have to draw the same
number of values in the same order. When they do not, the client stops the
fight with "ZGameRandom fatally out of sync" and asks for a refresh.

Two things are pinned here:

* the generator has one owner, and it counts what it draws;
* a turn draws exactly once, even when a unit is weak and the number it
  draws is thrown away.

The second one was the bug. A turn where the enemy was weak did not draw at
all, the client drew, and the two streams ended up a step apart.
"""
from __future__ import annotations

import pytest
from flask import Flask, session

import battle_engine
import game_random

app = Flask(__name__)
app.secret_key = "test-secret"


@pytest.fixture
def empire():
    """A world with the seeds a new empire starts with."""
    with app.test_request_context("/"):
        session["user_object"] = {
            "userInfo": {
                "player": {"uid": 1, "level": 5, "xp": 0, "cash": 0, "energy": 25},
                "world": {
                    "randSeedW": game_random.START_W,
                    "randSeedZ": game_random.START_Z,
                    "resources": {"coins": 0},
                    "objects": [],
                },
            }
        }
        yield session["user_object"]


class TestTheOwner:
    def test_it_starts_where_the_game_says(self, empire):
        assert game_random.get_seed_w() == game_random.START_W
        assert game_random.get_seed_z() == game_random.START_Z

    def test_it_counts_what_it_draws(self, empire):
        assert game_random.draws() == 0
        game_random.roll_random()
        assert game_random.draws() == 1
        game_random.roll_random()
        assert game_random.draws() == 2

    def test_the_count_survives_in_the_save(self, empire):
        """The count is part of the world, so a resumed fight keeps it."""
        game_random.roll_random()
        assert empire["userInfo"]["world"]["randDraws"] == 1

    def test_the_rewards_have_a_stream_of_their_own(self, empire):
        """Paying a reward out must not move the battle's numbers."""
        before = game_random.seeds()
        game_random.roll_reward_random()
        assert game_random.seeds() == before
        assert empire["userInfo"]["world"]["rewardRandDraws"] == 1

    def test_the_seeds_move_the_way_the_client_moves_them(self, empire):
        """The client reads the same two halves and steps them the same way."""
        before = game_random.seeds()
        game_random.roll_random()
        after = game_random.seeds()

        for half, multiplier in ((before[0], 18000), (before[1], 36969)):
            expected = (multiplier * (half & 0xFFFF) + ((half >> 16) & 0xFFFF)) & 0xFFFFFFFF
            assert expected in after


class TestTheTurn:
    def test_a_weak_unit_still_draws(self, empire):
        """The bug: a weak unit made the server skip the draw.

        The client draws every turn and throws the number away when a unit
        is weak. The server has to draw as well, or the two streams get a
        step apart and the client refuses the fight.
        """
        assert game_random.draws() == 0
        assert battle_engine.unit_roll(attacker_weak=True, defender_weak=False) == -2
        assert game_random.draws() == 1

        assert battle_engine.unit_roll(attacker_weak=False, defender_weak=True) == 2
        assert game_random.draws() == 2

    def test_a_plain_turn_draws_once_too(self, empire):
        assert game_random.draws() == 0
        battle_engine.unit_roll(attacker_weak=False, defender_weak=False)
        assert game_random.draws() == 1

    def test_the_roll_still_says_who_is_weak(self, empire):
        """The value of the roll is what the client checks as well."""
        assert battle_engine.unit_roll(True, False) == -2
        assert battle_engine.unit_roll(False, True) == 2
        plain = battle_engine.unit_roll(False, False)
        assert 0 <= plain <= 1
