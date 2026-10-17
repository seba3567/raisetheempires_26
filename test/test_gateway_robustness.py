"""The gateway used to answer 500 on malformed or out-of-order client calls.

Every case here is a traceback that actually happened on this server and is
recorded in log.txt:

* ``KeyError: 'fleets'`` from ``add_fleet_response``;
* ``AttributeError: 'int' object has no attribute 'functionName'`` from a batch
  entry that was not a call object;
* ``pyamf.DecodeError`` on a body pyamf could not read.

None of them are exotic. They are the three shapes a Flash client produces
when it and the server disagree about what the player is doing -- a fleet
arriving before the registry exists, a stray scalar in a batch, a retry with a
truncated body -- and each one used to take the whole request down.

The point of this file is not that the exceptions stopped. It is that the
server now answers: a stale or malformed call gets an empty response and the
game carries on, instead of a 500 that Ruffle reports as "gateway unreachable"
and retries forever.
"""

from __future__ import annotations

import pytest
from pyamf import AMF0, remoting

from save_engine import ensure_fleets


@pytest.fixture(scope="module")
def client(gateway_app):
    """A client on the shared throwaway gateway app. See test/conftest.py."""
    return gateway_app.test_client()


@pytest.fixture(scope="module")
def gateway_client(client):
    """A callable that posts a raw AMF0 body and returns the Flask response."""
    sequence = iter(range(1, 10_000))

    def post(body):
        envelope = remoting.Envelope(AMF0)
        envelope.bodies = [("/2", remoting.Request("BaseService.dispatchBatch", body=body))]
        raw = remoting.encode(envelope)
        raw = raw.getvalue() if hasattr(raw, "getvalue") else bytes(raw)
        return client.post("/flashservices/gateway.php", data=raw,
                           content_type="application/x-amf")

    post.sequence = sequence  # type: ignore[attr-defined]
    return post


def call(function_name, params=None, sequence=1):
    """One AMF call object, shaped the way the client sends them."""
    return {
        "transaction": None,
        "sequence": sequence,
        "stamp": 1641513847112.56,
        "params": params if params is not None else [],
        "functionName": function_name,
    }


class TestFleetRegistry:
    """`KeyError: 'fleets'` -- empires-server.py, add_fleet_response."""

    def test_ensure_fleets_creates_a_missing_key(self, client):
        with client.session_transaction() as session:
            session.pop("fleets", None)

        with client.session_transaction() as session:
            assert session.get("fleets") is None
            assert ensure_fleets(session) == {}
            assert session["fleets"] == {}

    def test_ensure_fleets_repairs_a_none_value(self, client):
        """The case the old `if 'fleets' not in session` guard missed."""
        with client.session_transaction() as session:
            session["fleets"] = None

        with client.session_transaction() as session:
            assert ensure_fleets(session) == {}
            assert session["fleets"] == {}

    @pytest.mark.parametrize("broken", ["missing", None, [], "not-a-dict"])
    def test_every_broken_shape_becomes_a_dict(self, client, broken):
        with client.session_transaction() as session:
            if broken == "missing":
                session.pop("fleets", None)
            else:
                session["fleets"] = broken

        with client.session_transaction() as session:
            assert ensure_fleets(session) == {}

    def test_a_healthy_registry_is_left_alone(self, client):
        with client.session_transaction() as session:
            session["fleets"] = {"fleet1_1": ["a,b,c"]}

        with client.session_transaction() as session:
            assert ensure_fleets(session) == {"fleet1_1": ["a,b,c"]}

    def test_ensure_fleets_returns_the_same_object_each_call(self, client):
        """Callers hold the returned dict, so it must not be re-created."""
        with client.session_transaction() as session:
            session["fleets"] = {}
            first = ensure_fleets(session)
            first["x"] = 1

            assert ensure_fleets(session)["x"] == 1

    def test_add_fleet_answers_on_a_session_with_no_registry(self, client, gateway_client):
        """The actual crash: no KeyError, and the gateway still answers 200."""
        with client.session_transaction() as session:
            session.pop("fleets", None)

        response = gateway_client([
            {"flashRevision": None},
            [call("WorldService.addFleet", [{"name": "fleet1_1", "units": ["a,b,c"]}])],
            0,
        ])

        assert response.status_code == 200
        with client.session_transaction() as session:
            assert session["fleets"]["fleet1_1"] == ["a,b,c"]

    def test_add_fleet_answers_when_the_registry_is_none(self, client, gateway_client):
        """The TypeError twin: present but None, as an editor paste leaves it."""
        with client.session_transaction() as session:
            session["fleets"] = None

        response = gateway_client([
            {"flashRevision": None},
            [call("WorldService.addFleet", [{"name": "fleet2_1", "units": ["d,e,f"]}])],
            0,
        ])

        assert response.status_code == 200
        with client.session_transaction() as session:
            assert session["fleets"]["fleet2_1"] == ["d,e,f"]


class TestMalformedBatch:
    """`AttributeError: 'int' object has no attribute 'functionName'`."""

    def test_a_scalar_entry_is_skipped_and_the_rest_answered(self, client, gateway_client):
        """One bad entry must not take down every other call in the batch."""
        response = gateway_client([
            {"flashRevision": None},
            [
                42,
                call("ZlingshotService.presence", sequence=2),
            ],
            0,
        ])

        assert response.status_code == 200

    def test_a_string_entry_is_skipped_too(self, client, gateway_client):
        response = gateway_client([
            {"flashRevision": None},
            ["not a call", call("ZlingshotService.presence", sequence=2)],
            0,
        ])

        assert response.status_code == 200

    def test_a_well_formed_batch_still_works(self, client, gateway_client):
        """The batch guard must not swallow real calls. `ZlingshotService.presence` is
        used because its handler builds a fixed dict and touches nothing."""
        response = gateway_client([
            {"flashRevision": None},
            [call("ZlingshotService.presence")],
            0,
        ])

        assert response.status_code == 200
        assert b"onResult" in response.get_data()


class TestUndecodableBody:
    """`pyamf.DecodeError` escaping as a 500."""

    def test_garbage_answers_400_not_500(self, client):
        response = client.post("/flashservices/gateway.php", data=b"not amf at all",
                               content_type="application/x-amf")

        assert response.status_code == 400

    def test_an_empty_body_answers_400(self, client):
        response = client.post("/flashservices/gateway.php", data=b"",
                               content_type="application/x-amf")

        assert response.status_code == 400

    def test_the_session_is_survived(self, client):
        """A bad body must not leave the save half-written."""
        with client.session_transaction() as session:
            session["user_object"] = {"userInfo": {"player": {"level": 7}}}

        client.post("/flashservices/gateway.php", data=b"\xff\xfe garbage",
                    content_type="application/x-amf")

        with client.session_transaction() as session:
            assert session["user_object"]["userInfo"]["player"]["level"] == 7