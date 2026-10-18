"""End to end: write a save, list its history, roll it back.

The unit tests drive save_store directly. This drives the whole loop the way
the admin panel does -- three POSTs to /editor/save, a GET of /editor.json, and
a POST to /editor/restore -- and checks the save actually came back, because
that path crosses three layers that the store's own tests do not touch: the
route, the reason create_backup records, and the interface that snapshots on
write.

The interesting claim is the size of the row afterwards. Ten snapshots used to
be nested inside it; now the row is the empire no matter how much history there
is, which is what the rebuild was for.
"""
from __future__ import annotations

import json

import pytest


@pytest.fixture(scope="module")
def client(gateway_app):
    return gateway_app.test_client()


@pytest.fixture
def admin_client(gateway_app):
    """A fresh client each time, and a clean row when it is done.

    An anonymous session's store id comes from its cookie, so a shared client
    would share a row -- and one test would see the history the last one left.

    The cleanup is the other half. ``gateway_app`` is session-scoped, so its
    database is shared by every module; a save left behind here turns up in
    ``/list_session`` for whatever runs next. Cascading, so its snapshots go
    with it.
    """
    fresh = gateway_app.test_client()
    try:
        yield fresh
    finally:
        with gateway_app.app_context():
            store = gateway_app.session_interface.save_store
            store.delete(_store_id(gateway_app, fresh))


def _store_id(gateway_app, client) -> str:
    """The row key this client's cookie resolves to."""
    with client.session_transaction() as session:
        return gateway_app.session_interface._get_store_id(session.sid)


def empire(level: int, coins: int) -> str:
    return json.dumps({
        "user_object": {
            "userInfo": {
                "player": {"level": level, "cash": 1000, "xp": 500,
                           "uid": 2361750976462888, "playerResourceType": 0,
                           "socialXpGood": 0, "socialLevelGood": 0,
                           "socialXpBad": 0, "socialLevelBad": 0},
                "worldName": "End To End",
                "world": {"randSeedW": 18000, "randSeedZ": 36969,
                          "resources": {"coins": coins, "wood": 1}},
            }
        },
        "quests": [], "battle": {}, "fleets": {}, "population": 10,
        "save_version": "test",
    })


def write(client, level: int, coins: int, message: str):
    response = client.post("/editor/save",
                           data={"savegame": empire(level, coins), "message": message})
    assert response.status_code == 200, response.get_data()[:300]


def state(client) -> dict:
    response = client.get("/editor.json")
    assert response.status_code == 200
    return response.get_json()


class TestWriteThenRollBack:
    def test_three_writes_leave_two_snapshots(self, admin_client):
        write(admin_client, 1, 10, "first")
        write(admin_client, 2, 20, "second")
        write(admin_client, 3, 30, "third")

        current = state(admin_client)

        assert current["level"] == 3
        assert current["backups"] == 2
        assert [entry["level"] for entry in current["backupList"]] == [2, 1]

    def test_each_snapshot_says_what_it_was_replacing(self, admin_client):
        write(admin_client, 1, 10, "first")
        write(admin_client, 2, 20, "second")
        write(admin_client, 3, 30, "third")

        entries = state(admin_client)["backupList"]

        # A snapshot is labelled with the superseding write's reason, so each row
        # describes the change that would undo it.
        assert entries[0]["message"] == "before third"
        assert entries[1]["message"] == "before second"

    def test_rolling_back_brings_the_old_save_back(self, admin_client):
        write(admin_client, 1, 10, "first")
        write(admin_client, 2, 20, "second")
        write(admin_client, 3, 30, "third")

        oldest = state(admin_client)["backupList"][-1]
        response = admin_client.post("/editor/restore",
                                     data={"revision": oldest["revision"]})

        assert response.status_code == 200
        rolled_back = state(admin_client)
        assert rolled_back["level"] == 1
        assert rolled_back["resources"]["coins"] == 10

    def test_a_rollback_can_be_undone(self, admin_client):
        """store.restore snapshots what it replaced rather than consuming what
        it read, so going back and forward again both work."""
        write(admin_client, 1, 10, "first")
        write(admin_client, 2, 20, "second")
        write(admin_client, 3, 30, "third")

        target = state(admin_client)["backupList"][-1]
        admin_client.post("/editor/restore", data={"revision": target["revision"]})
        assert state(admin_client)["level"] == 1

        forward = [row for row in state(admin_client)["backupList"]
                   if row["level"] == 3]
        assert forward, "the state the rollback replaced should have been kept"
        admin_client.post("/editor/restore", data={"revision": forward[0]["revision"]})
        assert state(admin_client)["level"] == 3


class TestTheRowStaysSmall:
    def test_history_does_not_go_back_inside_the_save(self, admin_client):
        """The rebuild, measured through the real editor route."""
        for level in range(1, 9):
            write(admin_client, level, level * 10, f"level {level}")

        current = state(admin_client)

        assert current["backups"] == current["maxBackups"] or \
            current["backups"] < current["maxBackups"]
        # Nothing backup-shaped is left in the payload.
        assert "backup" not in current["raw"]
        assert current["raw"].get("__save_revision") is None
        assert current["raw"].get("__backup_reason") is None

    def test_listing_the_history_does_not_need_the_payloads(self, admin_client):
        """Every entry carries its numbers; none of them is the save itself."""
        for level in range(1, 5):
            write(admin_client, level, level * 10, f"level {level}")

        for entry in state(admin_client)["backupList"]:
            assert set(entry) >= {"revision", "message", "level", "coins", "size"}
            assert "user_object" not in entry