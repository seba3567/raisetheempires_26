/**
 * Shared test helpers.
 */
import { db } from '#lib/server/db/client';

/**
 * Empty every table.
 *
 * Three things forced this, all of them MariaDB-specific:
 *
 * * The shared connection, not one of its own. TRUNCATE needs an exclusive
 *   metadata lock, so truncating from a *second* connection makes it wait on
 *   whatever the pool is still holding and every beforeEach times out at 5s.
 *   Going through the same handle the models use cannot deadlock with them,
 *   because it is the same pool.
 *
 * * DELETE in dependency order, not TRUNCATE. FOREIGN_KEY_CHECKS is a *session*
 *   variable, and the pool is free to run the TRUNCATE on a different session
 *   from the one that was told to stop checking -- so the reset died with
 *   errno 1701, "Cannot truncate a table referenced in a foreign key
 *   constraint". Deleting the children first needs no such switch at all.
 *
 * * AUTO_INCREMENT reset. Otherwise `ana` is created as id 6, 7, 8 across a
 *   run, and the zid tests that derive an id from the account break.
 */
export async function resetDb(): Promise<void> {
	const sql = await db();

	for (const table of ['activity', 'friendships', 'progress', 'users']) {
		await sql.unsafe(`DELETE FROM \`${table}\``);
	}
	await sql.unsafe('ALTER TABLE `users` AUTO_INCREMENT = 1');
}

/** Close the shared connection. Used by tests that opened one. */
export { closeDb } from '#lib/server/db/client';

/** Extract a cookie value from a Set-Cookie header. */
export function cookieValue(setCookie: string | null, name = 'rte_session'): string | null {
	if (!setCookie) return null;
	const match = setCookie.match(new RegExp(`${name}=([^;]*)`));
	return match?.[1] ?? null;
}