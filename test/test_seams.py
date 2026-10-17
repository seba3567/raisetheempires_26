"""The parts have to be able to talk to each other.

What is verified here
---------------------
Three seams, each of which this week changed underneath the others:

1. **The client and the gateway.** The SWF speaks AMF0 remoting to
   ``/flashservices/gateway.php``; pyamf decodes each call into an ``ASObject``
   and the 200-branch dispatch chain reads ``reqq.functionName`` off it. That
   only works because ASObject is a dict subclass that also answers attribute
   access -- if that ever stops being true, all 200 comparisons break at once
   and silently answer nothing.

2. **The gateway and the save store.** ``session['battle']`` and
   ``session['last_battle']`` are ``BattleContext``, a tagged ``msgspec.Struct``.
   flask-session round-trips the session through the serializer between every
   request, so if encoding or decoding loses the type, the game loses its
   battle context on the next click -- with no error anywhere, just a battle
   that stopped knowing where it was.

3. **The save and the decoder fast path.** ``decode_wrapper`` now skips the
   ``decode_objects`` walk when the payload has no ``BattleContext`` marker in
   it. That is an optimisation resting on an assumption -- that a BattleContext
   cannot exist in a payload that does not contain its tag -- so both branches
   are pinned here: the marker present means the walk runs and the type comes
   back, and the marker absent means the payload comes back untouched.
"""

from __future__ import annotations

import pytest
from pyamf import AMF0, remoting

from battle_engine import BattleContext

empires_server = __import__("empires-server")


@pytest.fixture(scope="module")
def client(gateway_app):
    return gateway_app.test_client()


@pytest.fixture(scope="module")
def serializer(gateway_app):
    """The live serializer on the configured app.

    Reached through the session interface rather than by rebuilding one, so
    this is the object the running gateway actually encodes and decodes with,
    including the ``enc_hook`` and the decode patch from empires-server.

    It comes from the shared ``gateway_app`` fixture rather than by importing
    ``wsgi``: importing that module configures a *second* app, and with it a
    second SQLAlchemy engine pointed at the real save database, which nothing
    ever disposes.
    """
    with gateway_app.app_context():
        return gateway_app.session_interface.serializer


class TestClientToGateway:
    """Seam 1: AMF0 in, dispatch on functionName, AMF0 out."""

    def _call(self, client, function_name, params=None):
        body = [
            {"flashRevision": None},
            [{
                "transaction": None,
                "sequence": 1,
                "stamp": 1641513847112.56,
                "params": params or [],
                "functionName": function_name,
            }],
            0,
        ]
        envelope = remoting.Envelope(AMF0)
        envelope.bodies = [("/2", remoting.Request("BaseService.dispatchBatch", body=body))]
        raw = remoting.encode(envelope)
        raw = raw.getvalue() if hasattr(raw, "getvalue") else bytes(raw)
        return client.post("/flashservices/gateway.php", data=raw,
                           content_type="application/x-amf")

    def test_a_decoded_call_is_an_ASObject(self):
        """The 200 dispatch comparisons depend on this, not on plain dicts."""
        body = [
            {"flashRevision": None},
            [{"transaction": None, "sequence": 1, "stamp": 1.0,
              "params": [], "functionName": "ZlingshotService.presence"}],
            0,
        ]
        envelope = remoting.Envelope(AMF0)
        envelope.bodies = [("/2", remoting.Request("BaseService.dispatchBatch", body=body))]
        raw = remoting.encode(envelope)
        raw = raw.getvalue() if hasattr(raw, "getvalue") else bytes(raw)

        decoded = remoting.decode(raw)
        call = decoded.bodies[0][1].body[1][0]

        # Attribute access is the load-bearing part.
        assert call.functionName == "ZlingshotService.presence"
        assert call.get("functionName") == "ZlingshotService.presence"
        assert isinstance(call, dict)

    def test_a_real_call_round_trips_through_the_gateway(self, client):
        response = self._call(client, "ZlingshotService.presence")

        assert response.status_code == 200
        assert b"onResult" in response.get_data()

    def test_an_unknown_service_is_answered_not_raised(self, client):
        """The client probes for services it may not have; that must not 500."""
        response = self._call(client, "SomeService.doesNotExist")

        assert response.status_code == 200


class TestGatewayToSaveStore:
    """Seam 2: a BattleContext must survive the session round trip."""

    def test_a_battle_context_survives_encode_and_decode(self, serializer):
        context = BattleContext(map_name="C037", island=42, replaying=True)
        # flask-session encodes the whole session dict, never a bare value --
        # encode() treats its argument as the session, so a lone struct raises.
        encoded = serializer.encode({"battle": [None, None, None, context]})

        restored = serializer.decode(encoded)["battle"][3]

        assert isinstance(restored, BattleContext), (
            "the save came back as "
            f"{type(restored).__name__}; a battle would lose its map and island"
        )
        assert restored.map_name == "C037"
        assert restored.island == 42
        assert restored.replaying is True

    def test_it_survives_being_nested_in_a_save(self, serializer):
        """The real shape: inside session['battle'] at index 3."""
        save = {"user_object": {"level": 9}, "battle": [[300, 300], [1, 2], [], BattleContext()]}

        restored = serializer.decode(serializer.encode(save))

        assert isinstance(restored["battle"][3], BattleContext)

    def test_it_survives_a_real_request_cycle(self, client):
        """flask-session decodes the row again between requests."""
        context = BattleContext(map_name="campaign", island=7, replaying=True)

        with client.session_transaction() as session:
            session["battle"] = context

        with client.session_transaction() as session:
            stored = session["battle"]

        assert isinstance(stored, BattleContext)
        assert stored.map_name == "campaign"
        assert stored.island == 7
        assert stored.replaying is True

    def test_a_save_without_one_comes_back_as_plain_data(self, serializer):
        save = {"user_object": {"level": 9}, "battle": [[300, 300], [1, 2], [], None]}

        restored = serializer.decode(serializer.encode(save))

        assert restored == save


class TestDecoderFastPath:
    """Seam 3: the marker check must skip only when there is nothing to do."""

    def test_the_marker_is_present_when_a_battle_is_saved(self, serializer):
        """If this ever fails the fast path silently breaks real battles."""
        encoded = serializer.encode({"battle": [None, None, None, BattleContext()]})

        assert empires_server.BATTLE_CONTEXT_MARKER in encoded

    def test_the_marker_is_absent_when_there_is_no_battle(self, serializer):
        encoded = serializer.encode({"user_object": {"level": 9}, "fleets": {}})

        assert empires_server.BATTLE_CONTEXT_MARKER not in encoded

    def test_a_payload_without_the_marker_skips_the_walk(self, serializer):
        """Nothing to convert, so the decode is handed over as msgspec made it."""
        save = {"user_object": {"level": 9}, "fleets": {"f1": ["a,b,c"]}}

        restored = serializer.decode(serializer.encode(save))

        assert restored == save

    def test_a_payload_with_the_marker_still_walks(self, serializer):
        """The other half of the assumption: presence means the walk runs."""
        encoded = serializer.encode({"battle": [None, None, None, BattleContext()]})

        restored = serializer.decode(encoded)

        assert isinstance(restored["battle"][3], BattleContext)

    def test_a_marker_in_an_unrelated_string_does_not_break_anything(self, serializer):
        """The check is on the bytes, so a literal mention counts as a false
        positive. It must cost a walk, not a wrong answer."""
        save = {"user_object": {"level": 9}, "banner": "BattleContext rules the sea"}

        restored = serializer.decode(serializer.encode(save))

        assert restored == save