from __future__ import annotations

import pytest
from flask import Flask, session

empires_server = pytest.importorskip("empires-server")

app = Flask(__name__)
app.secret_key = "test-secret"


def _player(**overrides):
    player = {
        "uid": 1,
        "level": 5,
        "cash": 100,
        "energy": 10,
        "energyMax": 25,
        "lastEnergyCheck": 0,
        "seenFlags": {},
        "unlockedUnits": [],
        "motdsViewed": [],
        "motdsAccepted": [],
        "clearedIncentives": [],
        "inventory": {"items": {"U01": 2}},
    }
    player.update(overrides)
    return player


def _user_object(**overrides):
    return {
        "userInfo": {
            "player": _player(**overrides.pop("player", {})),
            "world": {
                "objects": [{"id": 42, "itemName": "Small Brick House", "state": 0}],
                "globalObjectId": 42,
                "resources": {"coins": 1000},
                "unitDropData": {"unclaimedUnits": ["U02", "U03"]},
            },
        },
        "pvp": {
            "invaders": {
                "u99": {"attacker_fleet": ["PT24,,,,"]}
            }
        },
        "quests": [],
    }


def test_targeting_groups_response():
    resp = empires_server.targeting_groups_response()
    assert resp["errorType"] == 0
    assert resp["metadata"]["newPVE"] == 0
    assert isinstance(resp["data"], list)


def test_matchmaking_users_response():
    resp = empires_server.matchmaking_users_response()
    assert resp["errorType"] == 0
    assert isinstance(resp["data"], list)
    if resp["data"]:
        candidate = resp["data"][0]
        assert "uid" in candidate
        assert "name" in candidate
        assert "country" in candidate


def test_clear_incentive_response():
    with app.test_request_context("/"):
        session["user_object"] = _user_object()
        resp = empires_server.clear_incentive_response({"incentiveId": "starter_pack_01"})
        assert resp["errorType"] == 0
        assert "starter_pack_01" in session["user_object"]["userInfo"]["player"]["clearedIncentives"]


def test_do_seen_quest_notification_response():
    with app.test_request_context("/"):
        session["user_object"] = _user_object()
        resp = empires_server.do_seen_quest_notification_response({"quest": "Q0516", "task": 0})
        assert resp["errorType"] == 0
        flags = session["user_object"]["userInfo"]["player"]["seenFlags"]
        assert flags.get("quest_seen_Q0516_0") == 1


def test_motd_action_response():
    with app.test_request_context("/"):
        session["user_object"] = _user_object()
        # Test viewed action
        resp = empires_server.motd_action_response({"motdId": "motd_halloween", "action": "viewed"})
        assert resp["errorType"] == 0
        assert "motd_halloween" in session["user_object"]["userInfo"]["player"]["motdsViewed"]

        # Test accepted action
        resp2 = empires_server.motd_action_response({"motdId": "motd_promo", "action": "accepted"})
        assert resp2["errorType"] == 0
        assert "motd_promo" in session["user_object"]["userInfo"]["player"]["motdsAccepted"]


def test_unit_unlock_response():
    with app.test_request_context("/"):
        session["user_object"] = _user_object()
        resp = empires_server.unit_unlock_response({"unitCode": "U15"})
        assert resp["errorType"] == 0
        assert "U15" in session["user_object"]["userInfo"]["player"]["unlockedUnits"]


def test_unit_drop_reveal_all_response():
    with app.test_request_context("/"):
        session["user_object"] = _user_object()
        resp = empires_server.unit_drop_reveal_all_response({})
        assert resp["errorType"] == 0
        inv = session["user_object"]["userInfo"]["player"]["inventory"]["items"]
        assert inv.get("U02", 0) >= 1
        assert inv.get("U03", 0) >= 1
        assert session["user_object"]["userInfo"]["world"]["unitDropData"]["unclaimedUnits"] == []


def test_unit_drop_switch_unit_response():
    resp = empires_server.unit_drop_switch_unit_response({})
    assert resp["errorType"] == 0
    assert resp["data"] == []


def test_matchmaking_opt_flag_response():
    with app.test_request_context("/"):
        session["user_object"] = _user_object()
        resp = empires_server.matchmaking_opt_flag_response({"optOut": True})
        assert resp["errorType"] == 0
        assert session["user_object"]["userInfo"]["player"]["matchmakingOptOut"] is True


def test_upgrade_state_response():
    with app.test_request_context("/"):
        session["user_object"] = _user_object()
        # id 42 exists in world
        resp = empires_server.upgrade_state_response({"id": 42})
        assert resp["errorType"] == 0


def test_random_enemy_fleet_challenge_resilience():
    with app.test_request_context("/"):
        session["user_object"] = _user_object()
        # Missing invader fallback
        resp = empires_server.random_enemy_fleet_challenge_response("enemy_nonexistent")
        assert resp["errorType"] == 0
        assert "challengerFleet" in resp["data"]

        # Valid invader
        resp2 = empires_server.random_enemy_fleet_challenge_response("enemy_99")
        assert resp2["errorType"] == 0
        assert resp2["data"]["challengerFleet"]["uid"] == "99"


def test_buy_quest_task_with_cash_deduction():
    with app.test_request_context("/"):
        user_obj = _user_object(player={"cash": 100})
        # Mock quest in session
        quests = [{"name": "QW122", "complete": False, "expired": False, "progress": [0, 0, 0], "completedTasks": 0}]
        user_obj["quests"] = quests
        session["user_object"] = user_obj
        session["quests"] = quests

        # QW122 task 0 costs 34 cash in questsettings
        resp = empires_server.buy_quest_task_response({"name": "QW122", "taskIndex": 0})
        assert resp["errorType"] == 0
        assert session["user_object"]["userInfo"]["player"]["cash"] == 100 - 34

        # When player cannot afford
        session["user_object"]["userInfo"]["player"]["cash"] = 5
        resp2 = empires_server.buy_quest_task_response({"name": "QW122", "taskIndex": 1})
        # Cash shouldn't drop negative and task refused
        assert session["user_object"]["userInfo"]["player"]["cash"] == 5


def test_tend_ally_handlers_resilience():
    with app.test_request_context("/"):
        session["user_object"] = _user_object()
        # visitorHelpRequests missing completely: should not raise KeyError
        resp = empires_server.accept_tend_ally_response(["999"])
        assert resp["errorType"] == 0

        resp2 = empires_server.decline_tend_ally_response(["999"])
        assert resp2["errorType"] == 0

        # Now with existing request
        session["user_object"]["visitorHelpRequests"] = {"999": "42"}
        resp3 = empires_server.decline_tend_ally_response(["999"])
        assert resp3["errorType"] == 0
        assert "999" not in session["user_object"]["visitorHelpRequests"]


def test_service_handlers_null_resilience():
    import service_handlers
    from save_engine import lookup_object, lookup_object_save

    with app.test_request_context("/"):
        # 1. user_object with None values
        session["user_object"] = {
            "userInfo": None,
            "clansInfo": None,
            "unlockedResource": {"aluminum": 3},
        }

        # Clans info should return default dict without crashing
        clan_resp = service_handlers.clans_get_clan_info()
        assert clan_resp["errorType"] == 0
        assert clan_resp["data"]["name"] == "Vanguard Alliance"

        # Update name and buy health with None or existing clan
        resp = service_handlers.clans_update_name([{"name": "Alpha Clan"}])
        assert resp["errorType"] == 0

        resp_health = service_handlers.clans_buy_health()
        assert resp_health["errorType"] == 0

        resp_feed = service_handlers.clans_post_group_feed([{"message": "Hello warriors!"}])
        assert resp_feed["errorType"] == 0
        assert len(session["user_object"]["clansInfo"]["feed"]) == 1

        # Resource unlock with dict in unlockedResource
        res_resp = service_handlers.user_unlock_resource([{"resource": "uranium"}])
        assert res_resp["errorType"] == 0
        assert "uranium" in session["user_object"]["unlockedResource"]

        # Resource unlock with list in unlockedResource
        session["user_object"]["unlockedResource"] = ["gold"]
        service_handlers.user_unlock_resource(["uranium"])
        assert "uranium" in session["user_object"]["unlockedResource"]

        # PVP global opt in with bool
        session["user_object"]["userInfo"] = {"player": {"uid": 1, "pvpOptIn": False}}
        service_handlers.pvp_global_opt_in_out([True])
        assert session["user_object"]["userInfo"]["player"]["pvpOptIn"] is True

        # Lookup object with None userInfo
        save_with_null = {"user_object": {"userInfo": None}}
        session["user_object"] = {"userInfo": None}
        assert lookup_object(42) == {}
        assert lookup_object_save(save_with_null, 42) == {}
