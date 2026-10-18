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


class TestTheAdminRouteStillWorks:
    def test_the_art_serve(self, client):
        """Nothing above should have broken the asset routes."""
        assert asset_status(client, "/avatar.json") == 200
        assert asset_status(client, "/motd.json") == 200