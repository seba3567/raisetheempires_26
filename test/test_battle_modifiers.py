"""The counters the game is built on, and the bits that used to crash.

Three things are pinned here:

* the ``against`` modifier of a unit -- a bomber is worth one and a half
  against a tank -- used to be in the catalogue and never reached the
  damage, so every unit hit every other one exactly as hard;
* a mega unit is "mega_arm,tank,land,mega": a mega arm that acts as a
  tank. The modifier has to see the tank;
* the bits of the engine that raised instead of answering: a session with
  no fleets, an ally fleet that is not there any more, a unit the
  catalogue knows without a nested definition.
"""
from __future__ import annotations

import pytest
from flask import Flask, session

import battle_engine
from game_settings import lookup_item_by_code

app = Flask(__name__)
app.secret_key = "test-secret"


@pytest.fixture
def session_in_request():
    with app.test_request_context("/"):
        yield session


class TestTheAgainstModifier:
    def test_a_bomber_is_worth_more_against_a_tank(self):
        """The catalogue says so: the bomber is worth one and a half."""
        bomber = lookup_item_by_code("U02")
        tank = lookup_item_by_code("LU01")

        assert battle_engine.get_against_modifier(bomber, tank) == 1.5

    def test_and_nothing_more_against_something_else(self):
        bomber = lookup_item_by_code("U02")
        infantry = lookup_item_by_code("U01")

        assert battle_engine.get_against_modifier(bomber, infantry) == 1.0

    def test_a_mega_arm_acts_as_a_tank(self):
        """The second slot of a mega unit's type is the class it acts as."""
        mega_arm = lookup_item_by_code("ML02")
        tank = lookup_item_by_code("LU01")

        assert battle_engine.get_unit_type(mega_arm) == "mega_arm"
        assert battle_engine.get_unit_acting_class(mega_arm) == "tank"
        # So the bomber gets its bonus against it.
        bomber = lookup_item_by_code("U02")
        assert battle_engine.get_against_modifier(bomber, mega_arm) == 1.5

    def test_an_ordinary_unit_has_no_other_class(self):
        """For everybody else the second slot is the terrain."""
        assert battle_engine.get_unit_acting_class(lookup_item_by_code("U01")) == ""

    def test_a_unit_without_a_modifier_is_unchanged(self):
        assert battle_engine.get_against_modifier(
            lookup_item_by_code("U01"), lookup_item_by_code("LU01")
        ) == 1.0

    def test_a_unit_the_catalogue_does_not_know_is_not_a_crash(self):
        assert battle_engine.get_against_modifier({}, {}) == 1.0


class TestTheBaseDamage:
    def test_it_comes_from_the_game_settings(self):
        """The number is the game's, not one written down in the engine."""
        from game_settings import game_settings

        section = game_settings["settings"]["combatDamage"]
        expected = float(str(section["-combatDamageBase"]).split(",")[0])

        assert battle_engine.get_base_damage() == expected


class TestThePartsThatUsedToRaise:
    def test_a_session_with_no_fleets(self, session_in_request):
        """The old code indexed session["fleets"] straight away."""
        session_in_request.sid = "0"
        assert "fleets" not in session_in_request
        assert battle_engine.get_last_fleet_name().startswith("fleet")

    def test_an_ally_fleet_that_is_not_there(self, session_in_request):
        """The old code took the first match and threw when there was none."""
        session_in_request["fleets"] = {"fleet1_1": ["U01,,,"]}
        assert battle_engine.get_friendly_by_ally_fleet("fleet2_999") == ""

    def test_an_ally_fleet_that_is_there(self, session_in_request):
        """The ally fleet is keyed with the name of the fleet it points at."""
        session_in_request["fleets"] = {"ally_fleet2_999": ["fleet2_999"]}
        assert battle_engine.get_friendly_by_ally_fleet("fleet2_999") == "fleet2_999"

    def test_a_unit_without_a_nested_definition(self):
        """A building the catalogue knows has no second weapon."""
        building = {"-code": "CA2", "-name": "Parliament"}
        assert battle_engine.get_unit_secondary(building) is None

    def test_a_unit_that_has_one(self):
        unit = {"unit": {"-secondary": "rocket"}}
        assert battle_engine.get_unit_secondary(unit) == "rocket"


def _bomber(with_modifier: bool):
    """A bomber, with or without the bonus it has against tanks."""
    unit = {"-code": "U02", "-name": "Bomber", "unit": {"-type": "bomber,aircraft", "-strength": "100"}}
    if with_modifier:
        unit["unit"]["against"] = [{"-type": "tank", "-mod": "1.5"}]
    return unit


def _tank():
    return {"-code": "LU01", "-name": "Tank", "unit": {"-type": "tank,land", "-strength": "100"}}


def _damage_dealt(attacker, defender, session_in_request, monkeypatch):
    """How much damage the attacker deals, in one turn of a real battle."""
    strengths = [100]
    baddie_strengths = [100]
    monkeypatch.setattr(
        battle_engine,
        "init_battle",
        lambda params: ([attacker], strengths, [defender], baddie_strengths, []),
    )
    # The seed decides the roll, so it is put back before every turn.
    world = session_in_request["user_object"]["userInfo"]["world"]
    world["randSeedW"] = 18000
    world["randSeedZ"] = 36969

    battle_engine.battle_complete_response({"id": [0, 0], "fleet": "fleet1_1"})

    return 100 - baddie_strengths[0]


class TestTheCounterReachesTheDamage:
    """The modifier is not only read: it has to be in the damage.

    The turn is played for real here -- the same one the client plays -- with
    the two units differing in nothing but the bonus they carry.
    """

    @pytest.fixture
    def seeded(self, session_in_request):
        session_in_request["user_object"] = {
            "userInfo": {
                "player": {
                    "level": 5,
                    "uid": 2361750976462848,
                    "xp": 100,
                    "cash": 500,
                    "energy": 25,
                    "energyMax": 25,
                    "lastEnergyCheck": 0,
                },
                "world": {
                    "randSeedW": 18000,
                    "randSeedZ": 36969,
                    "resources": {"coins": 10},
                    "objects": [],
                },
            }
        }
        session_in_request["fleets"] = {}
        session_in_request["quests"] = []
        return session_in_request

    def test_a_bomber_hits_a_tank_harder(self, seeded, monkeypatch):
        """One and a half the damage, because that is what the catalogue says."""
        plain = _damage_dealt(_bomber(False), _tank(), seeded, monkeypatch)
        with_bonus = _damage_dealt(_bomber(True), _tank(), seeded, monkeypatch)

        assert with_bonus > plain, (
            f"the against modifier did not reach the damage: {plain} vs {with_bonus}"
        )
        # The damage is rounded up to a whole number, so the ratio is close
        # and not exact.
        assert with_bonus == pytest.approx(plain * 1.5, abs=1)

