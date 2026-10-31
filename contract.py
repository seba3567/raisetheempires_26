"""The facts this project and the web front door have to agree on.

Why this module exists
----------------------
The project runs two programs in two languages: the Python AMF0 gateway (this
side) and the SvelteKit front door in ``web/``. They meet over HTTP, over one
PostgreSQL database, and over the identity of the player. Every value that
crosses one of those seams used to be written down twice -- once per language
-- with nothing that checked the two copies still matched.

That is not a style problem. The front door bound port 3000 while the origin
compiled into its build said 8080, so every page loaded and every form was
refused with 403 "Cross-site POST form submissions are forbidden", the login
included, and neither language had anything to say about the disagreement.

So the values live in one place now: ``contract/runtime.json``, next to this
file. This module is the Python view of it. The web side reads the same file
through ``web/src/lib/server/config.ts``, and both test suites assert that
what each runtime resolved matches what is written there.

Environment variables still win over the file. The file is where the defaults
live, not where a deployment is configured: the gateway reads ``SAVE_STORE_PATH``
and the front door reads ``RTE_DB_URL``, and either one overrides everything
below.

The file is required, not optional. A missing contract means the two runtimes
would silently disagree about where the database is or what the player's id
header is called, and that failure surfaces as a broken game rather than as an
error -- which is exactly the class of failure this module exists to remove.
"""

from __future__ import annotations

import json
import os
import re
import sys
from pathlib import Path
from typing import Any

__all__ = [
    "CONTRACT_PATH",
    "DATABASE_NAME",
    "DATABASE_URL",
    "ENV_ALIASES",
    "ENV_DATABASE_URL",
    "ENV_GATEWAY_ORIGIN",
    "ENV_PUBLIC_ORIGIN",
    "GATEWAY_ORIGIN",
    "GATEWAY_PORT",
    "MAX_SAFE_ZID",
    "PLAYER_ROLE_HEADER",
    "PLAYER_ZID_HEADER",
    "PUBLIC_HOST",
    "PUBLIC_PORT",
    "RTE_CONTRACT_FILE_ENV",
    "ZID_DIVISOR",
    "env_value",
    "load_contract",
]

#: The environment variable that points at the contract, for a deployment that
#: keeps it somewhere other than next to the code.
RTE_CONTRACT_FILE_ENV = "RTE_CONTRACT_FILE"

#: Where the contract lives, relative to this file.
_CONTRACT_RELATIVE = Path("contract") / "runtime.json"


def _candidate_paths() -> list[Path]:
    """Every place the contract may be, most likely first.

    A frozen build (PyInstaller) puts the executable in the install directory
    and the data files next to it, so the installer's copy is found there. A
    checkout finds it next to this module. The environment can override both.
    """
    explicit = os.environ.get(RTE_CONTRACT_FILE_ENV)
    if explicit:
        return [Path(explicit)]

    candidates: list[Path] = []
    if getattr(sys, "frozen", False):
        candidates.append(Path(sys.executable).resolve().parent / _CONTRACT_RELATIVE)
    candidates.append(Path(__file__).resolve().parent / _CONTRACT_RELATIVE)
    return candidates


def _read_contract() -> dict[str, Any]:
    tried: list[str] = []
    for candidate in _candidate_paths():
        tried.append(str(candidate))
        try:
            raw = candidate.read_text(encoding="utf-8")
        except OSError:
            continue
        try:
            data = json.loads(raw)
        except json.JSONDecodeError as error:
            raise RuntimeError(
                f"The runtime contract at {candidate} is not valid JSON: {error}"
            ) from error
        if not isinstance(data, dict):
            raise TypeError(f"The runtime contract at {candidate} is not an object.")
        return data

    raise RuntimeError(
        "The runtime contract is missing. It is the single place the gateway and "
        "the web front door agree on the database, the gateway address and the "
        "player's id header, so neither can be configured without it.\n"
        "Looked in:\n  " + "\n  ".join(tried) + "\n"
        "Set RTE_CONTRACT_FILE to point at it."
    )


def load_contract() -> dict[str, Any]:
    """The raw contract, as written in ``contract/runtime.json``."""
    return _read_contract()


_CONTRACT = _read_contract()


def _section(name: str) -> dict[str, Any]:
    value = _CONTRACT.get(name)
    if not isinstance(value, dict):
        raise TypeError(f"The runtime contract has no {name!r} section.")
    return value


_database = _section("database")
_gateway = _section("gateway")
_public = _section("public")
_headers = _section("headers")
_zid = _section("zid")
_admin_paths = _section("adminPaths")
_env = _section("env")


def _require(section: dict[str, Any], key: str, where: str) -> Any:
    value = section.get(key)
    if value is None:
        raise RuntimeError(f"The runtime contract has no {where}.{key}.")
    return value


#: The database the whole project uses. The gateway keeps its saves here and
#: the front door keeps its accounts, so it is one server, not two.
DATABASE_HOST = str(_require(_database, "host", "database"))
DATABASE_PORT = int(_require(_database, "port", "database"))
DATABASE_USER = str(_require(_database, "user", "database"))
DATABASE_PASSWORD = str(_require(_database, "password", "database"))
DATABASE_NAME = str(_require(_database, "name", "database"))

#: The same URL the web front door builds, in the dialect psycopg2 wants. The
#: front door spells it ``postgres://``; ``save_engine`` rewrites the scheme
#: when it reads it, so both sides mean the same server.
DATABASE_URL = (
    f"postgresql+psycopg2://{DATABASE_USER}:{DATABASE_PASSWORD}"
    f"@{DATABASE_HOST}:{DATABASE_PORT}/{DATABASE_NAME}"
)

#: Where the AMF0 gateway listens. Loopback only: the front door is its only door.
GATEWAY_HOST = str(_require(_gateway, "host", "gateway"))
GATEWAY_PORT = int(_require(_gateway, "port", "gateway"))
GATEWAY_ORIGIN = f"http://{GATEWAY_HOST}:{GATEWAY_PORT}"

#: The front door's address. Its port has to be the port of the origin compiled
#: into its build, or every form POST is refused as a cross-site submission.
PUBLIC_HOST = str(_require(_public, "host", "public"))
PUBLIC_PORT = int(_require(_public, "port", "public"))

#: How the front door hands the signed-in account's id to the gateway.
PLAYER_ZID_HEADER = str(_require(_headers, "playerZid", "headers"))

#: How the front door declares the role of the signed-in account.
#:
#: The role is the front door's to declare: it owns the accounts and the roles,
#: the gateway owns the saves. Asking the gateway to look the role up in the
#: accounts table would make it depend on another runtime's schema -- the
#: coupling that let the two halves drift apart in the first place.
PLAYER_ROLE_HEADER = str(_require(_headers, "playerRole", "headers"))

#: The checksum is divided by this so the result is an exact integer for the
#: Flash client, which has no integer type. See ``crc64_go_iso``.
ZID_DIVISOR = int(_require(_zid, "divisor", "zid"))

#: 2**53 - 1: the largest integer a double holds exactly, and therefore the
#: largest player id the client can be told about.
MAX_SAFE_ZID = int(_require(_zid, "maxSafe", "zid"))

#: Where the contract was actually found, for the startup log.
CONTRACT_PATH = next(
    (candidate for candidate in _candidate_paths() if candidate.is_file()),
    _candidate_paths()[0],
)


def _string_list(section: dict[str, Any], key: str, where: str) -> tuple[str, ...]:
    value = section.get(key)
    if not isinstance(value, list) or not all(isinstance(item, str) for item in value):
        raise TypeError(f"The runtime contract has no {where}.{key} list of strings.")
    return tuple(value)


#: Gateway routes that change game state or expose another player's data.
#:
#: The gateway used to have no authorization of its own: the whole cheat
#: surface -- ``/list_session`` handing over every player's session id,
#: ``DELETE /save`` deleting any empire, ``/patch/...`` granting any resource
#: -- was gated only by a list of paths in the web front door, in another
#: runtime. Bind the gateway to ``0.0.0.0`` and the gate was gone.
#:
#: The gateway checks this list itself now, so the lock is on the data as well
#: as on the door. The front door reads the same list.
ADMIN_ONLY_EXACT = _string_list(_admin_paths, "exact", "adminPaths")
ADMIN_ONLY_PREFIXES = _string_list(_admin_paths, "prefixes", "adminPaths")


def is_admin_only_path(path: str) -> bool:
    """Whether a gateway path is one of the admin tools."""
    if path in ADMIN_ONLY_EXACT:
        return True
    return any(path.startswith(prefix) for prefix in ADMIN_ONLY_PREFIXES)


#: The canonical name of every environment variable both runtimes read.
#:
#: One deployment configures both halves, so a fact that crosses the seam has
#: to have one name. It used to have two: the gateway called the database
#: ``SAVE_STORE_PATH`` and the front door called it ``RTE_DB_URL``; the front
#: door called the origin ``PUBLIC_ORIGIN`` and the gateway called it
#: ``WEB_ORIGIN``. An operator who set one of each pair left the two halves
#: pointing at different places.
ENV_DATABASE_URL = str(_require(_env, "databaseUrl", "env"))
ENV_PUBLIC_ORIGIN = str(_require(_env, "publicOrigin", "env"))
ENV_GATEWAY_ORIGIN = str(_require(_env, "gatewayOrigin", "env"))


def _alias_map() -> dict[str, tuple[str, ...]]:
    raw = _env.get("aliases", {})
    if not isinstance(raw, dict):
        return {}
    return {
        str(name): tuple(str(alias) for alias in aliases)
        for name, aliases in raw.items()
        if isinstance(aliases, list)
    }


#: The deprecated names each canonical name still answers to.
ENV_ALIASES = _alias_map()


def _dot_env_candidates() -> list[Path]:
    """Where a ``.env`` file for this project may be.

    ``web/.env`` is the front door's, and it is what an operator edits. The
    root one is here for a deployment that configures the project as a whole.
    """
    root = Path(__file__).resolve().parent
    return [root / "web" / ".env", root / ".env"]


def _parse_dot_env(raw: str) -> dict[str, str]:
    """The same reading the front door does: one layer of quotes, nothing else.

    ``.env`` is not shell: there is no expansion to do and a ``#`` inside a
    value is just a ``#``.
    """
    values: dict[str, str] = {}
    for line in raw.splitlines():
        match = re.match(r"^\s*([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*)$", line)
        if not match:
            continue
        value = match.group(2).strip()
        if len(value) >= 2 and value[0] == value[-1] and value[0] in "\"'":
            value = value[1:-1]
        values[match.group(1)] = value
    return values


def _load_dot_env() -> dict[str, str]:
    for candidate in _dot_env_candidates():
        try:
            raw = candidate.read_text(encoding="utf-8")
        except OSError:
            continue
        return _parse_dot_env(raw)
    return {}


#: The project's own settings file, when there is one.
#:
#: The gateway used to read the process environment and nothing else, while the
#: front door read ``web/.env``. One deployment configures both halves, so an
#: operator who edited ``web/.env`` moved the front door and left the gateway
#: pointing somewhere else -- the gateway writing saves to a database the front
#: door never read. The file is optional: the standalone Windows player has no
#: ``web`` directory at all.
_DOT_ENV = _load_dot_env()


def env_value(name: str, environ: dict[str, str] | None = None) -> str | None:
    """The value of an environment variable, honouring its deprecated aliases.

    The order is: the process environment first, the project's ``.env``
    second. A shell that sets a variable beats a file that sets it, whichever
    name each of them uses -- that is what every tool does, and it is what
    makes "the canonical name" about the *documented* name rather than about
    which source wins.
    """
    source = os.environ if environ is None else environ

    value = source.get(name)
    if value is not None:
        return value
    for alias in ENV_ALIASES.get(name, ()):
        value = source.get(alias)
        if value is not None:
            return value

    value = _DOT_ENV.get(name)
    if value is not None:
        return value
    for alias in ENV_ALIASES.get(name, ()):
        value = _DOT_ENV.get(alias)
        if value is not None:
            return value
    return None
