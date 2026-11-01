"""Look for the client's random generator in the SWF.

Run from the repo root:  .venv\\Scripts\\python.exe scratch_swf.py 36969
"""
from __future__ import annotations

import re
import sys
import zlib
from pathlib import Path

SWF = Path("assets/ZGame.109338.swf")
raw = SWF.read_bytes()
body = zlib.decompress(raw[8:]) if raw[:3] == b"CWS" else raw[8:]

PRINTABLE = re.compile(rb"[ -~]{3,}")
needle = sys.argv[1].encode("ascii")
span = int(sys.argv[2]) if len(sys.argv) > 2 else 900

for match in PRINTABLE.finditer(body):
    if needle in match.group(0):
        start = max(0, match.start() - span)
        end = min(len(body), match.end() + span)
        print(f"===== {match.group(0).decode()} @ {match.start()} =====")
        for other in PRINTABLE.finditer(body[start:end]):
            print("  " + other.group(0).decode("ascii", "replace"))
        print()
