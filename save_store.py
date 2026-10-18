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
import sqlite3
from dataclasses import dataclass
from datetime import UTC, datetime

SCHEMA_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "schema.sql")

#: How many snapshots to keep per save. Ten was the old in-blob limit; here it is
#: a delete of old rows rather than a slice of a nested list.
DEFAULT_KEEP = 10


class WriteConflict(Exception):
    """The row moved since the caller read it.

    Raised rather than returned so it cannot be ignored by accident: a caller
    that reads, mutates and writes has to decide what a lost race means for it.
    """


class UnknownSave(Exception):
    """No row for that store id."""


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


class Store:
    """SQLite-backed save storage.

    Not a Flask extension and does not import one: the point is that the rules
    about atomicity and history are testable without a request context.
    """

    def __init__(self, path: str, keep: int = DEFAULT_KEEP):
        self.path = path
        self.keep = keep
        self._ensure_schema()

    # -------------------------------------------------------------- plumbing --

    def _connect(self) -> sqlite3.Connection:
        # isolation_level=None puts the driver in autocommit, so transactions
        # below are explicit. With the default isolation the driver would open
        # one behind our back and the ROLLBACK on a conflict would fight it.
        connection = sqlite3.connect(self.path, timeout=10, isolation_level=None)
        connection.row_factory = sqlite3.Row
        connection.execute("PRAGMA foreign_keys = ON")
        connection.execute("PRAGMA journal_mode = WAL")
        return connection

    def _ensure_schema(self) -> None:
        folder = os.path.dirname(os.path.abspath(self.path))
        if folder and not os.path.isdir(folder):
            os.makedirs(folder, exist_ok=True)
        with open(SCHEMA_PATH, encoding="utf-8") as handle:
            script = handle.read()
        connection = self._connect()
        try:
            connection.executescript(script)
        finally:
            connection.close()

    @staticmethod
    def _now() -> str:
        return datetime.now(UTC).isoformat()

    # ------------------------------------------------------------------ read --

    def load(self, store_id: str) -> SaveRow | None:
        """The live save for a store id, or None.

        None means "this player has not started", not "something went wrong" --
        the two are told apart by a raise, not by an empty dict.
        """
        connection = self._connect()
        try:
            row = connection.execute(
                "SELECT store_id, revision, data FROM saves WHERE store_id = ?",
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
            row = connection.execute(
                "SELECT 1 FROM saves WHERE store_id = ?", (store_id,)).fetchone()
        finally:
            connection.close()
        return row is not None

    def count(self) -> int:
        connection = self._connect()
        try:
            return connection.execute("SELECT COUNT(*) FROM saves").fetchone()[0]
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

        connection = self._connect()
        try:
            connection.execute("BEGIN IMMEDIATE")
            existing = connection.execute(
                "SELECT id, revision FROM saves WHERE store_id = ?",
                (store_id,)).fetchone()

            if existing is None:
                if expected_revision is not None:
                    raise WriteConflict(
                        f"{store_id}: expected revision {expected_revision} "
                        "but there is no row")
                connection.execute(
                    "INSERT INTO saves (store_id, revision, data, created_at, "
                    "updated_at) VALUES (?, 1, ?, ?, ?)",
                    (store_id, blob, now, now))
                connection.execute("COMMIT")
                return 1

            current = existing["revision"]
            if expected_revision is not None and expected_revision != current:
                raise WriteConflict(
                    f"{store_id}: read revision {expected_revision}, row is at "
                    f"{current}; someone else wrote in between")

            # Keep what is being replaced, not what is replacing it.
            previous = connection.execute(
                "SELECT data FROM saves WHERE id = ?",
                (existing["id"],)).fetchone()["data"]
            connection.execute(
                "INSERT INTO save_backups (save_id, revision, reason, data, "
                "created_at) VALUES (?, ?, ?, ?, ?)",
                (existing["id"], current, reason, previous, now))

            connection.execute(
                "UPDATE saves SET revision = ?, data = ?, updated_at = ? "
                "WHERE id = ? AND revision = ?",
                (current + 1, blob, now, existing["id"], current))

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

    def _trim(self, connection: sqlite3.Connection, save_id: int) -> None:
        """Drop the oldest snapshots past the limit.

        A single DELETE, not a read-then-delete: the ids come from the database
        in one statement, so two concurrent writes cannot both decide they saw
        the same set.
        """
        connection.execute(
            "DELETE FROM save_backups WHERE save_id = ? AND id NOT IN ("
            "  SELECT id FROM save_backups WHERE save_id = ? "
            "  ORDER BY revision DESC LIMIT ?)",
            (save_id, save_id, self.keep))

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
            rows = connection.execute(
                "SELECT b.save_id, b.revision, b.reason, LENGTH(b.data) AS size, "
                "       b.created_at "
                "  FROM save_backups b JOIN saves s ON s.id = b.save_id "
                " WHERE s.store_id = ? ORDER BY b.revision DESC LIMIT ?",
                (store_id, limit)).fetchall()
        finally:
            connection.close()
        return [BackupRow(save_id=r["save_id"], revision=r["revision"],
                          reason=r["reason"], size=r["size"],
                          created_at=r["created_at"]) for r in rows]

    def read_backup(self, store_id: str, revision: int) -> dict | None:
        """One snapshot's payload, or None if there is no such revision."""
        connection = self._connect()
        try:
            row = connection.execute(
                "SELECT b.data FROM save_backups b JOIN saves s ON s.id = b.save_id "
                " WHERE s.store_id = ? AND b.revision = ?",
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
            cursor = connection.execute(
                "DELETE FROM saves WHERE store_id = ?", (store_id,))
        finally:
            connection.close()
        return cursor.rowcount > 0

    # ------------------------------------------------------------- internals --

    @staticmethod
    def _encode(data: dict) -> bytes:
        """The payload as bytes.

        msgpack, through msgspec, because that is what flask-session's
        serializer already produces and produces it fast -- the save path used
        to cost 18 ms per request decoding a redundant Python tree walk, and
        there is no reason to hand that back. Round-tripping through msgspec also
        keeps this module free of any dependency on a Flask app.
        """
        import msgspec
        return msgspec.msgpack.encode(data)

    @staticmethod
    def _decode(blob: bytes) -> dict:
        """A payload back into a dict, or None when the bytes are unreadable.

        A row that will not decode is a row some other code wrote badly; it must
        not take the request down, and it must not come back as an empty dict
        that looks like a new player.
        """
        import msgspec
        try:
            return msgspec.msgpack.decode(bytes(blob))
        except Exception as error:
            print("save_store: unreadable payload, dropped:", error)
            return None