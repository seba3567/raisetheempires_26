import { RUFFLE_VERSION } from '#lib/ruffle';
import type { PageServerLoad } from './$types';

// `user` is deliberately absent: it comes from the root layout load so the
// header knows about the session on every route, not only on this one.
export const load: PageServerLoad = async () => {
	return {
		ruffleVersion: RUFFLE_VERSION
	};
};