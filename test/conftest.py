"""One gateway app for the whole test session.

The Flask app, its SQLAlchemy instance and its session store are module-level
singletons inside ``empires-server``, and ``init_app`` refuses to run twice on
the same app. Two test modules each configuring their own database therefore
cannot coexist: whichever ran second raised "A 'SQLAlchemy' instance has already
been registered".

So the app is configured once, here, and every module gets its own *client*.
That is enough isolation anyway -- flask-session keys rows by the store id, so
two clients never see each other's save.

The database is MariaDB. There is no SQLite any more: SAVE_STORE_PATH decides
where saves go, and a separate throwaway database is used here so a test run
cannot touch the real one. If no server is reachable the module-level guard
below skips rather than failing, because "there is no database on this machine"
is not a reason to report the code as broken.
"""

from __future__ import annotations

import os

import pytest

#: Where the test suite points the save store. Override with
#: RTE_TEST_MARIADB to run against another server.
TEST_MARIADB = os.environ.get(
    "RTE_TEST_MARIADB", "mariadb://root:2001@127.0.0.1:3306/rte_gateway_test")

#: What the tests use for the vestigial flask-session ``sessions`` table. That
#: one is written by nothing any more -- the session interface persists through
#: save_store -- but flask-session still creates the table at init_app, so it
#: needs somewhere to point.
TEST_SQLALCHEMY = os.environ.get(
    "RTE_TEST_SQLALCHEMY",
    "mysql+pymysql://root:2001@127.0.0.1:3306/rte_gateway_test")


def _maria_reachable(url: str) -> bool:
    from urllib.parse import urlparse, urlunparse

    from save_store import connect

    try:
        connection = connect(urlunparse(urlparse(url)._replace(path="")))
        connection.close()
        return True
    except Exception:
        return False


pytestmark = pytest.mark.skipif(
    not _maria_reachable(TEST_MARIADB),
    reason=f"no MariaDB at {TEST_MARIADB}; the store has no SQLite fallback")


@pytest.fixture(scope="session")
def gateway_app():
    """The real gateway app, pointed at a throwaway MariaDB database."""
    empires_server = __import__("empires-server")

    app = empires_server.app
    app.config.update(
        TESTING=True,
        SECRET_KEY="rte-tests",
        SESSION_TYPE="sqlalchemy",
        SESSION_SQLALCHEMY=empires_server.db,
        SQLALCHEMY_DATABASE_URI=TEST_SQLALCHEMY,
        SQLALCHEMY_TRACK_MODIFICATIONS=False,
        SAVE_STORE_PATH=TEST_MARIADB,
    )
    empires_server.db.init_app(app)
    empires_server.sess.init_app(app)
    # logger.py reports battle/world events over socket.io, so the gateway
    # routes need a live SocketIO server too.
    empires_server.socketio.init_app(app)

    with app.app_context():
        empires_server.db.create_all()

    yield app

    # The pooled connections are held for the whole session; without this every
    # run ends with "ResourceWarning: unclosed database".
    with app.app_context():
        empires_server.db.engine.dispose()


@pytest.fixture(autouse=True)
def clean_save_store(gateway_app):
    """Empty the save store before each test.

    The store used to be a tmp file created fresh per run, so leftovers could
    not happen and no test needed to think about it. MariaDB persists, which
    broke that assumption in two directions: a row written by one test was
    still there for the next, and a row from a run days ago was still there too.

    Per-test rather than per-module because the tests *share* a store on purpose
    -- ``get_saves`` reads every row in it, which is exactly what
    ``test_gateway_e2e`` checks -- so any row that survives a module boundary is
    visible to the next one as if it were its own.

    Truncating costs two round trips. It is the price of a persistent database
    and it is worth paying here: the alternative, giving each test its own
    database, would mean a CREATE DATABASE per test and MariaDB does not enjoy
    that.
    """
    _empty_the_save_store(gateway_app)
    yield
    _empty_the_save_store(gateway_app)


def _empty_the_save_store(app):
    """Drop every save and every snapshot.

    DELETE rather than TRUNCATE: TRUNCATE is DDL, so it implicitly commits and
    that commit resets the ``FOREIGN_KEY_CHECKS`` session variable set just
    above it -- the second statement then fails on the foreign key. Backups
    first so the constraint is never in the way at all.
    """
    store = app.session_interface.save_store
    connection = store._connect()
    try:
        connection.execute("DELETE FROM save_backups")
        connection.execute("DELETE FROM saves")
    finally:
        connection.close()


def asset_status(client, path):
    """GET a static asset and return its status, with the handle released.

    Flask's ``send_file`` registers a close on the response and a WSGI server
    runs it after every request. The Flask *test client* does not, so a test
    that only reads the status leaves the file open until the collector gets to
    it -- which is where the "unclosed file" warnings in the suite came from.
    Measured both ways: five requests unclosed produce five warnings, and none
    with this.
    """
    response = client.get(path)
    try:
        return response.status_code
    finally:
        response.close()