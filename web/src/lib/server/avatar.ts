/**
 * The player's chosen avatar, read from and written to the gateway.
 *
 * Where it lives
 * --------------
 * In the save, under `session['profilePic']`, which is where the 2013 server
 * kept it and where the friend lists and the empire editor read it from. It is
 * deliberately *not* a column on `users`: the avatar is part of the empire, and
 * a second copy in the account store would be a second thing to drift.
 *
 * The account id travels with every call, same as in `editor.ts`. Without it
 * the gateway files the request under its own cookie, which is a different row
 * from the account's, and the save it answers with is somebody else's.
 *
 * The images are served from `static/img/avatars/` by this service, not by the
 * gateway: the gateway's `/img/` route belongs to the 2013 templates that are
 * being retired, and the catalogue here is the same list either way.
 */

import { avatarUrl, DEFAULT_AVATAR } from '#lib/avatar';
import { config } from './config.ts';
import { PLAYER_ZID_HEADER } from './proxy.ts';

export { avatarUrl, DEFAULT_AVATAR };

export interface AvatarState {
	/** Filenames, e.g. `2_PincusCP_100.png`. */
	avatars: string[];
	/** The chosen filename, or null when the player never picked one. */
	current: string | null;
	/** Gateway-relative path for the current choice, for the friend lists. */
	picture: string;
}

/**
 * Upstream headers: the account id plus this browser's cookies.
 *
 * The gateway binds the save to the account, and the session cookie is how a
 * player without an account is keyed, so both have to be present.
 */
function upstreamHeaders(request: Request, playerZid?: string | null): Headers {
	const headers = new Headers();
	if (playerZid) headers.set(PLAYER_ZID_HEADER, playerZid);
	const cookie = request.headers.get('cookie');
	if (cookie) headers.set('cookie', cookie);
	return headers;
}

/**
 * The catalogue and the current choice, or null when the gateway is unreachable.
 *
 * Null rather than a throw: a player who has already got an empire should still
 * be able to press play when this read fails, and the picker simply shows the
 * default avatar.
 */
export async function fetchAvatarState(
	request: Request,
	playerZid?: string | null
): Promise<AvatarState | null> {
	try {
		const response = await fetch(new URL('/avatar.json', config.gateway.origin), {
			headers: upstreamHeaders(request, playerZid),
			signal: AbortSignal.timeout(10_000),
			cache: 'no-store'
		});
		if (!response.ok) return null;
		return (await response.json()) as AvatarState;
	} catch {
		return null;
	}
}

/**
 * Store one avatar on the save.
 *
 * A plain GET to the 2013 `/chooseavatar/<file>` route, which sets
 * `profilePic` and redirects. `redirect: 'manual'` so the 302 is answered
 * rather than followed: following it would drag this request into `/home.html`,
 * which redirects again to `/juego`, which re-renders this page.
 *
 * The filename is never taken from free text -- callers pass one the gateway
 * itself listed, and the gateway rejects anything outside its catalogue.
 */
export async function chooseAvatar(
	request: Request,
	file: string,
	playerZid?: string | null
): Promise<boolean> {
	try {
		const response = await fetch(
			new URL(`/chooseavatar/${encodeURIComponent(file)}`, config.gateway.origin),
			{
				headers: upstreamHeaders(request, playerZid),
				redirect: 'manual',
				signal: AbortSignal.timeout(10_000)
			}
		);
		// The route answers 302 on success and 400 on a name it does not know.
		return response.status < 400;
	} catch {
		return false;
	}
}