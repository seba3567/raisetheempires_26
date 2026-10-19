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
| Types | `mypy` |
| Auto-fix safe lint issues | `ruff check . --fix` |
| Format (not enforced in CI yet) | `ruff format .` |
| Type-check | `mypy` |
| Run the server | `python empires-server.py` |
| Build a Windows binary | `pip install ".[build]"` then see `build-tools/README.md` |

`conftest.py` at the repo root puts the project on `sys.path`, so `pytest`
works from a clean checkout. You no longer need to export `PYTHONPATH`.

### Restarting the gateway: kill the workers too

The gateway is served by **Granian**, not by Flask's own server (see `serve.py`;
it is also what `python empires-server.py` starts). Granian imports the app in
each worker process, so **killing the parent does not stop the workers.** They
keep the listening socket on 5005 and go on serving the code they imported at
startup.

That is worse than a stale process: the new server starts too, both bind the
same port, and on Windows the socket that was created first keeps receiving the
traffic. The symptom is a change that "did not take" — you edit the gateway, you
restart it, and the response is byte-for-byte what it was before. Two ways it
bit us: `Cache-Control` on the asset routes kept coming back `no-cache` after the
change, and `print(path)` kept appearing in the log.

So restart the gateway by killing the whole tree, not the parent:

```powershell
# every python that is part of the gateway, parents and workers alike
Get-CimInstance Win32_Process -Filter "Name='python.exe'" |
  Where-Object { $_.CommandLine -like '*empires-server*' -or
                 $_.CommandLine -like '*multiprocessing.spawn*' } |
  ForEach-Object { Stop-Process -Id $_.ProcessId -Force }
```

If a response still looks stale afterwards, check who owns the port before
trusting anything: `netstat -ano | Select-String ':5005\s+.*LISTENING'`. Several
listening entries for one port is the tell.

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
connection. Two fixes make the player fully playable:

1. **`app_url` must be passed as an absolute URL.** Note it is `app_url`, not
   `sn_app_url` — the latter feeds a different constant and does nothing for the
   gateway. `buildFlashVars()` in `web/src/lib/server/flashvars.ts` builds it
   from the public origin and appends the trailing slash the client concatenates
   against.
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

## Ruffle is vendored, not fetched

`ruffle.js` is **not a single bundle**. It is a ~666 KB loader that resolves a
WebAssembly core at runtime, under a content-hashed filename, and it derives that
name from its own URL. Copying only the loader produces a page whose entire
symptom is:

```
GET /ruffle/ruffle_web_bg.<hash>.wasm net::ERR_ABORTED 404
Serious error occurred loading SWF file: Error: Failed to load Ruffle WASM
```

So `web/static/ruffle/` holds the **whole** package from
`node_modules/@ruffle-rs/ruffle` — 8 files, 29.2 MB, two of them ~13.5 MB WASM
binaries. They are committed, not downloaded at install time and not fetched
from a CDN at runtime. An archived game cannot depend on someone else's uptime,
and a CDN re-bundle would change the loader's core filename underneath us.

The copy is pinned by content, not by URL. `ruffle.js` must keep hashing to

```
C142B01123D1FAF2E8F20687409BD2080A9FD00CD56361F6DBD2BD805E3AB8A0
```

which is what the local copy of `0.8.0-nightly.2026.10.18` hashes to. An earlier
0.7.1 layout also pulled `core.ruffle.<hash>.js`; that requirement is gone with
the bump, so a 404 naming `core.ruffle.*` means an old loader is still deployed.

To move the version, empty `web/static/ruffle/`, then copy the new package over
it and re-hash:

```powershell
cd web
bun add @ruffle-rs/ruffle@<version>
Copy-Item node_modules\@ruffle-rs\ruffle\* static\ruffle\ -Recurse -Force
```

Then confirm every file answers 200 — the `.wasm` ones **as
`application/wasm`**, because `WebAssembly.instantiateStreaming` refuses any
other content type and fails with the same "Failed to load Ruffle WASM":

```powershell
bun .\build
curl.exe -s -o NUL -w "%{http_code} %{content_type}`n" http://localhost:8080/ruffle/878d548199cddef07035.wasm
# 200 application/wasm
```

For actual play without a browser, real Flash via NPAPI still works through
`/nodebug.html` (see `FLASH.md`).

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
| `save_engine.py` | Session store wiring and save validation |
| `mod_engine.py` | Mod loading (xmldiff / jsonpatch) |
| `crc64_go_iso.py` | `zid` checksum — typed and strict-checked |
| `test/` | pytest suite (`*_test.py`, legacy naming) |

## Two services, and which one is public

```
navegador -> web/ (SvelteKit+Bun, :8080)  ->  empires-server.py (Flask, 127.0.0.1:5005)
              landing, cuentas, amigos,             /assets, /js, /ruffle.html (-> /juego),
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

That loopback-only rule is also what the identity handoff rests on. The front
door passes the signed-in account's `zid` down in `x-player-zid`, and
`get_zid()` in `game_settings.py` prefers it over the cookie derivation, which
is what makes a login stick in the game instead of the save belonging to a
cookie. The gateway trusts that header **only** because nothing else can reach
it: expose Flask on `0.0.0.0` and anyone can claim another player's empire with
a hand-written header. Same assumption as the admin gate.

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