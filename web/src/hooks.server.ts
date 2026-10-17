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
import { isSecureRequest, readSession } from '#lib/server/session';

/**
 * The origin the browser used, without a trailing slash.
 *
 * SvelteKit 3 removed `process.env.ORIGIN`, so this is computed per request
 * from `event.url`, which does honour the incoming Host. Set `PUBLIC_ORIGIN`
 * when TLS terminates at a proxy that rewrites Host, so every layer agrees.
 */
function publicOriginFor(url: URL): string {
	const override = process.env['PUBLIC_ORIGIN'];
	return (override ?? url.origin).replace(/\/$/, '');
}

export const handle: Handle = async ({ event, resolve }) => {
	event.locals.secure = isSecureRequest(event.request);

	const userId = await readSession(event.request);
	const user = userId === null ? null : findById(userId);
	event.locals.user = user ? publicUser(user) : null;

	const publicOrigin = publicOriginFor(event.url);

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
		const result = await proxyToGateway(event.request, publicOrigin);
		if (result === 'websocket-unsupported') {
			error(501, 'Este despliegue solo proxea HTTP; el socket.io va en long-polling.');
		}
		return result;
	}

	return resolve(event);
};