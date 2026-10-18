"""Bring an existing save database up to the current schema.

    ``CREATE TABLE IF NOT EXISTS`` creates a table that is missing and leaves
    one that already exists alone, which is right for the tables and wrong for
    the columns: a database created by an earlier build keeps the earlier shape
    and every query against a new column fails on it. That is what happened to
    the MariaDB test database when ``saves.uid`` was added.

    So the steps are listed here explicitly and applied in order. Each one is
    idempotent and each is checked against the live database before it runs, so
    running this twice is a no-op.

    Usage:
        python migrate_schema.py                          # dry run, SQLite
        python migrate_schema.py --apply
        python migrate_schema.py --path mariadb://... --apply
"""

from __future__ import annotations

import argparse
import sys

from save_store import MariaConnection, Store

# (table, column, DDL to add it). The index is a separate step because it
# depends on the column and MariaDB will not add one for a missing column.
COLUMNS = [
    ("saves", "uid",
     "ALTER TABLE saves ADD COLUMN uid BIGINT NULL"),
]

INDEXES = [
    ("idx_saves_uid", "saves (uid)"),
]


def table_columns(store: Store, table: str) -> set:
    connection = store._connect()
    try:
        if isinstance(connection, MariaConnection):
            rows = store._exec(
                connection,
                "SELECT COLUMN_NAME AS name FROM information_schema.COLUMNS "
                "WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ?",
                (table,)).fetchall()
        else:
            rows = store._exec(
                connection, f"PRAGMA table_info({table})").fetchall()
            return {row["name"] for row in rows}
        return {row["name"] for row in rows}
    finally:
        connection.close()


def index_names(store: Store) -> set:
    connection = store._connect()
    try:
        if isinstance(connection, MariaConnection):
            rows = store._exec(
                connection,
                "SELECT DISTINCT INDEX_NAME AS name FROM information_schema."
                "STATISTICS WHERE TABLE_SCHEMA = DATABASE()").fetchall()
        else:
            rows = store._exec(
                connection,
                "SELECT name FROM sqlite_master WHERE type = 'index'").fetchall()
        return {row["name"] for row in rows}
    finally:
        connection.close()


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--path", default="instance/save.db",
                        help="a database file, or a mariadb:// URL")
    parser.add_argument("--apply", action="store_true",
                        help="run the statements; without it, only report them")
    args = parser.parse_args()

    store = Store(args.path)
    applied, skipped = [], []

    for table, column, ddl in COLUMNS:
        if column in table_columns(store, table):
            skipped.append(f"{table}.{column} already exists")
            continue
        applied.append(ddl)
        if args.apply:
            connection = store._connect()
            try:
                store._exec(connection, ddl)
            finally:
                connection.close()

    existing = index_names(store)
    for name, target in INDEXES:
        if name in existing:
            skipped.append(f"index {name} already exists")
            continue
        ddl = f"CREATE INDEX {name} ON {target}"
        applied.append(ddl)
        if args.apply:
            connection = store._connect()
            try:
                store._exec(connection, ddl)
            finally:
                connection.close()

    for line in applied:
        print(("applied: " if args.apply else "would run: ") + line)
    for line in skipped:
        print("skipped: " + line)

    if not applied:
        print("\nschema is up to date")
    elif not args.apply:
        print("\ndry run; pass --apply to run these")

    return 0


if __name__ == "__main__":
    sys.exit(main())