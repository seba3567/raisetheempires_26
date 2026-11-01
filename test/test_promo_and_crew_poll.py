"""The two methods that used to answer with nothing.

``UserService.checkForPromoReward`` and ``UserService.crewNeighborPoll`` were
the last two on the surface that answered with the empty result, which is
what a feature that does not exist looks like from the outside. Both are
answered now, out of the game's own data:

* the incentive catalogue is the ``incentives`` section of the game settings,
  which says what every code gives, what level it needs and how many times
  it may be claimed;
* the crew poll reads the crew templates, so it knows which slots a
  neighbour has empty.

These tests pin the rules, because a promotion that pays out twice, or one
that pays out below the level it asks for, is worse than no promotion.
"""
from __future__ import annotations

import pytest
from flask import Flask, session

from empires_gateway.amf.handlers import promo as promo_handlers
from empires_gateway.amf.handlers import world as world_handlers

app = Flask(__name__)
app.secret_key = "test-secret"


def _user_object(level: int = 5, **player_overrides):
    player = {
        "uid": 1,
        "level": level,
        "cash": 100,
        "xp": 0,
        "energy": 10,
        "inventory": {"items": {}},
    }
    player.update(player_overrides)
    return {
        "userInfo": {
            "player": player,
            "world": {"objects": [], "resources": {"coins": 1000}},
        }
    }


@pytest.fixture
def save_in_session():
    with app.test_request_context("/"):
        session["user_object"] = _user_object()
        yield session["user_object"]


class TestThePromotionalReward:
    def test_a_known_code_hands_the_reward_over(self, save_in_session):
        """The catalogue says what the code gives, and the player gets it."""
        response = promo_handlers.check_for_promo_reward_response(
            {"incentiveCode": "D3"}
        )

        data = response["data"]
        assert len(data) == 1, "the reward came back empty"

        incentive = data[0]
        assert incentive["code"] == "D3"
        # The catalogue: items="EN3,N02" resources="coins:50".
        assert incentive["items"] == ["EN3", "N02"]
        assert incentive["resources"] == {"coins": 50}

        inventory = save_in_session["userInfo"]["player"]["inventory"]["items"]
        assert inventory["EN3"] == 1
        assert inventory["N02"] == 1
        assert save_in_session["userInfo"]["world"]["resources"]["coins"] == 1050

    def test_the_empire_points_go_to_the_cash(self, save_in_session):
        """``ep`` is what the game calls empire points, and they are cash."""
        incentive = promo_handlers.lookup_incentive("14d5")
        assert incentive is not None
        assert incentive.get("-ep") == "5"

    def test_an_unknown_code_gets_nothing(self, save_in_session):
        response = promo_handlers.check_for_promo_reward_response(
            {"incentiveCode": "no-existe"}
        )
        assert response["data"] == []

    def test_a_player_below_the_level_gets_nothing(self, save_in_session):
        """The cross-promotion prizes ask for level 5."""
        save_in_session["userInfo"]["player"]["level"] = 1
        response = promo_handlers.check_for_promo_reward_response(
            {"incentiveCode": "CP_AW1"}
        )
        assert response["data"] == []

    def test_a_player_at_the_level_gets_it(self, save_in_session):
        save_in_session["userInfo"]["player"]["level"] = 5
        response = promo_handlers.check_for_promo_reward_response(
            {"incentiveCode": "CP_AW1"}
        )
        assert len(response["data"]) == 1
        assert response["data"][0]["items"] == ["UA08"]

    def test_the_click_limit_is_kept(self, save_in_session):
        """A code that may be claimed 250 times stops at 250."""
        code = "COMM_CS1"
        for _ in range(250):
            response = promo_handlers.check_for_promo_reward_response(
                {"incentiveCode": code}
            )
            assert response["data"], "the claim was refused before the limit"

        response = promo_handlers.check_for_promo_reward_response({"incentiveCode": code})
        assert response["data"] == [], "the click limit was not kept"

    def test_a_one_off_incentive_is_claimed_once(self, save_in_session):
        """An incentive with no click limit is granted once.

        Without this, any code the client cared to send would pay out for
        ever, which is a way to print empire points.
        """
        code = "D3"
        first = promo_handlers.check_for_promo_reward_response({"incentiveCode": code})
        assert first["data"], "the first claim was refused"

        second = promo_handlers.check_for_promo_reward_response({"incentiveCode": code})
        assert second["data"] == [], "a one-off incentive was paid twice"

        inventory = save_in_session["userInfo"]["player"]["inventory"]["items"]
        assert inventory["EN3"] == 1, "the reward was handed over twice"

    def test_a_zero_click_limit_is_also_once(self, save_in_session):
        """The cross-promotion prizes carry a click limit of zero."""
        code = "CP_AW1"
        first = promo_handlers.check_for_promo_reward_response({"incentiveCode": code})
        assert first["data"], "the first claim was refused"

        second = promo_handlers.check_for_promo_reward_response({"incentiveCode": code})
        assert second["data"] == [], "a zero-click incentive was paid twice"

    def test_the_claims_are_counted(self, save_in_session):
        promo_handlers.check_for_promo_reward_response({"incentiveCode": "D3"})
        assert save_in_session["userInfo"]["player"]["incentiveClaims"]["D3"] == 1
        assert "D3" in save_in_session["userInfo"]["player"]["grantedIncentives"]

    def test_a_campaign_without_a_calendar_is_not_offered(self, save_in_session):
        """The "fourteenth day" incentives need a campaign epoch to be dated."""
        incentive = promo_handlers.lookup_incentive("14d3")
        assert incentive is not None, "the catalogue changed"
        response = promo_handlers.check_for_promo_reward_response(
            {"incentiveCode": "14d3"}
        )
        assert response["data"] == []

    def test_the_code_can_arrive_as_a_bare_string(self, save_in_session):
        response = promo_handlers.check_for_promo_reward_response("D7")
        assert len(response["data"]) == 1


class TestThePromoData:
    def test_it_lists_what_the_player_may_have(self, save_in_session):
        response = promo_handlers.promo_data_response([])
        incentives = response["data"]["incentives"]
        assert "D3" in incentives
        # The cross-promotion prizes need level 5 and this player is level 5.
        assert "CP_AW1" in incentives
        # The dated ones cannot be dated, so they are not on offer.
        assert "14d3" not in incentives

    def test_the_two_calls_agree(self, save_in_session):
        """What the data lists, the reward call can actually hand over."""
        offered = promo_handlers.promo_data_response([])["data"]["incentives"]
        for code in offered[:5]:
            response = promo_handlers.check_for_promo_reward_response(
                {"incentiveCode": code}
            )
            assert response["data"], f"{code} is on offer but cannot be claimed"


class TestTheNeighbourPoll:
    def _neighbour_save(self, uid: int, crewed: int):
        """A save with one crewable building and ``crewed`` crew in it."""
        template = None
        from game_settings import lookup_crew_template

        template = lookup_crew_template("Parliament")
        positions = [slot["-key"] for slot in template["position"]]
        return {
            "user_object": {
                "userInfo": {
                    "player": {"uid": uid},
                    "world": {
                        "objects": [{
                            "id": 1000,
                            "itemName": "Parliament",
                            "crewInfo": list(range(crewed)),
                        }],
                        "resources": {},
                    },
                }
            }
        }

    def test_a_neighbour_with_a_free_slot_is_offered(self, monkeypatch):
        """The Parliament has three slots; one crew member leaves two free."""
        neighbour = self._neighbour_save(42, crewed=1)
        monkeypatch.setattr(world_handlers, "get_saves", lambda: [neighbour])

        with app.test_request_context("/"):
            session["user_object"] = _user_object()
            response = world_handlers.crew_neighbor_poll_response("parliament2")
        assert response["data"] == [42]

    def test_a_filled_slot_is_not_offered(self, monkeypatch):
        """The slot the crew already sits in is not free."""
        neighbour = self._neighbour_save(42, crewed=1)
        monkeypatch.setattr(world_handlers, "get_saves", lambda: [neighbour])

        with app.test_request_context("/"):
            session["user_object"] = _user_object()
            response = world_handlers.crew_neighbor_poll_response("parliament1")
        assert response["data"] == []

    def test_a_neighbour_with_no_free_slot_is_not(self, monkeypatch):
        neighbour = self._neighbour_save(42, crewed=3)
        monkeypatch.setattr(world_handlers, "get_saves", lambda: [neighbour])

        with app.test_request_context("/"):
            session["user_object"] = _user_object()
            response = world_handlers.crew_neighbor_poll_response("parliament1")
        assert response["data"] == []

    def test_the_player_does_not_get_asked(self, monkeypatch):
        """The player cannot lend to itself."""
        with app.test_request_context("/"):
            session["user_object"] = _user_object()
            mine = self._neighbour_save(1, crewed=0)
            monkeypatch.setattr(world_handlers, "get_saves", lambda: [mine])

            response = world_handlers.crew_neighbor_poll_response("parliament1")
            assert response["data"] == []

    def test_without_a_slot_there_is_nothing_to_ask(self, monkeypatch):
        monkeypatch.setattr(world_handlers, "get_saves", list)
        response = world_handlers.crew_neighbor_poll_response("")
        assert response["data"] == []
