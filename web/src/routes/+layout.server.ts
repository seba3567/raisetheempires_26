import type { LayoutServerLoad } from './$types';

/**
 * The signed-in account, for every route.
 *
 * The header reads `page.data.user`, and `page.data` only carries what the load
 * of the route being visited returned. With this in the root *page* load, the
 * account was only ever known on `/`: on `/juego` and `/cuenta` the header
 * switched to "Entrar" while the page behind it was working fine, which reads
 * exactly like a session that keeps getting lost.
 *
 * A root *layout* load runs for every route and merges into `page.data`, so the
 * header stays right everywhere.
 */
export const load: LayoutServerLoad = async ({ locals }) => {
	return { user: locals.user };
};