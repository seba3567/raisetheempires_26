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

`bun .\build` answers on the port in `web/.env` (`PORT`, 8080 by default), and
that has to be the port of `PUBLIC_ORIGIN`. The Bun adapter rewrites every
request onto the origin compiled into the build, and SvelteKit rejects any
form POST whose `Origin` header names another one — so a mismatch between the
two does not look like a port problem, it looks like a broken login: every
page loads and every form answers 403. Both values come from
`web/src/lib/server/config.ts`; `web/README.md` has the detail.

### One settings file for the whole project

`web/.env` configures **both** halves. The gateway used to read the process
environment and nothing else, while the front door read `web/.env`, so an
operator who edited the file moved the front door and left the gateway
pointing somewhere else — the gateway writing saves to a database the front
door never read.

The variables are the ones in `web/.env.example`, with the same names on both
sides: `RTE_DB_URL` for the database, `PUBLIC_ORIGIN` for the origin,
`GATEWAY_ORIGIN` for the gateway's address. The names the gateway used before
(`SAVE_STORE_PATH`, `WEB_ORIGIN`) still work, but they are not written down
any more. The order is the process environment first and the file second, so
a shell that sets a variable beats the file.

`contract/runtime.json` is where those names are written down, along with
everything else the two runtimes have to agree on.

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
| `empires-server.py` | The entry point: the Flask app, the extensions, the socket.io events and nothing else |
| `empires_gateway/` | The gateway, split out of the monolith. `routes/catalog.py` (the catalogue, the player state, the neighbour list), `routes/editor.py` (the empire editor), `routes/tools.py` (the operator tools), `assets.py` (the files the client downloads), `shared.py` (the pieces both halves need), `amf/protocol.py` (the rules of the AMF0 wire), `amf/handlers/` (the game's rules, one module per domain: `player`, `battle`, `economy`, `social`, `world`, `ranking`, `units`, `promo`), `amf/dispatch.py` (the table that wires the handlers to the names the client calls, and the route that carries the batch) |
| `service_handlers.py` | The extended AMF services (clans, gifts, PVP, matchmaking) |
| `battle_engine.py` | Combat resolution |
| `quest_engine.py`, `state_machine.py` | Quest progression |
| `game_settings.py` | Game data loading and lookups |
| `save_engine.py` | Session store wiring and save validation |
| `save_store.py`, `account_saves.py` | PostgreSQL save store and account binding |
| `schema.sql` | The gateway's own tables (`saves`, `save_backups`) |
| `mod_engine.py` | Mod loading (xmldiff / jsonpatch) |
| `crc64_go_iso.py` | `zid` checksum — typed and strict-checked |
| `test/` | pytest suite (`test_*.py` and the legacy `*_test.py`) |

## The database, and who owns which table

Everything lives in one PostgreSQL 18 server, but the schema has two owners and
the split is deliberate:

| Owner | Files | Tables |
| --- | --- | --- |
| The gateway's save store | `schema.sql` | `saves`, `save_backups` |
| The web front end | `web/src/lib/server/db/migrations/*.sql` | `users`, `friendships`, `progress`, `activity`, `clans`, `clan_members`, `clan_messages`, `gifts` |

The save store applies `schema.sql` itself when it is built, and creates its
database if it is not there yet.

### The gateway reads the web's tables too

Both runtimes point at the same database, so the gateway can read what the web
wrote -- and for the parts of the game that are social, it does:

- The alliance system. `ClansService.getClanInfo`, `createClan`, `updateName`,
  `updateCrest`, `buyHealth`, `buySlots` and `postGroupFeed` work on `clans`,
  `clan_members` and `clan_messages`, so a message posted in the game lands in
  the same wall that `/amigos` shows. Before that, the gateway kept a fiction of
  its own inside the player's save -- a hardcoded id and one made-up member --
  and the two sides never agreed on anything.
- The PvP challenges, which come from `activity` and `users`.

A session is tied to a web account through the `zid`: the front door passes it
down in `x-player-zid`, and the gateway finds the matching row in `users`. A
session that never went through the front door has no account, and the
alliance handlers fall back to the copy in the save.

### Which database a helper talks to

`save_engine.save_store_url()` prefers the app's configuration over the
environment. The test suite points the app at a throwaway database, and a
helper that read the environment instead would quietly reach into the real
one -- the suite would be writing to the live database while believing it was
not.

### Two things about the connection

**The client encoding is UTF-8, and it is set explicitly.** PostgreSQL reports
errors in the server's locale and sends them in the connection's encoding,
and psycopg2 picks that encoding from the *client's* locale -- which on
Windows is cp1252. A server that speaks Spanish then answers with one stray
byte where an accent should be, and psycopg2 raises `UnicodeDecodeError`
instead of saying what went wrong. That turned "the database does not exist"
into an unreadable error about encoding.

**The suite does not hammer the store.** The cleanup between tests used to
open a fresh connection per test and delete the rows one statement at a time:
a run of the suite forked a PostgreSQL backend per test, twice over, and
flushed the WAL twice. `Store.clear()` now counts first and deletes only if
there is something to delete, and the suite holds one connection for the
whole session. Measured on the same machine, with the same PostgreSQL:

| | Before | After |
| --- | --- | --- |
| Suite time | 184 s | **119 s** |
| Connections opened | 2.097 | **1.104** |
| Transactions | 5.244 | **3.363** |

### Migrations

`web/src/lib/server/db/client.ts` applies the files in
`web/src/lib/server/db/migrations/` in filename order and records the ones it
applied in `schema_migrations`. To add a migration, drop a new file in that
directory and name it `006_something.sql` — it runs on the next start.

Each file runs inside its own transaction, together with the row that records
it. PostgreSQL's DDL is transactional, so a migration that fails leaves nothing
behind and is retried whole on the next start instead of being half-applied and
marked as done.

The files use `CREATE TABLE IF NOT EXISTS` and `ADD COLUMN IF NOT EXISTS`, so
re-running one is harmless.

> The runner used to only *record* the migrations and build the schema from an
> inline copy of the same DDL in `client.ts`. The files were never executed,
> which meant a migration added to the directory did nothing at all while still
> being marked as applied. The inline copy is gone; the files are the schema.

### The database in CI

The three jobs that need a server (`run_web_tests`, `run_tests` and
`gateway_smoke`) start the PostgreSQL that the GitHub runner image already
ships — 18.6, the version this project targets — through
`.github/actions/start-postgresql`. No container runtime is involved.

Without that, `bun test` failed on the connection for every test that touches
the database, `pytest` errored in every fixture, and `gateway_smoke` could not
even start the gateway: it builds the save store while the app is configured,
so it dies in `configure_app()` before it binds a port.

The Python suite points at its own database (`RTE_TEST_DB`) and the save
store's tests at another (`RTE_PG_TEST_URL`), so a run never wipes the tables
the other is using. Both databases are created by the suite itself.

## PostgreSQL dies on this machine

**The cluster crashes every ten to twenty minutes.** A new backend fails to
map the shared memory segment:

```
could not reserve shared memory region (addr=...) for child ...: error code 487
```

and takes the whole cluster down with it. This is PostgreSQL bug #18954 on
Windows: the *Bottom-up ASLR* mitigation, which Windows enforces on the
PostgreSQL binaries, breaks the mapping. It is not the project, and not the
configuration — it happens on a fresh cluster with any settings.

**The real fix needs administrator rights** (it writes to `HKLM`):

```powershell
Set-ProcessMitigation -Name postgres.exe -Disable BottomUp
Set-ProcessMitigation -Name pg_ctl.exe   -Disable BottomUp
```

Excluding the PostgreSQL directory from the antivirus's real-time scanning
helps too, and is worth doing either way.

Until that is applied, `watchdog_postgres.bat` keeps the cluster alive: it
watches for the crash and restarts it, which takes a few seconds and is
invisible from the game. It is a workaround for the machine, not for the
project.

### Keeping the other two alive

`watchdog_stack.bat` does the same for the gateway and the front door: it
probes both every ten seconds and restarts whichever stops answering, after
three failures in a row so a single dropped request does not start a restart
loop. A restart is survivable for both — the gateway's sessions live in
PostgreSQL and the front door's are signed cookies — so the player logs back
in and carries on.

```powershell
.\watchdog_stack.bat
```

The launcher and the watchdog are separate tools on purpose: `start_all.bat`
brings the stack up, the watchdog keeps it up. Run both, in their own windows.



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

Because `--host` can break that in one flag, the gateway says so at startup when
it is bound to anything other than loopback. It does not refuse to start -- an
operator who meant to put it on the network may know something the warning does
not -- but it does not start quietly either.

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
bun test          # 146 tests
bun run check     # svelte-check
bun run --bun build
bun run scripts/manage-user.ts list-admins
```

## Adding tests

Name them `*_test.py` to match the existing suite, or `test_*.py` (both are
configured). `test/` already contains a `RaiseTheEmpires.ini`, so tests run
without touching a real install.

## The log, and what belongs in it

`log.txt` is the gateway's own log, and it is the file to read when something
went wrong. Two rules keep it readable.

**The test suite writes to `log-test.txt`, not to `log.txt`.** Both runtimes
share one logging setup, and the suite deliberately makes handlers raise to
prove the gateway survives them. Before the split, those failures landed in
the server's log: of the 1,481 traceback lines `log.txt` carried, every one
of them pointed at a test file, and the server looked broken when it was the
suite doing its job. `RTE_LOG_FILE` chooses the file; the root `conftest.py`
sets it before the gateway is imported.

**A warning means something is wrong.** The gateway logs a lot of traffic the
client generates and the server handles: a purchase the player cannot afford,
a campaign this server does not know, an item code the catalogue does not
carry, a battle reference that has already moved on. All of those are answered
gracefully and logged at INFO, because at WARNING they drowned out the things
that needed attention. The ones left at WARNING and ERROR are the ones where
the server could not carry on:

| Level | What it means now |
| --- | --- |
| `ERROR` | The gateway could not answer, or the client and the server disagree about the state (`Battle named fleet ..., which is not registered`) |
| `WARNING` | Something was refused that a person may want to know about (a gift that could not be delivered, a save that kept colliding) |
| `INFO` | Ordinary traffic, including everything the client asks for and the server declines |

The level of a log line is a decision about how often it fires. A line that
fires on every load is not a warning, however true it is.
