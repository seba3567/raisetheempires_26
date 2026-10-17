/**
 * The empire editor's view of the save.
 *
 * Everything the 2013 `/save-editor` page showed -- numbers, quests, the raw
 * JSON -- served as JSON so the web front end can render it instead of a wall
 * of links. Admin-only at the proxy; the page that reads this is gated again in
 * its own load, because this fetch goes straight to the gateway.
 */

import { PLAYER_ZID_HEADER } from './proxy.ts';
import { config } from './config.ts';

export interface EditorState {
	hasSave: boolean;
	zid: number;
	level: number | null;
	xp: string | number | null;
	empirePoints: number | null;
	ore: number | null;
	worldName: string | null;
	picture: string | null;
	resources: Record<string, number | null>;
	quests: {
		/** Not started yet -- the ones that can be unlocked. */
		locked: Record<string, string | null>;
		/** Started and unfinished -- can be completed or removed. */
		incomplete: Record<string, string | null>;
		/**
		 * Finished -- can be removed. Titles are nullable because the quest
		 * catalogue has entries with no localised name; the key is the fallback.
		 */
		complete: Record<string, string | null>;
	};
	raw: unknown;
	backups: number;
	/**
	 * The stacked backups, newest first, so an admin can roll back.
	 *
	 * `index` is what `/editor/restore` takes: 0 is the save that was replaced
	 * most recently. 128 of them is normal for a played-on world, so the UI
	 * shows the tail and keeps the list scrollable.
	 */
	backupList: BackupEntry[];
}

export interface BackupEntry {
	index: number;
	/** `format_backup_message`: replaced window, version and why it was taken. */
	label: string;
	saveVersion: string | null;
	message: string;
	/**
	 * What this backup actually holds.
	 *
	 * A played-on world stacks over a hundred of them and the timestamps alone
	 * do not say which one you want, so the two numbers that move between saves
	 * an hour apart are carried along.
	 */
	level: number | null;
	empirePoints: number | null;
	coins: number | null;
}

export async function fetchEditorState(
	request: Request,
	playerZid: string
): Promise<EditorState | null> {
	// The account id travels with every gateway read. Without it the gateway
	// files the request under the browser's session cookie, which is a
	// different row from the account's -- the editor then reports "no save in
	// this browser" for an empire that very much exists.
	const headers = new Headers({ [PLAYER_ZID_HEADER]: playerZid });
	const cookie = request.headers.get('cookie');
	if (cookie) headers.set('cookie', cookie);

	try {
		const response = await fetch(new URL('/editor.json', config.gateway.origin), {
			headers,
			signal: AbortSignal.timeout(10_000),
			cache: 'no-store'
		});
		if (!response.ok) return null;
		return (await response.json()) as EditorState;
	} catch {
		return null;
	}
}

/**
 * Forward one write to the gateway, returning the status it answered with.
 *
 * The path is never taken from the request: callers pass a key and it is
 * resolved against the whitelist. `/patch/<path>/int/<value>` writes any nested
 * path the gateway is handed, which must not sit behind a text input.
 */
export async function sendPatch(
	request: Request,
	path: string,
	value: number,
	playerZid?: string
): Promise<number> {
	const headers = new Headers();
	if (playerZid) headers.set('x-player-zid', playerZid);
	const cookie = request.headers.get('cookie');
	if (cookie) headers.set('cookie', cookie);

	const response = await fetch(`${config.gateway.origin}/patch/${path}/int/${value}`, {
		headers,
		redirect: 'manual',
		signal: AbortSignal.timeout(10_000)
	});
	return response.status;
}

/**
 * Roll the save back to one of the stacked backups.
 *
 * The gateway deep-copies the backup out of the session chain before applying
 * it and backs the current save up first, so this is reversible even if the
 * backup itself turns out to be bad. The index comes from `/editor.json`, never
 * from free text, and the gateway range-checks it against its own chain.
 */
export async function restoreBackup(
	request: Request,
	index: number,
	playerZid?: string
): Promise<{ ok: boolean; message?: string; label?: string }> {
	const headers = new Headers();
	if (playerZid) headers.set('x-player-zid', playerZid);
	const cookie = request.headers.get('cookie');
	if (cookie) headers.set('cookie', cookie);

	const response = await fetch(`${config.gateway.origin}/editor/restore`, {
		method: 'POST',
		headers,
		body: new URLSearchParams({ index: String(index) }),
		signal: AbortSignal.timeout(15_000)
	});

	const result = (await response.json().catch(() => null)) as
		| { ok?: boolean; message?: string; label?: string }
		| null;

	return {
		ok: response.ok && result?.ok === true,
		message: result?.message,
		label: result?.label
	};
}