"""A request that changes nothing must not write the save.

The symptom
-----------

The empire's revision climbed by fifty in twenty minutes of playing, and every
one of the ten snapshots in the history was an identical copy of the same
37 KB. The history the editor offers to restore from -- "put me back at level
50" -- had been trimmed away to make room for ten copies of the level 24 the
player was at.

Why
---

flask-session persists the session at the end of *every* request, and it does
not check whether the session changed. The game client downloads ten assets to
start (the two settings files, the locale, the SWF, its pieces), so a page load
wrote the save ten times. Each write bumped the revision and snapshotted the
empire it replaced, which is what the ten identical copies were.

It was not only noise. Every one of those writes moved the revision, so the
requests that ran at the same time -- the asset downloads, mostly -- collided
on the optimistic lock, and the loser was dropped with a "the row moved
underneath" in the log. The write that lost was not always the useless one:
a request that changed the game state could lose to one that changed
nothing.

The rule pinned here
--------------------

**A save that did not change is not written.** No revision, no snapshot, and
nothing to collide with.
"""

from __future__ import annotations

import pytest


@pytest.fixture(scope="module")
def client(gateway_app):
    return gateway_app.test_client()


def seed(client):
    """Put a minimal but real empire in the session and persist it."""
    client.get("/avatar.json")
    with client.session_transaction() as session:
        session["user_object"] = {
            "userInfo": {
                "player": {"level": 12, "uid": 2361750976462888, "xp": 5000,
                           "cash": 777, "playerResourceType": 5,
                           "socialXpGood": 0, "socialLevelGood": 0,
                           "socialXpBad": 0, "socialLevelBad": 0},
                "worldName": "Quiet Empire",
                "world": {"randSeedW": 18000, "randSeedZ": 36969,
                          "resources": {"coins": 1234, "wood": 9}},
            }
        }
        session["fleets"] = {}
        session["battle"] = None
    client.get("/avatar.json")
    return client


def store_id_of(app, client) -> str:
    with client.session_transaction() as session:
        sid = session.sid
    return app.session_interface._get_store_id(sid)


def revision_of(app, client) -> int:
    store = app.session_interface.save_store
    return store.load(store_id_of(app, client)).revision


def history_of(app, client) -> list:
    store = app.session_interface.save_store
    return store.history(store_id_of(app, client))


class TestReadingTheGameDoesNotWriteIt:
    def test_the_revision_does_not_move(self, gateway_app, client):
        seed(client)
        before = revision_of(gateway_app, client)

        for _ in range(3):
            client.get("/avatar.json")

        assert revision_of(gateway_app, client) == before

    def test_the_history_does_not_fill_up(self, gateway_app, client):
        seed(client)
        before = len(history_of(gateway_app, client))

        client.get("/avatar.json")
        client.get("/motd.json")

        assert len(history_of(gateway_app, client)) == before

    def test_the_empire_is_still_there_afterwards(self, gateway_app, client):
        """Skipping the write must not skip the state."""
        seed(client)

        client.get("/avatar.json")

        store = gateway_app.session_interface.save_store
        saved = store.load(store_id_of(gateway_app, client)).data
        assert saved["user_object"]["userInfo"]["worldName"] == "Quiet Empire"


class TestAChangeIsStillWritten:
    def test_the_revision_moves(self, gateway_app, client):
        seed(client)
        before = revision_of(gateway_app, client)

        with client.session_transaction() as session:
            session["user_object"]["userInfo"]["player"]["cash"] += 100
        client.get("/avatar.json")

        assert revision_of(gateway_app, client) > before

    def test_the_change_is_what_the_row_holds(self, gateway_app, client):
        seed(client)

        with client.session_transaction() as session:
            session["user_object"]["userInfo"]["player"]["cash"] += 100
        client.get("/avatar.json")

        store = gateway_app.session_interface.save_store
        saved = store.load(store_id_of(gateway_app, client)).data
        assert saved["user_object"]["userInfo"]["player"]["cash"] == 877
