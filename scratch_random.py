"""Last hypothesis: the client is reading the reward stream's z.

Run from the repo root:  .venv\\Scripts\\python.exe scratch_random.py
"""
from __future__ import annotations

MASK = 4294967295


def roll(z, w):
    z = (36969 * (z & 65535) + ((z >> 16) & 65535)) & MASK
    w = (18000 * (w & 65535) + ((w >> 16) & 65535)) & MASK
    return z, w


def after(start_z, start_w, n):
    z, w = start_z, start_w
    for _ in range(n):
        z, w = roll(z, w)
    return z, w


CLIENT_Z_BEFORE = 2388287871
CLIENT_Z_AFTER = 922745713
CLIENT_W_AFTER = 683648664

starts = {
    "main (844, 5445)": (844, 5445),
    "reward (7549, 484584)": (7549, 484584),
    "ransom (7549, 456647)": (7549, 456647),
    "server's now (955019746, 567841884)": (955019746, 567841884),
}

for label, (z0, w0) in starts.items():
    for n in (52, 53, 54, 55):
        z, w = after(z0, w0, n)
        marks = []
        if z == CLIENT_Z_BEFORE:
            marks.append("client's z BEFORE")
        if z == CLIENT_Z_AFTER:
            marks.append("client's z AFTER")
        if w == CLIENT_W_AFTER:
            marks.append("client's w AFTER")
        if marks:
            print(f"{label:38} after {n} draws: z={z} w={w}   {'; '.join(marks)}")
