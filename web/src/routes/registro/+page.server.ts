import { fail, redirect } from '@sveltejs/kit';

import {
	createUser,
	recordActivity,
	touchLastSeen,
	UsernameTaken
} from '#lib/server/models/accounts';
import { setSessionCookie } from '#lib/server/session';
import type { Actions } from './$types';

export const actions: Actions = {
	default: async ({ request, locals, cookies }) => {
		const form = await request.formData();
		const username = String(form.get('username') ?? '').trim();
		const password = String(form.get('password') ?? '');

		if (!username || !password) {
			return fail(400, { error: 'Completa ambos campos.', username });
		}

		let userId: number;
		try {
			const user = await createUser(username, password);
			userId = user.id;
			recordActivity(userId, 'register');
		} catch (cause) {
			if (cause instanceof UsernameTaken) {
				return fail(409, {
					error: `El usuario "${cause.username}" ya está registrado.`,
					username
				});
			}
			if (cause instanceof RangeError) {
				return fail(400, { error: cause.message, username });
			}
			throw cause;
		}

		touchLastSeen(userId);
		await setSessionCookie(cookies, userId, locals.secure);

		// Straight into the player. home.html, the 2012 Facebook frame with a
		// dead Flash embed, must never be a landing point.
		redirect(303, '/juego');
	}
};