"""The gateway's own lock on its admin tools.

The gateway's cheat and editing routes -- ``/gazillionaire``, ``/patch/...``,
``/save-editor``, ``/wipe_session``, ``DELETE /save``, ``/list_session`` -- used
to have no authorization of their own. The only thing between an anonymous
visitor and every player's session id was a list of paths in the SvelteKit
front door, in another runtime.

The lock belongs on the data, so the gateway checks it too. These tests are
the other half of that: the front door's gate is tested in
``web/tests/access.test.ts``, and this one is about the gateway refusing to
take the front door's word for it.
"""

from __future__ import annotations

import pytest

import admin_gate
import contract

ADMIN_TOOL = "/gazillionaire"
ANOTHER_TOOL = "/list_session"


class TestTheList:
    def test_it_comes_from_the_contract(self):
        """The list is written down once, in contract/runtime.json.

        The front door reads the same file, so the two runtimes cannot end up
        with different ideas about which routes are the dangerous ones.
        """
        assert contract.ADMIN_ONLY_EXACT
        assert contract.ADMIN_ONLY_PREFIXES
        assert ADMIN_TOOL in contract.ADMIN_ONLY_EXACT
        assert ANOTHER_TOOL in contract.ADMIN_ONLY_EXACT
        assert "/patch/" in contract.ADMIN_ONLY_PREFIXES

    def test_a_path_is_admin_only_by_exact_name(self):
        assert admin_gate.is_admin_tool("/gazillionaire")
        assert admin_gate.is_admin_tool("/list_session")
        assert admin_gate.is_admin_tool("/editor/save")

    def test_a_prefix_is_admin_only_with_anything_after_it(self):
        assert admin_gate.is_admin_tool("/patch/player/name/string/bob")
        assert admin_gate.is_admin_tool("/seed/w/3/z/2")

    def test_the_ordinary_game_traffic_is_not_admin_only(self):
        """The game's own traffic must not be caught by the gate.

        The Flash client talks to /flashservices/gateway.php, and the front
        door serves its assets. Locking those out would break the game.
        """
        for path in [
            "/flashservices/gateway.php",
            "/assets/img/logo.png",
            "/nullassets/img/logo.png",
            "/snapi.json",
            "/player.json",
        ]:
            assert not admin_gate.is_admin_tool(path), path


class TestTheLock:
    def test_an_admin_is_allowed(self, gateway_app):
        """The gate lets the request through to the route.

        Not "the answer is not 403": /gazillionaire answers 403 of its own
        accord when the caller has no game session, which is a different
        refusal. What matters here is that the *gate* did not refuse it.
        """
        with gateway_app.test_client() as client:
            response = client.get(ADMIN_TOOL, headers={"x-player-role": "admin"})
        assert b"Admin only" not in response.data

    def test_a_player_is_refused(self, gateway_app):
        with gateway_app.test_client() as client:
            response = client.get(ADMIN_TOOL, headers={"x-player-role": "player"})
        assert response.status_code == 403
        assert b"Admin only" in response.data

    def test_somebody_who_claims_nothing_is_refused(self, gateway_app):
        """Failing closed.

        No header means no claim, and a claim that is not "admin" is not an
        admin. A gateway reachable without the front door in front of it must
        not hand out the cheat tools to whoever asks.
        """
        with gateway_app.test_client() as client:
            response = client.get(ADMIN_TOOL)
        assert response.status_code == 403

    def test_the_refusal_does_not_leak_the_data(self, gateway_app):
        """/list_session hands over every player's session id and world name.

        It has to answer the refusal, not the list.
        """
        with gateway_app.test_client() as client:
            response = client.get(ANOTHER_TOOL, headers={"x-player-role": "player"})
        assert response.status_code == 403
        assert b"session_id" not in response.data

    def test_the_role_is_not_taken_from_the_browser(self, gateway_app):
        """The gateway trusts the role because only the front door can set it.

        The front door copies the browser's headers and then overwrites this
        one, so a browser that sends its own copy of it is ignored. Here the
        same rule is checked from the other side: the gateway reads the
        header, and the front door is what puts a truthful value in it.
        """
        with gateway_app.test_client() as client:
            response = client.get(
                ADMIN_TOOL, headers={"x-player-role": "player", "x-player-zid": "1"}
            )
        assert response.status_code == 403


@pytest.mark.parametrize("path", ["/gazillionaire", "/list_session", "/patch/x/int/1"])
def test_every_admin_tool_is_locked(path, gateway_app):
    with gateway_app.test_client() as client:
        response = client.get(path, headers={"x-player-role": "player"})
    assert response.status_code == 403
