/**
 * Shared test helpers.
 */
import { db } from "../src/db/client.ts";

/** Empty every table without dropping the schema. */
export function resetDb(): void {
  db().exec(
    "DELETE FROM activity; DELETE FROM friendships; DELETE FROM progress; DELETE FROM users;",
  );
}

/** Extract a cookie value from a Set-Cookie header. */
export function cookieValue(setCookie: string | null, name = "rte_session"): string | null {
  if (!setCookie) return null;
  const match = setCookie.match(new RegExp(`${name}=([^;]*)`));
  return match?.[1] ?? null;
}