"""WSGI entry point for a production server.

Why this file exists
--------------------
``empires-server.py`` has a hyphen, so it cannot be written in an ``import``
statement. That is fine for ``python empires-server.py`` and for the test suite,
which reaches it through ``importlib`` (see test/conftest.py), but a WSGI server
takes its target as the string ``"module:attribute"`` and imports it itself.

Granian is the server this targets (see serve.py), and it imports the target in
each worker process. So the app has to come up from a *clean import*, not from
running the module as ``__main__`` -- otherwise ``db.init_app`` and
``sess.init_app`` never execute and the gateway answers every request without a
session store.

This module is that clean import. Granian is pointed at ``wsgi:app``.

    granian --interface wsgi --port 5005 wsgi:app
"""

import importlib

import init_settings

# Populates save_engine.config before anything reaches mod_engine, which reads it
# at import time. empires-server does this for its __main__ path; a worker
# importing it as a module needs it done here.
init_settings.read_ops()

server = importlib.import_module("empires-server")

# Extensions are module-level singletons inside empires-server and init_app
# refuses to run twice on one app, so this is called exactly once per process.
app = server.configure_app()