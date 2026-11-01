/**
 * Shared test helpers.
 */
import { db } from '#lib/server/db/client';

/**
 * Empty every table.
 *
 * Three things forced this, and all three are still true:
 *
 * * The shared connection, not one of its own. The reset has to go through the
 *   same handle the models use, or it can collide with whatever they are
 *   holding.
 *
 * * DELETE in dependency order, not TRUNCATE. The tables reference each other,
 *   and truncating a parent while a child still points at it is refused. The
 *   children go first and no such switch is needed at all.
 *
 * * The id sequence reset. Otherwise `ana` is created as id 6, 7, 8 across a
 *   run, and the zid tests that derive an id from the account break.
 */
export async function resetDb(): Promise<void> {
	const sql = await db();

	for (const table of ['activity', 'friendships', 'progress', 'users']) {
		await sql.unsafe(`DELETE FROM ${table}`);
	}
	await sql.unsafe('ALTER SEQUENCE users_id_seq RESTART WITH 1');
}

/** Close the shared connection. Used by tests that opened one. */
export { closeDb } from '#lib/server/db/client';

/** Extract a cookie value from a Set-Cookie header. */
export function cookieValue(setCookie: string | null, name = 'rte_session'): string | null {
	if (!setCookie) return null;
	const match = setCookie.match(new RegExp(`${name}=([^;]*)`));
	return match?.[1] ?? null;
}