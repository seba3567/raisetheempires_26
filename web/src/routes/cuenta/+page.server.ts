import { redirect } from '@sveltejs/kit';

import { addFriend, listFriends, suggestFriends } from '#lib/server/models/accounts';
import { getProgress, recordActivity, removeFriend, findByUsername } from '#lib/server/models/accounts';
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

	return {
		user,
		state,
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