"""The payloads the gateway produces, checked against the runtime contract.

The gateway produces these payloads and the web front door consumes them, and
they cross the seam as JSON. A shape is exactly the kind of thing that drifts:
somebody renames a key on one side, or adds a field to an interface and forgets
the producer, and the other side finds out at runtime.

The SNAPI one is the sharpest case. The client has no social network of its
own: during setup it calls ``getUserInfo()`` and reads fields off what comes
back. If the user object arrives without ``zid``, the client does not degrade,
it dies with Error #1009 before anything is playable -- and the symptom
appears in the browser console with nothing on the server to explain it.

So the shapes are written down once, in ``contract/runtime.json``, and both
sides are checked against it. This file checks the producer; the front door's
consumer is checked in ``web/tests/contract-shapes.test.ts``.
"""

from __future__ import annotations

import pytest

import contract
from empires_gateway import shared as gateway_shared


class TestTheSnapiPayload:
    def test_the_user_object_has_the_keys_the_contract_names(self, gateway_app):
        with gateway_app.test_client() as client:
            response = client.get("/snapi.json")
        assert response.status_code == 200

        payload = response.get_json()
        assert set(payload["user"]) == set(contract.SNAPI_USER_KEYS)

    def test_the_payload_has_the_keys_the_contract_names(self, gateway_app):
        with gateway_app.test_client() as client:
            response = client.get("/snapi.json")
        payload = response.get_json()
        assert set(payload) == set(contract.SNAPI_PAYLOAD_KEYS)

    def test_the_client_can_read_its_identity_off_it(self, gateway_app):
        """The two the client actually reads.

        ``zid`` is what the player is; ``uid`` is the same number under the
        name the 2012 client used. Both have to be there and both have to be
        numbers: ActionScript has no integer type and takes the value as an
        int, so a string here is the Error #1009 case.
        """
        with gateway_app.test_client() as client:
            response = client.get("/snapi.json")
        user = response.get_json()["user"]
        assert "zid" in user
        assert "uid" in user
        assert isinstance(user["zid"], int)
        assert isinstance(user["uid"], int)

    def test_the_friends_lists_are_lists(self, gateway_app):
        """The client walks them without checking, so a null is a crash."""
        with gateway_app.test_client() as client:
            response = client.get("/snapi.json")
        payload = response.get_json()
        assert isinstance(payload["friends"], list)
        assert isinstance(payload["appFriends"], list)


class TestThePlayerState:
    def test_it_has_the_keys_the_contract_names(self, gateway_app):
        with gateway_app.test_client() as client:
            response = client.get("/player.json")
        assert response.status_code == 200
        assert set(response.get_json()) == set(contract.PLAYER_STATE_KEYS)

    def test_a_player_without_a_save_is_not_an_error(self, gateway_app):
        """``hasSave: false`` with the rest nulled out.

        It used to be an error, and the account page had to special-case it.
        """
        with gateway_app.test_client() as client:
            response = client.get("/player.json")
        state = response.get_json()
        assert state["hasSave"] is False
        assert state["level"] is None

    def test_the_resources_are_the_contracted_ones(self, gateway_app):
        """The same resources, whatever order they arrive in.

        Not the same *order*: Flask sorts the keys of a JSON object, so the
        order the gateway builds them in does not survive the wire. The
        front door has its own list for the display order, and that is the one
        the player sees.
        """
        with gateway_app.test_client() as client:
            response = client.get("/player.json")
        state = response.get_json()
        assert set(state["resources"]) == set(contract.RESOURCE_ORDER)


class TestTheResourceOrder:
    def test_the_gateway_counts_them_in_the_contracted_order(self):
        """One list, in one place.

        The gateway used to carry the order and the front door carried a copy
        of it, and the two were expected to line up with nothing checking that
        they did.
        """
        catalog = pytest.importorskip("empires_gateway.routes.catalog")

        assert tuple(catalog.RESOURCE_ORDER) == tuple(contract.RESOURCE_ORDER)
        # And the set the economy charges against is the same one.
        assert frozenset(contract.RESOURCE_ORDER) == gateway_shared.WORLD_RESOURCES

    def test_the_coins_come_first(self):
        """The client shows them in this order and the coins are the first."""
        assert contract.RESOURCE_ORDER[0] == "coins"
