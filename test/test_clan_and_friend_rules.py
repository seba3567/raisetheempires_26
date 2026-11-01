"""The clan and friendship rules, checked on both doors.

The web front door and the gateway are two doors onto the same tables. A
player can create an alliance from the page or from inside the game, and ask
for a friendship from either side, and the rules have to hold whichever door
the request came through.

They did not. The web refused a request between two players when either one
had the other blocked; the gateway wrote the row anyway, so a player who had
been blocked could still send them a request from inside the game -- the same
action, two doors, one rule on one of them.

The values both sides need are written down once, in ``contract/runtime.json``.
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

SENDER_ID = 9101
SENDER_ZID = 991000001
TARGET_ID = 9102
TARGET_ZID = 992000002


def _test_database_url(app) -> str:
    from save_engine import save_store_url

    with app.app_context():
        return save_store_url()


def _apply_web_migrations(app) -> None:
    """Put the web's tables in the test database.

    The friendship and clan tables are the web's, and the two runtimes share
    one PostgreSQL database. The files that build them are the ones the front
    end applies.
    """
    from save_store import connect

    with connect(_test_database_url(app)) as conn:
        for path in sorted(WEB_MIGRATIONS.glob("*.sql")):
            conn.execute(path.read_text(encoding="utf-8"))


def _in_game_request(app, zid):
    """A request as the game makes it, with the front door's identity header."""
    return app.test_request_context("/", headers={"x-player-zid": str(zid)})


@pytest.fixture
def two_players(gateway_app):
    """Two accounts and the friendship table between them."""
    _apply_web_migrations(gateway_app)

    from save_store import connect

    with connect(_test_database_url(gateway_app)) as conn:
        conn.execute("DELETE FROM friendships")
        conn.execute(
            "DELETE FROM users WHERE zid IN (%s, %s)", (SENDER_ZID, TARGET_ZID)
        )
        for user_id, zid, name in (
            (SENDER_ID, SENDER_ZID, "remitente"),
            (TARGET_ID, TARGET_ZID, "destinatario"),
        ):
            conn.execute(
                "INSERT INTO users (id, zid, username, username_key, password_hash, role, created_at) "
                "VALUES (%s, %s, %s, %s, %s, 'player', CURRENT_TIMESTAMP)",
                (user_id, zid, name, name, "not-a-real-hash"),
            )

    yield gateway_app

    with connect(_test_database_url(gateway_app)) as conn:
        conn.execute("DELETE FROM friendships")
        conn.execute(
            "DELETE FROM users WHERE zid IN (%s, %s)", (SENDER_ZID, TARGET_ZID)
        )


def _friendship_rows(app) -> list[dict]:
    from save_store import connect

    with connect(_test_database_url(app)) as conn:
        cursor = conn.execute(
            "SELECT user_id, friend_id, status FROM friendships ORDER BY user_id, friend_id"
        )
        return list(cursor.fetchall())


def _block(app, blocker_id: int, blocked_id: int) -> None:
    from save_store import connect

    with connect(_test_database_url(app)) as conn:
        conn.execute(
            "INSERT INTO friendships (user_id, friend_id, status, requested_by, created_at) "
            "VALUES (%s, %s, 'blocked', %s, CURRENT_TIMESTAMP)",
            (blocker_id, blocked_id, blocker_id),
        )


def _clan_rows(app) -> list[dict]:
    from save_store import connect

    with connect(_test_database_url(app)) as conn:
        cursor = conn.execute(
            "SELECT name, crest, level, xp, health, max_health, slots FROM clans"
        )
        return list(cursor.fetchall())


class TestTheBlockRule:
    """The rule the web already had and the gateway did not.

    The blocked player is the one who blocks: they do not want to hear from
    the other, so a request in either direction is refused.
    """

    def test_a_request_between_two_players_is_written(self, two_players):
        """The normal case still works, through the gateway."""
        from service_handlers import request_neighbor

        with _in_game_request(two_players, SENDER_ZID):
            session["user_object"] = {
                "userInfo": {"player": {"uid": SENDER_ZID, "name": "remitente"}}
            }
            request_neighbor([[TARGET_ZID]])

        rows = _friendship_rows(two_players)
        assert len(rows) == 1
        assert rows[0]["status"] == "pending"

    def test_a_blocked_player_cannot_be_asked_again(self, two_players):
        """The web refused this. The gateway wrote the row anyway."""
        from service_handlers import request_neighbor

        _block(two_players, TARGET_ID, SENDER_ID)

        with _in_game_request(two_players, SENDER_ZID):
            session["user_object"] = {
                "userInfo": {"player": {"uid": SENDER_ZID, "name": "remitente"}}
            }
            request_neighbor([[TARGET_ZID]])

        rows = _friendship_rows(two_players)
        assert all(row["status"] != "pending" for row in rows), rows

    def test_blocking_works_the_other_way_round_too(self, two_players):
        """The rule is about the pair, not about who asked."""
        from service_handlers import request_neighbor

        _block(two_players, SENDER_ID, TARGET_ID)

        with _in_game_request(two_players, SENDER_ZID):
            session["user_object"] = {
                "userInfo": {"player": {"uid": SENDER_ZID, "name": "remitente"}}
            }
            request_neighbor([[TARGET_ZID]])

        rows = _friendship_rows(two_players)
        assert all(row["status"] != "pending" for row in rows), rows


class TestTheClanValues:
    def test_the_defaults_come_from_the_contract(self):
        import contract

        assert contract.CLAN_DEFAULTS["level"] == 1
        assert contract.CLAN_DEFAULTS["xp"] == 0
        assert contract.CLAN_DEFAULTS["health"] == 100
        assert contract.CLAN_DEFAULTS["maxHealth"] == 100
        assert contract.CLAN_DEFAULTS["slots"] == 10

    def test_the_shields_are_the_ones_the_web_knows(self):
        import contract

        assert list(contract.CLAN_CRESTS) == [
            "crest_01",
            "crest_02",
            "crest_03",
            "crest_04",
            "crest_05",
        ]
        assert contract.CLAN_DEFAULT_CREST in contract.CLAN_CRESTS

    def test_an_alliance_starts_with_the_contracted_values(self, two_players):
        """A real alliance in the tables, made by the gateway.

        The numbers used to be free to disagree with the ones the web writes.
        """
        import contract
        from save_store import connect
        from service_handlers import clans_create_clan

        with connect(_test_database_url(two_players)) as conn:
            conn.execute("DELETE FROM clan_members")
            conn.execute("DELETE FROM clans")

        with _in_game_request(two_players, SENDER_ZID):
            session["user_object"] = {
                "userInfo": {"player": {"uid": SENDER_ZID, "name": "remitente"}}
            }
            clans_create_clan([{"name": "Los Aliados", "crest": "crest_02"}])

        rows = _clan_rows(two_players)
        assert len(rows) == 1
        row = rows[0]
        assert row["name"] == "Los Aliados"
        assert row["crest"] == "crest_02"
        assert row["level"] == contract.CLAN_DEFAULTS["level"]
        assert row["xp"] == contract.CLAN_DEFAULTS["xp"]
        assert row["health"] == contract.CLAN_DEFAULTS["health"]
        assert row["max_health"] == contract.CLAN_DEFAULTS["maxHealth"]
        assert row["slots"] == contract.CLAN_DEFAULTS["slots"]

    def test_a_shield_the_contract_does_not_know_is_refused(self, two_players):
        """The gateway used to take any shield.

        An alliance created inside the game could then carry one the page had
        never heard of, and the page had no way to draw it.
        """
        import contract
        from save_store import connect
        from service_handlers import clans_create_clan

        with connect(_test_database_url(two_players)) as conn:
            conn.execute("DELETE FROM clan_members")
            conn.execute("DELETE FROM clans")

        with _in_game_request(two_players, SENDER_ZID):
            session["user_object"] = {
                "userInfo": {"player": {"uid": SENDER_ZID, "name": "remitente"}}
            }
            clans_create_clan([{"name": "Escudo Falso", "crest": "crest_99"}])

        rows = _clan_rows(two_players)
        assert [row["crest"] for row in rows] == [contract.CLAN_DEFAULT_CREST]
