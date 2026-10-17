"""Files a save under the account, not under the browser cookie.

The problem
-----------
Before this, the row in the session table was keyed by the sid in the
``session`` cookie. The account owned the *identity* (``get_zid`` preferred the
header) but not the *save*, so:

* signing in on a second browser produced a second, empty empire for the same
  account, and the player had no way to tell which one was real;
* clearing a cookie looked like losing the empire.

Why it is overridden here and not elsewhere
-------------------------------------------
``flask_session`` resolves the storage key in one place, ``_get_store_id``, and
both ``open_session`` (the read) and ``save_session`` (the write) go through it.
Overriding that single method makes the two agree by construction -- there is no
second code path to forget, and ``store_session``/``get_saves`` keep working
because they still see an ordinary session.

The cookie itself is deliberately left alone
--------------------------------------------
It keeps holding a random sid. Putting the account id in the cookie would let
anyone who guessed a zid claim that empire by sending one header, and Bun
forwards client cookies to the gateway untouched -- so the cookie would become
an unauthenticated read of any player's save. The account id only ever decides
the database key, never the value the browser holds.

Trust rule (unchanged from ``get_zid``): ``x-player-zid`` is believed because
the gateway is loopback-only and the Bun service is its only door, and Bun sets
that header itself after verifying the account cookie. **If Flask is ever bound
to anything other than 127.0.0.1, this header becomes forgeable and so does
every player's save.** That is the same single assumption the admin gate rests
on, so there is nothing new to reason about, but it is the thing to remember
before exposing the port.
"""

from __future__ import annotations

from flask import Flask
from flask.wrappers import Request
from flask_session import Session
from flask_session.sqlalchemy import SqlAlchemySessionInterface

#: Marks a storage key as account-bound. A cookie-keyed row keeps its bare sid,
#: which is urlsafe base64 and never starts with this.
ACCOUNT_STORE_PREFIX = "acct"


def account_store_id(zid: int) -> str:
    """The part of the store key that identifies an account."""
    return f"{ACCOUNT_STORE_PREFIX}{zid}"


def is_account_store_id(store_id: str) -> bool:
    """True when a storage key names an account rather than a browser cookie.

    Accepts either the full key or the bare sid, because the database column
    carries flask-session's configurable prefix while callers holding a cookie
    value do not. Splitting on the last colon is safe: a cookie-keyed sid is
    urlsafe base64 and never contains one.
    """
    return store_id.rsplit(":", 1)[-1].startswith(ACCOUNT_STORE_PREFIX)


class AccountBoundSqlAlchemySessionInterface(SqlAlchemySessionInterface):
    """Files and loads the save by account, not by cookie.

    Two halves, and both are needed:

    ``_get_store_id``  decides which row a read or a write touches. Overriding
        it alone is not enough, because it is also what makes read and write
        agree -- there is no second code path to forget.

    ``open_session``  is what the first request from a new browser goes
        through. Upstream it returns early when the request carries no cookie
        at all, generating a fresh sid and never asking for a stored row -- so a
        brand new browser would get an empty empire on its very first load and
        only pick up the account's save on the second one. That is the whole
        bug this class exists to remove, so the account branch is handled
        before delegating.

    Falling through to ``super()`` for an unauthenticated request is what keeps
    anonymous play working exactly as it did: no header, no account, same cookie
    behaviour as the original 2013 server.
    """

    def open_session(self, app: Flask, request: Request):
        zid = self._supplied_zid()
        if zid is None:
            return super().open_session(app, request)

        # A random sid for the cookie; _get_store_id ignores it and resolves to
        # the account's row, which is what keeps the cookie from ever holding
        # anything a client could use to claim this save.
        sid = self._generate_sid(self.sid_length)
        store_id = self._get_store_id(sid)
        stored = self._retrieve_session_data(store_id)

        if stored is not None:
            return self.session_class(stored, sid=sid)
        return self.session_class(sid=sid, permanent=self.permanent)

    def _get_store_id(self, sid: str) -> str:
        zid = self._supplied_zid()
        if zid is not None:
            return self.key_prefix + account_store_id(zid)
        return super()._get_store_id(sid)

    @staticmethod
    def _supplied_zid() -> int | None:
        """The account id the front door claimed for this request, or None.

        Imported here rather than at module scope: game_settings pulls in parts
        of the game, and this module is imported from the server's storage
        setup. The import is cached after the first call.
        """
        from game_settings import supplied_zid

        return supplied_zid()


class AccountBoundSession(Session):
    """``Session``, but the save it stores belongs to the account.

    Subclassing rather than exposing a second call to remember: this was very
    nearly the same bug as ``/editor/save`` being left out of the admin gate,
    where forgetting one line left the gate open. Binding it here means
    ``init_app`` cannot be called in the server and the tests without the
    behaviour coming along.
    """

    def init_app(self, app: Flask) -> None:
        super().init_app(app)
        # flask-session picks the backend from SESSION_TYPE and has no config
        # key for "and subclass this too", so the class is swapped on the
        # interface it just built. Same instance, same table, same cookie --
        # only the database key changes.
        app.session_interface.__class__ = AccountBoundSqlAlchemySessionInterface