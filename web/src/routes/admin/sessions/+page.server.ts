import { error, redirect } from '@sveltejs/kit';

import { findByZid } from '#lib/server/models/accounts';
import type { SavedSession } from '#lib/sessions';
import { fetchSessions } from '#lib/server/sessions';
import type { PageServerLoad } from './$types';

/**
 * A save plus the account that owns it, if any.
 *
 * `owner` is resolved here rather than in the component because the mapping is a
 * database lookup: each account carries the `zid` derived from its id, and the
 * gateway stamps that same value into the save. It is the first question this
 * page answers -- "why are there three Rising Empires" -- so it is worth doing
 * properly instead of printing the uid back at the reader.
 */
interface SessionRow extends SavedSession {
	owner: string | null;
}

export const load: PageServerLoad = async ({ locals }) => {
	if (!locals.user) redirect(303, '/entrar');
	if (locals.user.role !== 'admin') {
		error(403, 'Solo para administradores del servidor.');
	}

	const sessions = await fetchSessions();

	const rows: SessionRow[] | null =
		sessions?.map((session) => {
			const account = findByZid(session.uid);
			return {
				...session,
				// A save with no matching account belongs to a browser that never
				// signed in -- anonymous play, or a world left over from before.
				owner: account ? account.username : null
			};
		}) ?? null;

	return {
		sessions: rows,
		// Distinct from "no sessions": this is "could not ask the gateway".
		reachable: rows !== null
	};
};