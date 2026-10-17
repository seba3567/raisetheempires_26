"""End-to-end tests for the AMF gateway, driven the way the Flash client drives it.

Why this file exists
--------------------
The Flash client reaches the server over AMF remoting through
``NetConnection.connect()``, which **Ruffle does not implement**
(https://ruffle.rs/compatibility/avm2 lists ``connect()`` as a missing member).
The game therefore cannot be exercised through a browser without real Flash.

These tests are the safety net for day-to-day development. They go through the
**real Flask app and the real gateway URL** with real AMF0 bytes -- encoded the
way the client encodes them, then decoded, dispatched and re-encoded by the
server -- so a regression in routing, session persistence, the AMF codec or the
game engines fails here instead of in a 2013 browser.

Assertions target protocol shape and game state, not every field: the payloads
are large and versioned.
"""

from __future__ import annotations

import json
from typing import ClassVar

import pytest
from pyamf import AMF0, remoting

empires_server = __import__("empires-server")

GATEWAY_PATH = "/files/empire-s.assets.zgncdn.com/assets/109338/127.0.0.1flashservices/gateway.php"

_sequence = iter(range(1001, 100000))


@pytest.fixture(scope="module")
def client(tmp_path_factory):
    """A test client bound to the real app, backed by a throwaway database."""
    db_path = tmp_path_factory.mktemp("rte-e2e") / "save.db"
    app = empires_server.app
    app.config.update(
        TESTING=True,
        SECRET_KEY="gateway-e2e",
        SESSION_TYPE="sqlalchemy",
        SESSION_SQLALCHEMY=empires_server.db,
        SQLALCHEMY_DATABASE_URI=f"sqlite:///{db_path}",
        SQLALCHEMY_TRACK_MODIFICATIONS=False,
    )
    empires_server.db.init_app(app)
    empires_server.sess.init_app(app)
    # logger.py reports battle/world events over socket.io, so the gateway path
    # needs a live SocketIO server too.
    empires_server.socketio.init_app(app)
    with app.app_context():
        empires_server.db.create_all()

    return app.test_client()


@pytest.fixture
def gateway(client):
    """Return a callable that sends one AMF call and returns the decoded body."""
    # flask_session populates ``session.sid`` itself (see flask_session/base.py),
    # and ``get_zid()`` derives the player's id from it, so an empty session is
    # already a valid starting point.
    def call(function_name, params=None):
        body = [
            {"flashRevision": None},
            [
                {
                    "transaction": None,
                    "sequence": next(_sequence),
                    "stamp": 1641513847112.56,
                    "params": params if params is not None else [],
                    "functionName": function_name,
                }
            ],
            0,
        ]

        envelope = remoting.Envelope(AMF0)
        envelope.bodies = [("/2", remoting.Request("BaseService.dispatchBatch", body=body))]

        raw = remoting.encode(envelope)
        raw = raw.getvalue() if hasattr(raw, "getvalue") else bytes(raw)

        response = client.post(GATEWAY_PATH, data=raw, content_type="application/x-amf")
        assert response.status_code == 200, response.get_data()[:500]

        decoded = remoting.decode(response.get_data())
        ((_target, message),) = decoded.bodies
        return message.body

    return call


@pytest.fixture
def player(gateway):
    """A freshly created player, as the Flash client creates it on login."""
    result = gateway("UserService.initUser")
    assert result["errorType"] == 0
    # initUser answers with its own envelope; the world/player object is nested.
    payload = result["data"][0]
    assert payload["errorType"] == 0
    return payload["data"]


def _world(gateway):
    """Read the world back through a fresh initUser call."""
    return gateway("UserService.initUser")["data"][0]["data"]["userInfo"]["world"]


class TestGatewayProtocol:
    """Invariants every gateway response must satisfy."""

    def test_response_envelope_is_valid_amf(self, gateway):
        body = gateway("UserService.initUser")

        assert body["errorType"] == 0
        assert isinstance(body["serverTime"], (int, float))
        assert isinstance(body["data"], list)

    def test_unknown_service_still_returns_a_valid_envelope(self, gateway):
        """An unhandled service must not corrupt the envelope."""
        body = gateway("SomeService.doesNotExist")

        assert body["errorType"] == 0
        assert isinstance(body["data"], list)


class TestPlayerBootstrap:
    """``UserService.initUser`` is the first gateway call the client makes."""

    def test_player_is_created_with_a_zid(self, player):
        uid = player["userInfo"]["player"]["uid"]

        assert isinstance(uid, int)
        assert uid > 0, "zid must be derived from a real session id"

    def test_zid_is_stable_within_a_session(self, gateway, player):
        """zid is persisted in saves, so it must not drift between calls."""
        first = player["userInfo"]["player"]["uid"]

        assert _world(gateway) is not None
        second = gateway("UserService.initUser")["data"][0]["data"]["userInfo"]["player"]["uid"]
        assert first == second

    def test_world_is_generated_with_resources(self, player):
        world = player["userInfo"]["world"]

        assert world["objects"], "the starting island should not be empty"
        assert isinstance(world["resources"]["coins"], (int, float))
        assert isinstance(world["globalObjectId"], int)

    def test_starting_player_state_is_populated(self, player):
        player_info = player["userInfo"]["player"]

        assert player_info["level"] >= 1
        assert isinstance(player_info["inventory"], dict)
        assert isinstance(player_info["xp"], (int, float))

    def test_session_is_persisted_in_the_database(self, client, gateway, player):
        """The player lives in the session store, not just in the response."""
        response = client.get("/list_session")
        assert response.status_code == 200

        # The route serialises to a text/html body, so get_json() does not apply.
        listed = json.loads(response.get_data(as_text=True))
        assert len(listed) >= 1
        assert any(entry["uid"] == player["userInfo"]["player"]["uid"] for entry in listed)


class TestFleetLifecycle:
    """``addFleet`` registers a fleet in the session."""

    FLEET: ClassVar[dict] = {
        "status": 104,
        "allies": [],
        "name": "fleet15_e2e",
        "type": "army",
        "uid": "3398563345700246",
        "ch": 5921,
        "units": ["V61,300,0,0,0"],
    }

    def test_add_fleet_response_shape(self, gateway, player):
        body = gateway("WorldService.addFleet", [dict(self.FLEET)])

        payload = body["data"][0]
        assert payload["errorType"] == 0
        assert isinstance(payload["metadata"], dict)
        # add_fleet_response has always answered with a literal userId of 1; the
        # client ignores it, so pin the existing behaviour rather than "fix" it.
        assert payload["userId"] == 1

    def test_session_keeps_its_identity_across_requests(self, gateway, player):
        """A second initUser must not fork the player into a new save."""
        gateway("WorldService.addFleet", [dict(self.FLEET)])
        reloaded = gateway("UserService.initUser")["data"][0]["data"]

        assert reloaded["userInfo"]["player"]["uid"] == player["userInfo"]["player"]["uid"]


class TestWorldActions:
    """``performAction`` is how the client mutates the world."""

    def test_place_adds_an_object_to_the_world(self, gateway, player):
        # "Small Island Hut" exists in the starting island; performAction
        # resolves the name against gameSettings, so an invented name would
        # fail the lookup instead of testing the placement.
        count_before = len(_world(gateway)["objects"])

        body = gateway(
            "WorldService.performAction",
            [
                "place",
                {"id": "999999", "position": "10,10", "itemName": "Small Island Hut"},
                [{"referenceItem": None, "elapsed": 0}],
            ],
        )

        assert body["errorType"] == 0
        assert body["data"][0]["errorType"] == 0

        objects = _world(gateway)["objects"]
        assert len(objects) == count_before + 1
        assert sum(1 for o in objects if o["itemName"] == "Small Island Hut") >= 1

    def test_perform_action_returns_metadata(self, gateway, player):
        body = gateway(
            "WorldService.performAction",
            [
                "place",
                {"id": "999999", "position": "11,11", "itemName": "Small Island Hut"},
                [{"referenceItem": None, "elapsed": 0}],
            ],
        )

        payload = body["data"][0]
        assert payload["errorType"] == 0
        assert "metadata" in payload


class TestStartupServices:
    """The social calls the client fires while booting."""

    @pytest.mark.parametrize(
        "service",
        [
            "ZlingshotService.presence",
            "DataServicesService.getRequestFriends",
            "DataServicesService.getRecentPlayers",
            "DataServicesService.getFriendsInfo",
            "PVPService.getUsersInvaderChallenges",
        ],
    )
    def test_startup_service_answers(self, gateway, player, service):
        body = gateway(service)

        assert body["errorType"] == 0
        assert isinstance(body["data"], list)


class TestPlayerPages:
    """Smoke tests for the HTML the browser actually renders.

    The player pages are Jinja templates full of inline JavaScript, so a stray
    backslash or an unrendered ``{{ ... }}`` silently blanks the whole game.
    That class of bug is invisible to the gateway tests and only shows up in a
    browser console, so assert the page contract here.
    """

    @pytest.mark.parametrize("path", ["/ruffle.html", "/nodebug.html", "/home.html"])
    def test_page_renders(self, client, path):
        response = client.get(path)

        assert response.status_code == 200
        body = response.get_data(as_text=True)
        assert body.strip()
        # No template expression leaked into the output.
        assert "{{" not in body

    def test_ruffle_page_pins_and_verifies_the_emulator(self, client):
        """Ruffle must stay version-pinned and integrity-checked.

        An unpinned CDN tag means a future Ruffle release could break this
        archived game with no way to roll the change back.
        """
        body = client.get("/ruffle.html").get_data(as_text=True)

        assert "@ruffle-rs/ruffle@" in body, "Ruffle must be pinned to a version"
        assert "integrity=\"sha256-" in body, "Ruffle must be loaded with SRI"
        assert "crossorigin=\"anonymous\"" in body
        # The bare, moving tag is what we are trying to avoid.
        assert 'src="https://unpkg.com/@ruffle-rs/ruffle"' not in body

    def test_ruffle_page_config_is_complete(self, client):
        body = client.get("/ruffle.html").get_data(as_text=True)

        # allowScriptAccess must stay on or the SWF throws Error #2067 and
        # aborts GameSettingsInit.onConfigXmlLoaded.
        assert "allowScriptAccess: true" in body
        # The SWF itself.
        assert "ZGame.109338.swf" in body
        # FlashVars the client needs, including the server clock.
        for flashvar in ("serverTime=", "sn_app_url=", "stats=1"):
            assert flashvar in body

    def test_ruffle_bootstrap_has_no_broken_line_continuation(self, client):
        """A missing backslash leaves a raw newline inside a JS string literal.

        That is a SyntaxError which blanks the player entirely, and it is easy
        to introduce while editing the FlashVars block.
        """
        body = client.get("/ruffle.html").get_data(as_text=True)

        start = body.index("parameters:")
        line = body[start:body.index("\n", start)]
        assert line.rstrip().endswith(('"', "'")), f"unterminated parameters string: {line!r}"