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

The payloads stay opaque blobs (BYTEA). The empire is the 2012 game's own data and a
schema over it would need migrating every time the game settings change. What
this store can own -- atomicity, versioning, history -- is what it owns.

What it does not do
-------------------
It does not know what a fleet is. Callers hand it a dict and get back a dict;
none of the game's vocabulary appears in here, which is why nothing in this file
has to change when the game does.
"""

from __future__ import annotations

from dataclasses import dataclass
from datetime import UTC, datetime
from pathlib import Path
from typing import Any, Literal, Self

SCHEMA_PATH = str(Path(__file__).resolve().parent / "schema.sql")

#: How many snapshots to keep per save. Ten was the old in-blob limit; here it is
#: a delete of old rows rather than a slice of a nested list.
DEFAULT_KEEP = 10


def strip_sql_comments(script: str) -> str:
    """Drop ``--`` comment lines before the schema is split on ``;``."""
    return "\n".join(line for line in script.splitlines()
                     if not line.lstrip().startswith("--"))


def connect(url: str) -> PostgresConnection:
    """Open a connection to the PostgreSQL 18 database named by ``url``.

    The client encoding is set to UTF-8 rather than left to be negotiated.
    PostgreSQL reports errors in the server's locale and sends them in the
    connection's encoding, and psycopg2 picks that encoding from the *client's*
    locale -- which on Windows is cp1252. A server that speaks Spanish then
    answers with one stray byte where an accent should be, and psycopg2
    raises UnicodeDecodeError instead of saying what went wrong. That turned
    "the database does not exist" into an unreadable error about encoding.
    """
    from urllib.parse import unquote, urlparse

    import psycopg2

    parsed = urlparse(url)
    db_name = (parsed.path or "").strip("/") or None
    conn = psycopg2.connect(
        host=parsed.hostname or "127.0.0.1",
        port=parsed.port or 5432,
        user=unquote(parsed.username or "postgres"),
        password=unquote(parsed.password or ""),
        database=db_name,
        client_encoding="UTF8",
    )
    conn.autocommit = True
    return PostgresConnection(conn)


class PostgresConnection:
    """A psycopg2 connection shaped the way :class:`Store` expects."""

    def __init__(self, connection: Any) -> None:
        self._connection = connection

    def execute(self, sql: str, params: tuple[Any, ...] | list[Any] = ()) -> Any:
        from psycopg2.extras import RealDictCursor
        cursor = self._connection.cursor(cursor_factory=RealDictCursor)
        if params:
            cursor.execute(sql, params)
        else:
            cursor.execute(sql)
        return cursor

    def cursor_for(self) -> Any:
        from psycopg2.extras import RealDictCursor
        return self._connection.cursor(cursor_factory=RealDictCursor)

    def close(self) -> None:
        self._connection.close()

    def __enter__(self) -> Self:
        return self

    def __exit__(self, exc_type: object, exc_value: object, traceback: object) -> Literal[False]:
        self.close()
        return False

    def commit(self) -> None:
        self._connection.commit()

    def rollback(self) -> None:
        self._connection.rollback()

    def __getattr__(self, name: str) -> Any:
        return getattr(self._connection, name)


class WriteConflict(Exception):
    """The row moved since the caller read it.

    Raised rather than returned so it cannot be ignored by accident: a caller
    that reads, mutates and writes has to decide what a lost race means for it.
    """


class UnknownSave(Exception):
    """No row for that store id."""


# PostgreSQL error codes for transient lock collisions and serialization errors:
#   40P01 Deadlock detected
#   40001 Serialization failure
#   55P03 Lock not available
PG_TRANSIENT_CODES = frozenset({"40P01", "40001", "55P03"})


def is_transient_store_error(error: BaseException) -> bool:
    """True for a collision worth retrying, false for anything else."""
    pgcode = getattr(error, "pgcode", None)
    if pgcode and str(pgcode) in PG_TRANSIENT_CODES:
        return True
    code = getattr(error, "code", None) or (error.args[0] if error.args else None)
    if code and str(code) in PG_TRANSIENT_CODES:
        return True
    name = type(error).__name__
    return name in ("DeadlockDetected", "SerializationFailure", "LockNotAvailable")


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


def account_store_id(zid: int | str) -> str:
    """The store id for an account.

    Mirrors ``account_saves.account_store_id`` -- same shape, so a row written
    by one is found by the other. Kept here rather than imported so this module
    has no dependency on Flask.
    """
    return "acct" + str(zid)


def save_uid(data: Any) -> int | None:
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


def save_invaders(data: Any) -> dict[str, Any]:
    """The invasion map of a save, or an empty one."""
    if not isinstance(data, dict):
        return {}
    user_object = data.get("user_object")
    if not isinstance(user_object, dict):
        return {}
    pvp = user_object.get("pvp")
    if not isinstance(pvp, dict):
        return {}
    invaders = pvp.get("invaders")
    return invaders if isinstance(invaders, dict) else {}


class Store:
    """PostgreSQL 18-backed save storage.

    Not a Flask extension and does not import one: the point is that the rules
    about atomicity and history are testable without a request context.

    ``codec`` is anything with ``encode(dict) -> bytes`` and
    ``decode(bytes) -> dict``. It defaults to plain msgspec, which is right for
    a store holding arbitrary data. The gateway passes the session interface's
    serializer instead, because that one carries the hooks the game needs --
    ``enc_hook`` for the tagged BattleContext, and the decode walk that turns it
    back into a struct.
    """

    def __init__(self, path: str, keep: int = DEFAULT_KEEP, codec: Any = None) -> None:
        self.path = path
        self.keep = keep
        self.codec = codec or PlainMsgpack()
        self._ensure_schema()

    # -------------------------------------------------------------- plumbing --

    def _connect(self) -> PostgresConnection:
        return connect(self.path)

    def drop_database(self) -> bool:
        """Drop the whole database this store points at."""
        from urllib.parse import urlparse, urlunparse

        database = urlparse(self.path).path.strip("/")
        if not database:
            return False

        bootstrap = connect(urlunparse(urlparse(self.path)._replace(path="/postgres")))
        try:
            bootstrap.execute(f'DROP DATABASE IF EXISTS "{database}" WITH (FORCE)')
            return True
        finally:
            bootstrap.close()

    def _ensure_schema(self) -> None:
        """Create the database if it is missing, then apply the schema."""
        from urllib.parse import urlparse, urlunparse

        database = urlparse(self.path).path.strip("/")
        if not database:
            raise ValueError(
                f"{self.path!r} has no database name; SAVE_STORE_PATH must be a database URL")

        bootstrap = connect(urlunparse(urlparse(self.path)._replace(path="/postgres")))
        try:
            cur = bootstrap.execute("SELECT 1 FROM pg_database WHERE datname = %s", (database,))
            if not cur.fetchone():
                bootstrap.execute(f'CREATE DATABASE "{database}"')
        finally:
            bootstrap.close()

        script = Path(SCHEMA_PATH).read_text(encoding="utf-8").lstrip("\ufeff")
        connection = self._connect()
        try:
            for statement in strip_sql_comments(script).split(";"):
                if statement.strip():
                    connection.execute(statement)
        finally:
            connection.close()

    @staticmethod
    def _now() -> str:
        """A timestamp formatted for PostgreSQL TIMESTAMP columns."""
        return datetime.now(UTC).strftime("%Y-%m-%d %H:%M:%S")

    # --------------------------------------------------------------- queries --

    @staticmethod
    def _exec(connection: Any, sql: str, params: tuple[Any, ...] | list[Any] = ()) -> Any:
        """Run a parameterised statement."""
        return connection.execute(sql, params) if params else connection.execute(sql)

    # ------------------------------------------------------------------ read --

    def load(self, store_id: str) -> SaveRow | None:
        """The live save for a store id, or None."""
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

    def load_all(self) -> list[SaveRow]:
        """Every save, in one query."""
        connection = self._connect()
        try:
            rows = self._exec(
                connection,
                "SELECT store_id, revision, data FROM saves ORDER BY store_id",
            ).fetchall()
        finally:
            connection.close()

        decoded = []
        for row in rows:
            try:
                data = self._decode(row["data"])
            except Exception as error:
                print("Skipping undecodable save:", row["store_id"],
                      type(error).__name__, error)
                continue
            decoded.append(SaveRow(store_id=row["store_id"],
                                   revision=row["revision"], data=data))
        return decoded

    def exists(self, store_id: str) -> bool:
        connection = self._connect()
        try:
            row = self._exec(
                connection,
                "SELECT 1 FROM saves WHERE store_id = %s", (store_id,)).fetchone()
        finally:
            connection.close()
        return row is not None

    def load_by_uid(self, uid: int | str) -> SaveRow | None:
        """The save for a player the game addresses by uid, or None."""
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

    def rows_without_uid(self) -> list[tuple[str, Any]]:
        """(store_id, decoded payload) for every row the column is missing."""
        connection = self._connect()
        try:
            rows = self._exec(
                connection,
                "SELECT store_id, data FROM saves WHERE uid IS NULL").fetchall()
        finally:
            connection.close()
        return [(row["store_id"], self._decode(row["data"])) for row in rows]

    def set_uid(self, store_id: str, uid: int | str) -> bool:
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
            return self._exec(
                connection,
                "SELECT COUNT(*) AS total FROM saves").fetchone()["total"]
        finally:
            connection.close()

    # ----------------------------------------------------------------- write --

    def store(self, store_id: str, data: dict, reason: str | None = None,
              expected_revision: int | None = None) -> int:
        """Write a save, snapshotting what was there. Returns the new revision.

        Uses PostgreSQL row-level locking (FOR UPDATE) to serialize writes on the same store_id
        and prevent race conditions.
        """
        blob = self._encode(data)
        now = self._now()
        uid = save_uid(data)

        connection = self._connect()
        try:
            connection.execute("BEGIN")
            existing = self._exec(
                connection,
                "SELECT id, revision, data FROM saves WHERE store_id = %s FOR UPDATE",
                (store_id,)).fetchone()

            if existing is None:
                if expected_revision is not None and expected_revision != 0:
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
            previous = bytes(existing["data"]) if existing["data"] is not None else b""

            if previous == blob:
                connection.execute("COMMIT")
                return current

            if expected_revision is not None and expected_revision != current:
                raise WriteConflict(
                    f"{store_id}: read revision {expected_revision}, row is at "
                    f"{current}; someone else wrote in between")

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
            connection.execute("ROLLBACK")
            raise
        finally:
            connection.close()

    def _trim(self, connection: Any, save_id: int) -> None:
        """Drop the oldest snapshots past the limit."""
        rows = self._exec(
            connection,
            "SELECT id FROM save_backups WHERE save_id = %s ORDER BY revision DESC",
            (save_id,)).fetchall()
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
        return self.store(store_id, data, reason, expected_revision=0)

    # --------------------------------------------------------------- history --

    def history(self, store_id: str, limit: int = 50) -> list[BackupRow]:
        """Snapshots for a save, newest first, without their payloads."""
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
        """Bring a snapshot back as the live save."""
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

    def clear(self, connection: PostgresConnection | None = None) -> int:
        """Delete every save and every snapshot. Returns how many there were.

        The store owns its tables, so it is the thing that knows how to empty
        them.

        It counts before it deletes, because deleting is a write transaction
        with a WAL flush behind it and counting is a read. The test suite
        empties the store between every test, and most tests never touch it,
        so the common answer is "there was nothing there" -- and then nothing
        is written at all.

        An open `connection` can be handed in so that a caller emptying the
        store repeatedly does not open a connection per call. It is not closed
        here: it belongs to whoever passed it.
        """
        own = connection is None
        if own:
            connection = self._connect()
        try:
            cursor = connection.execute(
                "SELECT (SELECT count(*) FROM saves) + (SELECT count(*) FROM save_backups) AS pending"
            )
            row = cursor.fetchone()
            pending = int(row["pending"]) if row else 0
            if pending:
                connection.execute("TRUNCATE TABLE save_backups, saves CASCADE")
            return pending
        finally:
            if own:
                connection.close()

    # ------------------------------------------------------------- internals --

    def _encode(self, data: dict) -> bytes:
        return self.codec.encode(data)

    def _decode(self, blob: bytes) -> dict | None:
        """A payload back into a dict, or None when the bytes are unreadable."""
        try:
            return self.codec.decode(bytes(blob))
        except Exception as error:
            print("save_store: unreadable payload, dropped:", error)
            return None


class PlainMsgpack:
    """Default codec: msgspec, no game-specific hooks."""

    def encode(self, data: dict) -> bytes:
        import msgspec
        return msgspec.msgpack.encode(data)

    def decode(self, blob: bytes) -> dict:
        import msgspec
        return msgspec.msgpack.decode(blob)
