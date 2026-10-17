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

    def check(name, call, expect=lambda status: status == 200):
        """Run one check, reporting a failure rather than raising.

        The point of this script is to be legible when it fails in CI. A raw
        ConnectionRefusedError traceback for a gateway that is not up yet says
        less than "FAIL ... connection refused", and it aborts the remaining
        checks, so one early problem hides every later one.

        ``call`` returns ``(status, body)``; the body is only shown when there
        is something short and interesting to say about it.
        """
        try:
            status, body = call()
        except Exception as error:
            checks.append((name, False, f"{type(error).__name__}: {error}"))
            return
        detail = f"{status} {str(body)[:56]}" if body else str(status)
        checks.append((name, expect(status), detail.strip()))

    check("front door answers",
          lambda: http_get("/"),
          expect=lambda status: status in (200, 302))

    check("AMF call answered",
          lambda: amf_call("ZlingshotService.presence"))

    check("unknown service does not crash",
          lambda: amf_call("SomeService.doesNotExist"))

    check("addFleet with no registry",
          lambda: amf_call("WorldService.addFleet",
                           [{"name": "fleet1_1", "units": "a,b,c"}]))

    check("save list answers", lambda: http_get("/list_session"))
    check("avatar catalogue answers", lambda: http_get("/avatar.json"))
    check("motd catalogue answers", lambda: http_get("/motd.json"))

    failed = 0
    for name, ok, detail in checks:
        print(f"  {'PASS' if ok else 'FAIL'}  {name:38} {detail}")
        failed += not ok

    print()
    print(f"{len(checks) - failed}/{len(checks)} passed")
    if failed:
        print()
        print("Every check failing at once usually means the gateway is not up on "
              f"{HOST}:{PORT}, not that it is broken in seven ways.")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())