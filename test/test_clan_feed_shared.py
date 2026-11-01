"""The alliance wall is one wall, not two.

The web owns the relational clan system -- ``clans``, ``clan_members`` and
``clan_messages``. The gateway used to keep a fiction of its own inside the
player's save: a hardcoded id, a made-up member, and a feed only that player
could ever read. So a message posted in the game never reached the wall the
web shows, and the alliance the web knew about was invisible to the game.

These put a real alliance in the tables and check that the gateway sees the
same one, and that a message posted in the game lands in the table the web
reads.
"""

from __future__ import annotations

from pathlib import Path

import pytest
from flask import session

WEB_MIGRATIONS = (
    Path(__file__).resolve().parent.parent
    / "web"
    / "src"
    / "lib"
    / "server"
    / "db"
    / "migrations"
)

ZID = 987654321
USER_ID = 9001
CLAN_ID = 7001


def _test_database_url(app) -> str:
    from save_engine import save_store_url

    with app.app_context():
        return save_store_url()


def _apply_web_migrations(app) -> None:
    """Put the web's tables in the test database.

    The clan tables are the web's, and the gateway and the web share one
    PostgreSQL database. A test that puts an alliance in them needs them to
    exist here, and the files that build them are the ones the front end
    applies.
    """
    from save_store import connect

    with connect(_test_database_url(app)) as conn:
        for path in sorted(WEB_MIGRATIONS.glob("*.sql")):
            conn.execute(path.read_text(encoding="utf-8"))


@pytest.fixture
def alliance(gateway_app):
    """A real alliance in the tables, with one member."""
    _apply_web_migrations(gateway_app)

    from save_store import connect

    with connect(_test_database_url(gateway_app)) as conn:
        conn.execute("DELETE FROM clan_messages")
        conn.execute("DELETE FROM clan_members")
        conn.execute("DELETE FROM clans")
        conn.execute("DELETE FROM users WHERE zid = %s", (ZID,))
        conn.execute(
            "INSERT INTO users (id, zid, username, username_key, password_hash, role, created_at) "
            "VALUES (%s, %s, %s, %s, %s, 'player', CURRENT_TIMESTAMP)",
            (USER_ID, ZID, "Commander", "commander", "not-a-real-hash"),
        )
        conn.execute(
            "INSERT INTO clans (id, name, crest, level, xp, health, max_health, slots, "
            "leader_id, created_at, updated_at) "
            "VALUES (%s, %s, 'crest_01', 3, 40, 70, 100, 12, %s, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)",
            (CLAN_ID, "Vanguard Alliance", USER_ID),
        )
        conn.execute(
            "INSERT INTO clan_members (clan_id, user_id, role, joined_at) "
            "VALUES (%s, %s, 'leader', CURRENT_TIMESTAMP)",
            (CLAN_ID, USER_ID),
        )

    return {"zid": ZID, "user_id": USER_ID, "clan_id": CLAN_ID}


def _in_game_request(app, zid=None):
    """A request as the game makes it, with the front door's identity header."""
    headers = {"x-player-zid": str(zid)} if zid is not None else {}
    return app.test_request_context("/", headers=headers)


def test_the_gateway_sees_the_alliance_in_the_tables(gateway_app, alliance):
    from service_handlers import clans_get_clan_info

    with _in_game_request(gateway_app, alliance["zid"]):
        data = clans_get_clan_info()["data"]

    assert data["id"] == alliance["clan_id"]
    assert data["name"] == "Vanguard Alliance"
    assert data["level"] == 3
    assert data["health"] == 70
    assert data["slots"] == 12
    assert [m["name"] for m in data["members"]] == ["Commander"]
    assert data["members"][0]["role"] == "leader"


def test_a_message_posted_in_the_game_lands_in_the_wall_the_web_reads(gateway_app, alliance):
    from save_store import connect
    from service_handlers import clans_post_group_feed

    with _in_game_request(gateway_app, alliance["zid"]):
        session["user_object"] = {
            "userInfo": {"player": {"uid": alliance["zid"], "name": "Commander"}}
        }
        response = clans_post_group_feed([{"message": "Hello warriors!"}])

    assert response["errorType"] == 0

    with connect(_test_database_url(gateway_app)) as conn:
        rows = conn.execute(
            "SELECT message FROM clan_messages WHERE clan_id = %s ORDER BY id",
            (alliance["clan_id"],),
        ).fetchall()
    assert [row["message"] for row in rows] == ["Hello warriors!"]


def test_the_game_sees_the_messages_the_web_posted(gateway_app, alliance):
    from save_store import connect
    from service_handlers import clans_get_clan_info

    with connect(_test_database_url(gateway_app)) as conn:
        conn.execute(
            "INSERT INTO clan_messages (clan_id, user_id, message, created_at) "
            "VALUES (%s, %s, %s, CURRENT_TIMESTAMP)",
            (alliance["clan_id"], alliance["user_id"], "Posted from the web"),
        )

    with _in_game_request(gateway_app, alliance["zid"]):
        data = clans_get_clan_info()["data"]

    assert [entry["message"] for entry in data["feed"]] == ["Posted from the web"]


def test_renaming_the_alliance_reaches_the_tables(gateway_app, alliance):
    from save_store import connect
    from service_handlers import clans_update_name

    with _in_game_request(gateway_app, alliance["zid"]):
        session["user_object"] = {
            "userInfo": {"player": {"uid": alliance["zid"], "name": "Commander"}}
        }
        response = clans_update_name([{"name": "Iron Pact"}])

    assert response["errorType"] == 0

    with connect(_test_database_url(gateway_app)) as conn:
        rows = conn.execute("SELECT name FROM clans WHERE id = %s", (alliance["clan_id"],)).fetchall()
    assert [row["name"] for row in rows] == ["Iron Pact"]


def test_creating_an_alliance_in_the_game_creates_it_in_the_tables(gateway_app, alliance):
    from save_store import connect
    from service_handlers import clans_create_clan

    with connect(_test_database_url(gateway_app)) as conn:
        conn.execute("DELETE FROM clan_messages")
        conn.execute("DELETE FROM clan_members")
        conn.execute("DELETE FROM clans")

    with _in_game_request(gateway_app, alliance["zid"]):
        session["user_object"] = {
            "userInfo": {"player": {"uid": alliance["zid"], "name": "Commander"}}
        }
        response = clans_create_clan([{"name": "Iron Pact", "crest": "crest_02"}])

    assert response["errorType"] == 0
    assert response["data"]["name"] == "Iron Pact"

    with connect(_test_database_url(gateway_app)) as conn:
        clans = conn.execute("SELECT id, name, crest FROM clans").fetchall()
        members = conn.execute("SELECT clan_id, role FROM clan_members").fetchall()

    assert [row["name"] for row in clans] == ["Iron Pact"]
    assert [row["crest"] for row in clans] == ["crest_02"]
    assert [row["role"] for row in members] == ["leader"]
    assert [row["clan_id"] for row in members] == [clans[0]["id"]]


def test_a_player_with_no_account_keeps_the_session_copy(gateway_app):
    """Anonymous play still works: the session's own copy is all there is."""
    from service_handlers import clans_get_clan_info, clans_post_group_feed

    with _in_game_request(gateway_app):
        session["user_object"] = {
            "userInfo": {"player": {"uid": 1, "name": "Commander"}}
        }
        info = clans_get_clan_info()["data"]
        assert info["name"] == "Vanguard Alliance"

        clans_post_group_feed([{"message": "Only I can read this"}])
        assert len(session["user_object"]["clansInfo"]["feed"]) == 1
