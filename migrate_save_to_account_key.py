"""Put a save on its account's key, or bring one back from a backup.

Why
---
``account_saves.py`` now keys the session row by the account instead of by the
sid in the browser's ``session`` cookie. That means the save has to live under
``session:acct<zid>``. This script does that, in both directions:

``--move``          rename the row that is already in the database
``--restore-from``  copy the matching row out of another save.db first

Both paths can also rewrite the player id on the way (``--as``), because a save
taken before the account rename still answers to the old uid and the game
compares ``player.uid`` against the id the front door hands it.

What is safe to move
--------------------
The row is one record holding the whole world, including the nested ``backup``
chain. Nothing inside the payload is keyed by session id -- the save's own
self-references are keyed by ``uid`` -- so renaming the row's key moves the
save and its whole history together.

Nothing here imports the Flask app: the payload is plain msgpack and the
server's own encoder is ``msgspec.msgpack.Encoder`` with no hook, so decoding
and re-encoding it here is byte-compatible without booting the game.
"""

from __future__ import annotations

import argparse
import shutil
import sqlite3
import sys
from datetime import datetime
from pathlib import Path

import msgspec

# init_settings populates save_engine.config; game_settings reaches mod_engine,
# which reads that config at import time. Without this the import dies on
# KeyError: 'InstallFolders'.
import init_settings  # noqa: F401
from account_saves import account_store_id
from game_settings import MAX_SAFE_ZID

DECODER = msgspec.msgpack.Decoder()
ENCODER = msgspec.msgpack.Encoder()


def rename(node, old: int, new: int):
    """Replace every reference to `old` with `new`, keys included.

    Key rename matters as much as the value rename: `fleets` is keyed by
    `fleet<N>_<uid>` and `pvp.invaders` by `u<uid>`, so a value-only rewrite
    makes those lookups miss and the player's own armies vanish weeks later.
    """
    if isinstance(node, dict):
        return {
            (key.replace(str(old), str(new)) if isinstance(key, str) and str(old) in key else key):
            rename(value, old, new)
            for key, value in node.items()
        }
    if isinstance(node, list):
        return [rename(item, old, new) for item in node]
    if node == old:
        return new
    if isinstance(node, str) and str(old) in node:
        return node.replace(str(old), str(new))
    return node


def count_refs(node, old: int) -> int:
    if isinstance(node, dict):
        return sum(
            (1 if isinstance(k, str) and str(old) in k else 0) + count_refs(v, old)
            for k, v in node.items()
        )
    if isinstance(node, list):
        return sum(count_refs(item, old) for item in node)
    if node == old:
        return 1
    if isinstance(node, str) and str(old) in node:
        return 1
    return 0


def player_of(save) -> dict:
    if not isinstance(save, dict):
        return {}
    return ((save.get("user_object") or {}).get("userInfo") or {}).get("player") or {}


def backup_depth(save) -> int:
    depth = 0
    node = save
    while isinstance(node, dict) and "backup" in node:
        depth += 1
        node = node["backup"]
    return depth


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--db", default="instance/save.db", help="live database")
    parser.add_argument("--match", type=int, required=True,
                        help="player uid whose save to adopt")
    parser.add_argument("--as", dest="as_zid", type=int, default=None,
                        help="account id to file it under and rewrite uid to "
                             "(default: the matched uid)")
    parser.add_argument("--restore-from", default=None,
                        help="another save.db to read the save out of")
    parser.add_argument("--apply", action="store_true",
                        help="write; without it, only report")
    args = parser.parse_args()

    live = Path(args.db).resolve()
    if not live.exists():
        print(f"no existe {live}", file=sys.stderr)
        return 1

    zid = args.as_zid if args.as_zid is not None else args.match
    if not 0 < zid <= MAX_SAFE_ZID:
        print(f"zid {zid} fuera de rango", file=sys.stderr)
        return 2

    origin = Path(args.restore_from).resolve() if args.restore_from else live
    if not origin.exists():
        print(f"no existe {origin}", file=sys.stderr)
        return 1

    src = sqlite3.connect(origin)
    try:
        rows = src.execute("SELECT session_id, data, expiry FROM sessions").fetchall()
        label = "respaldo" if args.restore_from else "base"
        print(f"{live}: {sqlite3.connect(live).execute('SELECT COUNT(*) FROM sessions').fetchone()[0]} fila(s)")
        print(f"{label} : {origin} ({len(rows)} fila(s))\n")

        found = []
        for session_id, blob, expiry in rows:
            save = DECODER.decode(blob)
            player = player_of(save)
            hit = player.get("uid") == args.match
            print(
                f"  {session_id:56s} uid={player.get('uid')!s:>18} "
                f"nivel={player.get('level')!s:>5} xp={player.get('xp')!s:>9} "
                f"resp={backup_depth(save):>4} {len(blob):>9}b{' <== adopta' if hit else ''}"
            )
            if hit:
                found.append((session_id, blob, expiry, save))

        if not found:
            print(f"\ninguna fila de {label} tiene el uid {args.match}; no se toca nada.")
            return 1
        if len(found) > 1:
            print(f"\n{len(found)} filas coinciden: es ambiguo, no se toca nada.")
            return 1

        session_id, blob, expiry, save = found[0]
        player = player_of(save)
        print(f"\nadopta  : {session_id}")
        print(f"  mundo  : {(save.get('user_object') or {}).get('userInfo', {}).get('worldName')}")
        print(f"  xp     : {player.get('xp')}")
        print(f"  resp.  : {backup_depth(save)}")

        if args.match == zid:
            payload = blob
            print(f"\n  el uid ya es el de la cuenta ({zid}); solo se mueve la fila")
        else:
            refs = count_refs(save, args.match)
            payload = ENCODER.encode(rename(save, args.match, zid))
            left = count_refs(DECODER.decode(payload), args.match)
            if left:
                print(f"\nERROR: quedan {left} referencias al uid viejo; no escribo")
                return 1
            print(f"\n  uid {args.match} -> {zid}")
            print(f"  referencias renombradas: {refs}")
            print(f"  referencias nuevas al uid de la cuenta: {count_refs(DECODER.decode(payload), zid)}")
            print(f"  releido ok: {player_of(DECODER.decode(payload)).get('uid') == zid}")

        target = "session:" + account_store_id(zid)
        print(f"  destino: {target}")

        if not args.apply:
            print("\n(dry run: vuelve a pasarlo con --apply)")
            return 0

        stamp = datetime.now().strftime("%Y%m%d-%H%M%S")
        copy = live.with_name(f"save.db.pre-account-move-{stamp}")
        shutil.copy2(live, copy)
        print(f"\nrespaldo : {copy}")

        con = sqlite3.connect(live, isolation_level=None, timeout=10)
        try:
            con.execute("BEGIN IMMEDIATE")
            existing = con.execute(
                "SELECT session_id FROM sessions WHERE session_id = ?", (target,)
            ).fetchone()
            if existing:
                # Never overwrite a save that is already filed on the account
                # without keeping it: it may be newer than what is arriving.
                parked = f"{target}.replaced-{stamp}"
                con.execute(
                    "UPDATE sessions SET session_id = ? WHERE session_id = ?",
                    (parked, existing[0]),
                )
                print(f"la cuenta ya tenia fila; queda en {parked}")

            if args.restore_from:
                con.execute(
                    "INSERT INTO sessions (session_id, data, expiry) VALUES (?, ?, ?)",
                    (target, payload, expiry),
                )
            elif existing:
                con.execute(
                    "UPDATE sessions SET data = ? WHERE session_id = ?", (payload, target)
                )
            else:
                con.execute(
                    "UPDATE sessions SET session_id = ?, data = ? WHERE session_id = ?",
                    (target, payload, session_id),
                )
            con.execute("COMMIT")

            for check_id, check_blob in con.execute("SELECT session_id, data FROM sessions"):
                p = player_of(DECODER.decode(check_blob))
                print(f"  verificacion: {check_id:56s} uid={p.get('uid')} nivel={p.get('level')}")
        finally:
            con.close()
        print("\nlisto.")
        return 0
    finally:
        src.close()


if __name__ == "__main__":
    sys.exit(main())