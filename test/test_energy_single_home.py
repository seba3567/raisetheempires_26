"""Energy has one home, and it is an integer.

The shape of the bug
--------------------
``world["resources"]`` and ``player`` both carried an energy counter, and six
places in the codebase wrote to both. Three of those writes carried a question
nobody had answered -- ``#which one?``, ``# needed?``, ``#which one?``.

They diverged. A live save read ``player.energy = 27`` and
``resources.energy = 10``, and the player had drifted to ``27.0``: a float,
because a count that arrives by repeated ``+=`` stops being a count.

The mirror was never needed. The client reads ``player["energy"]`` -- that is
what ``init_user`` sends -- and ``RESOURCE_ORDER`` does not include energy, so
nothing ever showed the second number to anyone. It was a second answer to a
question that already had one, free to drift.

These tests fix which one that answer is, and that it stays an integer.
"""

from __future__ import annotations

import pytest
from flask import Flask, session

quest_engine = pytest.importorskip("quest_engine")
game_settings = pytest.importorskip("game_settings")

app = Flask(__name__)
app.secret_key = "test"


def _world(**overrides):
    resources = {"coins": 100, "energy": 25, "oil": 10, "wood": 50,
                 "aluminum": 10, "copper": 0, "gold": 0, "iron": 0, "uranium": 0}
    resources.update(overrides)
    return {"userInfo": {
        "player": {"level": 1, "xp": 0, "energy": 20, "energyMax": 25, "cash": 500,
                   "socialXpGood": 0, "socialXpBad": 0, "socialLevelGood": 0,
                   "socialLevelBad": 0, "lastEnergyCheck": 0,
                   "playerResourceType": 3, "inventory": {"items": {}}},
        "worldName": "Probe",
        "world": {"resources": resources,
                  "resourceOrder": ["aluminum", "copper", "gold", "iron", "uranium"],
                  "research": {}},
    }}


def test_the_world_copy_is_no_longer_awarded_energy():
    """A quest reward for energy must land on the player only."""
    with app.test_request_context():
        session.sid = "0"
        session["user_object"] = _world()
        session["quests"] = []

        before_world = session["user_object"]["userInfo"]["world"]["resources"]["energy"]

        quest_engine.do_rewards("Quest", [{"_type": "energy", "_count": 5}], {})

        player = session["user_object"]["userInfo"]["player"]
        world = session["user_object"]["userInfo"]["world"]["resources"]

        assert player["energy"] == 25, "the player's energy is the one that pays"
        assert world["energy"] == before_world, \
            "the world copy must not be maintained any more"


def test_energy_stays_an_integer_after_a_reward():
    """It had drifted to 27.0. A resource that counts must be an int."""
    with app.test_request_context():
        session.sid = "0"
        session["user_object"] = _world()
        session["user_object"]["userInfo"]["player"]["energy"] = 27.0
        session["quests"] = []

        quest_engine.do_rewards("Quest", [{"_type": "energy", "_count": 1}], {})

        assert isinstance(session["user_object"]["userInfo"]["player"]["energy"], int)


def test_replenishing_coerces_a_float_that_already_crept_in():
    """The one function that runs on every request mends the drift.

    A save written before this change already holds 27.0, so the cast cannot
    only be on the awards -- something has to repair what is already stored.
    """
    with app.test_request_context():
        session.sid = "0"
        session["user_object"] = _world()
        player = session["user_object"]["userInfo"]["player"]
        player["energy"] = 27.0
        player["energyMax"] = 30.0
        player["lastEnergyCheck"] = 0

        game_settings.replenish_energy()

        assert isinstance(player["energy"], int), "replenish left it a float"
        assert isinstance(player["energyMax"], int)