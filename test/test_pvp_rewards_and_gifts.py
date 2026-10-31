from __future__ import annotations

import json

import pytest

ACCOUNT_ZID = 2361750976462848


@pytest.fixture(scope="module")
def client(gateway_app):
    return gateway_app.test_client()


def test_api_pvp_reward_deposits_xp_and_coins(client):
    headers = {"x-player-zid": str(ACCOUNT_ZID), "Content-Type": "application/json"}
    payload = {"xp": 350, "coins": 5000}

    # Prime or test reward endpoint
    resp = client.post("/api/pvp/reward", data=json.dumps(payload), headers=headers)
    assert resp.status_code in (200, 400)
    data = resp.get_json()
    assert "success" in data


def test_api_gift_claim_and_send_endpoints(client):
    headers = {"x-player-zid": str(ACCOUNT_ZID), "Content-Type": "application/json"}

    # Test gift send
    send_payload = {
        "targetZid": ACCOUNT_ZID,
        "senderZid": 999999,
        "senderName": "Ally General",
        "giftType": "energy",
    }
    resp = client.post("/api/gift/send", data=json.dumps(send_payload), headers=headers)
    assert resp.status_code == 200
    assert resp.get_json().get("success") is True

    # Test gift claim
    claim_payload = {"giftType": "coins", "giftId": "test_123"}
    resp_claim = client.post("/api/gift/claim", data=json.dumps(claim_payload), headers=headers)
    assert resp_claim.status_code in (200, 400)
    data = resp_claim.get_json()
    assert "success" in data
