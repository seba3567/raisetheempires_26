"""Move the account store out of SQLite and into MariaDB.

Why this exists
---------------
The gateway's saves already live in MariaDB. The *accounts* did not: Bun was
still opening ``web/instance/web.db`` with ``bun:sqlite``. One database was the
plan, and this is the script that finishes it.

What is copied
--------------
Every table in the web schema -- ``users``, ``friendships``, ``progress``,
``activity`` -- read from the SQLite file and written to MariaDB, preserving ids
and timestamps. Ids matter: friendships and activity reference ``users.id``, and
minting new ones here would orphan every row that points at them.

Nothing is deleted. The SQLite file is left alone, and the script is a dry run
unless ``--apply`` is passed, so a mistake is a re-run rather than a recovery.

Usage:
    python migrate_accounts.py                       # dry run
    python migrate_accounts.py --apply
"""

from __future__ import annotations

import argparse
import sqlite3
import sys

import pymysql

TABLES = ["users", "friendships", "progress", "activity"]

# The web schema, as 001_init.sql and 002_add_role.sql define it -- mirrored
# into MariaDB rather than copied, with two deliberate changes:
#
# TEXT date columns become DATETIME. SQLite has no date type and the original
# stored them as text; on MariaDB they would still accept text but never sort
# or compare as dates, and every "last N days" query would compare strings.
#
# users.id stays a plain INT PRIMARY KEY with no AUTO_INCREMENT. The id is
# assigned by the application from a stable source (see src/ids.ts) precisely
# so a save cannot be orphaned by a regenerated id, and handing the sequence
# back to the database would undo that decision.
CREATE = {
    "users": """
        CREATE TABLE IF NOT EXISTS users (
            id            INT PRIMARY KEY,
            zid           BIGINT NOT NULL,
            username      VARCHAR(64) NOT NULL,
            username_key  VARCHAR(64) NOT NULL,
            password_hash TEXT NOT NULL,
            created_at    DATETIME NOT NULL,
            last_seen_at  DATETIME NULL,
            role          VARCHAR(16) NOT NULL DEFAULT 'player',
            UNIQUE KEY users_zid_unique (zid),
            UNIQUE KEY users_username_key_unique (username_key)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    """,
    "friendships": """
        CREATE TABLE IF NOT EXISTS friendships (
            user_id      INT NOT NULL,
            friend_id    INT NOT NULL,
            status       VARCHAR(16) NOT NULL,
            requested_by INT NOT NULL,
            created_at   DATETIME NOT NULL,
            accepted_at  DATETIME NULL,
            PRIMARY KEY (user_id, friend_id),
            KEY idx_friendships_friend (friend_id),
            CONSTRAINT friendships_user_fk FOREIGN KEY (user_id)
                REFERENCES users (id) ON DELETE CASCADE,
            CONSTRAINT friendships_friend_fk FOREIGN KEY (friend_id)
                REFERENCES users (id) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    """,
    "progress": """
        CREATE TABLE IF NOT EXISTS progress (
            user_id    INT PRIMARY KEY,
            level      INT NOT NULL DEFAULT 1,
            xp         BIGINT NOT NULL DEFAULT 0,
            world_name VARCHAR(255) NOT NULL,
            updated_at DATETIME NOT NULL,
            CONSTRAINT progress_user_fk FOREIGN KEY (user_id)
                REFERENCES users (id) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    """,
    "activity": """
        CREATE TABLE IF NOT EXISTS activity (
            id         INT PRIMARY KEY,
            user_id    INT NULL,
            kind       VARCHAR(32) NOT NULL,
            detail     TEXT,
            created_at DATETIME NOT NULL,
            KEY idx_activity_user (user_id, id),
            CONSTRAINT activity_user_fk FOREIGN KEY (user_id)
                REFERENCES users (id) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    """,
}


def connect(url: str, database: str | None = None):
    from urllib.parse import unquote, urlparse

    parsed = urlparse(url)
    connection = pymysql.connect(
        host=parsed.hostname or "127.0.0.1",
        port=parsed.port or 3306,
        user=unquote(parsed.username or "root"),
        password=unquote(parsed.password or ""),
        database=database,
        charset="utf8mb4",
        autocommit=False,
        # Dict rows, so COUNT(*) reads as ["n"] rather than [0]. Without it the
        # emptiness check below silently mis-typed.
        cursorclass=pymysql.cursors.DictCursor,
    )
    return connection


def to_mariadb_datetime(value):
    """SQLite has no date type, so these are ISO-8601 strings: '2026-10-17T19:32:45.644Z'.

    MariaDB's DATETIME rejects that with error 1292 -- it wants
    'YYYY-MM-DD HH:MM:SS'. Converted here rather than by changing the column
    back to TEXT, because a DATETIME that sorts and compares as a date is the
    whole point of moving.
    """
    if value is None or not isinstance(value, str):
        return value
    text = value.strip()
    if not text:
        return None
    text = text.removesuffix("Z")
    text = text.replace("T", " ", 1)
    # Drop sub-second precision: DATETIME without fractional seconds rejects it.
    if "." in text:
        text = text.split(".", 1)[0]
    return text


def convert_row(row: dict) -> tuple:
    """The row's values, with date columns in a shape MariaDB accepts."""
    return tuple(to_mariadb_datetime(value) for value in row.values())


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--sqlite", default="web/instance/web.db")
    parser.add_argument("--maria", required=True,
                        help="mariadb://user:pass@host:port/database")
    parser.add_argument("--apply", action="store_true",
                        help="write to MariaDB; without it, only report")
    args = parser.parse_args()

    from urllib.parse import urlparse

    database = urlparse(args.maria).path.strip("/")

    source = sqlite3.connect(args.sqlite)
    source.row_factory = sqlite3.Row

    print(f"from {args.sqlite}")
    print(f"to   {args.maria}\n")

    target = connect(args.maria)
    with target.cursor() as cursor:
        cursor.execute(f"CREATE DATABASE IF NOT EXISTS `{database}` "
                       "CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci")
        cursor.execute(f"USE `{database}`")
        for table in TABLES:
            cursor.execute(CREATE[table])
    target.commit()

    total = 0
    for table in TABLES:
        rows = [dict(r) for r in source.execute(f"SELECT * FROM {table}")]
        print(f"{table:14} {len(rows)} fila(s)")

        if args.apply and rows:
            columns = ", ".join(f"`{name}`" for name in rows[0])
            marks = ", ".join(["%s"] * len(rows[0]))

            # One statement per row rather than a multi-row VALUES. pymysql
            # escapes a *list* of tuples as a single operand, so a multi-row
            # insert comes out as one malformed row instead of many -- and with
            # a one-row table that fails as "Operand should contain 1 column(s)",
            # which points at the schema rather than at the driver.
            statement = f"INSERT INTO `{table}` ({columns}) VALUES ({marks})"
            try:
                with target.cursor() as cursor:
                    cursor.execute(f"SELECT COUNT(*) AS n FROM `{table}`")
                    already = cursor.fetchone()["n"]
                    if already:
                        print(f"  skipped: {table} already has {already} row(s); "
                              "truncating it first would orphan everything that "
                              "references these ids")
                        continue
                    for row in rows:
                        cursor.execute(statement, convert_row(row))
                target.commit()
            except Exception as error:
                # Name the table and the row: "Operand should contain 1
                # column(s)" with no context is unfollowable.
                raise SystemExit(
                    f"failed on {table}: {error}\n"
                    f"  columns: {columns}\n"
                    f"  first row: {rows[0]!r}") from error
        total += len(rows)

    print(f"\n{total} fila(s) en total")

    if args.apply:
        print("\napplied. The SQLite file is untouched -- delete it yourself "
              "once you have signed in on the new store.")
        print("Next: point Bun at MariaDB (see web/src/lib/server/db/client.ts) "
              "and set RTE_DB_URL.")
    else:
        print("\ndry run; pass --apply to write")

    source.close()
    target.close()
    return 0


if __name__ == "__main__":
    sys.exit(main())