"""Move the saved games from SQLite into MariaDB.

Why this exists
---------------
The rebuild made MariaDB the only store, and the sessions that were already on
disk were never copied across. Switching the server over without this means
every player opens a new game: the old rows are still in the SQLite file,
untouched and unreachable, and ``/list_session`` answers an empty list.

It is written to be re-runnable. A save that is already in MariaDB at the same
revision is skipped, so running it twice does not duplicate or overwrite
anything, and a save whose store id already exists *at a different revision* is
reported rather than silently replaced -- overwriting would be the exact thing
this project spent the rebuild preventing.

Usage:
    python migrate_saves.py                                   # dry run
    python migrate_saves.py --from instance/save.db --apply
"""

from __future__ import annotations

import argparse
import sqlite3
import sys

from save_store import Store


def read_sqlite(path: str) -> list[tuple[str, int, bytes]]:
    """(store_id, revision, payload) for every save in the SQLite database.

    Both tables are read. The rebuild writes to ``saves`` with a revision, but a
    database that has been through it part-way holds the real empires in the
    legacy ``sessions`` table while ``saves`` has only the empty anonymous
    sessions written since. Reading ``saves`` alone copies four 36-byte rows and
    leaves every actual world behind, which is what a first dry run here did.

    ``saves`` wins where both have the same store id -- it carries the revision,
    which is what the compare-and-swap check downstream needs.
    """
    connection = sqlite3.connect(path)
    try:
        found: dict[str, tuple[int, bytes]] = {}

        try:
            for store_id, revision, blob in connection.execute(
                    "SELECT store_id, revision, data FROM saves WHERE data IS NOT NULL"):
                if blob and _has_empire(blob):
                    found[store_id] = (revision, blob)
        except sqlite3.OperationalError:
            print("no 'saves' table; reading the legacy 'sessions' table only")

        legacy = 0
        for store_id, blob in connection.execute(
                "SELECT session_id, data FROM sessions WHERE data IS NOT NULL"):
            if not blob or not _has_empire(blob):
                continue
            legacy += 1
            found.setdefault(store_id, (1, blob))

        if legacy:
            print(f"{legacy} save(s) came from the legacy 'sessions' table "
                  f"(no revision; stored as 1)")

        return [(store_id, revision, blob)
                for store_id, (revision, blob) in sorted(found.items())]
    finally:
        connection.close()


def _has_empire(blob: bytes) -> bool:
    """Whether a legacy row holds a real save rather than an empty session."""
    import msgspec

    try:
        data = msgspec.msgpack.decode(bytes(blob))
    except Exception:
        return False
    user_object = data.get("user_object") if isinstance(data, dict) else None
    return isinstance(user_object, dict) and bool(user_object.get("userInfo"))


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--from", dest="source", default="instance/save.db",
                        help="the SQLite database to read")
    parser.add_argument("--to", dest="target", required=True,
                        help="mariadb://user:password@host:port/database")
    parser.add_argument("--apply", action="store_true",
                        help="write to MariaDB; without it, only report")
    args = parser.parse_args()

    rows = read_sqlite(args.source)
    store = Store(args.target)

    print(f"from {args.source}")
    print(f"to   {args.target}\n")
    print(f"{len(rows)} save(s) found\n")

    copied = 0
    conflicts = 0
    skipped = 0

    for store_id, revision, blob in rows:
        existing = store.load(store_id)
        if existing is not None:
            if existing.revision == revision:
                skipped += 1
                print(f"  skip     {store_id}  (already there, revision {revision})")
            else:
                conflicts += 1
                print(f"  CONFLICT {store_id}  (sqlite revision {revision}, "
                      f"mariadb revision {existing.revision}) -- not touched")
            continue

        if args.apply:
            import msgspec
            store.store(store_id, msgspec.msgpack.decode(bytes(blob)),
                        reason="migrated from sqlite")
        copied += 1
        print(f"  {'copied' if args.apply else 'would copy'} {store_id}  "
              f"({len(blob):,} bytes)")

    print(f"\ncopied {copied}, skipped {skipped}, conflicts {conflicts}")

    if not args.apply:
        print("\ndry run; pass --apply to write")
    elif conflicts:
        print("\nSome rows were left alone on purpose. Look at them before "
              "deciding which version is the real one.")
    return 0


if __name__ == "__main__":
    sys.exit(main())