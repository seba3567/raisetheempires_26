/**
 * Every save on the server, as the admin session list shows it.
 *
 * Admin-only at two independent layers: `/list_session` is gated by the proxy
 * in access.ts, and the page that reads this is gated again in its own load.
 * The fetch here goes straight to the gateway, bypassing the proxy's gate, so
 * the page's own check is the one that has to be right -- keep both.
 */

import type { SavedSession } from '../sessions.ts';
import { config } from './config.ts';
import { PLAYER_ROLE_HEADER, PLAYER_ZID_HEADER } from './proxy.ts';

/**
 * Every save on the server, as the admin session list shows it.
 *
 * Admin-only at two independent layers: the gateway checks the path against
 * the contracted list of admin tools and refuses anybody who is not an admin
 * (see `admin_gate.py`), and the page that reads this is gated again in its
 * own load. The fetch here goes straight to the gateway, bypassing the proxy's
 * gate, so it has to present the admin's identity itself: the gateway cannot
 * ask who is signed in, it can only see what the caller claims.
 */
export async function fetchSessions(playerZid?: string, playerRole?: string): Promise<SavedSession[] | null> {
	const headers = new Headers();
	if (playerZid) headers.set(PLAYER_ZID_HEADER, playerZid);
	if (playerRole) headers.set(PLAYER_ROLE_HEADER, playerRole);

	try {
		const response = await fetch(new URL('/list_session', config.gateway.origin), {
			headers,
			signal: AbortSignal.timeout(10_000),
			// Live list: a cached copy would show a world that no longer exists.
			cache: 'no-store'
		});
		if (!response.ok) return null;
		const data: unknown = await response.json();
		return Array.isArray(data) ? (data as SavedSession[]) : null;
	} catch {
		return null;
	}
}

/**
 * Delete one saved game.
 *
 * Takes the store id `/list_session` already hands out -- the `session:acct<zid>`
 * the save is filed under -- rather than a uid, because two saves can carry the
 * same uid and only the store key names one row.
 *
 * Returns `ok` plus whatever the gateway said. A failure is a value rather than
 * a throw: the page shows the message instead of an error page, and "the
 * gateway said no" is something an admin needs to read.
 */
export async function deleteSession(
	request: Request,
	storeId: string,
	playerZid?: string,
	playerRole?: string
): Promise<{ ok: boolean; message?: string }> {
	const headers = new Headers({
		// A form-encoded DELETE, because the body is what carries the id and
		// the gateway reads it from there.
		'content-type': 'application/x-www-form-urlencoded'
	});
	if (playerZid) headers.set(PLAYER_ZID_HEADER, playerZid);
	if (playerRole) headers.set(PLAYER_ROLE_HEADER, playerRole);
	const cookie = request.headers.get('cookie');
	if (cookie) headers.set('cookie', cookie);

	try {
		const response = await fetch(new URL('/save', config.gateway.origin), {
			method: 'DELETE',
			headers,
			body: new URLSearchParams({ store_id: storeId }),
			signal: AbortSignal.timeout(15_000),
			cache: 'no-store'
		});

		const data = (await response.json().catch(() => ({}))) as {
			ok?: boolean;
			message?: string;
		};

		if (!response.ok || data.ok !== true) {
			return {
				ok: false,
				message: data.message ?? `El gateway respondió ${response.status}`
			};
		}
		return { ok: true };
	} catch (error) {
		return { ok: false, message: (error as Error).message };
	}
}