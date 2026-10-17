/**
 * Reverse proxy to the Python AMF0 gateway.
 *
 * Why the gateway stays behind a proxy instead of being merged into this
 * service: the SWF speaks AMF0, and the exact payload dialect pyamf produces is
 * a compatibility contract (dense arrays vs. objects with numeric keys, and
 * reference markers). Re-encoding it in TypeScript would break a client we
 * cannot recompile. So the gateway is a loopback-only service and this file is
 * the only way to reach it.
 *
 * The load-bearing detail is the Host header. ``templates/ruffle.html`` renders
 * ``app_url={{ request.host_url }}`` into the FlashVars, and the client builds
 * its gateway URL from it (``Config.SERVICES_GATEWAY_PATH``). Flask therefore
 * has to see the *public* host, not 127.0.0.1:5005, or the game would call
 * straight back into Python and bypass this service entirely.
 */
import { config } from "./config.ts";

/** Headers that describe a single hop and must not be forwarded. */
const HOP_BY_HOP = new Set([
  "connection",
  "keep-alive",
  "proxy-authenticate",
  "proxy-authorization",
  "te",
  "trailer",
  "transfer-encoding",
  "upgrade",
]);

/**
 * Where the signed-in account's id travels to the gateway.
 *
 * Kept in sync with `PLAYER_ZID_HEADER` in `game_settings.py`, which is where
 * it is read. The gateway trusts it only because it is loopback-only and this
 * service is its sole door — the same reasoning that puts the admin gate here.
 */
export const PLAYER_ZID_HEADER = "x-player-zid";

function shouldForwardRequestHeader(name: string): boolean {
  const lower = name.toLowerCase();
  return !HOP_BY_HOP.has(lower) && lower !== "host" && lower !== "content-length";
}

/**
 * Response headers need one more exclusion than request headers.
 *
 * `fetch` decodes the body for us: it transparently inflates a gzipped response
 * and hands back plain bytes, while leaving `Content-Encoding: gzip` in the
 * headers. Forwarding that header makes the browser try to inflate text that is
 * already plain, and the page dies with ERR_CONTENT_DECODING_FAILED — a blank
 * screen with no other symptom.
 *
 * Content-Length goes for the same reason: it described the compressed length,
 * which no longer matches the body we are forwarding.
 */
function shouldForwardResponseHeader(name: string): boolean {
  const lower = name.toLowerCase();
  if (!shouldForwardRequestHeader(name)) return false;
  return lower !== "content-encoding" && lower !== "content-length";
}

function buildHeaders(
  req: Request,
  publicOrigin: string,
  playerZid?: string | null
): Headers {
  const headers = new Headers();
  for (const [name, value] of req.headers) {
    if (shouldForwardRequestHeader(name)) headers.set(name, value);
  }

  // SvelteKit 3 removed process.env.ORIGIN, so the public host is passed in
  // rather than read from the request here. It must be the same value the
  // FlashVars use, or Flask and the SWF disagree about where the gateway is.
  const publicUrl = new URL(publicOrigin);

  // Flask's request.host_url reads Host, so this is what puts the right
  // app_url into the FlashVars.
  headers.set("host", publicUrl.host);
  headers.set("x-forwarded-host", publicUrl.host);
  headers.set("x-forwarded-proto", publicUrl.protocol.replace(":", ""));
  const existing = req.headers.get("x-forwarded-for");
  headers.set("x-forwarded-for", existing ? `${existing}, ${publicUrl.hostname}` : publicUrl.hostname);

  // The signed-in account's id, and only when there is one. Without it the
  // gateway files the player under a hash of its own cookie, which is why a
  // login here never stuck in the game. Absent, it falls back to that cookie,
  // so anonymous play and direct requests keep working unchanged.
  //
  // Set, never forwarded: the loop over req.headers above copies whatever the
  // client sent, so a client must not be able to claim an identity by sending
  // the header itself. This line is the only thing allowed to set it.
  if (playerZid) {
    headers.set(PLAYER_ZID_HEADER, playerZid);
  } else {
    headers.delete(PLAYER_ZID_HEADER);
  }

  return headers;
}

const UPSTREAM_TIMEOUT_MS = 30_000;

export type ProxyResult = Response | "websocket-unsupported";

/**
 * Forward `req` to the gateway.
 *
 * `publicOrigin` is required, never defaulted. It is the origin the browser
 * used, and it is load-bearing: Flask builds the SWF's `app_url` FlashVar out
 * of it. An optional parameter defaulting to the upstream address would quietly
 * hand Flask `127.0.0.1:5005`, and the game would then call the gateway
 * directly and skip this service entirely — with no error anywhere to notice.
 *
 * `origin` points at the gateway itself and is overridable so tests can use a
 * throwaway upstream or a dead port.
 *
 * `playerZid` is the signed-in account's id, or null/undefined for anonymous
 * traffic. See {@link PLAYER_ZID_HEADER}.
 */
export async function proxyToGateway(
  req: Request,
  publicOrigin: string,
  origin: string = config.gateway.origin,
  playerZid?: string | null,
): Promise<ProxyResult> {
  // socket.io currently runs in long-polling mode on Werkzeug, so an upgrade
  // would mean something changed upstream. Fail loudly instead of silently
  // returning a broken stream.
  if (req.headers.get("upgrade")?.toLowerCase() === "websocket") {
    return "websocket-unsupported";
  }

  const incoming = new URL(req.url);
  const target = new URL(incoming.pathname + incoming.search, origin);

  const hasBody = req.method !== "GET" && req.method !== "HEAD";
  const body = hasBody ? await req.arrayBuffer() : null;

  if (body && body.byteLength > config.gateway.maxBodyBytes) {
    return new Response("payload too large", { status: 413 });
  }

  try {
    const upstream = await fetch(target, {
      method: req.method,
      headers: buildHeaders(req, publicOrigin, playerZid),
      redirect: "manual",
      signal: AbortSignal.timeout(UPSTREAM_TIMEOUT_MS),
      ...(body === null ? {} : { body }),
    });

    const headers = new Headers();
    for (const [name, value] of upstream.headers) {
      if (shouldForwardResponseHeader(name)) headers.set(name, value);
    }

    return new Response(upstream.body, {
      status: upstream.status,
      statusText: upstream.statusText,
      headers,
    });
  } catch (error) {
    const reason = error instanceof Error ? error.message : String(error);

    // The detail belongs in the log, not in the response. Telling whoever
    // triggered this to "start empires-server.py on 127.0.0.1:5005" hands a
    // stranger the internal address and the operator's command line, and this
    // page is shown to players, not to whoever runs the box.
    console.error(`[proxy] ${incoming.pathname} -> ${config.gateway.origin}: ${reason}`);

    return new Response(
      `<!doctype html><meta charset="utf-8">
       <title>Game server not responding</title>
       <body style="font-family:system-ui;max-width:40rem;margin:4rem auto;padding:0 1rem">
       <h1>Game server not responding</h1>
       <p>The game server could not be reached. This is on our side, not yours.</p>
       <p>Try again in a moment.</p>`,
      { status: 502, headers: { "content-type": "text/html; charset=utf-8" } },
    );
  }
}