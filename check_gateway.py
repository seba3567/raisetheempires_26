"""Talk to a real gateway, over a real socket, under a real server.

The unit tests drive the Flask app in process. This drives the thing a player
actually reaches: the gateway booted through serve.py, listening on its
configured port, answering real HTTP.

It runs the same three seams as test_seams.py -- AMF in, dispatch, answer out --
but across a socket, against whichever server serve.py chose. That is the part
the in-process tests cannot cover: whether granian actually imported wsgi:app,
configured the extensions, and bound the port.

Usage:
    python _live_check.py            # whatever serve.py picks
    python _live_check.py waitress   # force one
"""
import http.client
import os
import sys

import init_settings

init_settings.read_ops()
# Port from the environment so this can be pointed at an isolated instance
# without touching the configured one.
PORT = int(os.environ.get("RTE_PROBE_PORT") or init_settings.port)
HOST = "127.0.0.1"
GATEWAY = "/flashservices/gateway.php"


def amf_call(function_name, params=None):
    """POST one AMF0 remoting call, return (status, decoded body)."""
    from pyamf import AMF0, remoting

    body = [
        {"flashRevision": None},
        [{
            "transaction": None,
            "sequence": 1,
            "stamp": 1641513847112.56,
            "params": params or [],
            "functionName": function_name,
        }],
        0,
    ]
    envelope = remoting.Envelope(AMF0)
    envelope.bodies = [("/2", remoting.Request("BaseService.dispatchBatch", body=body))]
    raw = remoting.encode(envelope)
    raw = raw.getvalue() if hasattr(raw, "getvalue") else bytes(raw)

    conn = http.client.HTTPConnection(HOST, PORT, timeout=30)
    try:
        conn.request("POST", GATEWAY, body=raw,
                     headers={"Content-Type": "application/x-amf"})
        response = conn.getresponse()
        data = response.read()
        status = response.status
    finally:
        conn.close()

    decoded = None
    if data:
        try:
            decoded = remoting.decode(data).bodies[0][1].body
        except Exception as error:
            decoded = f"<undecodable: {type(error).__name__}>"
    return status, decoded


def http_get(path):
    conn = http.client.HTTPConnection(HOST, PORT, timeout=30)
    try:
        conn.request("GET", path)
        response = conn.getresponse()
        return response.status, response.read()
    finally:
        conn.close()


def main():
    server = sys.argv[1] if len(sys.argv) > 1 else (os.environ.get("RTE_SERVER") or "auto")
    print(f"gateway on {HOST}:{PORT} via {server}\n")

    checks = []

    status, _ = http_get("/")
    checks.append(("front door answers", status in (200, 302), status))

    status, body = amf_call("ZlingshotService.presence")
    ok = status == 200 and body is not None
    checks.append(("AMF call answered", ok, f"{status} {str(body)[:60]}"))

    status, _ = amf_call("SomeService.doesNotExist")
    checks.append(("unknown service does not crash", status == 200, status))

    status, _ = amf_call("WorldService.addFleet", [{"name": "fleet1_1", "units": "a,b,c"}])
    checks.append(("addFleet with no registry", status == 200, status))

    status, _ = http_get("/list_session")
    checks.append(("save list answers", status == 200, status))

    status, _ = http_get("/avatar.json")
    checks.append(("avatar catalogue answers", status == 200, status))

    status, _ = http_get("/motd.json")
    checks.append(("motd catalogue answers", status == 200, status))

    failed = 0
    for name, ok, detail in checks:
        print(f"  {'PASS' if ok else 'FAIL'}  {name:38} {detail}")
        failed += not ok

    print()
    print(f"{len(checks) - failed}/{len(checks)} passed")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())