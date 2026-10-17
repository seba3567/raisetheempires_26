/**
 * Runtime configuration.
 *
 * Everything is overridable by environment variable so the same build runs in
 * development (Bun on 8080 -> Flask on 5005) and in production behind a proxy.
 */

function env(name: string, fallback: string): string {
  const value = process.env[name];
  return value === undefined || value === "" ? fallback : value;
}

function envInt(name: string, fallback: number): number {
  const raw = process.env[name];
  if (raw === undefined || raw === "") return fallback;
  const parsed = Number.parseInt(raw, 10);
  return Number.isFinite(parsed) ? parsed : fallback;
}

export const config = {
  /** Public port for this Bun service. */
  port: envInt("PORT", 8080),
  host: env("HOST", "0.0.0.0"),

  /**
   * The AMF0 gateway. It stays in Python because the SWF's AMF0 payload format
   * is a fixed contract (pyamf reference semantics, dense arrays) and must not
   * be reimplemented. It listens on loopback only; this service is its front
   * door and is the only thing that should ever be exposed.
   */
  gateway: {
    origin: env("GATEWAY_ORIGIN", "http://127.0.0.1:5005"),
    /** Longest AMF0 request we will buffer, matching the Flask MAX_FORM_MEMORY_SIZE. */
    maxBodyBytes: envInt("GATEWAY_MAX_BODY", 5 * 1024 * 1024),
  },

  /**
   * Data file for the account/friends/progress store.
   *
   * SQLite by default: zero external services, one file, which matches the
   * preservation character of this project. All SQL lives in db/ and is written
   * to a portable dialect so switching to Postgres later is a driver change,
   * not a rewrite.
   */
  database: {
    file: env("DATABASE_FILE", "instance/web.db"),
  },

  session: {
    cookieName: env("SESSION_COOKIE", "rte_session"),
    /** 10 years, matching the game client cookie so a login survives. */
    maxAgeSeconds: envInt("SESSION_MAX_AGE", 60 * 60 * 24 * 365 * 10),
    secret: env("SESSION_SECRET", ""),
  },
} as const;

export type Config = typeof config;