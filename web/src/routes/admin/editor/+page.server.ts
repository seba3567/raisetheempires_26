import { error, fail, redirect } from '@sveltejs/kit';

import { RESOURCES } from '#lib/resources';
import { PLAYER_ZID_HEADER } from '#lib/server/proxy';
import { config } from '#lib/server/config';
import { fetchPlayerState } from '#lib/server/player';
import type { Actions, PageServerLoad } from './$types';

/**
 * The only fields this editor is allowed to write.
 *
 * The gateway's `/patch/<path>/<type>/<value>` route will happily write any
 * dotted path in the save, which is exactly what you want when debugging and
 * exactly what you do not want behind a form field. So the path is never taken
 * from the request: the client names a field from this table and the server
 * decides where it lands. A name that is not here is rejected.
 */
const PATCH_PATHS: Record<string, string> = {
	level: 'user_object/userInfo/player/level',
	xp: 'user_object/userInfo/player/xp',
	empirePoints: 'user_object/userInfo/player/cash',
	ore: 'user_object/userInfo/player/playerResourceType'
};

/** Resources are one path per key, all under the same node. */
function resourcePath(key: string): string | null {
	return RESOURCES.some((resource) => resource.key === key)
		? `user_object/userInfo/world/resources/${key}`
		: null;
}

function requireAdmin(locals: App.Locals): void {
	if (!locals.user) redirect(303, '/entrar');
	if (locals.user.role !== 'admin') error(403, 'Solo para administradores del servidor.');
}

export const load: PageServerLoad = async ({ locals, request }) => {
	requireAdmin(locals);

	const state = await fetchPlayerState(request, locals.user!.zid);

	return {
		state,
		hasSave: state?.hasSave ?? false
	};
};

export const actions: Actions = {
	/**
	 * Write one integer into the save.
	 *
	 * The gateway answers with a redirect to its own `/home.html`; that is
	 * ignored so the operator stays in this page and can run several edits in a
	 * row. The write only lands on the save belonging to this browser's game
	 * session, which is why the cookie travels with the request.
	 */
	set: async ({ request, locals, fetch }) => {
		requireAdmin(locals);

		const form = await request.formData();
		const field = String(form.get('field') ?? '');
		const raw = String(form.get('value') ?? '');

		const path = field === 'ore' || field in PATCH_PATHS
			? PATCH_PATHS[field]
			: resourcePath(field);
		if (!path) return fail(400, { message: `Campo desconocido: ${field}` });

		const value = Number.parseInt(raw, 10);
		if (!Number.isSafeInteger(value)) {
			return fail(400, { message: `"${raw}" no es un número entero` });
		}

		const headers = new Headers({ [PLAYER_ZID_HEADER]: locals.user!.zid });
		const cookie = request.headers.get('cookie');
		if (cookie) headers.set('cookie', cookie);

		try {
			const upstream = await fetch(
				`${config.gateway.origin}/patch/${path}/int/${value}`,
				{ headers, redirect: 'manual', signal: AbortSignal.timeout(10_000) }
			);
			if (upstream.status >= 400) {
				return fail(502, { message: `El gateway respondió ${upstream.status}` });
			}
		} catch {
			return fail(502, { message: 'No se pudo contactar el gateway AMF0.' });
		}

		// Redirect instead of returning a payload so the load runs again and the
		// numbers on screen come from the save, not from the submitted form.
		return redirect(303, '/admin/editor?ok=' + encodeURIComponent(field));
	}
};