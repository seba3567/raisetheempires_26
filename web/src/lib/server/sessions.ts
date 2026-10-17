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