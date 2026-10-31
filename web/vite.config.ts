import adapter from '@sveltejs/adapter-bun';
import { sveltekit } from '@sveltejs/kit/vite';
import tailwindcss from '@tailwindcss/vite';
import { defineConfig } from 'vite';

import { adapterServerOptions, config } from './src/lib/server/config.ts';

/**
 * The port and the origin come from the app's own configuration, not from a
 * second reading of the environment.
 *
 * `src/lib/server/config.ts` is the module that already knows how to find
 * `web/.env` (Vite does not put `.env` into `process.env`, so a build that
 * read the environment directly would miss it). Importing it here is what
 * keeps the three numbers that have to agree actually agreeing:
 *
 * - the port the Bun adapter binds, which falls back to 3000 when the
 *   environment does not say otherwise;
 * - the origin the build bakes in, which the adapter rewrites every request
 *   onto and SvelteKit validates every form POST against;
 * - the dev server's port.
 *
 * When those disagreed, the symptom was a 403 "Cross-site POST form
 * submissions are forbidden" on the login and the registration, with every
 * page still loading. They are read from one place now so they cannot.
 */
export default defineConfig({
	server: {
		port: config.port,
		// The origin above names this exact port. If it is taken, failing
		// loudly is the honest answer: moving to the next free port would
		// put the server somewhere the baked origin does not point, and the
		// forms would be refused as cross-site submissions.
		strictPort: true
	},
	plugins: [
		tailwindcss(),
		sveltekit({
			// Official Bun adapter: builds a standalone server that runs on
			// Bun.serve. Requires Bun 1.4+.
			//
			// `serverOptions` is the fallback the adapter uses when PORT and
			// HOST are absent from the environment. Without it the adapter
			// binds 3000 while the origin points at 8080.
			adapter: adapter({
				serverOptions: adapterServerOptions(config.port, config.host)
			}),
			paths: { origin: config.publicOrigin },
			csrf: { trustedOrigins: config.trustedOrigins }
		})
	]
});
