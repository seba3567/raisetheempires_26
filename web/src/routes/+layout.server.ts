import { fetchAvatarState } from '#lib/server/avatar';
import type { LayoutServerLoad } from './$types';

/**
 * The signed-in account, for every route.
 *
 * Merges user and avatar info into `page.data` so the navbar stays accurate
 * across the entire application without redundant fetches.
 */
export const load: LayoutServerLoad = async ({ locals, request }) => {
	const user = locals.user;
	const avatar = user ? await fetchAvatarState(request, user.zid) : null;
	return { user, avatar };
};
