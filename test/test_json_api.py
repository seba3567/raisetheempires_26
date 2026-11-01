"""Tests for the JSON mirror of the AMF0 dispatch table.

The gateway now speaks HTTP+JSON alongside AMF0. These tests pin the two
surfaces (method listing and generic call) so a future change to the
dispatch table or to the JSON serialiser does not silently break them.
"""
from __future__ import annotations

import json

import pytest


@pytest.fixture(scope="module")
def client(gateway_app):
    return gateway_app.test_client()


def test_methods_lists_known_services(client):
    response = client.get("/api/v1/methods")

    assert response.status_code == 200
    body = response.get_json()
    assert isinstance(body["methods"], list)
    assert "UserService.initUser" in body["methods"]
    assert "WorldService.sendZaspReport" in body["methods"]


def test_call_unknown_method_returns_404(client):
    response = client.post(
        "/api/v1/call",
        data=json.dumps({"method": "NoSuch.Service", "params": []}),
        content_type="application/json",
    )

    assert response.status_code == 404
    body = response.get_json()
    assert body["error"] == "unknown method"


def test_call_init_user_returns_player(client):
    response = client.post(
        "/api/v1/call",
        data=json.dumps({"method": "UserService.initUser", "params": []}),
        content_type="application/json",
    )

    assert response.status_code == 200
    body = response.get_json()
    assert body["method"] == "UserService.initUser"
    result = body["result"]
    # The handler returns its own envelope, not the AMF batch envelope.
    assert result["errorType"] == 0
    assert isinstance(result["data"], dict)


def test_call_send_zasp_report_returns_dummy(client):
    response = client.post(
        "/api/v1/call",
        data=json.dumps({"method": "WorldService.sendZaspReport", "params": [{}]}),
        content_type="application/json",
    )

    assert response.status_code == 200
    body = response.get_json()
    assert body["result"] is not None


def test_call_without_body_does_not_crash(client):
    response = client.post("/api/v1/call", content_type="application/json")

    assert response.status_code == 404


def test_friendly_user_init_alias(client):
    response = client.post("/api/v1/user/init")

    assert response.status_code == 200
    body = response.get_json()
    assert body["method"] == "UserService.initUser"
    assert body["result"]["errorType"] == 0
