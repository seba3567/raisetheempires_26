"""Finding one player by the id the game actually uses.

Seven call sites -- neighbor_repelled, invasion_complete, pillage_response,
occupation_place_response and the rest -- used to find another player like
this:

    [save] = [save for save in get_saves()
              if str(save['user_object']["userInfo"]["player"]["uid"]) == str(uid)]

which deserialised *every* empire in the database to compare one number, on
every invasion and every pillage, and raised an unpacking ValueError on a miss.

The uid is an indexed column on saves now. These pin the lookup, the column
being filled on write, and the two things that make it safe: the uid comes from
the payload rather than from the caller, and a miss is a lookup miss rather than
an exception unless it was declared required.
"""
from __future__ import annotations

import os
import uuid

import pytest

from save_store import Store, save_uid

# Store takes a mariadb:// URL; there is no SQLite fallback any more, so each
# test names its own throwaway database on the shared server.
SERVER = os.environ.get("RTE_TEST_MARIADB",
                        "mariadb://root:2001@127.0.0.1:3306/rte_uid_test")


def a_store() -> Store:
    base = SERVER.rsplit("/", 1)[0]
    return Store(f"{base}/rte_uid_{uuid.uuid4().hex[:10]}")


@pytest.fixture
def store():
    return a_store()


def empire(uid, level=1, name="Empire"):
    return {"user_object": {"userInfo": {"player": {"uid": uid, "level": level},
                                        "worldName": name}},
            "fleets": {}, "battle": None}


class TestTheUidColumn:
    def test_it_is_filled_on_the_first_write(self, store):
        store.store("acct1", empire(111))

        assert store.load_by_uid(111).store_id == "acct1"

    def test_it_follows_the_payload_on_later_writes(self, store):
        store.store("acct1", empire(111))

        store.store("acct1", empire(222))

        assert store.load_by_uid(222).store_id == "acct1"
        assert store.load_by_uid(111) is None

    def test_two_players_stay_distinguishable(self, store):
        store.store("acct1", empire(111, level=1))
        store.store("acct2", empire(222, level=9))

        assert store.load_by_uid(111).data["user_object"]["userInfo"]["player"]["level"] == 1
        assert store.load_by_uid(222).data["user_object"]["userInfo"]["player"]["level"] == 9

    def test_a_save_with_no_player_stores_no_uid(self, store):
        """Not an error: the empire has not booted, so there is nobody to find."""
        store.store("acct1", {"user_object": None})

        assert store.load_by_uid(111) is None

    def test_an_unknown_uid_is_a_miss_not_an_exception(self, store):
        store.store("acct1", empire(111))

        assert store.load_by_uid(999) is None


class TestSaveUid:
    def test_it_reads_the_player_id(self):
        assert save_uid(empire(1234)) == 1234

    @pytest.mark.parametrize("payload", [
        None, [], "text", 42,
        {},
        {"user_object": None},
        {"user_object": {}},
        {"user_object": {"userInfo": {}}},
        {"user_object": {"userInfo": {"player": {}}}},
        {"user_object": {"userInfo": {"player": {"uid": None}}}},
        {"user_object": {"userInfo": {"player": {"uid": "1234"}}}},
    ])
    def test_anything_unusable_reads_as_no_uid(self, payload):
        """Runs against every row on every write, so it cannot raise.

        A row written by an older build, a half-finished paste and a test's stub
        all reach this.
        """
        assert save_uid(payload) is None

    def test_a_boolean_is_not_an_id(self):
        """bool is an int subclass; True would index a row as uid 1."""
        assert save_uid(empire(True)) is None


class TestTheBackfill:
    """rows_without_uid / set_uid, used by backfill_save_uid.py."""

    def test_a_row_written_before_the_column_is_found(self, store):
        store.store("acct1", empire(303))
        with store._connect() as connection:
            store._exec(connection,
                        "UPDATE saves SET uid = NULL WHERE store_id = %s",
                        ("acct1",))

        pending = store.rows_without_uid()

        assert len(pending) == 1
        assert save_uid(pending[0][1]) == 303

    def test_filling_it_makes_the_player_findable(self, store):
        store.store("acct1", empire(303))
        with store._connect() as connection:
            store._exec(connection,
                        "UPDATE saves SET uid = NULL WHERE store_id = %s",
                        ("acct1",))

        for store_id, payload in store.rows_without_uid():
            store.set_uid(store_id, save_uid(payload))

        assert store.load_by_uid(303).store_id == "acct1"
        assert store.rows_without_uid() == []

    def test_a_row_with_no_player_is_left_alone(self, store):
        store.store("acct1", {"user_object": None})

        assert store.rows_without_uid() == [] or \
            all(save_uid(p) is None for _, p in store.rows_without_uid())