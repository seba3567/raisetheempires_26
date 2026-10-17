"""How the gateway is actually served.

Why this is a module
--------------------
It used to be ``socketio.run(app, ..., allow_unsafe_werkzeug=True)``. That flag
is Flask-SocketIO's way of saying "you are running a development server in a
production setting" -- and its own docstring for ``run`` notes the options there
are not seen when using an external web server, because the method is not
called in that case. It was never a production entry point.

Werkzeug's development server handles one request at a time, and every request
in this game computes a battle synchronously. A player taking a turn blocks
everyone else for the duration.

The order below is deliberate:

* **Granian** (Rust, Hyper + Tokio) is the default. It is a real production
  server, it ships Windows wheels alongside Linux and macOS, and unlike
  Gunicorn -- which does not support Windows at all -- it works on the platform
  this project is developed and deployed on.
* **Waitress** is the fallback. Pure Python, zero dependencies, and it runs
  anywhere; its thread pool is smaller than Granian's worker pool but it never
  surprises you.
* **Werkzeug** is the last resort so a fresh checkout still starts without any
  extra install. It is single-threaded, so this is for development only.

Set ``RTE_SERVER`` to force one of the three.

Socket.io
---------
socket.io is still mounted, because the logger emits game events over it. It is
mounted through ``logger.init_socketio`` so the logger knows it is live and can
skip building payloads when nothing is listening -- see that module.
"""

from __future__ import annotations

import os
from pathlib import Path


def _run_granian(app, host: str, port: int) -> bool:
    """Serve with Granian. Returns False if it is not installed."""
    try:
        from granian import Granian
        from granian.constants import Interfaces
    except ImportError:
        return False

    # The target is "wsgi:app", not this module's `app` object. Granian imports
    # the target by string inside each worker, so handing it the live object
    # here would leave the workers with an unconfigured app -- no session store,
    # no database. wsgi.py does the import and the setup; see it for why the
    # hyphen in "empires-server" makes it necessary.
    Granian(
        target="wsgi:app",
        address=host,
        port=port,
        interface=Interfaces.WSGI,
        # One worker, threads inside. A battle mutates that account's session
        # row in SQLite; several worker processes would each hold their own
        # view of a session and race on the write. Threads share the store.
        workers=1,
        runtime_threads=8,
        blocking_threads=64,
        # A Path, not a str: granian calls .resolve() on it, and a string takes
        # the worker down with "'str' object has no attribute 'resolve'".
        # Also the directory granian imports "wsgi:app" from.
        working_dir=Path(__file__).resolve().parent,
    ).serve()

    return True


def _run_waitress(app, host: str, port: int) -> bool:
    """Serve with Waitress. Returns False if it is not installed."""
    try:
        from waitress import serve as waitress_serve
    except ImportError:
        return False

    waitress_serve(app, host=host, port=port, threads=16,
                   # The game posts a full battle payload and the client is on
                   # loopback, so this is generous rather than tuned.
                   max_request_body_size=64 * 1024 * 1024)
    return True


def _run_werkzeug(app, host: str, port: int, debug: bool) -> bool:
    """Serve with Werkzeug's development server. Always available.

    Single-threaded, so this is only for working on the gateway itself.
    """
    print("WARNING: serving with the Werkzeug development server.")
    print("         It handles one request at a time, so one player's turn blocks")
    print("         everyone else's. Install granian or waitress for anything else.")
    app.run(host=host, port=port, debug=debug)
    return True


def serve(app, host: str | None = None, port: int | None = None, debug: bool = False) -> None:
    """Serve ``app`` with the best available production server."""
    import init_settings as settings

    host = settings.host if host is None else host
    port = settings.port if port is None else port
    forced = (os.environ.get("RTE_SERVER") or "").strip().lower()

    runners = {
        "granian": lambda: _run_granian(app, host, port),
        "waitress": lambda: _run_waitress(app, host, port),
        "werkzeug": lambda: _run_werkzeug(app, host, port, debug),
    }

    order = [forced] if forced in runners else ["granian", "waitress", "werkzeug"]

    for name in order:
        print(f"Serving on {host}:{port} with {name}")
        runners[name]()
        return