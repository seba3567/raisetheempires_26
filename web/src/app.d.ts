import type { PublicUser } from '#lib/server/models/accounts';

declare global {
	namespace App {
		interface Error {
			message: string;
		}

		/**
		 * Set in hooks.server.ts on every request.
		 *
		 * `user` is null for anonymous visitors, which is not the same as a
		 * session that failed to verify: both are null, and the route decides
		 * whether to prompt for a login.
		 */
		interface Locals {
			user: PublicUser | null;
			secure: boolean;
		}

		interface PageData {
			user?: PublicUser | null;
		}
	}
}

/**
 * Ruffle's custom element.
 *
 * Ruffle.js registers `<ruffle-player>` from its own bundle, so TypeScript has
 * no idea it exists. Declaring it here is what lets Svelte accept it without a
 * `svelte-ignore` on every use.
 *
 * The attributes that matter for this game:
 *
 * - `allowScriptAccess` MUST be true. With it off, `MOTDManager` dies with
 *   Error #2067 and the client never reaches the login state.
 * - `flashvars` MUST carry `app_url` pointing at the public origin. The SWF
 *   builds its AMF0 gateway URL from it (Config.SERVICES_GATEWAY_PATH); get it
 *   wrong and the game silently calls the gateway directly, bypassing this
 *   service entirely.
 */
declare global {
	namespace svelteHTML {
		interface IntrinsicElements {
			'ruffle-player': {
				'data-movie'?: string;
				flashvars?: string;
				allowscriptaccess?: 'true' | 'false';
				allowfullscreen?: 'true' | 'false';
				autoplay?: 'true' | 'false';
				controls?: 'true' | 'false';
				quality?: 'low' | 'medium' | 'high';
				scale?: 'noScale' | 'showAll' | 'exactFit' | 'nearest';
				align?: string;
				width?: string;
				height?: string;
				style?: string;
				class?: string;
			};
		}
	}
}

export {};