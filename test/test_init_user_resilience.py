"""One player's broken save must not stop a different player from signing up.

The shape of the bug
--------------------
``init_user`` -- what ``UserService.initUser`` answers, the first thing every
new account does -- calls ``get_allies_info()``, which reads **every save in
the database** to build the neighbour list. So one corrupt row anywhere took
down sign-up for whoever happened to be creating an empire at the time, and the
error named a key they had never heard of. ``log.txt`` carried 121 of them.

The rule these tests pin: *a save that cannot be read is a neighbour you cannot
show, never a sign-up that cannot finish.*

These are end-to-end on purpose. The individual accessors being defensive is
not the same as ``init_user`` surviving them, and the coupling is the whole
problem: the sign-up path has no business caring what shape someone else's
save is in.
"""

from __future__ import annotations

import uuid

import pytest
from flask import session

from empires_gateway.amf.handlers.player import init_user


@pytest.fixture
def gateway(gateway_app):
    return gateway_app


def _valid_save(uid: int, name: str) -> dict:
    return {
        "user_object": {
            "userInfo": {
                "player": {"level": 12, "uid": uid, "xp": 500, "cash": 100,
                           "playerResourceType": 5,
                           "socialXpGood": 0, "socialLevelGood": 0,
                           "socialXpBad": 0, "socialLevelBad": 0},
                "worldName": name,
                "world": {"resources": {"coins": 10}, "objects": []},
            }
        },
        "profilePic": None,
    }


#: Every way a save can be unreadable without being empty. Each of these was a
#: live row in log.txt at some point, or the shape one of those rows took.
BROKEN = {
    "sin user_object": {},
    "user_object vacio": {"user_object": {}},
    "sin userInfo": {"user_object": {"userInfo": None}},
    "sin player": {"user_object": {"userInfo": {"player": None}}},
    "sin worldName": {"user_object": {"userInfo": {"player": {"level": 1,
                                                             "uid": 1}}}},
    "sin resources": {"user_object": {"userInfo": {"player": {"level": 1, "uid": 1},
                                                 "worldName": "x",
                                                 "world": {"resources": None}}}},
    "sin socialXpGood": {"user_object": {"userInfo": {"player": {"level": 1, "uid": 1,
                                                                 "xp": 1,
                                                                 "playerResourceType": 1},
                                                   "worldName": "x",
                                                   "world": {"resources": {"coins": 1}}}}},
    "player no es dict": {"user_object": {"userInfo": {"player": "boom",
                                                       "level": 1, "uid": 1,
                                                       "worldName": "x"}}},
    "user_object es lista": {"user_object": [1, 2, 3]},
}


def _seed_neighbours(app, payloads):
    store = app.session_interface.save_store
    with app.app_context():
        for name, payload in payloads:
            store.store("session:probe-" + name + "-" + uuid.uuid4().hex[:8], payload)


class TestInitUserSurvivesBrokenNeighbours:
    def test_a_neighbour_with_no_pvp_does_not_block_signup(self, gateway):
        """The one that actually happened: `KeyError: 'pvp'`, 121 times."""
        _seed_neighbours(gateway, [("novp", {
            "user_object": {
                "userInfo": {
                    "player": {"level": 5, "uid": 4242, "xp": 10, "cash": 0,
                               "playerResourceType": 5,
                               "socialXpGood": 0, "socialLevelGood": 0,
                               "socialXpBad": 0, "socialLevelBad": 0},
                    "worldName": "Vecino sin PvE",
                    "world": {"resources": {"coins": 5}, "objects": []},
                }
            }
        })])

        with gateway.test_request_context():
            session.sid = "0"
            session["profilePic"] = None
            user = init_user()

        assert "userInfo" in user
        assert isinstance(user.get("neighbors"), list)

    @pytest.mark.parametrize("shape", sorted(BROKEN))
    def test_no_shape_of_broken_row_can_reach_the_sign_up(self, gateway, shape):
        _seed_neighbours(gateway, [(shape, BROKEN[shape])])

        with gateway.test_request_context():
            session.sid = "0"
            session["profilePic"] = None
            user = init_user()

        assert "userInfo" in user, f"a {shape!r} neighbour broke sign-up"

    def test_the_readable_rows_are_still_listed(self, gateway):
        """Skipping a broken row is fine; skipping every row is not.

        The neighbour list is the static `allies` catalogue plus whatever the
        store yields. These assert the second half still happens -- a store
        that silently returned nothing would look identical from the front door
        except that every player would be alone on the map.
        """
        from empires_gateway.shared import get_sessions_info
        saves = [_valid_save(31337, "Vecino sano"), _valid_save(31338, "Otro vecino")]

        with gateway.test_request_context():
            session.sid = "0"
            rows = get_sessions_info(saves)

        assert [r["uid"] for r in rows] == [31337, 31338]
        assert [r["level"] for r in rows] == [12, 12]

    def test_an_unreadable_row_costs_only_itself(self, gateway):
        """The row is skipped, its healthy neighbours survive.

        `get_sessions_info` filters on `validate_save`, which reads every field
        defensively rather than indexing: a row that cannot be read is a
        neighbour you cannot show, not a list that cannot be built.
        """
        from empires_gateway.shared import get_sessions_info
        saves = [_valid_save(31337, "Vecino sano"), BROKEN["sin socialXpGood"]]

        with gateway.test_request_context():
            session.sid = "0"
            rows = get_sessions_info(saves)

        assert [r["uid"] for r in rows] == [31337]

    def test_the_broken_rows_are_simply_not_listed(self, gateway):
        """Skipped, not faked.

        Inventing a zero-valued neighbour for an unreadable save would put a
        phantom player on the map. Being absent is the honest answer.
        """
        from empires_gateway.shared import get_sessions_info

        rows = get_sessions_info([BROKEN["sin userInfo"]])

        assert rows == []