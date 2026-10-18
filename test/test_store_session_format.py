"""store_session was writing a format the rest of the server cannot read.

``store_session`` builds the row itself and fills ``record.data`` with
``pickle.dumps``. Everything else goes through ``session_interface.serializer``,
which this project patches to msgspec.msgpack in empires-server (see
``serializer_init_patch``, and the note at empires-server.py:143 that json was
switched off precisely because "msgspec makes it undepickleable").

So the bytes written are in a format nothing in the codebase decodes. The row is
not lost loudly: ``decode_save`` catches the failure, prints "Skipping corrupt
save", and returns None, and ``get_saves`` then drops the row entirely. The
player keeps playing against an in-memory session with no persistent row behind
it, and the loss is one line in a log nobody reads.

These were written to fail first. ``test_the_save_still_appears_in_the_session_list``
is the one that matters: it writes with store_session and reads back through the
same path the admin session list uses.
"""
from __future__ import annotations

import pickle

import pytest


@pytest.fixture(scope="module")
def client(gateway_app):
    return gateway_app.test_client()


@pytest.fixture
def roundtrip(gateway_app, client):
    """Yield a helper that writes a save with store_session and reads it back.

    Everything runs inside an app context: store_session goes through
    ``current_app.session_interface``, and the test client's request contexts do
    not stay pushed afterwards.
    """
    from save_engine import decode_save, get_saves, store_session

    def write_a_save():
        """Write a save the way production does, and return (record, saved).

        Every production caller reaches store_session through get_saves(), which
        stamps each save with the *store id* of the row it came from --
        ``session:acct<zid>`` once an account is bound, the cookie sid before
        that. The store id is what store_session looks the row up by, so the test
        has to use the same key or it is testing a different thing.
        """
        # Establish the row, then fill it in.
        client.get("/avatar.json")

        with client.session_transaction() as session:
            session["user_object"] = {
                "userInfo": {
                    "player": {
                        "level": 12, "uid": 2361750976462888, "xp": 5000,
                        "cash": 777, "playerResourceType": 5,
                        # validate_save insists on these four, and
                        # get_sessions_dropdown_info filters on it, so a save
                        # without them is one the admin list never shows.
                        "socialXpGood": 0, "socialLevelGood": 0,
                        "socialXpBad": 0, "socialLevelBad": 0,
                    },
                    "worldName": "Round Trip Empire",
                    "world": {"randSeedW": 18000, "randSeedZ": 36969,
                              "resources": {"coins": 1234, "wood": 9}},
                }
            }
            session["fleets"] = {}
            session["battle"] = None

        # A request, so flask-session writes the row out. Without it the row only
        # exists in the session's memory and get_saves -- which queries the
        # table -- cannot see it, which made this test pass or fail depending on
        # what ran before it.
        client.get("/avatar.json")

        # get_saves is what stamps the store id on, exactly as the invasion and
        # pillage paths do before they call store_session. Called directly rather
        # than through the fixture dict, because inside this closure the name
        # `roundtrip` refers to the fixture function, not the dict it yields.
        #
        # The accessors are defensive on purpose: get_saves keeps a row whose
        # "user_object" key is present but None -- its filter asks whether the key
        # is there, not whether it holds anything -- and other modules running
        # first in the shared database can leave such a row behind.
        def world_name_of(save):
            return (((save or {}).get("user_object") or {})
                    .get("userInfo") or {}).get("worldName")

        match = [s for s in get_saves() if world_name_of(s) == "Round Trip Empire"]
        assert match, "the session was not readable straight after writing it"
        save = match[0]

        stored = store_session(save)

        interface = gateway_app.session_interface
        record = interface.sql_session_model.query.filter_by(
            session_id=save["session_id"]).first()
        return record, stored

    with gateway_app.app_context():
        yield {
            "write": write_a_save,
            "decode": decode_save,
            "saves": get_saves,
            "store": store_session,
        }


def restored_looks_like_msgpack(data: bytes) -> bool:
    """True when the bytes decode as msgpack."""
    try:
        import msgspec
        msgspec.msgpack.decode(data)
        return True
    except Exception:
        return False


class TestWhatStoreSessionWrites:
    def test_the_write_happened(self, roundtrip):
        record, stored = roundtrip["write"]()

        assert record is not None
        assert stored is True

    def test_the_store_key_is_not_written_into_the_save(self, roundtrip):
        """It is how the row is found, not part of the empire.

        It used to be included, so every persisted save carried a key the game
        has no idea what to do with.
        """
        record, _ = roundtrip["write"]()

        restored = roundtrip["decode"](record.data)

        assert "session_id" not in restored

    def test_it_is_msgpack_now_not_pickle(self, roundtrip):
        """Pin the fix, so going back to pickle has to be a decision."""
        record, _ = roundtrip["write"]()

        # A pickle stream opens with a protocol marker; msgpack never emits it.
        assert not record.data.startswith(b"\x80"), "pickle is back"
        assert restored_looks_like_msgpack(record.data)


class TestWhatTheServerCanReadBack:
    """These are the ones that were failing."""

    def test_decode_save_reads_what_store_session_wrote(self, roundtrip):
        record, _ = roundtrip["write"]()

        assert roundtrip["decode"](record.data) is not None, (
            "store_session wrote bytes decode_save cannot read; the row is now "
            "dead weight that get_saves silently skips"
        )

    def test_the_empire_survives_the_roundtrip(self, roundtrip):
        record, _ = roundtrip["write"]()

        restored = roundtrip["decode"](record.data)

        assert restored["user_object"]["userInfo"]["worldName"] == "Round Trip Empire"
        assert restored["user_object"]["userInfo"]["player"]["level"] == 12

    def test_the_save_appears_in_the_session_list(self, roundtrip):
        """The user-visible symptom: the empire vanishes from /list_session.

        get_saves() drops any row decode_save returns None for, so a corrupt row
        is invisible to the player and to the admin alike.
        """
        roundtrip["write"]()

        def world_name_of(save):
            return (((save or {}).get("user_object") or {})
                    .get("userInfo") or {}).get("worldName")

        names = [world_name_of(s) for s in roundtrip["saves"]()]

        assert "Round Trip Empire" in names, (
            "the empire was written and then dropped on read; get_saves hides it"
        )

    def test_the_admin_route_still_lists_it(self, gateway_app, roundtrip):
        """Same thing one layer up, through the route an admin actually opens."""
        roundtrip["write"]()
        client = gateway_app.test_client()

        body = client.get("/list_session").get_json()

        assert any(s["world_name"] == "Round Trip Empire" for s in body), (
            "the empire is gone from the admin's session list"
        )

    def test_two_writes_in_a_row_keep_working(self, roundtrip):
        """The invasion and pillage paths write more than once.

        With pickle this is what lost the save: the second write went to a row
        nothing could read, so an invasion followed by a pillage destroyed the
        defender's empire outright.
        """
        roundtrip["write"]()
        record, stored = roundtrip["write"]()

        assert stored is True
        assert roundtrip["decode"](record.data) is not None

    def test_a_missing_row_is_reported_not_raised(self, roundtrip):
        """Assigning to record.data with no row raised on None.

        The whole request died instead, and the caller had no way to know the
        write had not happened.
        """
        stored = roundtrip["store"]({"session_id": "session:acct-nobody", "x": 1})

        assert stored is False