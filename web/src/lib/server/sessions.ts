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

export async function fetchSessions(): Promise<SavedSession[] | null> {
	try {
		const response = await fetch(new URL('/list_session', config.gateway.origin), {
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
	playerZid?: string
): Promise<{ ok: boolean; message?: string }> {
	const headers: Record<string, string> = {
		// A form-encoded DELETE, because the body is what carries the id and
		// the gateway reads it from there.
		'Content-Type': 'application/x-www-form-urlencoded'
	};
	if (playerZid) headers['x-player-zid'] = playerZid;
	const cookie = request.headers.get('cookie');
	if (cookie) headers['cookie'] = cookie;

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