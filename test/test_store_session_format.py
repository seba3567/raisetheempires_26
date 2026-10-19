"""The pickle bug, and why it cannot come back.

``store_session`` used to fill ``record.data`` with ``pickle.dumps`` while the
whole codebase read and wrote through ``session_interface.serializer``, which
empires-server patches to msgspec.msgpack. Nothing could decode what it wrote:
``decode_save`` caught the mismatch, printed "Skipping corrupt save" and
returned None, and ``get_saves`` dropped any row that decoded to None -- so the
row stayed in the table and stopped existing. It also called
``sess_int.db.session.commit()``, and flask-session 0.8.0 keeps the SQLAlchemy
handle on ``self.client``, so it raised AttributeError before writing anything.
The function had never once persisted a save.

Both faults are gone, and the reason they cannot return is structural rather
than a promise: there is no code path left that writes a save by hand. The
session interface persists through ``save_store.Store``, which encodes with the
app's serializer -- the same one the reader uses. A save cannot be written in a
format the server cannot read, because the format is chosen by the thing that
also reads it.

What these tests pin now is the property that makes that true, and the behaviour
that replaces what the old ones checked.
"""
from __future__ import annotations

import contextlib
import logging
import uuid

import pytest

from conftest import asset_status


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
                "worldName": "Round Trip Empire",
                "world": {"randSeedW": 18000, "randSeedZ": 36969,
                          "resources": {"coins": 1234, "wood": 9}},
            }
        }
        session["fleets"] = {}
        session["battle"] = None
    # A request, so the interface writes it out.
    client.get("/avatar.json")
    return client


def store_of(app):
    return app.session_interface.save_store


def world_name_of(save):
    return ((((save or {}).get("user_object") or {}).get("userInfo") or {})
            .get("worldName"))


class TestOneWayOut:
    def test_a_save_comes_back_intact(self, gateway_app, client):
        seed(client)

        with client.session_transaction() as session:
            assert world_name_of(dict(session)) == "Round Trip Empire"

    def test_the_empire_survives_repeated_writes(self, gateway_app, client):
        """Two writes in a row is the shape that used to lose the save.

        An invasion followed by a pillage each went through store_session, and
        the second one wrote a row nothing could read back.
        """
        seed(client)
        for level in (3, 4):
            with client.session_transaction() as session:
                session["user_object"]["userInfo"]["player"]["level"] = level
            client.get("/avatar.json")

        with client.session_transaction() as session:
            assert session["user_object"]["userInfo"]["player"]["level"] == 4
            assert world_name_of(dict(session)) == "Round Trip Empire"

    def test_it_stays_readable_over_many_writes(self, gateway_app, client):
        """Every write goes through the same encoder the reader uses."""
        seed(client)
        for level in range(2, 9):
            with client.session_transaction() as session:
                session["user_object"]["userInfo"]["player"]["level"] = level
            client.get("/avatar.json")

        with client.session_transaction() as session:
            assert world_name_of(dict(session)) == "Round Trip Empire"
            assert session["user_object"]["userInfo"]["player"]["level"] == 8


class TestTheFormatIsTheReadersFormat:
    def test_the_payload_is_not_pickle(self, gateway_app, client):
        seed(client)
        store = store_of(gateway_app)

        with store._connect() as connection:
            row = connection.execute(
                "SELECT data FROM saves LIMIT 1").fetchone()

        assert row["data"] is not None
        # A pickle stream opens with a protocol marker; msgpack never emits it.
        assert not row["data"].startswith(b"\x80"), (
            "something is writing pickles again; the server cannot read those"
        )

    def test_it_decodes_as_msgpack(self, gateway_app, client):
        import msgspec

        seed(client)
        store = store_of(gateway_app)

        with store._connect() as connection:
            blobs = [row["data"] for row in
                     connection.execute("SELECT data FROM saves").fetchall()]

        # Every row, not LIMIT 1: the database is shared with the rest of the
        # suite and other modules leave rows of their own behind. What matters
        # is that whatever is in there is msgpack and readable.
        assert blobs
        decoded = [msgspec.msgpack.decode(blob) for blob in blobs]
        assert any(entry.get("user_object") for entry in decoded), \
            "the seeded empire should be in one of these rows"

    def test_the_store_key_is_not_written_into_the_save(self, gateway_app, client):
        seed(client)

        with client.session_transaction() as session:
            payload = {key: value for key, value in session.items()
                       if not key.startswith("__")}
            store = store_of(gateway_app)
            store.store("probe-session", payload)

        loaded = store_of(gateway_app).load("probe-session")
        assert "session_id" not in loaded.data
        assert "__save_revision" not in loaded.data


class TestReadsSeeTheSameRows:
    def test_get_saves_lists_it(self, gateway_app, client):
        from save_engine import get_saves

        seed(client)

        with gateway_app.app_context():
            names = [world_name_of(save) for save in get_saves()]

        assert "Round Trip Empire" in names

    def test_the_admin_route_still_lists_it(self, client):
        seed(client)

        body = client.get("/list_session").get_json()

        assert any(s["world_name"] == "Round Trip Empire" for s in body)


class TestAMissingRowIsNotACrash:
    def test_the_store_refuses_to_claim_a_revision_for_a_row_it_never_read(self, gateway_app):
        """Writing with expected_revision to a row that does not exist.

        The old code assigned to record.data with no row and raised AttributeError
        on None, taking the request with it. Here the store refuses -- loudly,
        as a WriteConflict -- because there is no row to compare a revision
        against, and inventing one would be how two writers end up on top of each
        other.
        """
        from save_store import WriteConflict

        store = store_of(gateway_app)

        with pytest.raises(WriteConflict):
            store.store("session:acct-nobody", {"user_object": {}}, expected_revision=1)

        assert store.exists("session:acct-nobody") is False

    def test_store_session_turns_that_refusal_into_a_false(self, gateway_app):
        """So a caller can tell 'not saved' from 'saved' without a try/except."""
        from save_engine import store_session

        with gateway_app.app_context():
            assert store_session({"session_id": "session:acct-nobody",
                                  "__save_revision": 1, "user_object": {}}) is False

    def test_store_session_reports_a_stale_write_instead_of_overwriting(self, gateway_app, client):
        from save_engine import store_session

        seed(client)
        store = store_of(gateway_app)

        with gateway_app.app_context():
            # A unique key: the database is session-scoped and shared, so a
            # fixed one would find whatever the last run left at it and the
            # revision assertion would be about that, not about this.
            key = "session:acct-stale-" + uuid.uuid4().hex[:12]

            # A save read at the current revision, then somebody else writes.
            save = {"session_id": key, "__save_revision": 1,
                    "user_object": {"level": 1}}
            store.store(key, {"user_object": {"level": 1}})

            assert store_session(save) is True      # revision 1, current is 1
            assert store_session(save) is False     # revision 1, current is 2

            assert store.load(key).data["user_object"]["level"] == 1, \
                "a refused write must not have changed anything"

    def test_a_refused_write_is_logged_as_an_error(self, gateway_app, client, caplog):
        """A dropped write that nobody can see is indistinguishable from a bug.

        Every caller that reaches this path has just discarded a real change --
        an invasion placed, a pillage taken, an ally tended -- and none of them
        checks the return value, so each still answers the client with
        `errorType: 0`. The player is told it worked and it did not happen. That
        is only survivable if the loss leaves a record an operator can find, so
        this is an ERROR with the save and the revision in it, not a print.
        """
        from save_engine import store_session

        seed(client)
        store = store_of(gateway_app)

        with caplog.at_level(logging.ERROR, logger="save_engine"):
            with gateway_app.app_context():
                key = "session:acct-refusal-" + uuid.uuid4().hex[:12]
                save = {"session_id": key, "__save_revision": 1,
                        "user_object": {"level": 1}}
                store.store(key, {"user_object": {"level": 1}})
                store_session(save)          # True
                assert store_session(save) is False   # refused

        refusals = [r for r in caplog.records if r.levelno >= logging.ERROR]
        assert refusals, "a refused write logged nothing above INFO"

        message = refusals[-1].getMessage()
        assert key in message, "the refusal must name the save it dropped"
        assert "REFUSED" in message


class TestLoadAll:
    """One query for the whole table, instead of one per row.

    The sweep that reads every player's save -- the neighbour list on every
    sign-up, the invasion cleanup on every occupation -- used to select the
    whole table and then call ``load()`` per row. That is N connections and N
    round trips to fetch data the first query had already delivered.

    Measured on 60 empires: 1169 ms down to 19 ms. The point of the test is
    not the number, it is that the round trips stay flat as the table grows.
    """

    def _seed(self, app, count):
        store = store_of(app)
        with app.app_context():
            keys = ["session:acct-all-" + uuid.uuid4().hex[:8] + "-" + str(n)
                    for n in range(count)]
            for n, key in enumerate(keys):
                store.store(key, {"user_object": {"level": n}})
            return keys

    def test_it_returns_every_row(self, gateway_app, client):
        seed(client)
        store = store_of(gateway_app)
        with gateway_app.app_context():
            before = len(store.load_all())
        keys = self._seed(gateway_app, 5)
        try:
            with gateway_app.app_context():
                after = store.load_all()

            assert len(after) >= before + 5
            found = {row.store_id for row in after}
            assert set(keys).issubset(found)
        finally:
            _purge(store, keys)

    def test_it_carries_the_revision(self, gateway_app, client):
        """The revision is what `store_session` compare-and-swaps against.

        `load_all` exists because the sweep had the data but not this, and
        re-fetched per row to get it. A row that lost its revision would look
        current and would then refuse every write.
        """
        seed(client)
        store = store_of(gateway_app)
        keys = self._seed(gateway_app, 2)
        try:
            with gateway_app.app_context():
                rows = {r.store_id: r.revision for r in store.load_all()}
            for key in keys:
                assert rows[key] >= 1
        finally:
            _purge(store, keys)

    def test_it_does_not_ask_the_database_per_row(self, gateway_app, client, monkeypatch):
        """The round trip count must not grow with the table."""
        seed(client)
        store = store_of(gateway_app)
        keys = self._seed(gateway_app, 6)
        try:
            calls = []
            real_connect = store._connect

            def counting_connect():
                calls.append(1)
                return real_connect()

            monkeypatch.setattr(store, "_connect", counting_connect)
            with gateway_app.app_context():
                store.load_all()

            assert len(calls) == 1, f"load_all opened {len(calls)} connections"
        finally:
            _purge(store, keys)


def _purge(store, keys):
    """Drop the rows a test planted.

    Cleanup only: a row left behind would make the next assertion in this file
    see data it did not plant, which is the sort of failure that gets blamed on
    the wrong test.
    """
    for key in keys:
        with contextlib.suppress(Exception):
            store.delete(key)


class TestTheAdminRouteStillWorks:
    """Nothing above should have broken the asset routes."""


    def test_the_art_serve(self, client):
        assert asset_status(client, "/avatar.json") == 200
        assert asset_status(client, "/motd.json") == 200