"""One gateway app for the whole test session.

The Flask app, its SQLAlchemy instance and its session store are module-level
singletons inside ``empires-server``, and ``init_app`` refuses to run twice on
the same app. Two test modules each configuring their own database therefore
cannot coexist: whichever ran second raised "A 'SQLAlchemy' instance has already
been registered".

So the app is configured once, here, and every module gets its own *client*.
That is enough isolation anyway -- flask-session keys rows by the cookie it
issued, so two clients never see each other's save.
"""

from __future__ import annotations

import pytest


@pytest.fixture(scope="session")
def gateway_app(tmp_path_factory):
    """The real gateway app, pointed at a throwaway database."""
    empires_server = __import__("empires-server")

    app = empires_server.app
    db_path = tmp_path_factory.mktemp("rte-tests") / "save.db"
    app.config.update(
        TESTING=True,
        SECRET_KEY="rte-tests",
        SESSION_TYPE="sqlalchemy",
        SESSION_SQLALCHEMY=empires_server.db,
        SQLALCHEMY_DATABASE_URI=f"sqlite:///{db_path}",
        SQLALCHEMY_TRACK_MODIFICATIONS=False,
    )
    empires_server.db.init_app(app)
    empires_server.sess.init_app(app)
    # logger.py reports battle/world events over socket.io, so the gateway
    # routes need a live SocketIO server too.
    empires_server.socketio.init_app(app)

    with app.app_context():
        empires_server.db.create_all()

    yield app

    # The engine holds a pooled sqlite connection for the whole session. Nothing
    # else will close it, so without this every run ends with
    # "ResourceWarning: unclosed database in <sqlite3.Connection>".
    with app.app_context():
        empires_server.db.engine.dispose()


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