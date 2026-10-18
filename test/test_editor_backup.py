"""Rolling a save back to one of its snapshots.

The 2013 editor had a "Restore this backup" button per row that posted
``restore<n>`` walking a chain nested inside the save. History is a table now,
so this file pins the behaviour the button relies on, rebuilt against that:

* snapshots are listed newest-first, each labelled with the reason
  ``create_backup`` recorded and the level/coins it held;
* restoring applies that snapshot, and the state it replaced is snapshotted
  first, so a restore is itself undoable;
* a revision outside the history is refused rather than restoring something
  else;
* the index form still works, because old links and bookmarks post it.

The ``player`` fixture builds its history by making real writes rather than by
hand-placing a chain. That is the point of the rebuild: there is no chain to
hand-place any more, and a fixture that could still do so would be testing a
shape the code no longer has.
"""

from __future__ import annotations

import pytest


@pytest.fixture(scope="module")
def client(gateway_app):
    """A client on the shared throwaway gateway app. See test/conftest.py."""
    return gateway_app.test_client()


def _save(level: int, coins: int) -> dict:
    """A minimal but structurally valid save, as the editor would see it."""
    return {
        "user_object": {
            "userInfo": {
                "player": {"level": level, "cash": 1000, "xp": 500,
                           "uid": 2361750976462888, "playerResourceType": 0,
                           "socialXpGood": 0, "socialLevelGood": 0,
                           "socialXpBad": 0, "socialLevelBad": 0},
                "world": {"resources": {"coins": coins, "wood": 1},
                          "worldName": "Test"},
            }
        },
        "quests": [],
        "battle": {},
        "fleets": [],
        "population": 10,
        "save_version": "test",
    }


@pytest.fixture
def bare(gateway_app):
    """A fresh session with nothing in it.

    A new client, not the module-scoped one: an anonymous session's store id is
    derived from its cookie, so reusing a client reuses the same row and this
    test would see the snapshots the previous one left behind. That is exactly
    the kind of cross-test bleed that made "no snapshots to restore" answer 200.
    """
    fresh = gateway_app.test_client()
    with fresh.session_transaction() as session:
        session.clear()
    fresh.get("/avatar.json")
    return fresh


def _write(client, level: int, coins: int, reason: str | None = None):
    """Persist one save in a single request.

    Via ``/editor/save`` rather than fiddling with ``session_transaction``: that
    route sets the reason, applies the save and lets the session interface take
    the snapshot, all in one write. Mutating the session and then making another
    request to force a persist is two writes, and produced a duplicate snapshot
    per level -- history that looked five deep after three saves.
    """
    import json

    payload = _save(level, coins)
    response = client.post("/editor/save",
                           data={"savegame": json.dumps(payload),
                                 "message": reason or ""})
    assert response.status_code == 200, response.get_data()[:300]


@pytest.fixture
def player(bare):
    """A save at level 3 with two snapshots behind it: level 2, then level 1.

    Three writes. The first creates the row and snapshots nothing; each later
    write snapshots the state it replaced.

    Note whose reason a snapshot carries: the *superseding* write's. The
    snapshot of level 1 says "before second", because it was taken at the moment
    level 2 replaced it. That is what makes the list readable -- each entry
    describes the change that undoes it -- and it is the opposite of what the
    first draft of this fixture assumed.
    """
    _write(bare, 1, 10, reason="first")
    _write(bare, 2, 20, reason="second")
    _write(bare, 3, 30, reason="third")
    return bare


def _editor_state(client) -> dict:
    response = client.get("/editor.json")
    assert response.status_code == 200
    return response.get_json()


class TestSnapshotList:
    def test_lists_snapshots_newest_first(self, player):
        entries = _editor_state(player)["backupList"]

        assert [entry["level"] for entry in entries] == [2, 1]

    def test_each_entry_carries_the_reason(self, player):
        """The reason is the one the superseding write recorded."""
        entries = _editor_state(player)["backupList"]

        assert entries[0]["message"] == "before third"
        assert entries[1]["message"] == "before second"

    def test_each_entry_carries_the_numbers_an_admin_picks_by(self, player):
        entries = _editor_state(player)["backupList"]

        assert entries[0]["coins"] == 20
        assert entries[1]["coins"] == 10

    def test_the_count_agrees_with_the_list(self, player):
        state = _editor_state(player)

        assert state["backups"] == len(state["backupList"]) == 2

    def test_a_save_with_no_snapshots_is_not_an_error(self, bare):
        _write(bare, 1, 1)

        state = _editor_state(bare)

        assert state["backups"] == 0
        assert state["backupList"] == []


class TestRestore:
    def test_the_newest_snapshot_rolls_back_one_step(self, player):
        entries = _editor_state(player)["backupList"]

        response = player.post("/editor/restore",
                               data={"revision": entries[0]["revision"]})

        assert response.status_code == 200
        state = _editor_state(player)
        assert state["level"] == 2
        assert state["resources"]["coins"] == 20

    def test_an_older_snapshot_rolls_back_further(self, player):
        entries = _editor_state(player)["backupList"]

        player.post("/editor/restore", data={"revision": entries[1]["revision"]})

        state = _editor_state(player)
        assert state["level"] == 1

    def test_the_index_form_still_works(self, player):
        """Old links post an index; it resolves against the current listing."""
        response = player.post("/editor/restore", data={"index": "0"})

        assert response.status_code == 200
        assert _editor_state(player)["level"] == 2

    def test_a_restore_is_itself_undoable(self, player):
        """The old chain trimmed itself; this one cannot lose the way back."""
        entries = _editor_state(player)["backupList"]
        player.post("/editor/restore", data={"revision": entries[0]["revision"]})

        after = _editor_state(player)
        # Rolling forward again is possible because restoring snapshots what it
        # replaced rather than consuming the snapshot it read.
        forward = [row for row in after["backupList"]
                   if row["level"] == 3]
        assert forward, "the state that was replaced should have been kept"
        player.post("/editor/restore", data={"revision": forward[0]["revision"]})
        assert _editor_state(player)["level"] == 3

    def test_an_unknown_revision_is_refused(self, player):
        response = player.post("/editor/restore", data={"revision": "9999"})

        assert response.status_code == 400
        assert _editor_state(player)["level"] == 3

    @pytest.mark.parametrize("index", ["abc", "1.5", ""])
    def test_an_index_that_is_not_a_number_is_refused(self, player, index):
        response = player.post("/editor/restore", data={"index": index})

        assert response.status_code == 400

    @pytest.mark.parametrize("index", ["-1", "99"])
    def test_an_index_outside_the_chain_is_refused(self, player, index):
        response = player.post("/editor/restore", data={"index": index})

        assert response.status_code == 400
        assert _editor_state(player)["level"] == 3

    def test_restoring_without_snapshots_is_refused(self, bare):
        _write(bare, 5, 5)

        response = bare.post("/editor/restore", data={"index": "0"})

        assert response.status_code == 400