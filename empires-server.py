from __future__ import annotations

import os
import webbrowser

import msgspec
from flask_session.base import MsgSpecSerializer

os.environ["PBR_VERSION"] = '5.4.3'
import init_settings as settings
from single_instance import SingleInstance

if __name__ == '__main__':
    settings.read_ops()

if not settings.debug and __name__ == '__main__':
    # Only the launcher takes this lock. A production server imports this
    # module by name in every worker (see wsgi.py), and each of those workers
    # would otherwise contend for a lockfile the parent already holds and die
    # on startup -- granian reports it as "Unexpected exit from worker-1".
    #
    # Flavour the lock by port, so "one instance" means one per port rather
    # than one per machine. Two gateways on different ports are two different
    # services -- useful for a staging instance, and for driving a throwaway
    # copy of this server without stopping the real one.
    me = SingleInstance(flavor_id=str(settings.port))

if os.name == 'nt':
    os.system('color')

import random
import threading  #, webbrowaser
import time
import xml.etree.ElementTree as ET
from builtins import print
from datetime import timedelta

# Named explicitly rather than inherited through a star import: the asset routes
# build paths with it, and a `from quest_engine import *` that happens to
# re-export Path is not something to rely on when that import list changes.
from pathlib import Path

from flask import (
    Flask,
    g,
    jsonify,
    make_response,
    request,
)

import admin_gate
from account_saves import AccountBoundSession
from battle_engine import (
    BattleContext,
)
from empires_gateway.amf import dispatch as _amf_dispatch

# The HTTP surface moved into the package.
from empires_gateway.routes.catalog import (
    get_avail_motds,
)
from logger import init_socketio, socketio
from quest_engine import *
from save_engine import (
    _crash_editor_allowed,
    base_path,
    db,
    log_path,
    logger,
    my_games_path,
    save_store_url,
    set_crash_log,
)

# save_invaders reads the invasion map out of a save without raising on one that
# never had it. It lives with the other save-shape readers in save_store, which
# imports no Flask, so pulling it from there cannot cycle.
from serve import serve
from state_machine import *

try:
    from flask_compress import Compress
except ImportError as error:
    print("Warning: compression can't be initialized. Compression is disabled.", error)
    compression = False

# import logging.config

version = "0.08a.2026_08_13"
release_date = 'Friday, 24 February 2026'

COMPRESS_MIMETYPES = ['text/html', 'text/css', 'text/xml', 'application/json', 'application/javascript',
                      'application/x-amf']
COMPRESS_LEVEL = 6
COMPRESS_MIN_SIZE = 500

# starting seeds
rand_seed_w = 5445  # very random
rand_seed_z = 844

compress = Compress() if settings.compression else None
# AccountBoundSession, not Session: it files each save under the account id
# rather than under the session cookie, so signing in on a second browser opens
# the same empire instead of a fresh one. See account_saves.py.
sess = AccountBoundSession()


start = datetime.now()
app_base_path = base_path()
app: Flask = Flask(__name__, root_path=app_base_path)

print("Root folder", app.root_path)
print("Instance folder", app.instance_path)
app.config['SESSION_TYPE'] = 'sqlalchemy'
# Both keys get the same URL, and both point at PostgreSQL 18. The sessions table
# belongs to flask-session and is never written to -- SaveStoreSessionInterface
# overrides every read and write -- but Flask-SQLAlchemy still needs a valid URI
# to attach to. Pointing it at PostgreSQL rather than a save.db on disk means there
# is no second store left on the machine that can quietly disagree with the real
# one, which is exactly what a 10 MB save.db nobody remembered was.
app.config['SAVE_STORE_PATH'] = save_store_url()
app.config['SQLALCHEMY_DATABASE_URI'] = save_store_url()


@app.before_request
def mark_request_start():
    """Flask's Request has no start time, so one is taken here."""
    g.rte_started = time.perf_counter()


@app.after_request
def log_request(response):
    """One line per request, the way Werkzeug used to do it by itself.

    Werkzeug only logs requests while *it* is the server: ``log_request`` is
    called by its own WSGI request handler, so the moment the gateway moved to
    Granian or Waitress -- both of which serve the WSGI app directly -- every
    access line stopped. Nothing was lost from the application log; what was
    lost was the traffic. ``log.txt`` went quiet at the last request of the old
    Werkzeug run and then just sat there holding that day's errors, which reads
    exactly like a server that is still crashing and has been for twenty hours.

    Application errors were never affected -- they go through ``logger.error``
    and still land in the file. This restores the other half.
    """
    elapsed = (time.perf_counter() - g.get("rte_started", time.perf_counter())) * 1000
    logger.info("%s %s -> %s in %.1fms",
                request.method, request.full_path.rstrip("?"),
                response.status_code, elapsed)
    return response
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False # Flask-SQLAlchemy has its own event notification system that gets layered on top of SQLAlchemy. To do this, it tracks modifications to the SQLAlchemy session. This option disables the modification tracking system.
app.config['SESSION_SQLALCHEMY'] = db
app.config['SESSION_COOKIE_HTTPONLY'] = False
#app.config['SESSION_SERIALIZATION_FORMAT '] = 'json' # flask-session uses msgspec by default now which makes it undepickleable
app.config['MAX_FORM_MEMORY_SIZE'] = 5 * 1024 * 1024  # 5 MB
# MAX_FORM_MEMORY_SIZE only bounds the parts of a *form* body that Flask parses
# into memory. The AMF0 gateway posts `application/x-amf`, which is not a form
# content type, so that limit never applied to it: the proxy's own limit was the
# only one, and the two were set in different files with different values.
# MAX_CONTENT_LENGTH bounds the body as it arrives, whatever its type, so the
# gateway's limit is the one that holds.
# The HTTP surface lives in the package now.
from empires_gateway import assets as _asset_routes
from empires_gateway.routes import catalog as _catalog_routes
from empires_gateway.routes import editor as _editor_routes
from empires_gateway.routes import json_api as _json_api_routes
from empires_gateway.routes import tools as _tools_routes

app.register_blueprint(_catalog_routes.bp)
app.register_blueprint(_editor_routes.bp)
app.register_blueprint(_json_api_routes.bp)
app.register_blueprint(_tools_routes.bp)
app.register_blueprint(_asset_routes.bp)

# The AMF protocol lives in the package now.
app.register_blueprint(_amf_dispatch.bp)
app.config['MAX_CONTENT_LENGTH'] = 5 * 1024 * 1024  # 5 MB
app.permanent_session_lifetime = timedelta(weeks=520)


@app.before_request
def admin_tools_need_an_admin():
    """The second lock on the admin tools.

    The front door gates these paths too (see ``web/src/lib/access.ts``), but
    that gate lives in another runtime, and the gateway used to have no lock of
    its own at all: ``/list_session`` handed over every player's session id,
    ``DELETE /save`` deleted any empire, and ``/patch/...`` granted any
    resource to whoever asked.

    The list of paths is written down once, in ``contract/runtime.json``, and
    both runtimes read it. This side is the one that matters: the lock on the
    data, rather than only on the door.
    """
    if not admin_gate.is_admin_tool(request.path):
        return None
    if admin_gate.caller_is_admin():
        return None
    return jsonify({"success": False, "error": "Admin only"}), 403

# MIN_ADMIN_ID = -1
# STEELE_ID = -1
# MAX_ADMIN_ID = 123

@app.route("/motd.json")
def motd_state():
    """The Message of the Day art, for the loading screen.

    The 2013 player drew a random one of 139 and painted it behind the EA frame
    while the game booted. ``templates/ruffle.html`` did it inline; this is the
    same data as JSON so the SvelteKit player can do it without the template.

    Both the catalogue and the pick are sent: the pick so the page has something
    to show on the first paint without asking twice, and the catalogue so the
    front end can offer another without a round trip.
    """
    motds = get_avail_motds()
    return jsonify({
        "motds": motds,
        "current": random.choice(motds),
    })


@app.route("/language_editor")
def language_editor():
    tree = ET.parse("assets/29oct2012/en_US.xml")
    root = tree.getroot()
    for pkg in root:
        print(pkg.tag, pkg.attrib)
        for text in pkg:
            print("  ",text.tag, text.attrib)

    return '', 204


# @app.after_request
# def add_header(r):
#     """
#     Add headers to both force latest IE rendering engine or Chrome Frame,
#     and also to cache the rendered page for 10 minutes.
#     """
#     # r.headers["Cache-Control"] = "no-cache, no-store, must-revalidate"
#     # r.headers["Pragma"] = "no-cache"
#     # r.headers["Expires"] = "0"
#     # r.headers['Cache-Control'] = 'public, max-age=0'
#     return r

@socketio.on('message')
def handle_message(message):
    print('received message: ' + message)


@socketio.on('my event')
def handle_my_custom_event(json):
    print('received json: ' + str(json))


@socketio.on('delete_save')
def on_delete_save_socket(message):
    print("Save will be deleted after redirect " + message)


@app.errorhandler(500)
def server_error_page(error):
    """The last resort: something escaped that nothing else handled.

    Two things were wrong here and both of them hid failures rather than
    causing them.

    **It opened a text editor.** This is the 2012 desktop build's crash flow,
    inherited verbatim: `settings.crash_log` came from a command-line flag
    meant for a windowed app, so on the server every unhandled exception popped
    a Notepad on whoever's machine happened to be running it. Ninety-eight of
    them, in one session, from a single typo in this file.

    **It answered 200.** Returning a bare string from an error handler is a 200
    with `text/plain`, and thirteen characters of it. A client parsing AMF got
    `Unexpected token 'I'` and a browser got the word "wrong" on a blank page,
    neither of which says "the gateway failed". The status has to be the truth.

    The traceback goes to the log, which is the part that can actually be read
    after the fact.
    """
    logger.error("Unhandled server error", exc_info=getattr(error, "original_exc_info", None))

    if settings.crash_log and _crash_editor_allowed():
        log_file = str(Path(log_path()) / "log.txt")
        try:
            import subprocess
            subprocess.Popen(["notepad", log_file] if os.name == "nt" else ["xdg-open", log_file])
        except Exception as e:
            logger.error("Could not launch log editor: %s", e)

    # 500, not 200: the front end reads this as "the gateway is unreachable"
    # and stops, rather than trying to parse an apology as game data.
    return make_response("Internal Server Error", 500)


def enc_hook(obj):
    if isinstance(obj, BattleContext):
        return {
            "__type__": "BattleContext",
            "__v__": 1,
            "map_name": obj.map_name,
            "island": obj.island,
            "replaying": obj.replaying,
        }
    raise TypeError

def decode_objects(obj):
    if isinstance(obj, dict) and (obj.get("__type__") == "BattleContext" or obj.get("type") == "BattleContext"): #something odd going on
        return BattleContext(
            map_name=obj.get("map_name"),
            island=obj.get("island"),
            replaying=obj.get("replaying", False),
        )

    if isinstance(obj, list):
        return [decode_objects(x) for x in obj]

    if isinstance(obj, dict):
        return {k: decode_objects(v) for k, v in obj.items()}

    return obj


# The literal msgspec writes for a tagged BattleContext (see ``enc_hook`` and the
# ``tag=True`` on the struct). Used to skip the walk entirely.
BATTLE_CONTEXT_MARKER = b"BattleContext"

_original_init = MsgSpecSerializer.__init__

def serializer_init_patch(self, app, format):
    _original_init(self, app, format)

    self.encoder = msgspec.msgpack.Encoder(enc_hook=enc_hook)
    original_decode = self.decode

    def decode_wrapper(data):
        decoded = original_decode(data)

        # Only walk the tree when one is actually in there.
        #
        # decode_objects rebuilds every dict and list it visits, so a save with
        # no battle in progress was paying for a full copy of the whole
        # structure to convert zero objects. Profiling showed 932,700 calls to
        # decode_objects across 20 decodes -- about 46,000 per save -- while
        # msgspec itself took under 5% of the time. That walk was the single
        # largest cost in a gateway request.
        #
        # A BattleContext can only exist in the payload if its tag was written
        # into it, so when the marker is absent there is provably nothing to
        # convert and the decode can be returned as msgspec produced it.
        if BATTLE_CONTEXT_MARKER not in data:
            return decoded

        return decode_objects(decoded)

    self.decode = decode_wrapper

MsgSpecSerializer.__init__ = serializer_init_patch


def configure_app():
    """Wire the extensions that only exist at runtime.

    Kept out of ``__main__`` on purpose. A production server does not run this
    module as ``__main__``: granian imports it by name in each worker, so
    anything set up here would silently not run and the gateway would come up
    with no session store and no database. ``wsgi.py`` calls this; so does the
    ``__main__`` block below.

    ``init_app`` refuses to run twice on one app (the SQLAlchemy and session
    objects are module-level singletons), so this is guarded -- see wsgi.py,
    which imports the module and then calls this exactly once.
    """
    set_crash_log(settings.crash_log)
    if settings.compression:
        compress.init_app(app)
    init_socketio(app)
    db.init_app(app)
    sess.init_app(app)
    return app


def open_browser_when_ready():
    """Open the game in the bundled Chromium, or the default browser."""
    if 'WERKZEUG_RUN_MAIN' in os.environ or not settings.open_browser:
        return
    bundled = Path("chromium") / "chrome.exe"
    posix_bundled = Path("chromium") / "chrome"
    if bundled.exists():
        launch = str(bundled)
    elif posix_bundled.exists():
        launch = str(posix_bundled)
    else:
        threading.Timer(1.25, lambda: webbrowser.open(
            "http://" + settings.http_host + ":" + str(settings.port) + "/" + settings.http_path
        )).start()
        return

    threading.Timer(1.25, lambda: os.system(
        launch + " --user-data-dir=\"" + str(Path(my_games_path()) / "chromium-profile")
        + "\" --allow-outdated-plugins "
        + ("--app=" if settings.app_mode else "")
        + "http://" + settings.http_host + ":" + str(settings.port) + "/" + settings.http_path
    )).start()


if __name__ == '__main__':
    open_browser_when_ready()
    configure_app()
    serve(app, debug=settings.debug)
    # app.run(host='127.0.0.1', port=5005, debug=True)
    # logging.getLogger('socketio').setLevel(logging.ERROR)
    # logging.getLogger('engineio').setLevel(logging.ERROR)
    # logging.getLogger('geventwebsocket.handler').setLevel(logging.ERROR)