import { redirect } from '@sveltejs/kit';

import { buildFlashVars } from '#lib/server/flashvars';
import type { PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ url, locals, parent }) => {
	// No account means no progress to load, so send them to register rather
	// than to a game that would start from nothing.
	if (!locals.user) redirect(303, '/registro');

	return {
		// Same origin the proxy puts in the Host header. See #lib/flashvars.
		flashVars: buildFlashVars(process.env['PUBLIC_ORIGIN'] ?? url.origin),
		zid: locals.user.zid
	};
};