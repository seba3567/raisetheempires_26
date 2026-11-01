/**
 * Request pipeline.
 *
 * Three things happen here, in this order:
 *
 * 1. Resolve the session, so every route and page already knows who is asking.
 * 2. Gate the gateway's admin-only routes. This is the only layer that knows
 *    who is signed in, so the role check has to live here.
 * 3. Hand anything that is not one of our own routes to the Python AMF0
 *    gateway.
 */
import { error, redirect } from '@sveltejs/kit';
// SvelteKit 3 moved the hook and cookie types into their own entry point;
// they are no longer exported from the package root.
import type { Handle } from '@sveltejs/kit/hooks';

import { adminDecision } from '#lib/access';
import { findById, publicUser } from '#lib/server/models/accounts';
import { proxyToGateway } from '#lib/server/proxy';
import { config, resolveRequestOrigin } from '#lib/server/config';
import { isSecureRequest, readSession } from '#lib/server/session';

export const handle: Handle = async ({ event, resolve }) => {
	event.locals.secure = isSecureRequest(event.request);

	const userId = await readSession(event.request);
	const user = userId === null ? null : await findById(userId);
	event.locals.user = user ? publicUser(user) : null;

	const publicOrigin = resolveRequestOrigin(event.url);

	const decision = adminDecision(event.url.pathname, user);
	if (decision === 'redirect-login') {
		const next = encodeURIComponent(event.url.pathname + event.url.search);
		redirect(303, `/entrar?next=${next}`);
	}
	if (decision === 'forbid') {
		error(403, 'Esta sección es solo para administradores del servidor.');
	}

	// route.id is undefined when no route matched, which is exactly the set of
	// paths the gateway owns: the SWF, its assets, the AMF0 endpoint, the XML
	// settings files and the cheat routes.
	if (!event.route.id) {
		// FastAPI owns the JSON API surface (Fase A of the migration); everything
		// else keeps going to the Flask gateway.
		const upstreamOrigin =
			event.url.pathname.startsWith('/api/v1/')
				? config.fastapi.origin
				: undefined;

		// The account's id goes along so the game files the save under the
		// account instead of under a hash of the gateway's own cookie. Null for
		// anonymous traffic, which the gateway falls back to handling exactly as
		// it did before.
		//
		// The role goes along too: the gateway enforces its own lock on the
		// admin tools, and it can only do that from what this service vouches
		// for. It is set here and never forwarded from the browser.
		const result = await proxyToGateway(
			event.request,
			publicOrigin,
			upstreamOrigin,
			event.locals.user?.zid ?? null,
			event.locals.user?.role ?? null
		);
		if (result === 'websocket-unsupported') {
			error(501, 'Este despliegue solo proxea HTTP; el socket.io va en long-polling.');
		}
		return result;
	}

	const response = await resolve(event);

	// Ruffle's loader and WASM binaries are immutable for a given vendored
	// version. Serving them with a long-lived immutable cache removes the
	// revalidation round trip on every visit (the adapter sets no header for
	// static/ by default). See web/README.md "El arte del juego se cachea".
	if (event.url.pathname.startsWith('/ruffle/')) {
		response.headers.set('cache-control', 'public, max-age=31536000, immutable');
	}

	// HTML pages must never be cached: a stale index.html references chunks
	// that no longer exist after a rebuild, producing
	// "Failed to fetch dynamically imported module".
	const contentType = response.headers.get('content-type') ?? '';
	if (contentType.includes('text/html')) {
		response.headers.set('cache-control', 'no-store, no-cache, must-revalidate, max-age=0');
		response.headers.set('pragma', 'no-cache');
		response.headers.set('expires', '0');
	}

	return response;
};