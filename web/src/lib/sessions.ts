/**
 * The shape of a saved world, and the conversions the admin session list needs.
 *
 * Deliberately not under `server/`: these are pure functions, and the player
 * page imports them to render. SvelteKit refuses to let a component import from
 * `server/`, and it is right -- `fetchSessions` lives there and must stay
 * server-only, but a `xp` that arrives as a string does not.
 */

export interface SavedSession {
	/** `session:<sid>` -- the gateway's store key, not the cookie value. */
	session_id: string;
	uid: number;
	world_name: string;
	level: number | null;
	/**
	 * A string in the save, not a number. The live world reports xp as
	 * `"234454"` while level stays a number, so callers must not assume either.
	 */
	xp: string | number | null;
	profilePic: string;
}

/** Coerce xp, which the save stores as a string in some worlds. */
export function xpAsNumber(xp: string | number | null): number | null {
	if (xp === null) return null;
	const value = typeof xp === 'number' ? xp : Number.parseInt(xp, 10);
	return Number.isFinite(value) ? value : null;
}

/**
 * The part of the store key the cookie actually carries.
 *
 * flask-session puts `session:` on the front for the database column and stores
 * the bare sid in the cookie (see `_get_store_id` in flask_session/base.py).
 * Showing the full key and labelling it as a cookie would send the reader
 * looking for a value the gateway will not accept.
 */
export function cookieValueOf(sessionId: string): string {
	return sessionId.replace(/^session:/, '');
}