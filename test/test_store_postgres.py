"""The store's behaviour, against a real PostgreSQL 18 server.

PostgreSQL 18 is the only engine the project ships on. These run against it
directly to verify concurrency, transactions, cascading deletes, and revision guards.
"""
from __future__ import annotations

import os

import pytest

from save_store import Store, UnknownSave, WriteConflict

URL = os.environ.get(
    "RTE_PG_TEST_URL",
    os.environ.get(
        "RTE_TEST_DB",
        "postgresql+psycopg2://postgres:42kSM0ud2nRLlTZv6YVsXgPcbxwAx9Qe!7a@127.0.0.1:5432/rte_savestore_test"
    )
)


def _reachable(url: str) -> bool:
    from urllib.parse import urlparse, urlunparse

    from save_store import connect

    try:
        connection = connect(urlunparse(urlparse(url)._replace(path="/postgres")))
        connection.close()
        return True
    except Exception:
        return False


pytestmark = pytest.mark.skipif(
    not _reachable(URL), reason=f"no PostgreSQL at {URL}")


def fresh_store(**kwargs) -> Store:
    """A store over a database emptied first."""
    store = Store(URL, **kwargs)
    with store._connect() as connection:
        connection.execute("TRUNCATE TABLE save_backups, saves CASCADE")
    return store


def empire(level=1, name="Empire"):
    return {"user_object": {"userInfo": {"player": {"level": level},
                                        "worldName": name}},
            "fleets": {}, "battle": None}


class TestOneRowPerPlayer:
    def test_the_first_write_creates_it(self):
        store = fresh_store()
        assert store.store("acct1", empire()) == 1

        assert store.load("acct1").data["user_object"]["userInfo"]["worldName"] == "Empire"

    def test_a_second_write_bumps_the_revision(self):
        store = fresh_store()
        store.store("acct1", empire(level=1))

        assert store.store("acct1", empire(level=2)) == 2
        assert store.load("acct1").revision == 2

    def test_two_players_stay_separate(self):
        store = fresh_store()
        store.store("acct1", empire(level=5))
        store.store("acct2", empire(level=90))

        assert store.load("acct1").data["user_object"]["userInfo"]["player"]["level"] == 5
        assert store.load("acct2").data["user_object"]["userInfo"]["player"]["level"] == 90
        assert store.count() == 2

    def test_the_unique_constraint_holds(self):
        """One empire per account is the database's job, not the code's."""
        import psycopg2

        store = fresh_store()
        store.store("acct1", empire())

        with pytest.raises(psycopg2.IntegrityError):
            with store._connect() as connection:
                store._exec(
                    connection,
                    "INSERT INTO saves (store_id, revision, data, created_at, updated_at) "
                    "VALUES (%s, 1, %s, NOW(), NOW())",
                    ("acct1", b"\x80\x01", ))


class TestOptimisticLocking:
    def test_a_stale_revision_is_refused(self):
        store = fresh_store()
        store.store("acct1", empire())
        stale = store.load("acct1").revision
        store.store("acct1", empire(level=2), expected_revision=stale)

        with pytest.raises(WriteConflict):
            store.store("acct1", empire(level=3), expected_revision=stale)

    def test_the_refused_write_changed_nothing(self):
        store = fresh_store()
        store.store("acct1", empire())
        stale = store.load("acct1").revision
        store.store("acct1", empire(level=2), expected_revision=stale)

        with pytest.raises(WriteConflict):
            store.store("acct1", empire(level=99), expected_revision=stale)

        assert store.load("acct1").data["user_object"]["userInfo"]["player"]["level"] == 2

    def test_a_refused_write_leaves_no_orphan_snapshot(self):
        store = fresh_store()
        store.store("acct1", empire())
        stale = store.load("acct1").revision
        store.store("acct1", empire(level=2), expected_revision=stale)

        with pytest.raises(WriteConflict):
            store.store("acct1", empire(level=3), expected_revision=stale)

        assert len(store.history("acct1")) == 1


class TestHistory:
    def test_the_first_write_has_nothing_to_snapshot(self):
        store = fresh_store()
        store.store("acct1", empire())

        assert store.history("acct1") == []

    def test_the_second_write_snapshots_the_first(self):
        store = fresh_store()
        store.store("acct1", empire(level=1))
        store.store("acct1", empire(level=2), reason="Level 2")

        history = store.history("acct1")

        assert len(history) == 1
        assert history[0].revision == 1
        assert history[0].reason == "Level 2"

    def test_a_snapshot_is_what_the_row_used_to_be(self):
        store = fresh_store()
        store.store("acct1", empire(level=1))
        store.store("acct1", empire(level=2))

        assert store.read_backup("acct1", 1)["user_object"]["userInfo"]["player"]["level"] == 1

    def test_listing_does_not_fetch_the_payloads(self):
        store = fresh_store()
        for level in range(1, 8):
            store.store("acct1", empire(level=level))

        assert len(store.history("acct1")) == 6
        assert all(row.size > 0 for row in store.history("acct1"))

    def test_history_is_capped_and_keeps_the_newest(self):
        store = fresh_store(keep=3)
        for level in range(1, 9):
            store.store("acct1", empire(level=level))

        assert [row.revision for row in store.history("acct1")] == [7, 6, 5]


class TestAnUnchangedSaveIsNotWritten:
    def test_the_revision_does_not_move(self):
        store = fresh_store()
        store.store("acct1", empire(level=1))

        assert store.store("acct1", empire(level=1)) == 1
        assert store.load("acct1").revision == 1

    def test_no_snapshot_is_taken(self):
        store = fresh_store()
        store.store("acct1", empire(level=1))
        store.store("acct1", empire(level=1))

        assert store.history("acct1") == []

    def test_a_real_change_is_still_written(self):
        store = fresh_store()
        store.store("acct1", empire(level=1))

        assert store.store("acct1", empire(level=2)) == 2
        assert len(store.history("acct1")) == 1

    def test_two_writers_of_the_same_thing_do_not_collide(self):
        store = fresh_store()
        store.store("acct1", empire(level=1))
        stale = store.load("acct1").revision

        store.store("acct1", empire(level=1), expected_revision=stale)
        assert store.store("acct1", empire(level=1), expected_revision=stale) == stale

    def test_the_revision_guard_still_guards(self):
        store = fresh_store()
        store.store("acct1", empire(level=1))
        stale = store.load("acct1").revision
        store.store("acct1", empire(level=2), expected_revision=stale)

        with pytest.raises(WriteConflict):
            store.store("acct1", empire(level=3), expected_revision=stale)


class TestRestore:
    def test_it_brings_the_old_state_back(self):
        store = fresh_store()
        store.store("acct1", empire(level=1))
        store.store("acct1", empire(level=2))

        store.restore("acct1", 1)

        assert store.load("acct1").data["user_object"]["userInfo"]["player"]["level"] == 1

    def test_the_snapshot_is_not_consumed(self):
        store = fresh_store()
        store.store("acct1", empire(level=1))
        store.store("acct1", empire(level=2))
        store.restore("acct1", 1)

        store.restore("acct1", 2)

        assert store.load("acct1").data["user_object"]["userInfo"]["player"]["level"] == 2

    def test_an_unknown_revision_is_refused(self):
        store = fresh_store()
        store.store("acct1", empire())

        with pytest.raises(UnknownSave):
            store.restore("acct1", 42)


class TestCascadeDelete:
    def test_it_removes_the_history_too(self):
        store = fresh_store()
        for _ in range(3):
            store.store("acct1", empire())

        store.delete("acct1")

        assert store.history("acct1") == []
        assert store.count() == 0


class TestPayload:
    def test_the_row_carries_no_history(self):
        store = fresh_store()
        for level in range(1, 11):
            store.store("acct1", empire(level=level))

        live = store.load("acct1").data

        assert "backup" not in live
        assert "backups" not in live

    def test_the_row_does_not_grow_with_history(self):
        store = fresh_store()
        store.store("acct1", empire())

        def row_size():
            with store._connect() as connection:
                return store._exec(
                    connection,
                    "SELECT LENGTH(data) AS size FROM saves WHERE store_id = %s",
                    ("acct1",)).fetchone()["size"]

        first = row_size()
        for level in range(2, 12):
            store.store("acct1", empire(level=level))

        assert row_size() == first

    def test_nested_shapes_survive(self):
        store = fresh_store()
        payload = empire()
        payload["fleets"] = {"fleet1_1": ["a,b,c", "d,e,f"]}
        payload["battle"] = [[300, 300], [120, 0, 150], [], None]

        store.store("acct1", payload)

        assert store.load("acct1").data["fleets"]["fleet1_1"] == ["a,b,c", "d,e,f"]
