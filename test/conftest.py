"""One gateway app for the whole test session.

The Flask app, its SQLAlchemy instance and its session store are module-level
singletons inside ``empires-server``, and ``init_app`` refuses to run twice on
the same app. Two test modules each configuring their own database therefore
cannot coexist: whichever ran second raised "A 'SQLAlchemy' instance has already
been registered".

So the app is configured once, here, and every module gets its own *client*.
That is enough isolation anyway -- flask-session keys rows by the store id, so
two clients never see each other's save.

The database is PostgreSQL 18. SAVE_STORE_PATH decides where saves go, and a
separate throwaway database is used here so a test run cannot touch the real one.
"""

from __future__ import annotations

import contextlib
import os
import time
from typing import Any

import pytest
from flask.testing import FlaskClient

DEFAULT_TEST_DB = "postgresql+psycopg2://postgres:42kSM0ud2nRLlTZv6YVsXgPcbxwAx9Qe!7a@127.0.0.1:5432/rte_gateway_test"
TEST_DB = os.environ.get("RTE_TEST_DB", DEFAULT_TEST_DB)
TEST_SQLALCHEMY = os.environ.get("RTE_TEST_SQLALCHEMY", TEST_DB)


class _OperatorClient(FlaskClient):
    """A test client that presents the admin role, the way the front door does.

    The gateway refuses its admin tools to anybody who does not present an
    admin role, and in production the front door presents it: it owns the
    accounts, it knows who is signed in, and it sets the header without ever
    forwarding the browser's copy.

    Here there is no front door, so the client stands in for it. A test that
    wants to see the refusal passes the role itself and gets a plain client.
    """

    def open(self, *args: Any, **kwargs: Any) -> Any:
        headers = kwargs.setdefault("headers", {})
        if isinstance(headers, dict):
            headers.setdefault("x-player-role", "admin")
        return super().open(*args, **kwargs)


def _db_reachable(url: str) -> bool:
    from urllib.parse import urlparse, urlunparse

    from save_store import connect
    try:
        base_path = "/postgres" if "postgres" in url else ""
        connection = connect(urlunparse(urlparse(url)._replace(path=base_path)))
        connection.close()
        return True
    except Exception:
        return False


def _ensure_test_database(url: str) -> None:
    """Create the test database if the server does not have it yet.

    flask-session wires a SQLAlchemy engine straight at the database named in
    the URL, so a missing one fails in ``init_app`` before any of the project's
    own code runs. The save store creates its own database when it is built,
    but the session interface is configured first.

    The error that comes out of it is worth knowing about: PostgreSQL reports
    it in the server's own encoding, and psycopg2 decodes the message as UTF-8.
    On a server whose locale is not UTF-8 the result is a
    ``UnicodeDecodeError`` instead of "database does not exist", which sends
    the reader looking for an encoding bug that is not there.
    """
    from urllib.parse import urlparse, urlunparse

    from save_store import connect

    parsed = urlparse(url)
    database = (parsed.path or "").strip("/")
    if not database:
        return

    bootstrap = connect(urlunparse(parsed._replace(path="/postgres")))
    try:
        cursor = bootstrap.execute("SELECT 1 FROM pg_database WHERE datname = %s", (database,))
        if not cursor.fetchone():
            bootstrap.execute(f'CREATE DATABASE "{database}"')
    finally:
        bootstrap.close()


def pytest_collection_modifyitems(config, items) -> None:
    """Skip the suite when there is no PostgreSQL server to talk to.

    This used to be written as a module-level ``pytestmark`` in this file,
    which reads as "the suite skips gracefully without a database". It did not
    work that way: pytest only reads ``pytestmark`` from test modules, not
    from a conftest, so the mark never reached the tests and a machine
    without a server collected all of them and then errored in every fixture
    -- 443 errors and exit code 1.

    As a collection hook it does what it always meant to do.
    """
    if _db_reachable(TEST_DB):
        return
    skip = pytest.mark.skip(reason=f"no PostgreSQL at {TEST_DB}")
    for item in items:
        item.add_marker(skip)


@pytest.fixture(scope="session")
def gateway_app():
    """The real gateway app, pointed at a throwaway PostgreSQL database."""
    empires_server = __import__("empires-server")

    _ensure_test_database(TEST_DB)

    app = empires_server.app
    app.config.update(
        TESTING=True,
        SECRET_KEY="rte-tests",
        SESSION_TYPE="sqlalchemy",
        SESSION_SQLALCHEMY=empires_server.db,
        SQLALCHEMY_DATABASE_URI=TEST_SQLALCHEMY,
        SQLALCHEMY_TRACK_MODIFICATIONS=False,
        SAVE_STORE_PATH=TEST_DB,
    )
    empires_server.db.init_app(app)
    empires_server.sess.init_app(app)
    # logger.py reports battle/world events over socket.io, so the gateway
    # routes need a live SocketIO server too.
    empires_server.socketio.init_app(app)

    # The suite runs as the operator.
    #
    # The gateway enforces its own lock on the admin tools -- /list_session,
    # /patch/..., /editor/save -- and it checks the role the front door
    # declares in a header it sets and never forwards from the browser. In
    # production the front door is in front; here there is nobody in front, so
    # the client presents the role itself.
    #
    # Without this, every test that touches one of those routes gets a 403:
    # the gateway is refusing them, correctly, because nothing vouched for
    # them. A test that wants to see the refusal says so explicitly.
    app.test_client_class = _OperatorClient

    with app.app_context():
        empires_server.db.create_all()

    yield app

    # The pooled connections are held for the whole session; without this every
    # run ends with "ResourceWarning: unclosed database".
    with app.app_context():
        empires_server.db.engine.dispose()


class _StoreConnection:
    """The store's connection, re-opened when a test drops the database.

    ``DROP DATABASE ... WITH (FORCE)`` takes every connection to that database
    down with it, and the suite has tests that do exactly that. A connection
    opened once for the whole session would stay broken after the first of
    them, and every later test would fail in its fixture with "connection
    already closed".
    """

    def __init__(self, store: Any) -> None:
        self._store = store
        self._connection = store._connect()

    @property
    def connection(self) -> Any:
        if getattr(self._connection, "closed", False):
            self._connection = self._store._connect()
        return self._connection

    def reconnect(self, timeout: float = 90.0) -> bool:
        """Wait for the server to be back and open a new connection.

        The cluster can die underneath a run -- on this machine it does, every
        ten to twenty minutes -- and a run that fails every remaining test
        because of it says nothing about the code. Waiting for the server to
        come back and carrying on is worth a pause.
        """
        deadline = time.monotonic() + timeout
        while time.monotonic() < deadline:
            try:
                self._connection = self._store._connect()
                self._connection.execute("SELECT 1")
                return True
            except Exception:
                with contextlib.suppress(Exception):
                    self._connection.close()
                time.sleep(2)
        return False

    def close(self) -> None:
        with contextlib.suppress(Exception):
            self._connection.close()


@pytest.fixture(scope="session")
def save_store_connection(gateway_app):
    """One connection to the save store, for the whole session."""
    holder = _StoreConnection(gateway_app.session_interface.save_store)
    yield holder
    holder.close()


@pytest.fixture(autouse=True)
def clean_save_store(gateway_app, save_store_connection):
    """Empty the save store before each test."""
    _empty_the_save_store(gateway_app, save_store_connection)
    yield
    _empty_the_save_store(gateway_app, save_store_connection)


def _empty_the_save_store(app, holder):
    """Drop every save and every snapshot -- if there is anything to drop.

    Two things made this the heaviest thing in the suite. It deleted the
    rows with one statement per table, and each statement is a write
    transaction with a WAL flush behind it. And it opened a fresh connection
    every time, because the store does not pool: a run of the suite forked a
    PostgreSQL backend per test, twice over.

    The store now counts first and deletes only if there is something to
    delete. A read costs neither a flush nor a fork, and most tests never
    touch the store.
    """
    store = app.session_interface.save_store
    try:
        store.clear(holder.connection)
    except Exception:
        # The server can die underneath the run. If it comes back, the test
        # still has a chance; if it does not, the error belongs to whoever
        # runs this next.
        if not holder.reconnect():
            raise
        store.clear(holder.connection)


def asset_status(client, path):
    """GET a static asset and return its status, with the handle released."""
    response = client.get(path)
    try:
        return response.status_code
    finally:
        response.close()
