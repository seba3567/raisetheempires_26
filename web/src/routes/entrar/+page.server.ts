import { fail, redirect } from '@sveltejs/kit';

import {
	findByUsername,
	recordActivity,
	touchLastSeen,
	verifyPassword
} from '#lib/server/models/accounts';
import { setSessionCookie } from '#lib/server/session';
import type { Actions } from './$types';

export const actions: Actions = {
	default: async ({ request, url, locals, cookies }) => {
		const form = await request.formData();
		const username = String(form.get('username') ?? '').trim();
		const password = String(form.get('password') ?? '');

		if (!username || !password) {
			return fail(400, { error: 'Completa ambos campos.', username });
		}

		const user = findByUsername(username);
		// One message for both cases: the form must not confirm which usernames
		// exist.
		if (!user || !(await verifyPassword(user, password))) {
			recordActivity(null, 'login.failed', username.slice(0, 24));
			return fail(401, { error: 'Usuario o contraseña incorrectos.', username });
		}

		touchLastSeen(user.id);
		recordActivity(user.id, 'login');
		await setSessionCookie(cookies, user.id, locals.secure);

		// `next` lets the admin gate send people back where they were going.
		// Only same-site paths: an absolute URL here would be an open redirect.
		const next = url.searchParams.get('next');
		const destination =
			next && next.startsWith('/') && !next.startsWith('//') ? next : '/juego';

		redirect(303, destination);
	}
};