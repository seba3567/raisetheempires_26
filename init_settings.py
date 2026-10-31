import argparse
import sys

import contract

debug: bool = False
host: str = '127.0.0.1'  # host to listen on 0.0.0.0 for all interfaces, 127.0.0.1 for only localhost
http_host: str = '127.0.0.1'  # host to open on the webbrowser, can't be 0.0.0.0
http_path: str = ''  # in order to open a specific page on startup
# The port the gateway listens on. It comes from the runtime contract, which is
# where the front door reads it from too: the two halves have to agree about
# where the gateway is, or the front door proxies into the void.
port: int = contract.GATEWAY_PORT
open_browser: bool = True
crash_log: bool = True
compression: bool = True
caching: bool = True
app_mode: bool = True


def read_ops() -> None:
    global host, port, http_host, http_path, debug, open_browser, crash_log, compression, caching, app_mode
    parser = argparse.ArgumentParser(description="RaiseTheEmpires server options", add_help=False)
    parser.add_argument("--host", default=host, help="Host to listen on")
    parser.add_argument("--port", type=int, default=port, help="Port to listen on")
    parser.add_argument("--http-host", default=http_host, help="Host to open in browser")
    parser.add_argument("--http-path", default=http_path, help="Path to open in browser")
    parser.add_argument("--debug", action="store_true", default=debug, help="Enable debug mode")
    parser.add_argument("--no-popup", dest="open_browser", action="store_false", help="Disable browser popup")
    parser.add_argument("--no-crash-log", dest="crash_log", action="store_false", help="Disable crash log editor")
    parser.add_argument("--no-compression", dest="compression", action="store_false", help="Disable HTTP compression")
    parser.add_argument("--no-caching", dest="caching", action="store_false", help="Disable cache")
    parser.add_argument("--no-app_mode", dest="app_mode", action="store_false", help="Disable app mode")

    try:
        args, _ = parser.parse_known_args(sys.argv[1:])
    except Exception as e:
        print("Error parsing options:", e)
        sys.exit(1)

    host = args.host
    port = args.port
    http_host = args.http_host
    http_path = args.http_path
    debug = args.debug
    if args.open_browser is not None:
        open_browser = args.open_browser
    if args.crash_log is not None:
        crash_log = args.crash_log
    if args.compression is not None:
        compression = args.compression
    if args.caching is not None:
        caching = args.caching
    if args.app_mode is not None:
        app_mode = args.app_mode
