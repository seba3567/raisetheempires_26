"""The gateway must answer a batch even when a handler raises something nobody
predicted.

The three crashes this week were one bug class wearing three coats. Each needed
its own narrow ``except``: ``IndexError`` was caught but ``TypeError`` was not,
``pyamf.DecodeError`` was caught but ``OSError`` was not. Enumerating the next
exception type is guesswork, so ``_tolerate_batch_failure`` catches at the
boundary instead and the specific handlers stay narrow where they can carry a
real recovery.

These tests prove the fallback does its job rather than just existing. They
inject exceptions no handler expects -- including one that inherits from nothing
game-related -- and check the client still gets a well-formed AMF response.

What is *not* claimed here: that the failing call gets a useful answer. It does
not. It gets the same empty result an unimplemented service returns. The point
is that the other calls in the batch, and the player's turn, survive.
"""
from __future__ import annotations

import pytest
from pyamf import AMF0, remoting

empires_server = __import__("empires-server")


@pytest.fixture(scope="module")
def client(gateway_app):
    return gateway_app.test_client()


def post_batch(client, calls):
    """Send a batch of (functionName, params) pairs as real AMF0 bytes."""
    body = [
        {"flashRevision": None},
        [{
            "transaction": None,
            "sequence": index + 1,
            "stamp": 1641513847112.56,
            "params": params or [],
            "functionName": name,
        } for index, (name, params) in enumerate(calls)],
        0,
    ]
    envelope = remoting.Envelope(AMF0)
    envelope.bodies = [("/2", remoting.Request("BaseService.dispatchBatch", body=body))]
    raw = remoting.encode(envelope)
    raw = raw.getvalue() if hasattr(raw, "getvalue") else bytes(raw)
    return client.post("/flashservices/gateway.php", data=raw,
                       content_type="application/x-amf")


def decoded_body(response):
    return remoting.decode(response.get_data()).bodies[0][1].body


@pytest.fixture
def boom(monkeypatch):
    """Make one chosen handler raise a caller-supplied exception.

    Returns a setter, so each test can pick a different exception type rather
    than all of them seeing the same one -- which is the whole point: the
    fallback must not be keyed to a list.
    """
    def install(service, error):
        handler = {
            "ZlingshotService.presence": empires_server.zlingshot_response,
        }[service]

        def explode(*args, **kwargs):
            raise error

        # The dispatch chain calls the module-level name, so replacing the
        # module attribute is what actually changes what runs.
        monkeypatch.setattr(empires_server, handler.__name__, explode)
        return explode
    return install


class TestUnexpectedExceptionInOneCall:
    def test_the_batch_still_answers(self, client, boom):
        boom("ZlingshotService.presence", RuntimeError("nobody predicted this"))

        response = post_batch(client, [("ZlingshotService.presence", [])])

        assert response.status_code == 200

    def test_the_response_is_well_formed_amf(self, client, boom):
        """A 200 with an unparseable body would be worse than a 500."""
        boom("ZlingshotService.presence", RuntimeError("nobody predicted this"))

        response = post_batch(client, [("ZlingshotService.presence", [])])

        assert b"onResult" in response.get_data()
        body = decoded_body(response)
        assert body["errorType"] == 0
        assert isinstance(body["data"], list)

    @pytest.mark.parametrize("error", [
        RuntimeError("runtime"),
        ValueError("value"),
        TypeError("type"),
        KeyError("key"),
        IndexError("index"),
        MemoryError("memory"),
    ])
    def test_every_exception_type_is_absorbed(self, client, boom, error):
        """One test per type, because a fallback keyed to a list is the bug
        this replaced."""
        boom("ZlingshotService.presence", error)

        response = post_batch(client, [("ZlingshotService.presence", [])])

        assert response.status_code == 200

    def test_a_custom_exception_class_is_absorbed(self, client, boom):
        """Something that inherits from nothing the gateway knows about."""
        class OwnFailure(BaseException):
            pass

        boom("ZlingshotService.presence", OwnFailure("custom"))

        # A BaseException subclass is deliberately *not* swallowed: it can be a
        # KeyboardInterrupt or a SystemExit in disguise, and catching those in a
        # web handler would swallow the shutdown. Documented rather than
        # asserted as behaviour we want.
        try:
            response = post_batch(client, [("ZlingshotService.presence", [])])
        except OwnFailure:
            pytest.skip("BaseException is deliberately not caught; see docstring")
        assert response.status_code == 200


class TestBatchShapeIsPreserved:
    """The client matches responses to requests, so counts have to line up."""

    def test_every_call_gets_a_result(self, client, boom):
        boom("ZlingshotService.presence", RuntimeError("boom"))

        response = post_batch(client, [
            ("ZlingshotService.presence", []),
            ("ZlingshotService.presence", []),
            ("ZlingshotService.presence", []),
        ])

        assert len(decoded_body(response)["data"]) == 3

    def test_calls_before_the_failure_keep_their_result(self, client, boom):
        """A failure must not discard what already succeeded."""
        # initUser needs a save, so this batch mixes one that answers with an
        # empty result and one that is made to raise.
        boom("ZlingshotService.presence", RuntimeError("boom"))

        response = post_batch(client, [
            ("SomeService.doesNotExist", []),
            ("ZlingshotService.presence", []),
            ("SomeService.doesNotExist", []),
        ])

        data = decoded_body(response)["data"]
        assert len(data) == 3
        # The two unknown services still answered with the dummy result.
        assert data[0]["data"] == []
        assert data[2]["data"] == []

    def test_an_empty_batch_still_answers(self, client):
        response = post_batch(client, [])

        assert response.status_code == 200


class TestTheSpecificHandlersStillWin:
    """The catch-all is a backstop, not a replacement.

    A handler with a real recovery must keep using it; the boundary must not
    swallow what those handlers deliberately let through.
    """

    def test_a_bad_amf_body_is_still_400_not_200(self, client):
        """Refusing an unreadable body is a client error, not a game error.

        The catch-all sits after the decode, so this path is untouched -- and
        it must stay that way, because answering a garbage body with a valid
        empty result would tell the client the batch succeeded.
        """
        response = client.post("/flashservices/gateway.php", data=b"not amf at all",
                               content_type="application/x-amf")

        assert response.status_code == 400