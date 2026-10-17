/**
 * Reverse proxy to the AMF0 gateway.
 *
 * The Host assertion here is the load-bearing one: templates/ruffle.html renders
 * `app_url={{ request.host_url }}` into the FlashVars and the client builds its
 * gateway URL from it. If Flask sees 127.0.0.1:5005 instead of the public host,
 * the game silently bypasses this service.
 */
import { afterAll, beforeAll, describe, expect, test } from "bun:test";

import { proxyToGateway } from "../src/proxy.ts";

/** What the fake gateway saw, so tests can assert on the forwarded request. */
interface Seen {
  method: string;
  path: string;
  search: string;
  headers: Record<string, string>;
  bodyBase64: string;
}

let upstream: ReturnType<typeof Bun.serve>;
let seen: Seen[] = [];
let origin = "";

beforeAll(() => {
  upstream = Bun.serve({
    port: 0,
    async fetch(req) {
      const body = new Uint8Array(await req.arrayBuffer());
      seen.push({
        method: req.method,
        path: new URL(req.url).pathname,
        search: new URL(req.url).search,
        headers: Object.fromEntries(req.headers.entries()),
        bodyBase64: Buffer.from(body).toString("base64"),
      });

      if (new URL(req.url).pathname === "/boom") {
        return new Response("exploded", { status: 500 });
      }
      return new Response("from gateway", {
        headers: { "content-type": "text/plain", "x-gateway": "yes" },
      });
    },
  });
  origin = `http://127.0.0.1:${upstream.port}`;
});

afterAll(() => {
  upstream?.stop(true);
});

function lastSeen(): Seen {
  const entry = seen.at(-1);
  if (!entry) throw new Error("the gateway was never called");
  return entry;
}

describe("proxyToGateway", () => {
  test("preserves path and query string", async () => {
    await proxyToGateway(
      new Request("http://localhost:8080/flashservices/gateway.php?a=1&b=2"),
      origin,
    );
    expect(lastSeen().path).toBe("/flashservices/gateway.php");
    expect(lastSeen().search).toBe("?a=1&b=2");
  });

  test("gives Flask the PUBLIC host, not the upstream address", async () => {
    // This is what makes app_url correct in the FlashVars.
    await proxyToGateway(new Request("http://game.example.com/ruffle.html"), origin);

    expect(lastSeen().headers["host"]).toBe("game.example.com");
    expect(lastSeen().headers["host"]).not.toContain("127.0.0.1");
    expect(lastSeen().headers["x-forwarded-host"]).toBe("game.example.com");
    expect(lastSeen().headers["x-forwarded-proto"]).toBe("http");
  });

  test("keeps the port when the public service runs on one", async () => {
    await proxyToGateway(new Request("http://localhost:8080/ruffle.html"), origin);
    expect(lastSeen().headers["host"]).toBe("localhost:8080");
  });

  test("appends the client to an existing x-forwarded-for", async () => {
    await proxyToGateway(
      new Request("http://localhost:8080/", {
        headers: { "x-forwarded-for": "203.0.113.7" },
      }),
      origin,
    );
    expect(lastSeen().headers["x-forwarded-for"]).toContain("203.0.113.7");
  });

  test("forwards a binary body byte for byte", async () => {
    // AMF0 payloads are binary; any re-encoding would corrupt the request.
    const payload = new Uint8Array([0x0a, 0x00, 0x03, 0xff, 0x10, 0x00, 0x00, 0x00, 0x07]);
    await proxyToGateway(
      new Request("http://localhost:8080/flashservices/gateway.php", {
        method: "POST",
        body: payload,
      }),
      origin,
    );

    expect(lastSeen().method).toBe("POST");
    expect(Buffer.from(lastSeen().bodyBase64, "base64")).toEqual(Buffer.from(payload));
  });

  test("does not send a body on GET", async () => {
    await proxyToGateway(new Request("http://localhost:8080/home.html"), origin);
    expect(lastSeen().bodyBase64).toBe("");
  });

  test("forwards session cookies so the game stays logged in", async () => {
    await proxyToGateway(
      new Request("http://localhost:8080/flashservices/gateway.php", {
        headers: { cookie: "session=abc123" },
      }),
      origin,
    );
    expect(lastSeen().headers["cookie"]).toBe("session=abc123");
  });

  test("strips hop-by-hop headers the proxy is responsible for", async () => {
    await proxyToGateway(
      new Request("http://localhost:8080/", {
        headers: { te: "trailers", "proxy-authorization": "secret" },
      }),
      origin,
    );

    const headers = lastSeen().headers;
    expect(headers["te"]).toBeUndefined();
    expect(headers["proxy-authorization"]).toBeUndefined();
  });

  test("does not forward its own Host or Content-Length", async () => {
    // fetch() manages connection and content-length itself, so those arrive
    // regardless. What matters is that we send the *public* host and let the
    // runtime compute the length.
    await proxyToGateway(
      new Request("http://game.example.com/flashservices/gateway.php", {
        method: "POST",
        body: "x",
        headers: { "content-length": "999" },
      }),
      origin,
    );

    expect(lastSeen().headers["host"]).toBe("game.example.com");
    expect(lastSeen().headers["content-length"]).not.toBe("999");
  });

  test("passes the upstream status and headers back", async () => {
    const res = await proxyToGateway(new Request("http://localhost:8080/boom"), origin);
    expect(res).not.toBe("websocket-unsupported");
    if (res === "websocket-unsupported") throw new Error("unreachable");

    expect(res.status).toBe(500);
    expect(await res.text()).toBe("exploded");
  });

  test("passes custom gateway headers back to the browser", async () => {
    const res = await proxyToGateway(new Request("http://localhost:8080/home.html"), origin);
    if (res === "websocket-unsupported") throw new Error("unreachable");
    expect(res.headers.get("x-gateway")).toBe("yes");
  });

  test("reports an unreachable gateway instead of hanging", async () => {
    // Port 1 is reserved and nothing listens on it.
    const res = await proxyToGateway(new Request("http://localhost:8080/ruffle.html"), "http://127.0.0.1:1");

    if (res === "websocket-unsupported") throw new Error("unreachable");
    expect(res.status).toBe(502);
    const html = await res.text();
    expect(html).toContain("Gateway unreachable");
    expect(html).toContain("empires-server.py");
  });

  test("declines a WebSocket upgrade rather than breaking it silently", async () => {
    const res = await proxyToGateway(
      new Request("http://localhost:8080/socket.io/", {
        headers: { upgrade: "websocket", connection: "Upgrade" },
      }),
      origin,
    );
    expect(res).toBe("websocket-unsupported");
  });

  test("rejects a body above the configured limit", async () => {
    // 5 MiB limit, matching Flask's MAX_FORM_MEMORY_SIZE.
    const oversized = new Uint8Array(5 * 1024 * 1024 + 1);
    const res = await proxyToGateway(
      new Request("http://localhost:8080/flashservices/gateway.php", {
        method: "POST",
        body: oversized,
      }),
      origin,
    );

    if (res === "websocket-unsupported") throw new Error("unreachable");
    expect(res.status).toBe(413);
  });
});

describe("content encoding", () => {
  // Regression: Flask compresses with gzip. fetch() inflates the body for us but
  // leaves Content-Encoding in the headers, so forwarding it made the browser
  // try to inflate plain text. The symptom was a blank page and nothing else:
  // ERR_CONTENT_DECODING_FAILED.

  let gzipUpstream: ReturnType<typeof Bun.serve>;
  let gzipOrigin = "";

  beforeAll(async () => {
    // Real gzip bytes, so the failure mode is reproduced rather than simulated.
    const compressed = await gzip("<!DOCTYPE html><html>hola</html>");
    gzipUpstream = Bun.serve({
      port: 0,
      fetch() {
        return new Response(compressed, {
          headers: { "content-type": "text/html", "content-encoding": "gzip" },
        });
      },
    });
    gzipOrigin = `http://127.0.0.1:${gzipUpstream.port}`;
  });

  afterAll(() => {
    gzipUpstream?.stop(true);
  });

  test("does not claim an encoding that fetch already decoded", async () => {
    const res = await proxyToGateway(
      new Request("http://localhost:8080/home.html", {
        headers: { "accept-encoding": "gzip, deflate" },
      }),
      gzipOrigin,
    );
    if (res === "websocket-unsupported") throw new Error("unreachable");

    expect(res.headers.get("content-encoding")).toBeNull();
    expect(res.headers.get("content-length")).toBeNull();
    expect(await res.text()).toBe("<!DOCTYPE html><html>hola</html>");
  });

  test("the bytes on the wire are the decoded ones, not gzip", async () => {
    const res = await proxyToGateway(new Request("http://localhost:8080/home.html"), gzipOrigin);
    if (res === "websocket-unsupported") throw new Error("unreachable");

    const bytes = new Uint8Array(await res.arrayBuffer());
    expect(bytes[0]).toBe(0x3c); // '<'
    expect(bytes[1]).toBe(0x21); // '!'
  });
});

async function gzip(text: string): Promise<ArrayBuffer> {
  const stream = new CompressionStream("gzip");
  const writer = stream.writable.getWriter();
  void writer.write(new TextEncoder().encode(text));
  void writer.close();
  return await new Response(stream.readable).arrayBuffer();
}