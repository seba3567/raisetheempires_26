/**
 * The Message of the Day art, read from the gateway.
 *
 * The catalogue and the first pick both come from `/motd.json`, so the page has
 * something to paint on its first render without a second round trip, and
 * {@link MotdState.motds} lets the player ask for another without going back
 * out at all.
 */

import { config } from './config.ts';
import { PLAYER_ZID_HEADER } from './proxy.ts';

export interface MotdState {
	/** Filenames, e.g. `MOTD_Tyrants_and_Assassins.png`. */
	motds: string[];
	/** One picked at random by the gateway. */
	current: string;
}

export async function fetchMotdState(request: Request, playerZid?: string | null): Promise<MotdState | null> {
	try {
		const response = await fetch(new URL('/motd.json', config.gateway.origin), {
			headers: buildHeaders(request, playerZid),
			signal: AbortSignal.timeout(10_000),
			cache: 'no-store'
		});
		if (!response.ok) return null;
		return (await response.json()) as MotdState;
	} catch {
		return null;
	}
}

/**
 * The same headers `editor.ts` and `avatar.ts` send: the account id so the
 * gateway files this under the player's own row, and the cookie for anyone
 * without an account.
 */
function buildHeaders(request: Request, playerZid?: string | null): Headers {
	const headers = new Headers();
	if (playerZid) headers.set(PLAYER_ZID_HEADER, playerZid);
	const cookie = request.headers.get('cookie');
	if (cookie) headers.set('cookie', cookie);
	return headers;
}