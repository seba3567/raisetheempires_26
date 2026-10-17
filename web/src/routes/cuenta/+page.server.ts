import { redirect } from '@sveltejs/kit';

import { addFriend, listFriends, suggestFriends } from '#lib/server/models/accounts';
import { getProgress, recordActivity, removeFriend, findByUsername } from '#lib/server/models/accounts';
import type { Actions, PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ locals }) => {
	if (!locals.user) redirect(303, '/entrar');
	const user = locals.user;

	const progress = getProgress(user.id);

	return {
		user,
		progress: {
			level: progress?.level ?? 1,
			xp: progress?.xp ?? 0,
			worldName: progress?.world_name ?? user.username
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