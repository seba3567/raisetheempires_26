from __future__ import annotations

import pytest
from flask import Flask, session

import service_handlers
from empires_gateway.amf.handlers import ranking as ranking_handlers
from save_engine import fetch_all_commanders

app = Flask(__name__)
app.secret_key = "test-secret"


def test_fetch_all_commanders():
    commanders = fetch_all_commanders()
    assert isinstance(commanders, list)
    for c in commanders:
        assert "uid" in c
        assert "zid" in c
        assert "name" in c
        assert "level" in c
        assert "rating" in c


def test_matchmaking_users_response_has_candidates():
    with app.test_request_context("/"):
        resp = ranking_handlers.matchmaking_users_response()
        assert resp["errorType"] == 0
        assert isinstance(resp["data"], list)
        assert len(resp["data"]) > 0
        candidate = resp["data"][0]
        assert "uid" in candidate
        assert "name" in candidate
        assert "country" in candidate


def test_leaderboards_response_connected():
    with app.test_request_context("/"):
        session["user_object"] = {
            "userInfo": {
                "player": {
                    "uid": 9999,
                    "level": 18,
                    "xp": 3500,
                    "name": "Ace Commander"
                }
            }
        }
        resp = ranking_handlers.leaderboards_response()
        assert resp["errorType"] == 0
        data = resp["data"]
        assert "campaign" in data
        assert "pvp" in data
        assert "domination" in data
        assert "Week52" in data

        # Check rankings are monotonic
        campaign = data["campaign"]
        assert len(campaign) >= 4
        for i in range(len(campaign) - 1):
            assert campaign[i]["value"] >= campaign[i + 1]["value"]
            assert campaign[i]["rank"] == i + 1


def test_pvp_fight_list_and_challenges():
    with app.test_request_context("/"):
        session["user_object"] = {
            "userInfo": {
                "player": {"uid": 111}
            }
        }
        resp = service_handlers.pvp_get_fight_list()
        assert resp["errorType"] == 0
        data = resp["data"]["fightList"] if isinstance(resp["data"], dict) else resp["data"]
        assert isinstance(data, list)
        assert len(data) > 0

        # Self (uid 111) should be excluded from targets
        uids = [str(item["uid"]) for item in data]
        assert "111" not in uids

        resp_challenges = service_handlers.pvp_get_all_challenges()
        assert resp_challenges["errorType"] == 0
        assert "incoming" in resp_challenges["data"]
        assert "outgoing" in resp_challenges["data"]


def test_deathmatch_opponents_connected(monkeypatch):
    monkeypatch.setattr(
        service_handlers,
        "get_saves",
        lambda: [
            {
                "user_object": {
                    "userInfo": {
                        "worldName": "Valkyrie Island",
                        "player": {"uid": 7777, "name": "General Valkyrie", "level": 22, "xp": 4200},
                    }
                }
            }
        ],
    )
    with app.test_request_context("/"):
        resp = service_handlers.deathmatch_fetch_opponents()
        assert resp["errorType"] == 0
        assert isinstance(resp["data"], list)
        assert len(resp["data"]) >= 4
        valkyrie = next((o for o in resp["data"] if o["uid"] == 7777), None)
        assert valkyrie is not None
        assert valkyrie["level"] == 22
        assert valkyrie["score"] == 4200


def test_mana_refill_preserves_dict_shape():
    with app.test_request_context("/"):
        session["user_object"] = {
            "userInfo": {
                "player": {
                    "uid": 1,
                    "cash": 20,
                    "mana": {"value": 15},
                    "manaMax": 100,
                }
            }
        }
        resp = service_handlers.user_purchase_mana_refill()
        assert resp["errorType"] == 0
        player = session["user_object"]["userInfo"]["player"]
        assert player["cash"] == 15
        assert player["mana"] == {"value": 100}


def test_save_migration_from_0_08a_updates_save_version():
    import save_migration

    with app.test_request_context("/"):
        session["save_version"] = "0.08a"
        session["user_object"] = {
            "experiments": {"empire_mech_lab_master": 3},
            "userInfo": {"world": {"objects": []}},
        }
        save_migration.migrate({}, "0.08a", "0.08a.2026_08_13")
        assert session["save_version"] == "0.08a.2026_08_13"
        assert session["user_object"]["experiments"]["empire_domination_master"] == 4
        assert session["user_object"]["experiments"]["empire_alliances_master"] == 3
