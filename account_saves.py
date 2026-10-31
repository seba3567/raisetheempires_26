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

import logging
from typing import Any

from flask import Flask
from flask.wrappers import Request
from flask_session import Session
from flask_session.sqlalchemy import SqlAlchemySessionInterface

import contract

#: Where the three "the save was not written" messages go.
#:
#: They used to be ``print`` calls, which meant they went to stdout and
#: nowhere else: the gateway's log file never saw them, and the only way to
#: know a save had been dropped was to read the console of the process. A
#: dropped save is the worst thing that can happen here -- the player loses
#: their empire -- so it has to be in the log where the rest of the trouble
#: is.
logger = logging.getLogger(__name__)

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

    One row per account
    -------------------
    Overriding ``_get_store_id`` guarantees that an account always *reads and
    writes* one row, but it does not stop a second row appearing next to it: a
    player who plays before signing in gets a cookie-keyed row, and signing in
    afterwards silently starts a *different* empire under the account key. Two
    rows, one player, and nothing on screen says which is real. That is not a
    hypothetical -- it is what the ``saves`` table held.

    So the account branch asks ``_adopt_anonymous_save`` on the way in. It only
    runs when the account has no save yet, so an account's real empire is never
    at risk, and it removes the cookie row rather than copying it, so "one
    account, one save" is true of the table and not merely of the code path.
    """

    def open_session(self, app: Flask, request: Request) -> Any:
        zid = self._supplied_zid()
        if zid is None:
            return super().open_session(app, request)

        # A random sid for the cookie; _get_store_id ignores it and resolves to
        # the account's row, which is what keeps the cookie from ever holding
        # anything a client could use to claim this save.
        sid = self._generate_sid(self.sid_length)
        store_id = self._get_store_id(sid)
        stored = self._retrieve_session_data(store_id)

        if stored is None:
            # No empire for this account yet. If this browser played anonymously
            # before signing in, that empire is theirs and belongs here.
            stored = self._adopt_anonymous_save(app, request, store_id)

        if stored is not None:
            return self.session_class(stored, sid=sid)
        return self.session_class(sid=sid, permanent=self.permanent)

    def _adopt_anonymous_save(self, app: Flask, request: Request, account_key: str) -> dict[str, Any] | None:
        """Take over the browser's anonymous save. Overridden where there is a store.

        The parent has no save store of its own -- it persists through the
        sessions table -- so there is nothing to move and nothing to say.
        """
        return None

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

    #: Where save_engine.create_backup records *why* the next write happens.
    #: Same deal: stripped before the payload is stored.
    REASON_KEY = "__backup_reason"

    #: Snapshot of the initial state loaded at request start, used for 3-way merge
    #: if a concurrent write conflict occurs during session finalization.
    SNAPSHOT_KEY = "__save_snapshot"

    def open_session(self, app: Flask, request: Request) -> Any:
        sess = super().open_session(app, request)
        if sess and hasattr(sess, "__setitem__"):
            try:
                import copy
                sess[self.SNAPSHOT_KEY] = copy.deepcopy(dict(sess))
            except Exception:
                sess[self.SNAPSHOT_KEY] = None
        return sess

    @property
    def save_store(self) -> Any:
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
        """The PostgreSQL URL the saves live in.

        Read from ``RTE_DB_URL`` so the deployment, not the code, decides
        which server. The old name, ``SAVE_STORE_PATH``, still works.
        """
        from flask import current_app

        current = current_app or app
        configured = current.config.get("SAVE_STORE_PATH")
        if configured:
            return configured
        return contract.env_value(contract.ENV_DATABASE_URL) or contract.DATABASE_URL

    def _retrieve_session_data(self, store_id: str) -> dict[str, Any] | None:
        row = self.save_store.load(store_id)
        if row is None or row.data is None:
            return None
        payload = dict(row.data)
        payload[self.REVISION_KEY] = row.revision
        return payload

    def _adopt_anonymous_save(self, app: Flask, request: Request, account_key: str) -> dict[str, Any] | None:
        """Move a browser's anonymous empire onto the account, once.

        Only ever called for an account that has no save, so this can never
        overwrite a real one. The cookie row is *deleted*, not copied: leaving it
        behind is exactly the two-rows-one-player state this exists to remove,
        and it would otherwise be picked up again by a later anonymous request.

        Returns the account's row in the same shape ``_retrieve_session_data``
        produces, so the caller cannot tell an adoption from an ordinary read.
        """
        cookie_sid = request.cookies.get(self.get_cookie_name(app))
        if not cookie_sid:
            return None

        # The *parent's* keying on purpose: self._get_store_id would resolve to
        # the account again and we would "adopt" the account onto itself.
        cookie_key = SqlAlchemySessionInterface._get_store_id(self, cookie_sid)
        if cookie_key == account_key:
            return None

        row = self.save_store.load(cookie_key)
        if row is None or not row.data:
            return None

        payload = dict(row.data)
        # An empty session is not an empire. Adopting one would carry a stranger
        # row's revision across for nothing and hide the fact that this account
        # genuinely starts fresh.
        if not isinstance(payload.get("user_object"), dict):
            return None

        payload.pop(self.REVISION_KEY, None)
        payload.pop(self.REASON_KEY, None)
        self.save_store.store(account_key, payload)
        self.save_store.delete(cookie_key)
        logger.info("Adopted anonymous save %s into %s", cookie_key, account_key)

        # Read back rather than reusing `payload`: the revision has to be the
        # one the row is at now, or the write at the end of this request would
        # conflict with the write we just made.
        return self._retrieve_session_data(account_key)

    def _store_with_retry(self, store_id: str, payload: dict[str, Any], reason: str | None, revision: int | None) -> int:
        """Write the session, retrying once if PostgreSQL reports a lock collision."""
        import time

        from save_store import TransientStoreError, is_transient_store_error

        for attempt in (1, 2):
            try:
                return self.save_store.store(
                    store_id, payload, reason=reason, expected_revision=revision)
            except Exception as error:
                if not is_transient_store_error(error):
                    raise
                if attempt == 2:
                    raise TransientStoreError(
                        f"{store_id}: lock collision survived one retry") from error
                # The retry is the recovery. A collision that survives it
                # raises, and that is logged as the error it is.
                logger.info("Session save hit a lock collision, retrying once: %s", error)
                time.sleep(0.05 * attempt)
        raise AssertionError("unreachable")

    @classmethod
    def _merge_3way(cls, base: Any, ours: Any, theirs: Any) -> Any:
        """3-way merge of two concurrent mutations `ours` and `theirs` against `base`."""
        if ours == base:
            return theirs
        if theirs == base:
            return ours
        if ours == theirs:
            return ours

        if isinstance(ours, dict) and isinstance(theirs, dict):
            base_dict = base if isinstance(base, dict) else {}
            all_keys = set(base_dict.keys()) | set(ours.keys()) | set(theirs.keys())
            merged: dict[str, Any] = {}
            for k in all_keys:
                in_base = k in base_dict
                in_ours = k in ours
                in_theirs = k in theirs

                if in_ours and not in_theirs and not in_base:
                    merged[k] = ours[k]
                elif in_theirs and not in_ours and not in_base:
                    merged[k] = theirs[k]
                elif not in_ours and in_base and (not in_theirs or theirs[k] == base_dict[k]):
                    # Deleted in ours and untouched in theirs
                    continue
                elif not in_theirs and in_base and (not in_ours or ours[k] == base_dict[k]):
                    # Deleted in theirs and untouched in ours
                    continue
                elif in_ours and in_theirs:
                    v_ours = ours[k]
                    v_theirs = theirs[k]
                    v_base = base_dict.get(k)

                    if k == "objects" and isinstance(v_ours, list) and isinstance(v_theirs, list):
                        merged[k] = cls._merge_world_objects(v_base, v_ours, v_theirs)
                    elif (isinstance(v_ours, (int, float)) and not isinstance(v_ours, bool) and
                          isinstance(v_theirs, (int, float)) and not isinstance(v_theirs, bool) and
                          in_base and isinstance(v_base, (int, float)) and not isinstance(v_base, bool)):
                        if k == "globalObjectId":
                            merged[k] = max(v_ours, v_theirs)
                        else:
                            # Delta merge for numeric counters (coins, cash, xp, energy, etc.)
                            d_ours = v_ours - v_base
                            d_theirs = v_theirs - v_base
                            merged[k] = type(v_base)(v_base + d_ours + d_theirs)
                    elif isinstance(v_ours, dict) and isinstance(v_theirs, dict):
                        merged[k] = cls._merge_3way(v_base, v_ours, v_theirs)
                    else:
                        if in_base and v_ours == v_base:
                            merged[k] = v_theirs
                        else:
                            merged[k] = v_ours
                elif in_ours:
                    merged[k] = ours[k]
                elif in_theirs:
                    merged[k] = theirs[k]
            return merged

        # Fallback for non-dicts: prefer ours
        return ours

    @classmethod
    def _merge_world_objects(cls, base_list: Any, ours_list: list[Any], theirs_list: list[Any]) -> list[Any]:
        """Merge list of world objects by their object 'id'."""
        base_map = {obj.get("id"): obj for obj in (base_list or []) if isinstance(obj, dict) and "id" in obj}
        ours_map = {obj.get("id"): obj for obj in ours_list if isinstance(obj, dict) and "id" in obj}
        theirs_map = {obj.get("id"): obj for obj in theirs_list if isinstance(obj, dict) and "id" in obj}

        seen_ids = set()
        merged_ids = []
        for obj in theirs_list:
            if isinstance(obj, dict) and "id" in obj:
                oid = obj["id"]
                if oid not in seen_ids:
                    seen_ids.add(oid)
                    merged_ids.append(oid)
        for obj in ours_list:
            if isinstance(obj, dict) and "id" in obj:
                oid = obj["id"]
                if oid not in seen_ids:
                    seen_ids.add(oid)
                    merged_ids.append(oid)

        result = []
        for oid in merged_ids:
            in_base = oid in base_map
            in_ours = oid in ours_map
            in_theirs = oid in theirs_map

            if in_ours and in_theirs:
                result.append(cls._merge_3way(base_map.get(oid), ours_map[oid], theirs_map[oid]))
            elif in_ours:
                result.append(ours_map[oid])
            elif in_theirs:
                if in_base and theirs_map[oid] == base_map[oid]:
                    continue
                result.append(theirs_map[oid])

        extra_theirs = [x for x in theirs_list if not (isinstance(x, dict) and "id" in x)]
        extra_ours = [x for x in ours_list if not (isinstance(x, dict) and "id" in x)]
        result.extend(extra_theirs)
        for x in extra_ours:
            if x not in result:
                result.append(x)

        return result

    def _upsert_session(self, session_lifetime: Any, session: Any, store_id: str) -> None:

        from save_store import TransientStoreError, WriteConflict

        private = (self.REVISION_KEY, self.REASON_KEY, self.SNAPSHOT_KEY)
        payload = {key: value for key, value in session.items()
                   if key not in private}
        revision = session.get(self.REVISION_KEY)
        # What create_backup was called with, if anything. The store stamps it
        # on the snapshot it takes of what this write replaces, which is how
        # "Level 50" ends up next to the right entry in the editor without
        # create_backup having to write a row of its own.
        reason = session.get(self.REASON_KEY)

        # An emptied session means "delete the save", which is what flask-session
        # does with an empty one. Testing the stripped payload, not the session:
        # the revision key would keep it looking non-empty forever.
        if not payload:
            self.save_store.delete(store_id)
            return

        written = None
        max_conflict_retries = 3
        current_payload = payload
        current_revision = revision

        for conflict_attempt in range(max_conflict_retries):
            try:
                written = self._store_with_retry(store_id, current_payload, reason, current_revision)
                break
            except WriteConflict as conflict:
                if conflict_attempt == max_conflict_retries - 1:
                    logger.error(
                        "Session save skipped, the row moved underneath (exhausted %d retries): %s",
                        max_conflict_retries, conflict
                    )
                    session.modified = False
                    return
                logger.warning(
                    "Session save hit WriteConflict (attempt %d/%d): %s; merging changes",
                    conflict_attempt + 1, max_conflict_retries, conflict
                )
                try:
                    latest_row = self.save_store.load(store_id)
                    if latest_row is None or latest_row.data is None:
                        current_revision = None
                        continue
                    base = session.get(self.SNAPSHOT_KEY)
                    current_payload = self._merge_3way(base, current_payload, latest_row.data)
                    current_revision = latest_row.revision
                    session[self.SNAPSHOT_KEY] = latest_row.data
                except Exception as merge_err:
                    logger.error("Failed to merge concurrent session updates: %s", merge_err)
                    session.modified = False
                    return
            except TransientStoreError as error:
                # Same reasoning as above: the response is already built and the
                # player cannot read anything we could put in an error body. A
                # collision that survived its retry is worth shouting about in the
                # log, and not worth a 500.
                logger.error("Session save dropped after a retry: %s", error)
                session.modified = False
                return
            except Exception as error:
                # The general rule, because enumerating driver errnos never finishes.
                logger.error("Session save failed during response finalisation: %r", error)
                session.modified = False
                return

        # Keep the session's idea of the revision current.
        #
        # This is the fix for "It went wrong" on the first turn. A request that
        # wrote explicitly -- store_session(), from an invasion or a pillage --
        # moved the row to a new revision, but left __save_revision holding the
        # value it had on the way in. The automatic write at the end of that same
        # request then arrived with a revision that was already stale, and
        # conflicted with itself.
        session[self.REVISION_KEY] = written
        base_snapshot = session.get(self.SNAPSHOT_KEY)
        # The reason has been spent on the write that just happened; carrying it
        # over would label the next snapshot with it too.
        session.pop(self.REASON_KEY, None)
        session.pop(self.SNAPSHOT_KEY, None)

        if is_account_store_id(store_id) and self._progress_changed(base_snapshot, current_payload):
            from save_engine import sync_account_progress
            sync_account_progress(current_payload)

    @staticmethod
    def _progress_changed(base: Any, current: dict[str, Any]) -> bool:
        from save_engine import get_dict

        cur_info = get_dict(current, "user_object", "userInfo")
        cur_p = cur_info.get("player")
        if not isinstance(cur_p, dict):
            return False
        if not isinstance(base, dict):
            return True
        base_info = get_dict(base, "user_object", "userInfo")
        base_p = base_info.get("player")
        if not isinstance(base_p, dict):
            return True
        return (
            cur_p.get("level") != base_p.get("level")
            or cur_p.get("xp") != base_p.get("xp")
            or cur_info.get("worldName") != base_info.get("worldName")
        )

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