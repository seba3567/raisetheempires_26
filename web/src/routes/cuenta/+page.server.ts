import { fail, redirect } from '@sveltejs/kit';

import { addFriend, listFriends, suggestFriends } from '#lib/server/models/accounts';
import { getProgress, recordActivity, removeFriend, findByUsername } from '#lib/server/models/accounts';
import { chooseAvatar, fetchAvatarState } from '#lib/server/avatar';
import { fetchPlayerState } from '#lib/server/player';
import type { Actions, PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ locals, request }) => {
	if (!locals.user) redirect(303, '/entrar');
	const user = locals.user;

	/*
	 * Level, XP and resources come from the save, not from the account.
	 *
	 * The `progress` table was the original plan, but nothing in the game ever
	 * wrote to it, so it reported level 1 and 0 XP next to a level 85 empire.
	 * It is kept only as the fallback for an account that has never played.
	 */
	const state = await fetchPlayerState(request, user.zid);
	const stored = getProgress(user.id);
	const hasSave = state?.hasSave ?? false;

	// The catalogue, so this page does not hardcode the filenames. `state.picture`
	// already carries the current choice, but reading it from the same endpoint
	// that lists the alternatives means the two can never disagree.
	const avatar = await fetchAvatarState(request, user.zid);

	return {
		user,
		state,
		avatar,
		progress: {
			level: hasSave ? (state?.level ?? null) : (stored?.level ?? 1),
			xp: hasSave ? (state?.xp ?? null) : (stored?.xp ?? 0),
			worldName: (hasSave ? state?.worldName : null) ?? stored?.world_name ?? user.username,
			empirePoints: hasSave ? (state?.empirePoints ?? null) : null,
			resources: state?.resources ?? {},
			picture: state?.picture ?? null
		},
		friends: listFriends(user.id),
		suggestions: suggestFriends(user.id)
	};
};

export const actions: Actions = {
	/**
	 * Change the account's avatar.
	 *
	 * This is not an account setting -- it writes `profilePic` on the save,
	 * which is where the game has always kept it and where the client reads it
	 * from. `/snapi.json` hands it back as `pic_square` on every ExternalInterface
	 * call, and the friend lists and the empire editor read the same field, so
	 * one write here moves the picture everywhere the player is seen.
	 *
	 * That is also why it is not a column on `users`: a second copy would be a
	 * second thing to fall out of step with the game.
	 */
	pickAvatar: async ({ request, locals }) => {
		if (!locals.user) redirect(303, '/entrar');

		const state = await fetchAvatarState(request, locals.user.zid);
		if (!state) {
			return fail(502, { avatarMessage: 'El servidor del juego no respondió' });
		}

		const form = await request.formData();
		const file = String(form.get('avatar') ?? '');
		// Checked against what the gateway listed, never against the form: the
		// route this reaches takes the name as a path parameter.
		if (!state.avatars.includes(file)) {
			return fail(400, { avatarMessage: 'Ese avatar no existe' });
		}

		if (!(await chooseAvatar(request, file, locals.user.zid))) {
			return fail(502, { avatarMessage: 'No se pudo guardar el avatar' });
		}

		return { avatarPicked: file };
	},

	add: async ({ request, locals }) => {
		if (!locals.user) redirect(303, '/entrar');

		const form = await request.formData();
		const target = findByUsername(String(form.get('friend') ?? ''));
		if (target) {
			addFriend(locals.user.id, target.id);
			recordActivity(locals.user.id, 'friend.add', target.username);
		}
		return { added: target?.username ?? null };
	},

	remove: async ({ request, locals }) => {
		if (!locals.user) redirect(303, '/entrar');

		const form = await request.formData();
		const target = findByUsername(String(form.get('friend') ?? ''));
		if (target) {
			removeFriend(locals.user.id, target.id);
			recordActivity(locals.user.id, 'friend.remove', target.username);
		}
		return { removed: target?.username ?? null };
	}
};