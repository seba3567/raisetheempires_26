import adapter from '@sveltejs/adapter-bun';
import { sveltekit } from '@sveltejs/kit/vite';
import tailwindcss from '@tailwindcss/vite';
import { defineConfig } from 'vite';

/**
 * The origin the browser uses.
 *
 * SvelteKit 3 removed process.env.ORIGIN and moved it here. It is not
 * cosmetic: without it SvelteKit has no idea which origin the site lives on,
 * so its cross-site POST protection rejects every form submission with
 * "Cross-site POST form submissions are forbidden" — including this app's own
 * login. Set PUBLIC_ORIGIN in production to the public hostname.
 */
const origin = process.env['PUBLIC_ORIGIN'] ?? `http://localhost:${process.env['PORT'] ?? 8080}`;

export default defineConfig({
	server: {
		port: Number(process.env['PORT'] ?? 8080),
		strictPort: false
	},
	plugins: [
		tailwindcss(),
		sveltekit({
			// Official Bun adapter: builds a standalone server that runs on
			// Bun.serve. Requires Bun 1.4+.
			adapter: adapter(),
			paths: { origin }
		})
	]
});