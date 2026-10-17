import { error, fail, redirect } from '@sveltejs/kit';

import { RESOURCES } from '#lib/resources';
import { fetchEditorState, restoreBackup, sendPatch } from '#lib/server/editor';
import { config } from '#lib/server/config';
import type { Actions, PageServerLoad } from './$types';

/**
 * The only fields this editor may write.
 *
 * The gateway's `/patch/<path>/int/<value>` route will happily write any dotted
 * path in the save, which is what you want when debugging and exactly what you
 * do not want behind a form field. The request names a field; the server
 * decides where it lands.
 */
const PATCH_PATHS: Record<string, string> = {
	level: 'user_object/userInfo/player/level',
	xp: 'user_object/userInfo/player/xp',
	empirePoints: 'user_object/userInfo/player/cash',
	ore: 'user_object/userInfo/player/playerResourceType'
};

/** Resources are one path per key, all under the same node. */
function resourcePath(key: string): string | null {
	return RESOURCES.some((resource) => resource.key === key)
		? `user_object/userInfo/world/resources/${key}`
		: null;
}

function resolvePath(field: string): string | null {
	if (field in PATCH_PATHS) return PATCH_PATHS[field] as string;
	return resourcePath(field);
}

const QUEST_ACTIONS: Record<string, string> = {
	unlock: '/unlock_quest',
	complete: '/complete_quest',
	remove: '/remove_quest'
};

function requireAdmin(locals: App.Locals): void {
	if (!locals.user) redirect(303, '/entrar');
	if (locals.user.role !== 'admin') error(403, 'Solo para administradores del servidor.');
}

/** The gateway's own session cookie is what selects the save to write to. */
function upstreamHeaders(request: Request, locals: App.Locals): Headers {
	const headers = new Headers();
	if (locals.user) headers.set('x-player-zid', locals.user.zid);
	const cookie = request.headers.get('cookie');
	if (cookie) headers.set('cookie', cookie);
	return headers;
}

export const load: PageServerLoad = async ({ locals, request }) => {
	requireAdmin(locals);

	const state = await fetchEditorState(request);

	return {
		state,
		hasSave: state?.hasSave ?? false,
		// Distinct from "no save": this is "could not ask the gateway".
		reachable: state !== null
	};
};

export const actions: Actions = {
	/** Write one integer. */
	set: async ({ request, locals }) => {
		requireAdmin(locals);

		const form = await request.formData();
		const field = String(form.get('field') ?? '');
		const path = resolvePath(field);
		if (!path) return fail(400, { message: `Campo desconocido: ${field}` });

		const value = Number.parseInt(String(form.get('value') ?? ''), 10);
		if (!Number.isSafeInteger(value)) {
			return fail(400, { message: 'El valor tiene que ser un número entero' });
		}

		const status = await sendPatch(request, path, value, locals.user?.zid);
		if (status >= 400) return fail(502, { message: `El gateway respondió ${status}` });

		return redirect(303, '/admin/editor?ok=' + encodeURIComponent(field));
	},

	/**
	 * Write several fields in one submit.
	 *
	 * The old editor was one link per value, so fixing a world meant nine
	 * round trips and nine chances to stop halfway with a half-edited save. The
	 * values arrive as parallel `field[]`/`value[]` lists and go out in order.
	 * Each is validated before anything is written, so a typo in the last box
	 * does not leave the first four already applied.
	 */
	setMany: async ({ request, locals }) => {
		requireAdmin(locals);

		const form = await request.formData();
		const fields = form.getAll('field');
		const values = form.getAll('value');

		if (fields.length === 0) return fail(400, { message: 'No se envió ningún campo' });
		if (fields.length !== values.length) {
			return fail(400, { message: 'Cada campo necesita su valor' });
		}

		// Validate everything first. Writing half a batch is worse than writing
		// none, because the save is left in a state nobody asked for.
		const writes: Array<{ field: string; path: string; value: number }> = [];
		for (const [index, rawField] of fields.entries()) {
			const field = String(rawField);
			const path = resolvePath(field);
			if (!path) return fail(400, { message: `Campo desconocido: ${field}` });

			const value = Number.parseInt(String(values[index] ?? ''), 10);
			if (!Number.isSafeInteger(value)) {
				return fail(400, { message: `"${String(values[index])}" no es un número entero` });
			}
			writes.push({ field, path, value });
		}

		for (const write of writes) {
			const status = await sendPatch(request, write.path, write.value, locals.user?.zid);
			if (status >= 400) {
				return fail(502, {
					message: `El gateway respondió ${status} al guardar "${write.field}"`
				});
			}
		}

		return redirect(303, `/admin/editor?ok=${writes.length}`);
	},

	/** Unlock, complete or remove a quest. */
	quest: async ({ request, locals }) => {
		requireAdmin(locals);

		const form = await request.formData();
		const action = String(form.get('action') ?? '');
		const name = String(form.get('name') ?? '');

		const prefix = QUEST_ACTIONS[action];
		// A quest name is an identifier from the catalogue, not a path. Anything
		// with a slash or a dot segment in it never reaches the gateway.
		if (!prefix || !/^[A-Za-z0-9_-]+$/.test(name)) {
			return fail(400, { message: `Operación o quest inválida: ${action} ${name}` });
		}

		const response = await fetch(`${config.gateway.origin}${prefix}/${name}`, {
			headers: upstreamHeaders(request, locals),
			redirect: 'manual',
			signal: AbortSignal.timeout(10_000)
		});
		if (response.status >= 400) {
			return fail(502, { message: `El gateway respondió ${response.status}` });
		}

		return redirect(303, '/admin/editor?ok=quest');
	},

	/** Replace the save from a raw JSON paste. */
	raw: async ({ request, locals }) => {
		requireAdmin(locals);

		const form = await request.formData();
		const savegame = String(form.get('savegame') ?? '');
		if (!savegame) return fail(400, { message: 'Falta el JSON' });

		const response = await fetch(`${config.gateway.origin}/editor/save`, {
			method: 'POST',
			headers: upstreamHeaders(request, locals),
			body: new URLSearchParams({ savegame, message: 'raw edit' }),
			signal: AbortSignal.timeout(15_000)
		});

		const result = (await response.json().catch(() => null)) as
			| { ok?: boolean; message?: string }
			| null;

		if (!response.ok || result?.ok !== true) {
			return fail(400, { message: result?.message ?? `El gateway respondió ${response.status}` });
		}

		return redirect(303, '/admin/editor?ok=raw');
	},

	/**
	 * Roll the save back to a stacked backup.
	 *
	 * The 2013 editor posted `restore<n>`; this posts the index `/editor.json`
	 * handed out, so the two cannot drift apart. The gateway range-checks it.
	 */
	restore: async ({ request, locals }) => {
		requireAdmin(locals);

		const form = await request.formData();
		const index = Number.parseInt(String(form.get('index') ?? ''), 10);
		if (!Number.isSafeInteger(index) || index < 0) {
			return fail(400, { message: 'El índice del respaldo no es válido' });
		}

		const result = await restoreBackup(request, index, locals.user?.zid);
		if (!result.ok) {
			return fail(502, { message: result.message ?? 'No se pudo restaurar el respaldo' });
		}

		return redirect(303, `/admin/editor?ok=restore-${index}`);
	},

	/**
	 * Destructive operations, spelled out so they cannot be reached by a
	 * mistyped URL: wiping the save or rewinding the battle map.
	 */
	danger: async ({ request, locals }) => {
		requireAdmin(locals);

		const form = await request.formData();
		const what = String(form.get('what') ?? '');
		const path = what === 'wipe' ? '/wipe_session' : what === 'deprogress' ? '/deprogress' : null;
		if (!path) return fail(400, { message: `Operación desconocida: ${what}` });

		await fetch(`${config.gateway.origin}${path}`, {
			headers: upstreamHeaders(request, locals),
			redirect: 'manual',
			signal: AbortSignal.timeout(15_000)
		});

		return redirect(303, '/admin/editor?ok=' + encodeURIComponent(what));
	}
};