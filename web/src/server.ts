/**
 * Entry point: this service is the public face of Raise the Empires.
 *
 * It owns accounts, friendships and progress, and it reverse-proxies everything
 * else to the Python AMF0 gateway on loopback. The gateway is never exposed
 * directly, so the Flask development server never has to be production-ready.
 */
import { config } from "./config.ts";
import { db, migrate } from "./db/client.ts";
import { proxyToGateway } from "./proxy.ts";
import { handle, ownsPath } from "./router.ts";

db();
console.log(`[web] database ready at ${config.database.file}`);

const server = Bun.serve({
  port: config.port,
  hostname: config.host,
  idleTimeout: 60,

  async fetch(req: Request): Promise<Response> {
    const path = new URL(req.url).pathname;

    try {
      if (ownsPath(path)) return await handle(req);

      const result = await proxyToGateway(req);
      if (result === "websocket-unsupported") {
        return new Response(
          "This deployment proxies HTTP only; the gateway's socket.io is in long-polling mode.",
          { status: 501 },
        );
      }
      return result;
    } catch (error) {
      const detail = error instanceof Error ? (error.stack ?? error.message) : String(error);
      console.error(`[web] ${req.method} ${path} failed\n${detail}`);
      return new Response("internal server error", { status: 500 });
    }
  },
});

console.log(`[web] listening on http://${config.host}:${config.port}`);
console.log(`[web] gateway upstream: ${config.gateway.origin}`);

if (import.meta.main) {
  const shutdown = (signal: string) => {
    console.log(`[web] ${signal}, shutting down`);
    server.stop();
    process.exit(0);
  };
  process.on("SIGINT", () => shutdown("SIGINT"));
  process.on("SIGTERM", () => shutdown("SIGTERM"));
}

export { server, migrate };