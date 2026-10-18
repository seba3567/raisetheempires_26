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


class SaveStoreSessionInterface(AccountBoundSqlAlchemySessionInterface):
    """Persists the save through ``save_store.Store`` instead of the sessions table.

    Why this is the whole migration
    -------------------------------
    flask-session was doing two jobs: an HTTP session store (cookie to a row that
    expires) *and* the game's save store (one per account, never expires, needs
    history and a version). That double duty is why ``store_session`` existed as
    a bolt-on -- it wrote a row that flask-session was also going to write, and it
    never once succeeded.

    So the fix is to make flask-session's own two methods delegate to the rebuilt
    store, rather than to bolt anything on the side:

    * ``_retrieve_session_data`` reads a row and records the revision it saw;
    * ``_upsert_session`` writes it back only if the row is still at that
      revision.

    Nothing else changes. ``session["fleets"] = x`` in battle_engine -- 105 places
    -- keeps working exactly as before, and now every one of those writes is
    checked instead of overwriting whatever landed in between.

    The revision travels inside the session under a private key rather than in a
    side table, because the session object is the only thing carried from the
    read to the write. It is stripped before the payload is stored, so it never
    reaches the save.
    """

    #: Where the read revision is parked for the length of one request. Private
    #: by convention and stripped on the way out, not a game field.
    REVISION_KEY = "__save_revision"

    @property
    def save_store(self):
        from save_store import Store

        store = getattr(self, "_save_store", None)
        if store is None:
            # The app's serializer, not a plain msgspec codec: it carries the
            # enc_hook that writes a tagged BattleContext and the decode walk
            # that turns it back into a struct. With a plain codec the battle
            # context comes back as an ordinary dict and has_battle_context()
            # starts answering False mid-battle.
            store = Store(self._save_store_path(self.app),
                          codec=self.serializer)
            self._save_store = store
        return store

    @staticmethod
    def _save_store_path(app: Flask) -> str:
        from flask import current_app

        current = current_app or app
        configured = current.config.get("SAVE_STORE_PATH")
        if configured:
            return configured
        # Same file the sessions table lives in; the new tables are created
        # alongside it rather than in a second database, so there is one thing to
        # back up and one thing to point at.
        uri = current.config.get("SQLALCHEMY_DATABASE_URI", "")
        return uri.replace("sqlite:///", "").replace("sqlite://", "") or "save.db"

    def _retrieve_session_data(self, store_id: str):
        row = self.save_store.load(store_id)
        if row is None or row.data is None:
            return None
        payload = dict(row.data)
        payload[self.REVISION_KEY] = row.revision
        return payload

    def _upsert_session(self, session_lifetime, session, store_id) -> None:
        from save_store import WriteConflict

        payload = {key: value for key, value in session.items()
                   if key != self.REVISION_KEY}
        revision = session.get(self.REVISION_KEY)

        # An emptied session means "delete the save", which is what flask-session
        # does with an empty one. Testing the stripped payload, not the session:
        # the revision key would keep it looking non-empty forever.
        if not payload:
            self.save_store.delete(store_id)
            return

        try:
            self.save_store.store(store_id, payload, expected_revision=revision)
        except WriteConflict as conflict:
            # The default policy is to refuse and say so. See the module note in
            # save_store for why the alternatives were not taken: retrying would
            # need the mutation to be idempotent, and accepting the last write is
            # the lost update this whole change exists to stop.
            print(f"Save for {store_id} was written by someone else: {conflict}")
            session.modified = False
            raise

    def _delete_session(self, session_id: str, app: Flask | None = None) -> None:
        self.save_store.delete(session_id)


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
        # interface it just built. Same instance, same cookie, same store id --
        # only the persistence underneath changes.
        #
        # Swap to SaveStoreSessionInterface, which extends the account-bound one
        # above rather than replacing it: the account keying has to keep working
        # and it is the class that owns it. Swapping to something that did not
        # extend it is how the account binding would silently come back off.
        app.session_interface.__class__ = SaveStoreSessionInterface