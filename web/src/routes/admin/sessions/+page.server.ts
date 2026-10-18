import { error, fail, redirect } from '@sveltejs/kit';

import { findByZid } from '#lib/server/models/accounts';
import type { SavedSession } from '#lib/sessions';
import { deleteSession, fetchSessions } from '#lib/server/sessions';
import type { Actions, PageServerLoad } from './$types';

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

	// Resolved with Promise.all rather than awaited in the loop: one lookup per
	// session, all independent reads, and a sequential version would take the
	// slowest one times the count.
	const rows: SessionRow[] | null = sessions
		? await Promise.all(
				sessions.map(async (session) => {
					const account = await findByZid(session.uid);
					return {
						...session,
						// A save with no matching account belongs to a browser that
						// never signed in -- anonymous play, or a world left over
						// from before.
						owner: account ? account.username : null
					};
				})
			)
		: null;

	return {
		sessions: rows,
		// Distinct from "no sessions": this is "could not ask the gateway".
		reachable: rows !== null
	};
};

export const actions: Actions = {
	/**
	 * Delete a saved game, so a player can start over.
	 *
	 * Gated here as well as at the page's own load, because a form action is
	 * reachable by POST without ever running the load -- the load's admin check
	 * is for rendering, not for this.
	 *
	 * The store id comes from the form and is checked by the gateway against the
	 * list of saves it actually holds, so an arbitrary string cannot be used to
	 * delete something else.
	 */
	delete: async ({ request, locals }) => {
		if (!locals.user) redirect(303, '/entrar');
		if (locals.user.role !== 'admin') {
			return fail(403, { message: 'Solo para administradores del servidor.' });
		}

		const form = await request.formData();
		const storeId = String(form.get('store_id') ?? '');
		if (!storeId) {
			return fail(400, { message: 'Falta el id de la partida' });
		}

		const result = await deleteSession(request, storeId, locals.user.zid);
		if (!result.ok) {
			return fail(502, { message: result.message ?? 'No se pudo borrar la partida' });
		}

		return { deleted: storeId };
	}
};