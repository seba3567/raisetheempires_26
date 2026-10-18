/**
 * Shared test helpers.
 */
import { closeDb, db } from '#lib/server/db/client';

/**
 * Empty every table without dropping the schema.
 *
 * Async because the client is, and because the ORDER matters: friendships and
 * progress both carry a foreign key onto users, so users goes last. MariaDB
 * enforces that; SQLite did not, which is why the original could do it in one
 * semicolon-separated statement and this cannot.
 */
export async function resetDb(): Promise<void> {
	const sql = await db();
	await sql.unsafe("DELETE FROM activity");
	await sql.unsafe("DELETE FROM friendships");
	await sql.unsafe("DELETE FROM progress");
	await sql.unsafe("DELETE FROM users");
}

/** Close the shared connection, for a test file that is finished with it. */
export { closeDb };

/** Extract a cookie value from a Set-Cookie header. */
export function cookieValue(setCookie: string | null, name = "rte_session"): string | null {
  if (!setCookie) return null;
  const match = setCookie.match(new RegExp(`${name}=([^;]*)`));
  return match?.[1] ?? null;
}