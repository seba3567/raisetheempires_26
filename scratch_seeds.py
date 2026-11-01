"""The seeds in the saved empire.

Run from the repo root:  .venv\\Scripts\\python.exe scratch_seeds.py
"""
from __future__ import annotations

import save_store


def main() -> None:
    saves = save_store.get_saves() if hasattr(save_store, "get_saves") else []
    print("save_store exports:", [n for n in dir(save_store) if not n.startswith("_")][:20])


if __name__ == "__main__":
    main()
