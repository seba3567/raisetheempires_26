"""Rolling a save back to one of the stacked backups.

The 2013 editor had a "Restore this backup" button per row that posted
``restore<n>``; ``/editor/restore`` is what replaced it, and this file pins the
behaviour that button relied on:

* the chain is walked newest-first, so index 0 is the save that was replaced
  most recently;
* restoring applies that save, and the state it replaced is backed up first, so
  a restore is itself undoable;
* the backup is deep-copied out of the chain before it is applied -- the node
  is still linked from the session it was copied out of, and mutating it in
  place would corrupt every backup behind it;
* an index outside the chain is refused rather than crashing on a KeyError.
"""

from __future__ import annotations

import pytest


@pytest.fixture(scope="module")
def client(gateway_app):
    """A client on the shared throwaway gateway app.

    ``test/conftest.py`` owns the app configuration; this module only needs a
    client, and each one gets its own cookie so sessions do not collide.
    """
    return gateway_app.test_client()


def _save(level: int, coins: int) -> dict:
    """A minimal but structurally valid save, as the editor would see it."""
    return {
        "user_object": {
            "userInfo": {
                "player": {"level": level, "cash": 1000, "xp": 500},
                "world": {"resources": {"coins": coins, "wood": 1}, "worldName": "Test"},
            }
        },
        "quests": [],
        "battle": {},
        "fleets": [],
        "population": 10,
        "save_version": "test",
    }


@pytest.fixture
def bare(client):
    """A session with nothing in it, so no test can see another's leftovers."""
    with client.session_transaction() as session:
        session.clear()
    return client


@pytest.fixture
def player(bare):
    """A session holding a save plus a two-deep backup chain."""
    with bare.session_transaction() as session:
        session["user_object"] = _save(level=3, coins=30)["user_object"]
        session["quests"] = []
        session["battle"] = {}
        session["fleets"] = []
        session["population"] = 10
        session["save_version"] = "test"
        session["saved"] = "current"
        # Two backups behind the current save: index 0 is level 2, index 1 is 1.
        session["backup"] = {**_save(level=2, coins=20), "message": "second"}
        session["backup"]["backup"] = {**_save(level=1, coins=10), "message": "first"}
    return bare


def _editor_state(client) -> dict:
    response = client.get("/editor.json")
    assert response.status_code == 200
    return response.get_json()


def _level_and_coins(client) -> tuple:
    state = _editor_state(client)
    return state["level"], state["resources"]["coins"]


class TestBackupChain:
    def test_lists_backups_newest_first(self, player):
        entries = _editor_state(player)["backupList"]

        assert [entry["index"] for entry in entries] == [0, 1]
        assert entries[0]["message"] == "second"
        assert entries[1]["message"] == "first"

    def test_the_count_agrees_with_the_list(self, player):
        state = _editor_state(player)

        assert state["backups"] == len(state["backupList"])

    def test_a_save_with_no_backups_is_not_an_error(self, bare):
        with bare.session_transaction() as session:
            session["user_object"] = _save(level=1, coins=1)["user_object"]

        state = _editor_state(bare)

        assert state["backups"] == 0
        assert state["backupList"] == []


class TestRestore:
    def test_index_zero_rolls_back_one_step(self, player):
        response = player.post("/editor/restore", data={"index": "0"})

        assert response.status_code == 200
        assert response.get_json()["ok"] is True
        assert _level_and_coins(player) == (2, 20)

    def test_a_deeper_index_rolls_back_further(self, player):
        response = player.post("/editor/restore", data={"index": "1"})

        assert response.get_json()["ok"] is True
        assert _level_and_coins(player) == (1, 10)

    def test_restoring_backs_the_replaced_save_up_first(self, player):
        """A restore has to be undoable, or it is a one-way door."""
        player.post("/editor/restore", data={"index": "1"})
        assert _level_and_coins(player) == (1, 10)

        state = _editor_state(player)

        assert state["backups"] == 3, "the replaced save was not preserved"
        assert state["backupList"][0]["message"].startswith("revert to backup")

    def test_restoring_does_not_mutate_the_backup_behind_it(self, player):
        """The chain node is still linked from the session it was copied from.

        ``_apply_save`` reassigns keys on whatever dict it is handed. If that
        were the live chain node instead of a copy, restoring one backup would
        rewrite every older one behind it and two restores would be enough to
        destroy the history.
        """
        player.post("/editor/restore", data={"index": "1"})
        entries = _editor_state(player)["backupList"]

        # Three entries now: the save just replaced (level 3), then the
        # untouched level 2 and level 1 that were already there.
        assert [(e["index"], e["level"], e["coins"]) for e in entries] == [
            (0, 3, 30),
            (1, 2, 20),
            (2, 1, 10),
        ]

        # Restoring the oldest again still yields the oldest, twice over.
        player.post("/editor/restore", data={"index": "2"})
        assert _level_and_coins(player) == (1, 10)

    @pytest.mark.parametrize("index", ["99", "-1", "", "abc", "1.5"])
    def test_an_index_outside_the_chain_is_refused(self, player, index):
        response = player.post("/editor/restore", data={"index": index})

        assert response.status_code == 400
        assert response.get_json()["ok"] is False
        assert _level_and_coins(player) == (3, 30), "a refused restore changed the save"

    def test_restoring_without_backups_is_refused(self, bare):
        with bare.session_transaction() as session:
            session["user_object"] = _save(level=1, coins=1)["user_object"]

        response = bare.post("/editor/restore", data={"index": "0"})

        assert response.status_code == 400
        assert response.get_json()["ok"] is False
        assert _level_and_coins(bare) == (1, 1)