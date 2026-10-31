import { fail, redirect } from '@sveltejs/kit';

import { chooseAvatar, fetchAvatarState } from '#lib/server/avatar';
import { buildFlashVars } from '#lib/server/flashvars';
import { resolveRequestOrigin } from '#lib/server/config';
import { fetchMotdState } from '#lib/server/motd';
import type { Actions, PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ url, request, locals }) => {
	// No account means no progress to load, so send them to register rather
	// than to a game that would start from nothing.
	const user = locals.user;
	if (!user) redirect(303, '/registro');

	return {
		// The same origin the proxy puts in the Host header, resolved by the
		// same function. See #lib/server/config.
		flashVars: buildFlashVars(resolveRequestOrigin(url)),
		zid: user.zid,
		role: user.role,
		// Null when the gateway cannot be reached, in which case the picker
		// falls back to the default avatar and play is not blocked.
		avatar: await fetchAvatarState(request, user.zid),
		// Same for the loading art: no MOTD is a plain loading screen, never an
		// error. Both reads go out together rather than one after the other.
		motd: await fetchMotdState(request, user.zid)
	};
};

export const actions: Actions = {
	/**
	 * Store the chosen avatar on the save.
	 *
	 * The filename is checked against the catalogue the gateway just listed,
	 * never against the submitted form: `/chooseavatar` takes it as a path
	 * parameter, and the gateway refuses anything it does not know.
	 */
	pick: async ({ request, locals }) => {
		if (!locals.user) return fail(401, { message: 'Inicia sesión para elegir avatar' });

		const state = await fetchAvatarState(request, locals.user.zid);
		if (!state) return fail(502, { message: 'El servidor no respondió' });

		const file = String((await request.formData()).get('avatar') ?? '');
		if (!state.avatars.includes(file)) {
			return fail(400, { message: 'Ese avatar no existe' });
		}

		if (!(await chooseAvatar(request, file, locals.user.zid))) {
			return fail(502, { message: 'No se pudo guardar el avatar' });
		}

		// 303 back to the player so a refresh re-renders rather than re-posts.
		return redirect(303, '/juego?avatar=' + encodeURIComponent(file));
	}
};