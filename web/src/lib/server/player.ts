/**
 * The player's real state, read from the gateway.
 *
 * Why this is not read from Bun's own database: the `progress` table belongs to
 * the account, but nothing in the game ever wrote to it, so it sat at level 1
 * forever next to a level 85 empire. The save in the gateway is the only source
 * of truth, so that is what this reads.
 */

import { config } from './config.ts';
import { PLAYER_ZID_HEADER } from './proxy.ts';
import type { Equal, Expect } from '../type-checks.ts';

/**
 * The keys `/player.json` has to carry.
 *
 * The gateway produces this and the account page reads it, so the shape is
 * written down once, in `contract/runtime.json`, and both sides are checked
 * against it.
 */
export const PLAYER_STATE_KEYS = [
	'hasSave',
	'zid',
	'level',
	'xp',
	'empirePoints',
	'worldName',
	'picture',
	'resources'
] as const;

export interface PlayerState {
	hasSave: boolean;
	zid: number;
	level: number | null;
	xp: number | null;
	/** The client has always displayed `player.cash` as Empire Points. */
	empirePoints: number | null;
	worldName: string | null;
	picture: string | null;
	resources: Record<string, number | null>;
}

/** The interface and the key list are the same fact written twice. */
export type _PlayerStateKeysMatch = Expect<
	Equal<keyof PlayerState, (typeof PLAYER_STATE_KEYS)[number]>
>;

/**
 * Ask the gateway what the signed-in player's save contains.
 *
 * Two cookies have to travel with this request, and they are unrelated:
 *
 * - `rte_session`, the account cookie, which this service verifies itself. It
 *   never goes to the gateway; `playerZid` carries what matters from it.
 * - the gateway's own `session` cookie, which is what selects **which save** to
 *   read. Without it the gateway would report a brand new empty game, and the
 *   account page would show level 1 again while the empire sits right there.
 *
 * Returns null when the gateway cannot be reached, so a page that wants stats
 * can still render everything else.
 */
export async function fetchPlayerState(
	request: Request,
	playerZid: string
): Promise<PlayerState | null> {
	const headers = new Headers({ [PLAYER_ZID_HEADER]: playerZid });
	const cookie = request.headers.get('cookie');
	if (cookie) headers.set('cookie', cookie);

	try {
		const response = await fetch(new URL('/player.json', config.gateway.origin), {
			headers,
			signal: AbortSignal.timeout(10_000),
			// Live game state: a cached copy would show a stale empire.
			cache: 'no-store'
		});
		if (!response.ok) return null;
		return (await response.json()) as PlayerState;
	} catch {
		return null;
	}
}