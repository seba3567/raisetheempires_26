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

## The browser problem, and what it needed

The Flash client reaches the server over AMF remoting through
`NetConnection.connect()`. Ruffle only accepts URLs starting with `http://` or
`https://`; anything else is stubbed out and every subsequent `call()` throws
`Error #2126: NetConnection object must be connected`.

The client builds its endpoint URLs from the `app_url` FlashVar
(`GlobalEngine.parseFlashVars`). When that is absent it falls back to the
constant compiled into the SWF:

```actionscript
// Config.as
public static var BASE_PATH:String = "127.0.0.1";
public static var SERVICES_GATEWAY_PATH:String = BASE_PATH + "flashservices/gateway.php";
```

`127.0.0.1flashservices/gateway.php` is scheme-less, so Ruffle dropped the
connection. Two fixes make `/ruffle.html` fully playable:

1. **`app_url` must be passed as an absolute URL.** Note it is `app_url`, not
   `sn_app_url` — the latter feeds a different constant and does nothing for the
   gateway. `templates/ruffle.html` passes `app_url={{ request.host_url }}`.
2. **The gateway must accept both AMF array encodings.** Flash encodes arrays as
   dense AMF arrays (pyamf decodes them to lists); Ruffle encodes them as
   objects with numeric keys (`{0: ...}`). `_amf_as_list` in
   `empires-server.py` accepts both. Without it the batch comes through as a
   dict and dispatch fails with
   `AttributeError: 'int' object has no attribute 'functionName'`.

Because of this the server also registers absolute routes alongside the legacy
relative ones: `/flashservices/gateway.php`, `/record_stats.php`, `/en_US.xml`
and `/questSettings.xml`.

`test/test_gateway_e2e.py` covers the AMF protocol, and
`test_crc64.py` pins the `zid` checksum. Together they are the regression net
for changes to the gateway or the engines.

Ruffle is loaded from a **version-pinned URL with a Subresource Integrity
hash** — keep it that way. For actual play without a browser, real Flash via
NPAPI still works through `/nodebug.html` (see `FLASH.md`).

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
| `web/` | Public front end — SvelteKit 3 + Svelte 5 on Bun. See `web/README.md` |
| `empires-server.py` | Flask app and AMF gateway (2.4k lines, entry point) |
| `battle_engine.py` | Combat resolution |
| `quest_engine.py`, `state_machine.py` | Quest progression |
| `game_settings.py` | Game data loading and lookups |
| `save_engine.py` | SQLite session storage and save validation |
| `mod_engine.py` | Mod loading (xmldiff / jsonpatch) |
| `crc64_go_iso.py` | `zid` checksum — typed and strict-checked |
| `test/` | pytest suite (`*_test.py`, legacy naming) |

## Two services, and which one is public

```
navegador -> web/ (SvelteKit+Bun, :8080)  ->  empires-server.py (Flask, 127.0.0.1:5005)
              landing, cuentas, amigos,             /ruffle.html, /assets, /js,
              progreso, y el JUEGO con el            /flashservices/gateway.php
              SWF embebido en la página
```

`web/` is the only thing that should ever be exposed. It owns the landing page,
accounts, friendships, progress and the player, and proxies everything else
through to the Python gateway. See `web/README.md`.

The gateway stays in Python because the AMF0 payload dialect is a compatibility
contract with a client we cannot recompile. The practical consequence is that the
Flask dev server is never reachable from outside, so **the previously planned
app-factory and WSGI work is dropped, not deferred**. Do not start it.

Run both while developing:

```powershell
# terminal 1 — la puerta publica
cd web; bun run --bun build; bun .\build

# terminal 2 — el gateway, solo loopback
..\.venv\Scripts\python.exe empires-server.py --port 5005 --no-popup
```

## Everyday commands (web)

```powershell
cd web
bun test          # 73 tests
bun run check     # svelte-check
bun run --bun build
bun run scripts/manage-user.ts list-admins
```

## Adding tests

Name them `*_test.py` to match the existing suite, or `test_*.py` (both are
configured). `test/` already contains a `RaiseTheEmpires.ini`, so tests run
without touching a real install.