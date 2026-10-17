# Development setup

How to work on Raise the Empires in 2026. The game logic is untouched legacy
Python; the tooling around it is modern and pinned.

## Requirements

- **Python 3.11+** (developed and verified on 3.12 and 3.13)
- No C compiler. The project is pure Python on purpose — see
  [Why `libscrc` is gone](#why-libscrc-is-gone).

## Setup

```bash
git clone https://github.com/AcidCaos/raisetheempires
cd raisetheempires

python -m venv .venv
# Windows: .venv\Scripts\activate      POSIX: source .venv/bin/activate

pip install -U pip
pip install -e ".[dev]"
```

`pyproject.toml` is the single source of truth for dependencies. The old
`requirements.txt` and `.coveragerc` were removed; their settings now live in
`[project]`, `[tool.coverage]` and friends.

## Everyday commands

| Task | Command |
| --- | --- |
| Run the tests | `pytest` |
| Only the AMF gateway end-to-end tests | `pytest test/test_gateway_e2e.py` |
| Tests with coverage | `pytest --cov=. --cov-report=html` |
| Lint | `ruff check .` |
| Auto-fix safe lint issues | `ruff check . --fix` |
| Format (not enforced in CI yet) | `ruff format .` |
| Type-check | `mypy` |
| Run the server | `python empires-server.py` |
| Build a Windows binary | `pip install ".[build]"` then see `build-tools/README.md` |

`conftest.py` at the repo root puts the project on `sys.path`, so `pytest`
works from a clean checkout. You no longer need to export `PYTHONPATH`.

## The browser problem, and what replaces it

The Flash client reaches the server over AMF remoting through
`NetConnection.connect()`. **Ruffle does not implement that method** — it is
listed as a missing member at <https://ruffle.rs/compatibility/avm2> — so
loading the game in a browser with Ruffle renders the UI but every server call
fails with `Error #2126: NetConnection object must be connected`. No Ruffle
config flag changes that, and none of the SWF variants shipped in this repo
avoid `NetConnection`.

`test/test_gateway_e2e.py` is therefore the substitute for clicking through the
game. It boots the **real Flask app** against a throwaway SQLite database and
drives `post_gateway` over the real gateway URL with **real AMF0 bytes**, the
same way the client encodes them:

- `TestGatewayProtocol` — envelope invariants for every call
- `TestPlayerBootstrap` — `UserService.initUser`, zid stability, world generation
- `TestFleetLifecycle` — `WorldService.addFleet`
- `TestWorldActions` — `WorldService.performAction` mutating the world
- `TestStartupServices` — the social calls fired at boot

When you change an engine, run this file. If it passes, the client contract is
intact even though no browser is involved.

To see the game itself, you still need real Flash via NPAPI (Basilisk +
Flash Player 32.0.0.371 from the Internet Archive) and the `/nodebug.html`
page — see `FLASH.md`. `/ruffle.html` is still useful for the UI and assets.

## Tooling decisions

**ruff** replaces the disabled flake8 step from the old CI. The rule set is
deliberately split:

- **Enabled and enforced** — `F` (pyflakes), `E7` (comparisons), `B` (bugbear),
  `I` (import order), `UP` (pyupgrade), `SIM`, `RET`, `RUF`. These catch real
  defects; two genuine bugs were found and fixed this way (a late-binding
  closure in `mod_engine.py` and an implicit `None` return in
  `battle_engine.get_adjacent_factor`).
- **Ignored with a written reason** — see `ignore = [...]` in
  `pyproject.toml`. The star imports in `empires-server.py`, the 127
  same-arm `if/elif` pairs and the `os.path`→`pathlib` migration are all real
  work, deferred to a phase 2 so this pass stays reviewable.

**mypy** runs in permissive mode over the engines and in `--strict` mode over
new modules. The engines index schema-less JSON/msgpack payloads, so a strict
pass would drown in false positives. Tighten per module in the
`[[tool.mypy.overrides]]` table as code gains annotations.

**CI** (`.github/workflows/python-app.yml`) tests on a 3.12/3.13 matrix, runs
ruff and mypy as separate steps, and keeps the existing Windows build,
installer and release jobs intact.

## Why `libscrc` is gone

The project used `libscrc.iso()` to derive the player's `zid`. Two problems:

1. **`libscrc` ships no wheels** — only a source distribution, so installing it
   requires a C compiler (MSVC on Windows, gcc elsewhere). It was the single
   reason this project could not be installed cleanly.
2. **The name lies.** `iso` is registered on libscrc's **CRC-64** module, not
   CRC-32: poly `0x1B`, init/xorout all-ones, reflected — CRC-64/GO-ISO.
   Substituting `zlib.crc32` silently changes every `zid` and invalidates
   existing saves.

`crc64_go_iso.py` reimplements it in ~40 lines of pure Python. `test/test_crc64.py`
pins the published check value, cross-checks the table against a table-free
reference implementation, and asserts the `zid` the rest of the suite already
hardcodes. **Do not "simplify" it to `zlib.crc32`.**

## Layout

| Path | Purpose |
| --- | --- |
| `empires-server.py` | Flask app and AMF gateway (2.4k lines, entry point) |
| `battle_engine.py` | Combat resolution |
| `quest_engine.py`, `state_machine.py` | Quest progression |
| `game_settings.py` | Game data loading and lookups |
| `save_engine.py` | SQLite session storage and save validation |
| `mod_engine.py` | Mod loading (xmldiff / jsonpatch) |
| `crc64_go_iso.py` | `zid` checksum — typed and strict-checked |
| `test/` | pytest suite (`*_test.py`, legacy naming) |

## Adding tests

Name them `*_test.py` to match the existing suite, or `test_*.py` (both are
configured). `test/` already contains a `RaiseTheEmpires.ini`, so tests run
without touching a real install.