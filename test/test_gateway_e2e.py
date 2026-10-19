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
import pathlib
from typing import ClassVar

import pytest
from pyamf import AMF0, remoting

empires_server = __import__("empires-server")

GATEWAY_PATH = "/files/empire-s.assets.zgncdn.com/assets/109338/127.0.0.1flashservices/gateway.php"

_sequence = iter(range(1001, 100000))


@pytest.fixture(scope="module")
def client(gateway_app):
    """A test client bound to the real app, backed by a throwaway database.

    The app itself is configured once in ``conftest.py`` -- SQLAlchemy cannot
    be registered on the same Flask app twice, so two modules cannot each set
    up their own database.
    """
    return gateway_app.test_client()


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


class TestRetired2013Pages:
    """The 2013 web cluster, and where each piece went.

    Every page here was a launcher or a session picker from before accounts
    existed. The routes are asserted rather than left to rot: a stale template
    that nothing renders any more should 404, and every redirect that used to
    land on a dead page should land on a live one.
    """

    @pytest.mark.parametrize("path", ["/index.html", "/releases.html", "/login.html"])
    def test_retired_pages_are_gone(self, client, path):
        """Their only consumers went with them, so they must not linger.

        ``index.html`` was shadowed by this service's own landing page,
        ``releases.html`` was linked only from ``index.html``, and
        ``login.html`` was the session picker the account system replaced.
        """
        assert client.get(path).status_code == 404

    def test_friends_page_points_at_the_migrated_list(self, client):
        """It used to print every player's world, level and xp to anyone.

        ``/admin/sessions`` renders the same list behind the admin gate, and
        the two 2013 debug players now link straight there.
        """
        response = client.get("/friends.html")

        assert response.status_code in (301, 302, 303, 307, 308)
        assert response.headers["Location"].endswith("/admin/sessions")

    def test_wiping_a_save_lands_somewhere_that_exists(self, client):
        """It redirected to /login.html, which no longer renders."""
        response = client.get("/wipe_session")

        assert response.status_code in (301, 302, 303, 307, 308)
        assert response.headers["Location"] in ("/", "http://localhost/")

    def test_the_changelog_is_still_served(self, client):
        """Data, not a 2013 page: nothing renders it, but it is still content."""
        response = client.get("/changelog.txt")

        assert response.status_code == 200
        assert response.get_data(as_text=True).strip()


class TestPlayerPages:
    """The old player URLs must be dead ends, and stay that way.

    ``/juego`` is the only player. ``/ruffle.html`` used to be able to render
    the 2013 Jinja template again via ``?raw=1``, which kept a second copy of
    the FlashVars and a CDN-pinned Ruffle alive behind a query flag. That
    template is deleted, and these tests are what stops it from coming back.
    The player's own options are pinned in web/tests/player.test.ts.
    """

    def test_legacy_pages_redirect_to_real_player(self, client):
        """Legacy players redirect to /juego, with no way back to the old template."""
        for path in ("/ruffle.html", "/nodebug.html", "/new.html", "/home.html"):
            response = client.get(path)
            assert response.status_code in (301, 302, 303, 307, 308)
            assert response.headers["Location"].endswith("/juego")

    def test_ruffle_html_has_no_raw_escape_hatch(self, client):
        """`?raw=1` used to render templates/ruffle.html for diagnostics.

        That template is gone; the flag now redirects like any other request.
        A 200 here would mean the old player is somehow still reachable.
        """
        for path in ("/ruffle.html?raw=1", "/ruffle.html?fallback=1"):
            response = client.get(path)
            assert response.status_code in (301, 302, 303, 307, 308)
            assert response.headers["Location"].endswith("/juego")


class TestNullAssetsRoute:
    """``/nullassets/`` is how the archived game art actually reaches the client.

    The SWF builds its asset URLs as ``<base>/game/...``, where ``<base>`` is the
    ``zcache_url`` FlashVar -- Zynga's image/texture CDN, dead since 2012. We
    deliberately do not send that FlashVar, so the concatenation yields the
    literal string ``null`` and the client asks this origin for
    ``/nullassets/game/...``. `empires-server.py` maps that prefix onto the
    archived tree in ``assets/sol_assets_octdict/assets``.

    So the ``StatsManager.count errors zcache`` trace in the browser console is
    this design showing through, not a fault. Deleting either half breaks the
    game silently -- the client falls back to `EmbeddedResourceProvider` and the
    art simply never appears -- which is what these tests exist to catch.
    """

    ASSET_ROOT = "assets/sol_assets_octdict/assets"

    def test_the_archived_tree_is_present_and_not_empty(self):
        """Without the archive on disk every asset below 404s at runtime."""
        root = pathlib.Path(__file__).resolve().parents[1] / self.ASSET_ROOT
        assert root.is_dir(), f"missing archived assets: {self.ASSET_ROOT}"

        files = [p for p in root.rglob("*") if p.is_file()]
        assert len(files) > 100, f"only {len(files)} files archived"

    def test_serves_a_terrain_tileset(self, client):
        """One real file, end to end, with the bytes it should have."""
        with client.get("/nullassets/game/terrain/Island3_Tileset_ENV.swf") as response:
            assert response.status_code == 200
            assert response.data[:3] in (b"CWS", b"FWS", b"ZWS"), "not a SWF header"

    def test_serves_the_same_tree_as_the_assets_alias(self, client):
        """/assets/ and /nullassets/ are two names for one archive."""
        path = "/nullassets/game/terrain/Island3_Tileset_ENV.swf"

        # Closed explicitly: send_from_directory hands back a live file handle,
        # which the test client would otherwise leak for every asset it serves.
        with client.get(path) as response:
            assert response.status_code == 200
        with client.get(path.replace("/nullassets/", "/assets/")) as response:
            assert response.status_code == 200

    def test_a_missing_asset_is_a_404_and_not_a_crash(self, client):
        """The game probes for files that were never archived.

        It must get a clean 404. An unhandled exception here surfaces in the
        client as a failed load with no explanation.
        """
        with client.get("/nullassets/game/terrain/NoSuchTileset.swf") as response:
            assert response.status_code == 404


class TestAssetCacheHeaders:
    """Archived art must be cacheable, or every visit re-downloads it.

    The game asks for the same assets on every visit. Served with Werkzeug's
    default ``no-cache`` the browser keeps the file but still revalidates it, so
    each one became a full round trip through the proxy and back to the disk for
    a 304 carrying no body: 1133 of the 1328 asset requests in ``log.txt``.

    ``max-age`` cannot be ``immutable`` here. These files are named after what
    they are (``Island3_Tileset_ENV.swf``), not after a hash of their contents,
    so an immutable cache would survive an edit to the archive and players would
    keep seeing the old art until the year expired.
    """

    def test_archived_art_is_cacheable_for_a_week(self, client):
        with client.get("/nullassets/game/terrain/Island3_Tileset_ENV.swf") as response:
            assert response.status_code == 200
            cache_control = response.headers["Cache-Control"]

        assert "public" in cache_control
        assert "max-age=604800" in cache_control
        assert "no-cache" not in cache_control, "no-cache defeats the whole point"

    def test_img_is_cacheable_too(self, client):
        """/img/ is the second-busiest static route: avatars, MOTDs and chrome."""
        with client.get("/img/motds/Loading_BattleBlitz.png") as response:
            assert response.status_code == 200
            assert "max-age=604800" in response.headers["Cache-Control"]

    def test_assets_still_carry_an_etag(self, client):
        """A max-age is not a licence to serve stale bytes after an edit.

        The ETag is what lets a browser that already holds the file notice, once
        the week is up, that the archive changed.
        """
        with client.get("/nullassets/game/terrain/Island3_Tileset_ENV.swf") as response:
            assert response.headers.get("ETag")

    def test_a_404_is_not_cacheable(self, client):
        """Caching a miss would pin a broken asset even after it is archived.

        A game that probes for a file it does not have gets a 404 today and
        would still get it tomorrow; if that 404 were cached, adding the file
        later would not reach anyone who already asked.
        """
        with client.get("/nullassets/game/terrain/NoSuchTileset.swf") as response:
            assert response.status_code == 404
            assert "max-age=604800" not in response.headers.get("Cache-Control", "")

    def test_template_css_stays_uncached(self, client):
        """/css/ and /js/ are the 2013 pages' own assets, edited by hand.

        They are a rounding error next to the art (301 requests against 2132),
        and caching them makes editing one a guessing game during development.
        """
        with client.get("/css/facebook.css") as response:
            assert response.status_code == 200
            assert "max-age=604800" not in response.headers.get("Cache-Control", "")

class TestEditorJsonSurvivesALiveBattle:
    """``/editor.json`` must answer even when the session is not plain JSON.

    ``session['battle']`` and ``session['last_battle']`` come back from the
    store as ``BattleContext`` -- a tagged ``msgspec.Struct`` -- whenever a save
    carries one. Without a fallback the endpoint raises, and because the web
    front end treats a non-OK gateway answer as "unreachable", the whole admin
    page claimed the gateway was down while it was answering 500.
    """

    def _world(self, level: int, cash: int, ore: int, coins: int) -> dict:
        return {
            "userInfo": {
                "player": {"level": level, "uid": 2361750976462848, "xp": 234462,
                           "cash": cash, "playerResourceType": ore},
                "worldName": "Rising Empire",
                "world": {"resources": {"coins": coins, "wood": 1}},
            }
        }

    def test_a_battle_in_progress_does_not_break_the_endpoint(self, client):
        from battle_engine import BattleContext

        with client.session_transaction() as session:
            session["user_object"] = self._world(47, 10000, 3, 39999)
            session["battle"] = BattleContext(map_name="campaign", island=3)
            session["last_battle"] = BattleContext(map_name="pvp", island=7)

        response = client.get("/editor.json")

        assert response.status_code == 200
        body = response.get_json()
        assert body["level"] == 47
        assert body["worldName"] == "Rising Empire"
        # The unencodable value is replaced rather than fatal.
        assert body["raw"]["battle"] == "<not serializable>"

    def test_the_typed_fields_are_unaffected(self, client):
        """The numbers an admin actually edits must not become the marker."""
        from battle_engine import BattleContext

        with client.session_transaction() as session:
            session["user_object"] = self._world(12, 777, 5, 1234)
            session["battle"] = BattleContext(map_name="campaign")

        body = client.get("/editor.json").get_json()

        assert body["level"] == 12
        assert body["empirePoints"] == 777
        assert body["ore"] == 5
        assert body["resources"]["coins"] == 1234