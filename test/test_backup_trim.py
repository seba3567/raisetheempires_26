"""The backup chain has a ceiling.

``create_backup`` deep-copies the save *and the backup it replaced*, so the
chain is a nested list of full saves: it grows by a whole save per backup,
forever. The Rising Empire save stacked 85 of them into 3029 KB, and the client
decodes that blob over AMF on every request -- 18.7 ms per call, which is what
made the menus feel slow. Measured: 40 backups cost 8.5 ms, 10 cost 2.3 ms.

This file pins the ceiling: a long-playing save stops growing, the backups that
survive are the recent ones, and trimming never touches the save.
"""

from __future__ import annotations

import json

import pytest

from save_engine import (
    MAX_BACKUPS,
    backup_chain,
    trim_backups,
)


def _save(level: int) -> dict:
    """A minimal but structurally valid save."""
    return {
        "user_object": {
            "userInfo": {
                "player": {"level": level, "cash": 1000, "xp": 500},
                "world": {"resources": {"coins": level, "wood": 1}, "worldName": "Test"},
            }
        },
        "quests": [],
        "battle": {},
        "fleets": [],
        "population": 10,
        "save_version": "test",
    }


def _chain(depth: int) -> dict:
    """A save with ``depth`` backups behind it, the newest one numbered highest."""
    save = _save(level=depth + 1)
    node = save
    for i in range(depth, 0, -1):
        node["backup"] = {**_save(level=i), "message": f"b{i}"}
        node = node["backup"]
    return save


class TestBackupChain:
    def test_walks_newest_first(self):
        chain = backup_chain(_chain(3))

        assert [node["message"] for node in chain] == ["b3", "b2", "b1"]

    def test_a_save_without_backups_has_an_empty_chain(self):
        assert backup_chain(_save(level=1)) == []

    def test_a_link_that_is_not_a_dict_ends_the_walk(self):
        """A half-written chain must not hang the walk or the editor."""
        for corrupt in ("corrupt", None, 42, ["nope"]):
            save = _save(level=1)
            save["backup"] = {**_save(level=0), "backup": corrupt}

            assert len(backup_chain(save)) == 1, corrupt


class TestTrimBackups:
    def test_keeps_only_the_newest(self):
        save = _chain(50)

        assert trim_backups(save=save) == 50 - MAX_BACKUPS

        messages = [node["message"] for node in backup_chain(save)]
        assert len(messages) == MAX_BACKUPS
        assert messages[0] == "b50"
        assert messages[-1] == f"b{50 - MAX_BACKUPS + 1}", "the wrong end was cut"

    def test_the_save_itself_is_untouched(self):
        save = _chain(50)
        live = save["user_object"]

        trim_backups(save=save)

        assert save["user_object"] is live
        assert save["user_object"]["userInfo"]["player"]["level"] == 51
        assert "population" in save

    def test_a_short_chain_is_left_alone(self):
        save = _chain(3)
        before = backup_chain(save)

        assert trim_backups(save=save) == 0
        assert backup_chain(save) == before, "a chain under the limit was rewritten"

    def test_a_chain_exactly_at_the_limit_is_left_alone(self):
        save = _chain(MAX_BACKUPS)

        assert trim_backups(save=save) == 0
        assert len(backup_chain(save)) == MAX_BACKUPS

    def test_zero_clears_every_backup(self):
        save = _chain(50)

        assert trim_backups(0, save=save) == 50
        assert backup_chain(save) == []
        assert "backup" not in save

    def test_the_surviving_nodes_are_the_same_objects(self):
        """The editor lists these nodes; trimming must not swap them out."""
        save = _chain(50)
        kept = backup_chain(save)[:MAX_BACKUPS]

        trim_backups(save=save)

        assert backup_chain(save) == kept


class TestCreateBackup:
    """The ceiling on the real path: every backup the game takes.

    ``/editor/save`` posts a raw paste, which is the same ``create_backup`` call
    every cheat, quest and level-up makes, over a real request so the session is
    persisted the way the gateway persists it.
    """

    @pytest.fixture(scope="module")
    def client(self, gateway_app):
        return gateway_app.test_client()

    def _post_save(self, client, level: int) -> None:
        response = client.post(
            "/editor/save",
            data={"savegame": json.dumps(_save(level)), "message": f"save {level}"},
        )
        assert response.status_code == 200, response.get_data(as_text=True)

    def test_a_long_session_stops_growing(self, client):
        with client.session_transaction() as session:
            session.clear()

        for level in range(1, MAX_BACKUPS + 31):
            self._post_save(client, level)

        state = client.get("/editor.json").get_json()

        assert state["backups"] == MAX_BACKUPS, "the chain grew past the ceiling"
        assert state["level"] == MAX_BACKUPS + 30, "the live save was trimmed away"

    def test_the_newest_backups_are_the_ones_kept(self, client):
        with client.session_transaction() as session:
            session.clear()

        for level in range(1, MAX_BACKUPS + 6):
            self._post_save(client, level)

        state = client.get("/editor.json").get_json()

        assert state["backups"] == MAX_BACKUPS
        labels = [entry["label"] for entry in state["backupList"]]
        assert labels[0].endswith(f"save {MAX_BACKUPS + 5}")
        assert labels[-1].endswith("save 6"), "the wrong end of the chain was cut"

    def test_the_editor_still_restores_what_is_left(self, client):
        """Trimming must not cost the way back."""
        with client.session_transaction() as session:
            session.clear()

        for level in range(1, MAX_BACKUPS + 4):
            self._post_save(client, level)

        # Level MAX_BACKUPS + 1 is the oldest survivor: index 0 is the one
        # before the current save, index 1 the one before that.
        response = client.post("/editor/restore", data={"index": "1"})

        assert response.status_code == 200
        assert client.get("/editor.json").get_json()["level"] == MAX_BACKUPS + 1

    def test_the_editor_is_told_the_ceiling(self, client):
        """The page renders the ceiling instead of hard-coding it."""
        state = client.get("/editor.json").get_json()

        assert state["maxBackups"] == MAX_BACKUPS
