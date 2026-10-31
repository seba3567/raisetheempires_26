"""How the gateway talks to PostgreSQL.

Two things are worth pinning down.

**The client encoding is UTF-8, and it is set explicitly.** PostgreSQL
reports errors in the server's locale and sends them in the connection's
encoding, and psycopg2 picks that encoding from the *client's* locale --
which on Windows is cp1252. A server that speaks Spanish then answers with
one stray byte where an accent should be, and psycopg2 raises
UnicodeDecodeError instead of saying what went wrong. That turned "the
database does not exist" into an unreadable error about encoding.

**The suite does not hammer the store.** The cleanup used to open a fresh
connection per test and delete the rows one statement at a time, which
meant the suite forked a PostgreSQL backend per test, twice over. A read
costs neither a flush nor a fork, so the count decides whether there is
anything to delete.
"""

from __future__ import annotations

import pytest

empires_server = pytest.importorskip("empires-server")


def test_the_connection_asks_for_utf8(gateway_app):
    """The encoding is a decision, not something left to the locale."""
    from save_engine import save_store_url
    from save_store import connect

    with gateway_app.app_context():
        url = save_store_url()

    connection = connect(url)
    try:
        cursor = connection.execute("SHOW client_encoding")
        assert cursor.fetchone()["client_encoding"].upper() == "UTF8"
    finally:
        connection.close()


def test_the_cleanup_writes_nothing_when_the_store_is_empty(gateway_app):
    """Most tests never touch the store, and for those the cleanup is a read."""
    store = gateway_app.session_interface.save_store
    connection = store._connect()
    try:
        statements: list[str] = []
        original = connection.execute

        def spy(sql, *args, **kwargs):
            statements.append(sql)
            return original(sql, *args, **kwargs)

        connection.execute = spy
        try:
            store.clear(connection)
        finally:
            connection.execute = original

        assert not any("TRUNCATE" in sql.upper() for sql in statements), statements
    finally:
        connection.close()


def test_the_cleanup_does_clear_a_store_that_has_something(gateway_app):
    """And it still empties the store when there is something to empty."""
    store = gateway_app.session_interface.save_store
    connection = store._connect()
    try:
        connection.execute(
            "INSERT INTO saves (store_id, revision, data) VALUES (%s, 1, %s)",
            ("test-store", b"\x00"),
        )
        cleared = store.clear(connection)
        cursor = connection.execute("SELECT count(*) AS remaining FROM saves")
        assert cleared >= 1
        assert cursor.fetchone()["remaining"] == 0
    finally:
        connection.close()
