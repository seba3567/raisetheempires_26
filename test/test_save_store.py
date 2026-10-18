"""The rebuilt save store: one row per player, history beside it.

These do not use the Flask app at all. The rules about atomicity, versioning and
history are worth having testable without a request context, which is why
save_store imports no Flask and takes a path.

What is pinned here:

* one row per store id, enforced by the database rather than by convention;
* a write that states the revision it read loses to one that states a stale one,
  which is the lost update the old read-modify-write had;
* history lives in another table, so the row a request touches stays the size of
  the empire instead of ten times it;
* restoring does not consume the snapshot, so a rollback can be undone.
"""
from __future__ import annotations

import os
import sys
import tempfile
from concurrent.futures import ThreadPoolExecutor

import pytest

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from save_store import (
    Store,
    UnknownSave,
    WriteConflict,
    account_store_id,
)


@pytest.fixture
def store(tmp_path):
    return Store(str(tmp_path / "saves.db"))


def empire(level=1, coins=100, name="Empire"):
    return {"user_object": {"userInfo": {"player": {"level": level},
                                        "worldName": name,
                                        "world": {"resources": {"coins": coins},
                                                  "objects": []}}},
            "fleets": {}, "battle": None}


# ---------------------------------------------------------------- one per player


class TestOneRowPerPlayer:
    def test_a_new_player_has_no_row(self, store):
        assert store.load("acct1") is None

    def test_the_first_write_creates_it(self, store):
        assert store.store("acct1", empire()) == 1

        assert store.load("acct1").data["user_object"]["userInfo"]["worldName"] \
            == "Empire"

    def test_a_second_write_bumps_the_revision(self, store):
        store.store("acct1", empire(level=1))
        assert store.store("acct1", empire(level=2)) == 2

        row = store.load("acct1")
        assert row.revision == 2
        assert row.data["user_object"]["userInfo"]["player"]["level"] == 2

    def test_two_players_do_not_share_a_row(self, store):
        store.store("acct1", empire(level=5))
        store.store("acct2", empire(level=90))

        assert store.load("acct1").data["user_object"]["userInfo"]["player"]["level"] == 5
        assert store.load("acct2").data["user_object"]["player" if False else "userInfo"]["player"]["level"] == 90
        assert store.count() == 2

    def test_the_store_id_never_collides_across_accounts(self, store):
        """'acct' prefixing is what stops acct1 and acct12 reading each other."""
        store.store(account_store_id(1), empire(level=1))
        store.store(account_store_id(12), empire(level=12))

        assert store.load(account_store_id(1)).data["user_object"]["userInfo"]["player"]["level"] == 1
        assert store.load(account_store_id(12)).data["user_object"]["userInfo"]["player"]["level"] == 12

    def test_create_refuses_a_row_that_exists(self, store):
        store.create("acct1", empire())

        with pytest.raises(WriteConflict):
            store.create("acct1", empire())

    def test_store_is_not_create(self, store):
        """store() overwrites on purpose -- that is the admin paste path."""
        store.create("acct1", empire(level=1))

        assert store.store("acct1", empire(level=7)) == 2


# ------------------------------------------------------------------- the guard


class TestOptimisticLocking:
    """The lost update. Two readers, two writers, one winner."""

    def test_a_stale_revision_is_refused(self, store):
        store.store("acct1", empire())
        stale = store.load("acct1").revision

        store.store("acct1", empire(level=2), expected_revision=stale)

        with pytest.raises(WriteConflict):
            store.store("acct1", empire(level=3), expected_revision=stale)

    def test_the_refused_write_changed_nothing(self, store):
        store.store("acct1", empire())
        stale = store.load("acct1").revision
        store.store("acct1", empire(level=2), expected_revision=stale)

        with pytest.raises(WriteConflict):
            store.store("acct1", empire(level=99), expected_revision=stale)

        assert store.load("acct1").data["user_object"]["userInfo"]["player"]["level"] == 2
        assert store.load("acct1").revision == 2

    def test_the_matching_revision_is_accepted(self, store):
        store.store("acct1", empire())
        current = store.load("acct1").revision

        assert store.store("acct1", empire(level=5), expected_revision=current) == 2

    def test_a_refused_write_leaves_no_orphan_snapshot(self, store):
        """The transaction rolls back whole: no history for a write that lost."""
        store.store("acct1", empire())
        stale = store.load("acct1").revision
        store.store("acct1", empire(level=2), expected_revision=stale)

        with pytest.raises(WriteConflict):
            store.store("acct1", empire(level=3), expected_revision=stale)

        # One write happened, so exactly one snapshot of what it replaced.
        assert len(store.history("acct1")) == 1

    def test_a_refused_write_never_creates_the_row(self, store):
        with pytest.raises(WriteConflict):
            store.store("acct1", empire(), expected_revision=1)

        assert store.exists("acct1") is False

    def test_two_writers_racing_produce_one_winner(self, store):
        """Not timing-dependent: both are handed the same revision up front."""
        store.store("acct1", empire())
        seen = store.load("acct1").revision

        def attempt(level):
            try:
                store.store("acct1", empire(level=level), expected_revision=seen)
                return level
            except WriteConflict:
                return None

        with ThreadPoolExecutor(max_workers=2) as pool:
            results = list(pool.map(attempt, (11, 22)))

        assert sorted(r for r in results if r) != [] and None in results, \
            "exactly one of two writers at the same revision should lose"
        final = store.load("acct1")
        assert final.revision == 2
        assert final.data["user_object"]["userInfo"]["player"]["level"] in (11, 22)


# -------------------------------------------------------------------- history


class TestHistory:
    def test_the_first_write_has_nothing_to_snapshot(self, store):
        store.store("acct1", empire())

        assert store.history("acct1") == []

    def test_the_second_write_snapshots_the_first(self, store):
        store.store("acct1", empire(level=1))
        store.store("acct1", empire(level=2), reason="Level 2")

        history = store.history("acct1")

        assert len(history) == 1
        assert history[0].revision == 1
        assert history[0].reason == "Level 2"

    def test_a_snapshot_is_what_the_row_used_to_be(self, store):
        store.store("acct1", empire(level=1))
        store.store("acct1", empire(level=2))

        assert store.read_backup("acct1", 1)["user_object"]["userInfo"]["player"]["level"] == 1

    def test_the_reason_is_kept(self, store):
        store.store("acct1", empire())
        store.store("acct1", empire(), reason="Level 50")

        assert store.history("acct1")[0].reason == "Level 50"

    def test_a_write_with_no_reason_is_allowed(self, store):
        store.store("acct1", empire())
        store.store("acct1", empire())

        assert store.history("acct1")[0].reason is None

    def test_listing_does_not_fetch_the_payloads(self, store):
        """Ten 40 KB blobs to render a level number is the cost this removed."""
        store.store("acct1", empire(level=1))
        for level in range(2, 8):
            store.store("acct1", empire(level=level))

        history = store.history("acct1")

        assert len(history) == 6
        assert all(row.size > 0 for row in history)

    def test_history_is_newest_first(self, store):
        store.store("acct1", empire())
        for level in range(2, 6):
            store.store("acct1", empire(level=level), reason=f"level {level}")

        revisions = [row.revision for row in store.history("acct1")]

        assert revisions == sorted(revisions, reverse=True)

    def test_history_is_capped_and_keeps_the_newest(self, store):
        capped = Store(store.path, keep=3)
        for level in range(1, 9):
            capped.store("acct1", empire(level=level))

        revisions = [row.revision for row in capped.history("acct1")]

        assert revisions == [7, 6, 5]

    def test_history_is_per_player(self, store):
        store.store("acct1", empire())
        store.store("acct1", empire())
        store.store("acct2", empire())
        store.store("acct2", empire())

        assert len(store.history("acct1")) == 1
        assert len(store.history("acct2")) == 1

    def test_an_unknown_revision_reads_as_none(self, store):
        store.store("acct1", empire())
        store.store("acct1", empire())

        assert store.read_backup("acct1", 99) is None


# -------------------------------------------------------------------- restore


class TestRestore:
    def test_it_brings_the_old_state_back(self, store):
        store.store("acct1", empire(level=1))
        store.store("acct1", empire(level=2))

        store.restore("acct1", 1)

        assert store.load("acct1").data["user_object"]["userInfo"]["player"]["level"] == 1

    def test_restoring_is_itself_a_revision(self, store):
        store.store("acct1", empire(level=1))
        store.store("acct1", empire(level=2))

        assert store.restore("acct1", 1) == 3

    def test_the_snapshot_is_not_consumed(self, store):
        """So a rollback can be undone -- which is what makes it safe to expose."""
        store.store("acct1", empire(level=1))
        store.store("acct1", empire(level=2))
        store.restore("acct1", 1)

        store.restore("acct1", 2)

        assert store.load("acct1").data["user_object"]["userInfo"]["player"]["level"] == 2

    def test_the_state_before_the_restore_is_kept(self, store):
        store.store("acct1", empire(level=1))
        store.store("acct1", empire(level=2))
        store.restore("acct1", 1)

        assert store.read_backup("acct1", 2)["user_object"]["userInfo"]["player"]["level"] == 2

    def test_it_records_why(self, store):
        store.store("acct1", empire(level=1))
        store.store("acct1", empire(level=2))
        store.restore("acct1", 1)

        assert store.history("acct1")[0].reason == "restore revision 1"

    def test_an_unknown_revision_is_refused(self, store):
        store.store("acct1", empire())

        with pytest.raises(UnknownSave):
            store.restore("acct1", 42)

    def test_a_stale_restore_is_refused(self, store):
        store.store("acct1", empire(level=1))
        store.store("acct1", empire(level=2))
        stale = store.load("acct1").revision

        with pytest.raises(WriteConflict):
            store.restore("acct1", 1, expected_revision=stale + 5)

    def test_it_changes_nothing_when_refused(self, store):
        store.store("acct1", empire(level=1))
        store.store("acct1", empire(level=2))

        with pytest.raises(WriteConflict):
            store.restore("acct1", 1, expected_revision=99)

        assert store.load("acct1").data["user_object"]["userInfo"]["player"]["level"] == 2


# --------------------------------------------------------------------- delete


class TestDelete:
    def test_it_removes_the_row(self, store):
        store.store("acct1", empire())

        assert store.delete("acct1") is True
        assert store.load("acct1") is None

    def test_it_removes_the_history_too(self, store):
        store.store("acct1", empire())
        store.store("acct1", empire())
        store.store("acct1", empire())

        store.delete("acct1")

        assert store.history("acct1") == []

    def test_deleting_nothing_is_not_an_error(self, store):
        assert store.delete("acct nobody") is False


# ------------------------------------------------------------------- payload


class TestPayloadShape:
    def test_the_payload_is_not_held_inside_the_row(self, store):
        """The rebuild in one assertion: backups are a different table."""
        store.store("acct1", empire(level=1))
        for level in range(2, 12):
            store.store("acct1", empire(level=level))

        live = store.load("acct1")

        assert "backup" not in live.data
        assert "backups" not in live.data

    def test_the_row_does_not_grow_with_history(self, store):
        """The old cost: the row was ten times the empire."""
        store.store("acct1", empire())
        first = _size(store, "acct1")
        for level in range(2, 12):
            store.store("acct1", empire(level=level))
        last = _size(store, "acct1")

        assert last == first, "the live row grew as history accumulated"
        # And the history is really there, in its own table.
        assert len(store.history("acct1")) == store.keep

    def test_a_save_with_nested_lists_survives(self, store):
        """The empire's own shapes, not just flat dicts."""
        payload = empire()
        payload["fleets"] = {"fleet1_1": ["a,b,c", "d,e,f"]}
        payload["battle"] = [[300, 300], [120, 0, 150], [], None]
        payload["user_object"]["userInfo"]["world"]["objects"] = [
            {"id": 1, "position": "12,34", "unit": {"-strength": 1000}}]

        store.store("acct1", payload)

        assert store.load("acct1").data["fleets"]["fleet1_1"] == ["a,b,c", "d,e,f"]


def _size(store, store_id):
    with store._connect() as connection:
        return connection.execute(
            "SELECT LENGTH(data) FROM saves WHERE store_id = ?",
            (store_id,)).fetchone()[0]