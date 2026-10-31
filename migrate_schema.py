"""Bring an existing PostgreSQL save database up to the current schema.

    ``CREATE TABLE IF NOT EXISTS`` creates a table that is missing and leaves
    one that already exists alone. This script applies incremental schema changes
    safely and idempotently.

    Usage:
        python migrate_schema.py --path postgresql://...          # dry run
        python migrate_schema.py --path postgresql://... --apply
"""

from __future__ import annotations

import argparse
import sys

from save_store import Store, save_uid

COLUMNS = [
    ("saves", "uid",
     "ALTER TABLE saves ADD COLUMN IF NOT EXISTS uid BIGINT NULL"),
]

INDEXES = [
    ("idx_saves_uid", "saves (uid)"),
]


def table_columns(store: Store, table: str) -> set[str]:
    connection = store._connect()
    try:
        rows = store._exec(
            connection,
            "SELECT column_name AS name FROM information_schema.columns "
            "WHERE table_schema = 'public' AND table_name = %s",
            (table,)).fetchall()
        return {str(row["name"]) for row in rows}
    finally:
        connection.close()


def index_names(store: Store) -> set[str]:
    connection = store._connect()
    try:
        rows = store._exec(
            connection,
            "SELECT indexname AS name FROM pg_indexes WHERE schemaname = 'public'").fetchall()
        return {str(row["name"]) for row in rows}
    finally:
        connection.close()


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--path", required=True,
                        help="postgresql+psycopg2://user:password@host:port/database")
    parser.add_argument("--apply", action="store_true",
                        help="run the statements; without it, only report them")
    args = parser.parse_args()

    store = Store(args.path)
    applied: list[str] = []
    skipped: list[str] = []

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
        ddl = f"CREATE INDEX IF NOT EXISTS {name} ON {target}"
        applied.append(ddl)
        if args.apply:
            connection = store._connect()
            try:
                store._exec(connection, ddl)
            finally:
                connection.close()

    if "uid" in table_columns(store, "saves") or args.apply:
        try:
            missing_rows = store.rows_without_uid()
        except Exception:
            missing_rows = []
        backfilled = 0
        for store_id, payload in missing_rows:
            uid = save_uid(payload)
            if uid is not None:
                backfilled += 1
                if args.apply:
                    store.set_uid(store_id, uid)
        if backfilled:
            applied.append(f"backfill saves.uid on {backfilled} row(s)")
        else:
            skipped.append("saves.uid backfill (no rows missing uid)")

    for line in applied:
        print(("applied: " if args.apply else "would run: ") + line)
    for line in skipped:
        print("skipped: " + line)
    return 0


if __name__ == "__main__":
    sys.exit(main())
