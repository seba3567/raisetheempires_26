"""A save belongs to the account, not to the browser cookie.

The behaviour this pins is the whole point of ``account_saves``: signing in on a
second browser must open the *same* empire, and two browsers signed into one
account must not end up with two saves that both claim the same id.

What is deliberately *not* asserted here is that the cookie changes: it must not.
The cookie keeps a random sid, because Bun forwards client cookies to the
gateway untouched and an account id in the cookie would be an unauthenticated
read of anyone's save.
"""

from __future__ import annotations

import pytest

from account_saves import (
    ACCOUNT_STORE_PREFIX,
    account_store_id,
    is_account_store_id,
)

ACCOUNT_ZID = 2361750976462848
OTHER_ZID = 2361750976462849


@pytest.fixture(scope="module")
def app(gateway_app):
    """The shared app.

    ``conftest.py`` owns the configuration, and it already installs
    ``AccountBoundSession`` because ``empires_server.sess`` is one -- so this
    file adds a fixture only to rename it. Configuring a second app here is not
    an option: SQLAlchemy cannot be registered on the same Flask app twice, and
    this module and the e2e tests share one global app object.
    """
    return gateway_app


@pytest.fixture
def client(app):
    return app.test_client()


def store_id(app, headers=None, sid="sidsidsidsid"):
    """The storage key flask-session resolves for this request."""
    with app.test_request_context("/", headers=headers or {}):
        from flask import session as flask_session

        flask_session.sid = sid
        return app.session_interface._get_store_id(sid)


class TestStoreKey:
    def test_a_signed_in_request_is_keyed_by_the_account(self, app):
        key = store_id(app, {"x-player-zid": str(ACCOUNT_ZID)})

        assert key == "session:" + account_store_id(ACCOUNT_ZID)
        assert is_account_store_id(key)

    def test_the_cookie_sid_is_ignored_when_signed_in(self, app):
        """Two browsers, one account, one row. The old behaviour made two."""
        from_browser_a = store_id(app, {"x-player-zid": str(ACCOUNT_ZID)}, "browser-a-sid")
        from_browser_b = store_id(app, {"x-player-zid": str(ACCOUNT_ZID)}, "browser-b-sid")

        assert from_browser_a == from_browser_b
        assert "browser-a" not in from_browser_a
        assert "browser-b" not in from_browser_b

    def test_two_accounts_never_share_a_row(self, app):
        assert store_id(app, {"x-player-zid": str(ACCOUNT_ZID)}) != store_id(
            app, {"x-player-zid": str(OTHER_ZID)}
        )

    def test_anonymous_play_falls_back_to_the_cookie(self, app):
        """No header, no account: exactly the 2013 behaviour."""
        key = store_id(app, {}, "plain-cookie-sid")

        assert key == "session:plain-cookie-sid"
        assert not is_account_store_id(key)

    @pytest.mark.parametrize(
        "header", ["", "not-a-number", "0", "-5", "12.5", "0x10", str(2**53)]
    )
    def test_a_malformed_header_does_not_bind_to_an_account(self, app, header):
        """The same values ``get_zid`` rejects must not file a save either.

        Otherwise a malformed header would create a row keyed to a garbage
        account while ``get_zid`` reported a different id for the same request.
        """
        key = store_id(app, {"x-player-zid": header})

        assert key == "session:sidsidsidsid"
        assert not is_account_store_id(key)

    def test_the_account_id_never_reaches_the_cookie(self, app):
        """The row key is the account; the browser still holds a random sid.

        Bun forwards client cookies to the gateway untouched, so an account id
        in the cookie would let anyone who guessed a zid open that empire with
        a single header.
        """
        client = app.test_client()
        response = client.get(
            "/list_session",
            headers={
                "Cookie": "session=browser-cookie-sid",
                "x-player-zid": str(ACCOUNT_ZID),
            },
        )

        set_cookie = response.headers.get("Set-Cookie", "")
        assert str(ACCOUNT_ZID) not in set_cookie
        assert ACCOUNT_STORE_PREFIX not in set_cookie


class TestWhereTheRowEndsUp:
    """Which row a real request writes to -- the behaviour, not the key.

    ``/editor/save`` is used because it is a route that actually writes the
    session: ``/list_session`` only reads, and flask-session deliberately does
    not store an empty session, so a read creates nothing to observe.
    """

    def _rows(self, app):
        return stored_rows(app)

    def test_a_signed_in_request_writes_the_account_row(self, app):
        before = self._rows(app)
        write_save(app, {"x-player-zid": str(ACCOUNT_ZID)})
        added = self._rows(app) - before

        assert "session:" + account_store_id(ACCOUNT_ZID) in added
        assert not any("brand-new-browser" in row for row in added)

    def test_an_anonymous_request_writes_a_cookie_row(self, app):
        """Unchanged from 2013: no account, no account-bound row.

        Which sid the row gets is flask-session's business -- a cookie with no
        stored row gets a freshly generated one -- so the invariant asserted
        here is only that the row is not account-bound.
        """
        before = self._rows(app)
        write_save(app)
        added = self._rows(app) - before

        assert added, "an anonymous write should still store a save"
        assert not any(is_account_store_id(row) for row in added)


def stored_rows(app) -> set:
    """Every store id that currently holds a row.

    Reads the ``saves`` table directly rather than through ``get_saves``. The
    two answer different questions: get_saves returns *usable* saves and skips
    one whose user_object is empty, and these tests write exactly that on
    purpose -- ``{"user_object": null}`` creates the row without needing a real
    empire. What is being asked here is which key the row landed under.
    """
    with app.app_context():
        store = app.session_interface.save_store
        with store._connect() as connection:
            return {row["store_id"]
                    for row in connection.execute("SELECT store_id FROM saves")}


def write_save(app, headers=None, cookie="session=brand-new-browser", body='{"user_object": null}') -> None:
    """POST something that writes the session, so a row is actually stored."""
    client = app.test_client()
    request_headers = {"Cookie": cookie}
    request_headers.update(headers or {})
    client.post("/editor/save", data={"savegame": body, "message": "test"}, headers=request_headers)


class TestFirstRequestFromANewBrowser:
    """The case that made this a bug rather than a nicety.

    A browser with no ``session`` cookie at all used to get an empty empire on
    its very first load: flask-session's ``open_session`` returns early when
    there is no cookie, so the account's row was never consulted until the
    second request. Signing in on a new machine looked like losing the empire.
    """

    def test_a_cookieless_signed_in_request_reads_the_account_save(self, app):
        """The seeded empire must come back on a browser with no cookie.

        Proven through the row rather than through a client: ``session_transaction``
        pushes its own request context, which carries no ``x-player-zid``, so it
        cannot be used to observe an account-bound read.
        """
        import json

        seeded = json.dumps(
            {"user_object": {"userInfo": {"player": {"level": 47, "uid": ACCOUNT_ZID}}}}
        )
        write_save(app, {"x-player-zid": str(ACCOUNT_ZID)}, body=seeded)

        # A client that has never carried a game cookie at all. The POST both
        # loads and writes, so what it snapshots is the seeded empire -- if it
        # had started from an empty session, the snapshot would say so.
        fresh = app.test_client()
        fresh.post(
            "/editor/save",
            data={"savegame": '{"user_object": null}', "message": "from a new browser"},
            headers={"x-player-zid": str(ACCOUNT_ZID)},
        )

        # History lives in save_backups now, not in a "backup" key inside the
        # row. The newest snapshot is what that cookieless write replaced, which
        # is the seeded empire if it loaded the account's row first.
        with app.app_context():
            store = app.session_interface.save_store
            history = store.history("session:" + account_store_id(ACCOUNT_ZID))

        assert history, "a cookieless request started an empty session"

        snapshot = store.read_backup(
            "session:" + account_store_id(ACCOUNT_ZID), history[0].revision)
        seen = (((snapshot or {}).get("user_object") or {})
                .get("userInfo") or {}).get("player") or {}
        assert seen.get("uid") == ACCOUNT_ZID, "it did not load the account's empire"
        assert seen.get("level") == 47

    def test_an_anonymous_cookieless_request_still_starts_fresh(self, app):
        fresh = app.test_client()
        fresh.get("/list_session")

        with fresh.session_transaction() as session:
            assert session.sid
            assert not is_account_store_id(f"session:{session.sid}")


class TestReadAndWriteAgree:
    """Read and write must resolve to the same row, or the save never sticks."""

    def test_the_same_account_resolves_to_one_row_from_two_cookies(self, app):
        headers_a = {"x-player-zid": str(ACCOUNT_ZID)}
        with app.test_request_context("/", headers=headers_a):
            from flask import session as flask_session

            flask_session.sid = "browser-one"
            written = app.session_interface._get_store_id(flask_session.sid)

        with app.test_request_context("/", headers=headers_a):
            from flask import session as flask_session

            flask_session.sid = "browser-two"
            read = app.session_interface._get_store_id(flask_session.sid)

        assert written == read

    def test_a_second_account_is_a_separate_row(self, app):
        from flask import session as flask_session

        with app.test_request_context("/", headers={"x-player-zid": str(OTHER_ZID)}):
            flask_session.sid = "browser-three"
            other = app.session_interface._get_store_id(flask_session.sid)

        with app.test_request_context("/", headers={"x-player-zid": str(ACCOUNT_ZID)}):
            flask_session.sid = "browser-three"
            mine = app.session_interface._get_store_id(flask_session.sid)

        assert other != mine