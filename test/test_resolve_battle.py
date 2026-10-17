"""resolveBattle must never take the gateway down.

Nothing exercised resolveBattle until now, which is why an out-of-range unit id
kept producing "Exception on /flashservices/gateway.php" in log.txt.

The path, as it actually is: ``battle_complete_response`` guards the unit ids it
received and, when they do not address a unit in the battle, falls through to an
``else`` that re-picks live units with ``next(...)``. That ``next`` yields
**None** when no unit is left standing -- and the ``result`` dict further down
indexes ``friendly_strengths[player_unit_id]`` with whatever it got. So the
failure moved rather than disappeared, and it changed exception type: the gateway
catches ``(StaleBattleReference, IndexError)`` but not ``TypeError``.

These tests drive the real dispatch with real AMF bytes.
"""
from __future__ import annotations

import pytest
from pyamf import AMF0, remoting

empires_server = __import__("empires-server")


@pytest.fixture(scope="module")
def client(gateway_app):
    return gateway_app.test_client()


@pytest.fixture
def resolve(client, monkeypatch):
    """POST a WorldService.resolveBattle call, with init_battle stubbed.

    Stubbing init_battle is what lets this cover the two shapes the real battle
    setup produces -- a unit id that addresses nothing, and a battle where
    nothing is alive -- without building a whole island first.
    """
    import battle_engine

    def _resolve(params):
        body = [
            {"flashRevision": None},
            [{
                "transaction": None,
                "sequence": 1,
                "stamp": 1641513847112.56,
                "params": [params],
                "functionName": "WorldService.resolveBattle",
            }],
            0,
        ]
        envelope = remoting.Envelope(AMF0)
        envelope.bodies = [("/2", remoting.Request("BaseService.dispatchBatch", body=body))]
        raw = remoting.encode(envelope)
        raw = raw.getvalue() if hasattr(raw, "getvalue") else bytes(raw)
        return client.post("/flashservices/gateway.php", data=raw,
                           content_type="application/x-amf")

    return _resolve


def _stub_init_battle(monkeypatch, friendlies, strengths, baddies, baddie_strengths):
    """Replace init_battle so the battle shape is exactly what a test needs."""
    import battle_engine

    monkeypatch.setattr(
        battle_engine, "init_battle",
        lambda params: (friendlies, strengths, baddies, baddie_strengths, []),
    )


@pytest.fixture(autouse=True)
def seeded_session(client):
    """The minimum session resolveBattle reads outside the battle itself.

    ``get_seed_w``/``get_seed_z`` reach for ``session['user_object']`` on every
    turn, so a request without one raises KeyError before it ever looks at the
    units -- which would hide the case under test.
    """
    with client.session_transaction() as session:
        session["user_object"] = {
            "userInfo": {
                "player": {"level": 5, "uid": 2361750976462848, "xp": 100, "cash": 500},
                "worldName": "Test Empire",
                "world": {"randSeedW": 18000, "randSeedZ": 36969,
                          "resources": {"coins": 10}, "objects": []},
            }
        }
        session["fleets"] = {}


@pytest.fixture
def one_each_side(monkeypatch):
    """One living unit per side, which is what the else branch re-picks."""
    _stub_init_battle(
        monkeypatch,
        friendlies=["a,b,c"],
        strengths=[100],
        baddies=["d,e,f"],
        baddie_strengths=[100],
    )


class TestOutOfRangeUnitId:
    """The exact traceback in log.txt: IndexError from gateway.php."""

    def test_the_gateway_answers_200(self, client, resolve, one_each_side):
        response = resolve({"id": [0, 99], "fleet": "fleet1_1", "map": "C037"})

        assert response.status_code == 200

    def test_it_answers_with_the_dummy_result(self, client, resolve, one_each_side):
        """Not an error, and not an exception in the log."""
        response = resolve({"id": [0, 99], "fleet": "fleet1_1", "map": "C037"})

        assert b"onResult" in response.get_data()

    def test_a_negative_index_is_the_same_case(self, client, resolve, one_each_side):
        assert resolve({"id": [0, -1], "fleet": "fleet1_1", "map": "C037"}).status_code == 200

    def test_a_stale_request_does_not_poison_the_next_one(self, client, resolve, one_each_side):
        """Repeating the bad request keeps answering rather than degrading."""
        for _ in range(3):
            assert resolve({"id": [0, 99], "fleet": "fleet1_1", "map": "C037"}).status_code == 200


class TestNothingLeftStanding:
    """The case the re-pick turns into a TypeError instead."""

    def test_every_unit_dead_answers_200(self, client, resolve, monkeypatch):
        _stub_init_battle(monkeypatch, friendlies=[], strengths=[],
                          baddies=["d,e,f"], baddie_strengths=[100])

        response = resolve({"id": [0, 0], "fleet": "fleet1_1", "map": "C037"})

        assert response.status_code == 200, response.get_data()[:400]

    def test_both_sides_empty_answers_200(self, client, resolve, monkeypatch):
        _stub_init_battle(monkeypatch, friendlies=[], strengths=[],
                          baddies=[], baddie_strengths=[])

        response = resolve({"id": [0, 0], "fleet": "fleet1_1", "map": "C037"})

        assert response.status_code == 200, response.get_data()[:400]