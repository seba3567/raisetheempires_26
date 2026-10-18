"""History is capped, and the cap is now the store's job.

``trim_backups`` used to cut a chain of nested copies inside the payload: it
walked ``session['backup']``, popped the link to the first dropped node, and
left the row the size of the empire times however many snapshots survived. It
did not exist anywhere else -- the cap was a property of that one walk.

Now every write goes through ``save_store.Store``, which snapshots whatever it
replaces and trims in the same transaction. So the behaviour under test is the
same thing, reached the other way round: the history stops growing, and the
surviving snapshots are the newest ones rather than an arbitrary tail.

The tests drive the store directly. Going through the session interface would
also work, but then each write is a request, and what is being pinned here is
about the storage layer.
"""
from __future__ import annotations

import pytest

from save_store import Store


@pytest.fixture
def store(tmp_path):
    return Store(str(tmp_path / "saves.db"))


def save(level=1):
    return {"user_object": {"userInfo": {"player": {"level": level}}}}


class TestHistoryStopsGrowing:
    def test_a_fresh_store_keeps_everything_up_to_the_cap(self, store):
        for level in range(1, 11):
            store.store("acct1", save(level))

        assert len(store.history("acct1")) == 9   # ten writes, first has nothing to snapshot

    def test_the_twelfth_snapshot_drops_the_first(self, store):
        # Twelve writes: the first creates the row and snapshots nothing, so
        # revisions 1..11 exist. The cap of ten cuts revision 1, and what
        # survives is revisions 2..11 -- the most recent ten.
        for level in range(1, 13):
            store.store("acct1", save(level))

        history = store.history("acct1")

        assert len(history) == store.keep
        assert history[-1].revision == 2, "the oldest snapshot should be the one cut"
        assert history[0].revision == 11

    def test_eleven_writes_still_fit_under_the_cap(self, store):
        """So the cut is not happening early."""
        for level in range(1, 12):
            store.store("acct1", save(level))

        assert len(store.history("acct1")) == store.keep

    def test_the_survivors_are_the_newest(self, store):
        for level in range(1, 30):
            store.store("acct1", save(level))

        revisions = [row.revision for row in store.history("acct1")]

        assert revisions == sorted(revisions, reverse=True)
        # 29 writes, but the first creates the row and snapshots nothing, so the
        # newest snapshot is of revision 28 -- the state before the last write.
        assert max(revisions) == 28

    def test_the_cap_is_configurable(self, tmp_path):
        generous = Store(str(tmp_path / "generous.db"), keep=25)
        for level in range(1, 20):
            generous.store("acct1", save(level))

        # Nineteen writes, the first of which snapshots nothing.
        assert len(generous.history("acct1")) == 18

    def test_the_live_row_is_unaffected_by_trimming(self, store):
        """The point of the rebuild: the row is the empire, not the history."""
        for level in range(1, 30):
            store.store("acct1", save(level))

        assert store.load("acct1").data["user_object"]["userInfo"]["player"]["level"] == 29

    def test_trimming_one_save_leaves_another_alone(self, store):
        for level in range(1, 15):
            store.store("acct1", save(level))
        store.store("acct2", save(level=100))
        store.store("acct2", save(level=101))

        assert len(store.history("acct1")) == store.keep
        assert len(store.history("acct2")) == 1


class TestReclaimingSpace:
    def test_a_higher_cap_starts_over(self, tmp_path):
        """Raising the cap keeps more history for a save that already had some.

        The 2013 way to reclaim a save that had grown large was to clear the
        chain; the new one is to trim with a lower cap or delete the save, and
        the old snapshots are rows like any other.
        """
        first = Store(str(tmp_path / "first.db"), keep=20)
        for level in range(1, 21):
            first.store("acct1", save(level))
        assert len(first.history("acct1")) == 19

        tighter = Store(str(tmp_path / "first.db"), keep=3)
        tighter.store("acct1", save(level=99))

        assert len(tighter.history("acct1")) == 3

    def test_deleting_a_save_takes_its_history_with_it(self, store):
        for level in range(1, 8):
            store.store("acct1", save(level))

        store.delete("acct1")

        assert store.history("acct1") == []
        assert store.load("acct1") is None