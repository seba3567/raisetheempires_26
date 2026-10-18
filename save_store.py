"""Save storage: one row per player, history beside it, writes guarded.

What this is
------------
The rebuild. Everything went through one table whose payload contained its own
backup chain -- nested copies inside the blob, ten deep, so one row reached 3 MB
and every request decoded the entire history to read the current empire. Writes
were ``get_saves()``, mutate in Python, overwrite the whole row, with nothing
checking whether the row had moved underneath. Two requests landing together
meant one of them lost its work silently.

Three guarantees now, and nothing else:

**One row per player.** ``saves.store_id`` is UNIQUE. ``acct<zid>`` for an
account, the cookie sid otherwise. It is a property of the database, not a
convention.

**Writes are checked.** :meth:`Store.store` takes the revision the caller read
and only writes if the row is still at it. The loser of a race gets
:class:`WriteConflict` rather than a silent overwrite.

**History is a different table.** ``save_backups`` is append-only, so the row a
request touches is the size of the empire and not ten times it.

The payloads stay opaque blobs. The empire is the 2012 game's own data and a
schema over it would need migrating every time the game settings change. What
this store can own -- atomicity, versioning, history -- is what it owns.

What it does not do
-------------------
It does not know what a fleet is. Callers hand it a dict and get back a dict;
none of the game's vocabulary appears in here, which is why nothing in this file
has to change when the game does.
"""

from __future__ import annotations

import os
from dataclasses import dataclass
from datetime import UTC, datetime

SCHEMA_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "schema.sql")

#: How many snapshots to keep per save. Ten was the old in-blob limit; here it is
#: a delete of old rows rather than a slice of a nested list.
DEFAULT_KEEP = 10


class _DictCursor:
    """Adapter giving pymysql cursors the ``row["name"]`` shape the queries use.

    pymysql returns tuples by default and every query in Store indexes by column
    name, so this wraps ``fetchall``/``fetchone`` to hand back dicts.

    Kept rather than switching every query to index 0, because ``SELECT *``
    column order is not something the callers should have to know.
    """

    def __init__(self, cursor):
        self._cursor = cursor

    def __getattr__(self, name):
        return getattr(self._cursor, name)

    def _as_dict(self, row):
        if row is None:
            return None
        return dict(zip([column[0] for column in self._cursor.description], row))

    def fetchone(self):
        return self._as_dict(self._cursor.fetchone())

    def fetchall(self):
        return [self._as_dict(row) for row in self._cursor.fetchall()]

    def __iter__(self):
        row = self.fetchone()
        while row is not None:
            yield row
            row = self.fetchone()


def strip_sql_comments(script: str) -> str:
    """Drop ``--`` comment lines before the schema is split on ``;``.

    The schema is the only SQL file in the project and it is heavily commented,
    which is worth keeping. But a semicolon inside a comment -- "until the move;
    the file kept the plain name" -- splits a statement in half and the server
    rejects the fragment, which points at the schema rather than at the comment.
    Removing the comments first makes the split safe and the error messages
    honest.
    """
    return "\n".join(line for line in script.splitlines()
                     if not line.lstrip().startswith("--"))


def connect(url: str):
    """Open a connection to the MariaDB named by ``url``.

    The URL is ``mariadb://user:password@host:port/database``, which is the
    same shape as ``SQLALCHEMY_DATABASE_URI`` so there is one format to learn.
    Passing a bare filename used to mean SQLite and no longer does.
    """
    from urllib.parse import unquote, urlparse

    import pymysql

    parsed = urlparse(url)
    return MariaConnection(pymysql.connect(
        host=parsed.hostname or "127.0.0.1",
        port=parsed.port or 3306,
        user=unquote(parsed.username or "root"),
        password=unquote(parsed.password or ""),
        database=(parsed.path or "").strip("/") or None,
        charset="utf8mb4",
        # autocommit on, so the transactions in Store are explicit.
        autocommit=True,
    ))


class MariaConnection:
    """A pymysql connection shaped the way :class:`Store` expects.

    pymysql executes on a cursor and returns tuples, where every query here
    does ``connection.execute(...).fetchone()`` and indexes by column name.
    Rather than rewrite the queries, this forwards ``execute`` to the cursor and
    hands back dict rows.
    """

    def __init__(self, connection):
        self._connection = connection
        self.cursor = _DictCursor(connection.cursor())

    def execute(self, sql: str, params=()):
        # Returns the cursor, not the rowcount: every read does
        # connection.execute(...).fetchone(), and an int would fail with
        # "'int' object has no attribute 'fetchone'".
        if params:
            self.cursor.execute(sql, params)
        else:
            self.cursor.execute(sql)
        return self.cursor

    def cursor_for(self):
        """A fresh cursor, for the rare caller that needs a second one."""
        return _DictCursor(self._connection.cursor())

    def close(self):
        self._connection.close()

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_value, traceback):
        # Autocommit is on, so there is nothing to commit; the context manager
        # exists so `with store._connect() as connection` reads the same as it
        # did under sqlite3.
        return False

    def commit(self):
        self._connection.commit()

    def rollback(self):
        self._connection.rollback()

    def __getattr__(self, name):
        return getattr(self._connection, name)


class WriteConflict(Exception):
    """The row moved since the caller read it.

    Raised rather than returned so it cannot be ignored by accident: a caller
    that reads, mutates and writes has to decide what a lost race means for it.
    """


class UnknownSave(Exception):
    """No row for that store id."""


# MariaDB errno for the errors that mean "somebody else was in here at the same
# time, run it again" rather than "this statement is wrong":
#   1020 Record has changed since last read in table X; try restarting transaction
#   1205 Lock wait timeout exceeded
#   1213 Deadlock found when trying to get lock; try restarting transaction
#
# 1020 earns its place here for a reason worth writing down. It is not even a lock
# failure: under REPEATABLE READ, writing a snapshot of the row that is being
# replaced aborts if anyone touched the history table in between. It arrived
# while serving /questSettings.xml -- a static file -- because flask-session
# flushes the session at the end of every request, so one unrepeatable write
# turned an asset download into a 500, and the game silently lost its quest
# catalogue. The error was a long way from anything that looked like quests.
TRANSIENT_STORE_ERRNOS = frozenset({1020, 1205, 1213})


def is_transient_store_error(error: BaseException) -> bool:
    """True for a collision worth retrying, false for anything else.

    None of these is a lost write: the transaction was rolled back, nothing was
    half-applied, and the statement was not wrong. Running it again is the
    correct response, and almost always works, because whatever collided has
    moved on.

    Everything else must *not* be retried. A duplicate key, a missing column or a
    bad parameter will fail identically every time, and retrying those just turns
    a clear error into a slow one.
    """
    code = error.args[0] if error.args else None
    return isinstance(code, int) and code in TRANSIENT_STORE_ERRNOS


class TransientStoreError(Exception):
    """A lock collision that outlived its retry.

    Named so a caller can choose to give up on a background write. The
    alternative, letting the driver's OperationalError escape, is what turned a
    deadlock during end-of-request session flushing into a 500 for the player.
    """


@dataclass(frozen=True)
class SaveRow:
    """One loaded save, with the revision it was read at."""

    store_id: str
    revision: int
    data: dict


@dataclass(frozen=True)
class BackupRow:
    """One snapshot, as listed by :meth:`Store.history`."""

    save_id: int
    revision: int
    reason: str | None
    size: int
    created_at: str


def account_store_id(zid) -> str:
    """The store id for an account.

    Mirrors ``account_saves.account_store_id`` -- same shape, so a row written
    by one is found by the other. Kept here rather than imported so this module
    has no dependency on Flask.
    """
    return "acct" + str(zid)


def save_uid(data) -> int | None:
    """The player id inside a save, or None.

    Read defensively all the way down: this runs against every row on every
    write, including rows written by an older build, a half-finished paste, or a
    test's stub. A missing or misshapen empire yields None, which is a lookup
    miss rather than an exception -- the column is nullable for exactly this.
    """
    if not isinstance(data, dict):
        return None
    user_object = data.get("user_object")
    if not isinstance(user_object, dict):
        return None
    info = user_object.get("userInfo")
    if not isinstance(info, dict):
        return None
    player = info.get("player")
    if not isinstance(player, dict):
        return None
    uid = player.get("uid")
    return uid if isinstance(uid, int) and not isinstance(uid, bool) else None


class Store:
    """MariaDB-backed save storage.

    Not a Flask extension and does not import one: the point is that the rules
    about atomicity and history are testable without a request context.

    ``codec`` is anything with ``encode(dict) -> bytes`` and
    ``decode(bytes) -> dict``. It defaults to plain msgspec, which is right for
    a store holding arbitrary data. The gateway passes the session interface's
    serializer instead, because that one carries the hooks the game needs --
    ``enc_hook`` for the tagged BattleContext, and the decode walk that turns it
    back into a struct. A plain encoder round-trips it as an ordinary dict,
    which is why this is a parameter and not a hardcoded call.
    """

    def __init__(self, path: str, keep: int = DEFAULT_KEEP, codec=None):
        self.path = path
        self.keep = keep
        self.codec = codec or PlainMsgpack()
        self._ensure_schema()

    # -------------------------------------------------------------- plumbing --

    def _connect(self):
        return connect(self.path)

    def drop_database(self) -> bool:
        """Drop the whole database this store points at.

        The counterpart to ``_ensure_schema``, and it exists for the throwaway
        databases the test suite makes: one per test, named with a uuid so runs
        cannot see each other. Without this they are simply never removed, and a
        few hundred runs later the server is carrying a database per assertion
        that ever ran -- which is exactly what happened.

        It goes through the server rather than ``_connect`` because a connection
        cannot drop the database it is itself using, for the same reason the
        CREATE cannot run from inside it.
        """
        from urllib.parse import urlparse, urlunparse

        database = urlparse(self.path).path.strip("/")
        if not database:
            return False

        bootstrap = connect(urlunparse(urlparse(self.path)._replace(path="")))
        try:
            bootstrap.execute(f"DROP DATABASE IF EXISTS `{database}`")
            return True
        finally:
            bootstrap.close()

    def _ensure_schema(self) -> None:
        """Create the database if it is missing, then apply the schema.

        Two connections, on purpose. ``_connect`` asks for the database by name
        and a database that does not exist yet cannot be connected to, so the
        CREATE runs against the server and only then is the real one opened.

        Statements are split on ``;`` and run one at a time: a statement that
        fails must not take the whole boot with it, and a skipped index on a
        column a migration has not added yet should say so rather than be fatal.
        """
        from urllib.parse import urlparse, urlunparse

        with open(SCHEMA_PATH, encoding="utf-8") as handle:
            script = handle.read().lstrip("\ufeff")

        database = urlparse(self.path).path.strip("/")
        if not database:
            raise ValueError(
                f"{self.path!r} has no database name; SAVE_STORE_PATH must be a "
                "mariadb://user:password@host:port/database URL")

        bootstrap = connect(urlunparse(urlparse(self.path)._replace(path="")))
        try:
            bootstrap.execute(
                f"CREATE DATABASE IF NOT EXISTS `{database}` "
                "CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci")
        finally:
            bootstrap.close()

        connection = self._connect()
        try:
            for statement in strip_sql_comments(script).split(";"):
                if statement.strip():
                    connection.execute(statement)
        finally:
            connection.close()

    @staticmethod
    def _now() -> str:
        """A timestamp both engines accept for a DATETIME column.

        Not ISO-8601: MariaDB rejects "2026-10-18T00:49:51+00:00" with error
        1292, and sqlite3 stores whatever it is given without complaint, so the
        portable spelling is the plain SQL form. Computed rather than left to
        the column default because sqlite3's updated_at default does not fire
        on UPDATE the way MariaDB's would.
        """
        return datetime.now(UTC).strftime("%Y-%m-%d %H:%M:%S")

    # --------------------------------------------------------------- queries --

    @staticmethod
    def _exec(connection, sql: str, params=()):
        """Run a parameterised statement.

        No placeholder translation: MariaDB wants ``%s`` and that is what the
        queries are written with. They used to be written with sqlite3's ``?``
        and rewritten here, which meant a query sent anywhere else stored the
        literal ``?`` instead of the value -- silently, without an error.
        """
        return connection.execute(sql, params) if params else connection.execute(sql)

    # ------------------------------------------------------------------ read --

    def load(self, store_id: str) -> SaveRow | None:
        """The live save for a store id, or None.

        None means "this player has not started", not "something went wrong" --
        the two are told apart by a raise, not by an empty dict.
        """
        connection = self._connect()
        try:
            row = self._exec(
                    connection, 
                "SELECT store_id, revision, data FROM saves WHERE store_id = %s",
                (store_id,),
            ).fetchone()
        finally:
            connection.close()

        if row is None:
            return None
        return SaveRow(store_id=row["store_id"], revision=row["revision"],
                       data=self._decode(row["data"]))

    def exists(self, store_id: str) -> bool:
        connection = self._connect()
        try:
            row = self._exec(
                    connection, 
                "SELECT 1 FROM saves WHERE store_id = %s", (store_id,)).fetchone()
        finally:
            connection.close()
        return row is not None

    def load_by_uid(self, uid) -> SaveRow | None:
        """The save for a player the game addresses by uid, or None.

        The game does not address players by store key. An invasion, a pillage
        and the neighbour list all say "this other player" and mean
        ``user_object.userInfo.player.uid``. Doing that by scanning meant
        deserialising *every* empire in the database to compare one number --
        which is what get_saves() plus a list comprehension did on every
        invasion, and is why this is an indexed column instead.

        No match is a normal answer, not an error: a row written before the
        column existed has no uid, and an empire that has never booted has no
        player either.
        """
        connection = self._connect()
        try:
            row = self._exec(
                connection,
                "SELECT store_id, revision, data FROM saves WHERE uid = %s LIMIT 1",
                (uid,)).fetchone()
        finally:
            connection.close()

        if row is None:
            return None
        return SaveRow(store_id=row["store_id"], revision=row["revision"],
                       data=self._decode(row["data"]))

    def rows_without_uid(self) -> list:
        """(store_id, decoded payload) for every row the column is missing.

        The backfill walks these; reading the payloads here rather than in the
        migration keeps the message-decoding rules in one place.
        """
        connection = self._connect()
        try:
            rows = self._exec(
                connection,
                "SELECT store_id, data FROM saves WHERE uid IS NULL").fetchall()
        finally:
            connection.close()
        return [(row["store_id"], self._decode(row["data"])) for row in rows]

    def set_uid(self, store_id: str, uid) -> bool:
        """Fill the uid on a row that predates the column."""
        connection = self._connect()
        try:
            self._exec(
                connection,
                "UPDATE saves SET uid = %s WHERE store_id = %s AND uid IS NULL",
                (uid, store_id))
            return True
        finally:
            connection.close()

    def count(self) -> int:
        connection = self._connect()
        try:
            # By name, not position: sqlite3's Row supports both, MariaDB's dict
            # rows only the name.
            return self._exec(
                connection,
                "SELECT COUNT(*) AS total FROM saves").fetchone()["total"]
        finally:
            connection.close()

    # ----------------------------------------------------------------- write --

    def store(self, store_id: str, data: dict, reason: str | None = None,
              expected_revision: int | None = None) -> int:
        """Write a save, snapshotting what was there. Returns the new revision.

        ``expected_revision`` is the guard. Pass what :meth:`load` returned and a
        concurrent writer turns into :class:`WriteConflict` instead of a lost
        turn. Leave it None only where overwriting is genuinely the intent, such
        as an admin paste from the editor.

        The snapshot and the new row are written in one transaction: a crash
        between them would either lose the history or lose the save.
        """
        blob = self._encode(data)
        now = self._now()
        # Read out of the payload rather than passed in, so a caller cannot
        # index one save under another's uid -- and cannot forget to.
        uid = save_uid(data)

        connection = self._connect()
        try:
            # "BEGIN IMMEDIATE" is sqlite3's way of taking the write lock up
            # front; MariaDB spells it START TRANSACTION, which is immediate by
            # default. Either way the point is that the snapshot and the new
            # row land together.
            connection.execute("START TRANSACTION")
            existing = self._exec(
                connection,
                "SELECT id, revision FROM saves WHERE store_id = %s",
                (store_id,)).fetchone()

            if existing is None:
                if expected_revision is not None:
                    raise WriteConflict(
                        f"{store_id}: expected revision {expected_revision} "
                        "but there is no row")
                self._exec(
                    connection,
                    "INSERT INTO saves (store_id, revision, uid, data, "
                    "created_at, updated_at) VALUES (%s, 1, %s, %s, %s, %s)",
                    (store_id, uid, blob, now, now))
                connection.execute("COMMIT")
                return 1

            current = existing["revision"]
            if expected_revision is not None and expected_revision != current:
                raise WriteConflict(
                    f"{store_id}: read revision {expected_revision}, row is at "
                    f"{current}; someone else wrote in between")

            # Keep what is being replaced, not what is replacing it.
            previous = self._exec(
                    connection, 
                "SELECT data FROM saves WHERE id = %s",
                (existing["id"],)).fetchone()["data"]
            self._exec(
                    connection, 
                "INSERT INTO save_backups (save_id, revision, reason, data, "
                "created_at) VALUES (%s, %s, %s, %s, %s)",
                (existing["id"], current, reason, previous, now))

            self._exec(
                    connection,
                "UPDATE saves SET revision = %s, data = %s, uid = %s, updated_at = %s "
                "WHERE id = %s AND revision = %s",
                (current + 1, blob, uid, now, existing["id"], current))

            self._trim(connection, existing["id"])
            connection.execute("COMMIT")
            return current + 1
        except Exception:
            # One transaction for the snapshot and the new row: a crash between
            # them would either lose the history or lose the save. ROLLBACK here
            # is what makes a WriteConflict leave no orphan snapshot behind.
            connection.execute("ROLLBACK")
            raise
        finally:
            connection.close()

    def _trim(self, connection, save_id: int) -> None:
        """Drop the oldest snapshots past the limit.

        The obvious one-statement form -- ``DELETE ... WHERE id NOT IN (SELECT ...
        LIMIT ?)`` -- is rejected by MariaDB with error 1235, which does not
        support LIMIT inside an IN subquery, and SQLite's multi-table DELETE
        syntax has no MariaDB equivalent either. So the ids to remove are read
        first and deleted by id.

        That is safe rather than racy because it happens inside the same
        transaction as the write that triggered it, on the same connection: the
        rows cannot move under it between the two statements.
        """
        rows = self._exec(
            connection,
            "SELECT id FROM save_backups WHERE save_id = %s ORDER BY revision DESC",
            (save_id,)).fetchall()
        # Everything past the newest `keep`. No LIMIT/OFFSET at all: MariaDB
        # rejects a placeholder in OFFSET (error 1064), and sqlite3 rejects the
        # "unlimited" value that MariaDB would accept. There are at most a
        # handful more rows than the limit, so fetching them is nothing.
        stale = [row["id"] for row in rows[self.keep:]]

        if stale:
            placeholders = ",".join(["%s"] * len(stale))
            self._exec(
                connection,
                f"DELETE FROM save_backups WHERE id IN ({placeholders})",
                tuple(stale))

    def create(self, store_id: str, data: dict, reason: str | None = None) -> int:
        """Insert a save that is not expected to exist. Fails if it does."""
        if self.exists(store_id):
            raise WriteConflict(f"{store_id} already exists")
        return self.store(store_id, data, reason)

    # --------------------------------------------------------------- history --

    def history(self, store_id: str, limit: int = 50) -> list[BackupRow]:
        """Snapshots for a save, newest first, without their payloads.

        The payload is deliberately not selected. Listing ten 40 KB blobs to show
        a menu is how the old editor page paid 18 ms for a level number.
        """
        connection = self._connect()
        try:
            rows = self._exec(
                    connection, 
                "SELECT b.save_id, b.revision, b.reason, LENGTH(b.data) AS size, "
                "       b.created_at "
                "  FROM save_backups b JOIN saves s ON s.id = b.save_id "
                " WHERE s.store_id = %s ORDER BY b.revision DESC LIMIT %s",
                (store_id, limit)).fetchall()
        finally:
            connection.close()
        return [BackupRow(save_id=r["save_id"], revision=r["revision"],
                          reason=r["reason"], size=r["size"],
                          created_at=str(r["created_at"])) for r in rows]

    def read_backup(self, store_id: str, revision: int) -> dict | None:
        """One snapshot's payload, or None if there is no such revision."""
        connection = self._connect()
        try:
            row = self._exec(
                    connection, 
                "SELECT b.data FROM save_backups b JOIN saves s ON s.id = b.save_id "
                " WHERE s.store_id = %s AND b.revision = %s",
                (store_id, revision)).fetchone()
        finally:
            connection.close()
        return self._decode(row["data"]) if row else None

    def restore(self, store_id: str, revision: int, reason: str | None = None,
                expected_revision: int | None = None) -> int:
        """Bring a snapshot back as the live save.

        The snapshot is not consumed: restoring writes the *current* state into
        history first, so going back one step and forward again is possible.
        That is what makes this safe to point a button at.
        """
        payload = self.read_backup(store_id, revision)
        if payload is None:
            raise UnknownSave(f"{store_id} has no snapshot at revision {revision}")
        note = reason if reason is not None else f"restore revision {revision}"
        return self.store(store_id, payload, note, expected_revision)

    def delete(self, store_id: str) -> bool:
        """Remove a save and, by cascade, its history."""
        connection = self._connect()
        try:
            cursor = self._exec(
                    connection, 
                "DELETE FROM saves WHERE store_id = %s", (store_id,))
        finally:
            connection.close()
        return cursor.rowcount > 0

    # ------------------------------------------------------------- internals --

    def _encode(self, data: dict) -> bytes:
        return self.codec.encode(data)

    def _decode(self, blob: bytes) -> dict | None:
        """A payload back into a dict, or None when the bytes are unreadable.

        A row that will not decode is a row some other code wrote badly; it must
        not take the request down, and it must not come back as an empty dict
        that looks like a new player.
        """
        try:
            return self.codec.decode(bytes(blob))
        except Exception as error:
            print("save_store: unreadable payload, dropped:", error)
            return None


class PlainMsgpack:
    """Default codec: msgspec, no game-specific hooks.

    Enough for the store's own tests and for anything holding plain data. The
    gateway replaces it because the empire carries a tagged struct that needs
    ``enc_hook`` on the way out and a walk on the way back in.
    """

    def encode(self, data: dict) -> bytes:
        import msgspec
        return msgspec.msgpack.encode(data)

    def decode(self, blob: bytes) -> dict:
        import msgspec
        return msgspec.msgpack.decode(blob)