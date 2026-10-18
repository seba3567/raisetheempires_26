"""Fill the uid column on rows written before it existed.

    The rebuild added ``saves.uid`` so the game can find a player by the id it
    actually uses. Rows written before that column -- every save that predates
    the rebuild -- have it NULL, and would be invisible to an invasion or a
    pillage that looked them up.

    The uid is not stored anywhere else: it lives inside the payload at
    ``user_object.userInfo.player.uid``, which is set to the account's zid on
    every ``initUser``. So the backfill decodes each row, reads it, and writes
    it back. Nothing else about the row changes.

    Safe to run twice: only rows with a NULL uid are touched.

    Usage:
        python backfill_save_uid.py                      # dry run, prints the plan
        python backfill_save_uid.py --apply              # do it
        python backfill_save_uid.py --path mariadb://... # against MariaDB
"""

from __future__ import annotations

import argparse
import sys

from save_store import Store, save_uid


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--path",
        default="instance/save.db",
        help="a database file, or a mariadb:// URL. Defaults to the SQLite store.")
    parser.add_argument(
        "--apply", action="store_true",
        help="write the column. Without it this only reports what it would do.")
    args = parser.parse_args()

    store = Store(args.path)
    pending = store.rows_without_uid()

    print(f"rows with no uid: {len(pending)}")

    updates = []
    for store_id, payload in pending:
        uid = save_uid(payload)
        if uid is not None:
            updates.append((uid, store_id))
        else:
            name = (((payload or {}).get("user_object") or {}).get("userInfo") or {})
            print(f"  skip {store_id}: no player in the save"
                  + (f" (worldName={name.get('worldName')!r})" if name else ""))

    print(f"would set {len(updates)} uid(s)")
    for uid, store_id in updates:
        print(f"  {store_id} -> uid {uid}")

    if not args.apply:
        print("\ndry run; pass --apply to write")
        return 0

    for uid, store_id in updates:
        store.set_uid(store_id, uid)

    still = store.rows_without_uid()
    print(f"\napplied. rows still without a uid: {len(still)}")
    return 1 if still else 0


if __name__ == "__main__":
    sys.exit(main())