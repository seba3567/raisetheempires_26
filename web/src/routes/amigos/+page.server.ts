import { fail, redirect } from '@sveltejs/kit';

import {
	addFriend,
	findById,
	findByUsername,
	getRecentBattles,
	listFriends,
	listPendingIncoming,
	listPendingOutgoing,
	recordActivity,
	recordBattleActivity,
	removeFriend,
	searchUsers,
	suggestFriends,
	updateProgress,
	getProgress,
	getLeaderboard,
	getPvPLeaderboard
} from '#lib/server/models/accounts';
import {
	createClan,
	getUserClan,
	listClanMembers,
	listClanMessages,
	listAllClans,
	addClanMember,
	removeClanMember,
	postClanMessage,
	updateClanName,
	updateClanCrest,
	applyClanWarDamage,
	awardClanXp,
	healClan
} from '#lib/server/models/clans';
import {
	sendGift,
	listPendingGifts,
	claimGift,
	GIFT_DEFINITIONS
} from '#lib/server/models/gifts';
import { fetchPlayerState } from '#lib/server/player';
import { config } from '#lib/server/config';
import { PLAYER_ZID_HEADER } from '#lib/server/proxy';
import { simulateBattle, type BattleReport } from '#lib/combat';
import type { Actions, PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ locals, request, url }) => {
	if (!locals.user) redirect(303, '/entrar');
	const user = locals.user;

	const state = await fetchPlayerState(request, user.zid);
	const stored = await getProgress(user.id);
	const playerLevel = state?.level ?? stored?.level ?? 1;

	const friends = await listFriends(user.id);
	const incoming = await listPendingIncoming(user.id);
	const outgoing = await listPendingOutgoing(user.id);
	const suggestions = await suggestFriends(user.id, 8);
	const battles = await getRecentBattles(user.id, 10);
	const gifts = await listPendingGifts(user.id);

	const userClan = await getUserClan(user.id);
	const clanMembers = userClan ? await listClanMembers(userClan.id) : [];
	const clanMessages = userClan ? await listClanMessages(userClan.id, 30) : [];
	const allClans = await listAllClans(15);
	const leaderboard = await getLeaderboard(25);
	const pvpLeaderboard = await getPvPLeaderboard(25);

	const q = url.searchParams.get('q') ?? '';
	const searchResults = q.trim().length > 0 ? await searchUsers(q, user.id, 10) : [];

	return {
		user,
		playerLevel,
		worldName: state?.worldName ?? stored?.world_name ?? user.username,
		friends,
		incoming,
		outgoing,
		suggestions,
		battles,
		gifts,
		userClan,
		clanMembers,
		clanMessages,
		allClans,
		leaderboard,
		pvpLeaderboard,
		searchResults,
		query: q
	};
};

export const actions: Actions = {
	/** Enviar o aceptar solicitud de amistad */
	add: async ({ request, locals }) => {
		if (!locals.user) redirect(303, '/entrar');

		const form = await request.formData();
		const username = String(form.get('username') ?? '').trim();
		const target = await findByUsername(username);

		if (!target) {
			return fail(404, { message: `No se encontró al comandante "${username}".` });
		}

		if (target.id === locals.user.id) {
			return fail(400, { message: 'No puedes forjar una alianza contigo mismo.' });
		}

		const status = await addFriend(locals.user.id, target.id);
		await recordActivity(
			locals.user.id,
			status === 'accepted' ? 'friend.accept' : 'friend.request',
			target.username
		);

		return {
			success: true,
			status,
			target: target.username,
			message:
				status === 'accepted'
					? `¡Alianza forjada con ${target.username}!`
					: `Solicitud de alianza enviada a ${target.username}.`
		};
	},

	/** Aceptar solicitud entrante de amistad */
	accept: async ({ request, locals }) => {
		if (!locals.user) redirect(303, '/entrar');

		const form = await request.formData();
		const targetId = Number(form.get('userId'));
		if (!Number.isSafeInteger(targetId) || targetId <= 0) {
			return fail(400, { message: 'Identificador de comandante inválido.' });
		}
		const target = await findById(targetId);

		if (target) {
			await addFriend(locals.user.id, target.id);
			await recordActivity(locals.user.id, 'friend.accept', target.username);
			return { success: true, message: `¡Alianza aceptada con ${target.username}!` };
		}
		return fail(404, { message: 'Comandante no encontrado.' });
	},

	/** Rechazar solicitud entrante o cancelar saliente */
	reject: async ({ request, locals }) => {
		if (!locals.user) redirect(303, '/entrar');

		const form = await request.formData();
		const targetId = Number(form.get('userId'));
		if (!Number.isSafeInteger(targetId) || targetId <= 0) {
			return fail(400, { message: 'Identificador de comandante inválido.' });
		}
		const target = await findById(targetId);

		if (target) {
			await removeFriend(locals.user.id, target.id);
			return { success: true, message: `Solicitud rechazada.` };
		}
		return fail(404, { message: 'Comandante no encontrado.' });
	},

	/** Quitar amigo existente */
	remove: async ({ request, locals }) => {
		if (!locals.user) redirect(303, '/entrar');

		const form = await request.formData();
		const targetName = String(form.get('username') ?? '');
		const target = await findByUsername(targetName);

		if (target) {
			await removeFriend(locals.user.id, target.id);
			await recordActivity(locals.user.id, 'friend.remove', target.username);
			return { success: true, message: `Alianza con ${target.username} disuelta.` };
		}
		return fail(404, { message: 'Comandante no encontrado.' });
	},

	/** Enviar regalo duradero a un amigo */
	sendGift: async ({ request, locals }) => {
		if (!locals.user) redirect(303, '/entrar');

		const form = await request.formData();
		const targetUsername = String(form.get('username') ?? '').trim();
		const giftType = String(form.get('giftType') ?? 'energy');

		const target = await findByUsername(targetUsername);
		if (!target) return fail(404, { message: 'Comandante no encontrado.' });
		if (target.id === locals.user.id) {
			return fail(400, { message: 'No puedes enviarte un regalo a ti mismo.' });
		}

		try {
			await sendGift(locals.user.id, target.id, giftType);

			// Notificar al servidor del juego para que aparezca en el inventario/save del destinatario
			try {
				await fetch(`${config.gateway.origin}/api/gift/send`, {
					method: 'POST',
					headers: { 'Content-Type': 'application/json' },
					body: JSON.stringify({
						targetZid: target.zid,
						senderZid: locals.user.zid,
						senderName: locals.user.username,
						giftType
					}),
					signal: AbortSignal.timeout(5_000)
				});
			} catch {}

			const giftInfo = GIFT_DEFINITIONS[giftType] ?? { label: giftType, icon: '🎁' };
			return {
				success: true,
				giftSent: true,
				target: target.username,
				message: `¡Has enviado ${giftInfo.icon} ${giftInfo.label} a ${target.username}!`
			};
		} catch (e: any) {
			return fail(400, { message: e?.message ?? 'No se pudo enviar el regalo.' });
		}
	},

	/** Reclamar regalo recibido de un amigo */
	claimGift: async ({ request, locals }) => {
		if (!locals.user) redirect(303, '/entrar');

		const form = await request.formData();
		const giftId = Number(form.get('giftId'));
		if (!Number.isSafeInteger(giftId) || giftId <= 0) {
			return fail(400, { message: 'Identificador de regalo inválido.' });
		}

		try {
			const claimed = await claimGift(giftId, locals.user.id);

			// Acreditar inmediatamente en la partida viva del jugador en el gateway
			try {
				const headers = new Headers({ [PLAYER_ZID_HEADER]: String(locals.user.zid) });
				const cookie = request.headers.get('cookie');
				if (cookie) headers.set('cookie', cookie);

				await fetch(`${config.gateway.origin}/api/gift/claim`, {
					method: 'POST',
					headers,
					body: new URLSearchParams({ giftType: claimed.giftType, giftId: String(giftId) }),
					signal: AbortSignal.timeout(5_000)
				});
			} catch {}

			return {
				success: true,
				message: `¡Reclamaste ${claimed.rewardDesc} enviado por ${claimed.senderUsername}!`
			};
		} catch (e: any) {
			return fail(400, { message: e?.message ?? 'No se pudo reclamar el regalo.' });
		}
	},

	/** Crear un nuevo Clan / Alianza */
	createClan: async ({ request, locals }) => {
		if (!locals.user) redirect(303, '/entrar');

		const form = await request.formData();
		const name = String(form.get('name') ?? '').trim();
		const crest = String(form.get('crest') ?? 'crest_01').trim();

		if (name.length < 3 || name.length > 32) {
			return fail(400, { message: 'El nombre del clan debe tener entre 3 y 32 caracteres.' });
		}

		try {
			const clan = await createClan(locals.user.id, name, crest);
			return {
				success: true,
				message: `¡La alianza "${clan.name}" ha sido fundada exitosamente!`
			};
		} catch (e: any) {
			return fail(400, { message: e?.message ?? 'Error al fundar la alianza.' });
		}
	},

	/** Unirse a una Alianza existente */
	joinClan: async ({ request, locals }) => {
		if (!locals.user) redirect(303, '/entrar');

		const form = await request.formData();
		const clanId = Number(form.get('clanId'));
		if (!Number.isSafeInteger(clanId) || clanId <= 0) {
			return fail(400, { message: 'Identificador de alianza inválido.' });
		}

		try {
			await addClanMember(clanId, locals.user.id, 'member');
			return {
				success: true,
				message: '¡Te has unido a las filas de la alianza!'
			};
		} catch (e: any) {
			return fail(400, { message: e?.message ?? 'No pudiste unirte a la alianza.' });
		}
	},

	/** Abandonar Alianza actual */
	leaveClan: async ({ request, locals }) => {
		if (!locals.user) redirect(303, '/entrar');

		const form = await request.formData();
		const clanId = Number(form.get('clanId'));
		if (!Number.isSafeInteger(clanId) || clanId <= 0) {
			return fail(400, { message: 'Identificador de alianza inválido.' });
		}

		try {
			await removeClanMember(clanId, locals.user.id);
			return {
				success: true,
				message: 'Has dejado la alianza militar.'
			};
		} catch (e: any) {
			return fail(400, { message: e?.message ?? 'Error al dejar la alianza.' });
		}
	},

	/** Publicar en el muro/feed de la Alianza */
	postClanFeed: async ({ request, locals }) => {
		if (!locals.user) redirect(303, '/entrar');

		const form = await request.formData();
		const clanId = Number(form.get('clanId'));
		if (!Number.isSafeInteger(clanId) || clanId <= 0) {
			return fail(400, { message: 'Identificador de alianza inválido.' });
		}
		const message = String(form.get('message') ?? '').trim();

		try {
			await postClanMessage(clanId, locals.user.id, message);
			return {
				success: true,
				message: 'Mensaje publicado en el muro táctico de la alianza.'
			};
		} catch (e: any) {
			return fail(400, { message: e?.message ?? 'No se pudo publicar el mensaje.' });
		}
	},

	/** Reparar la fortaleza de la Alianza */
	healClan: async ({ request, locals }) => {
		if (!locals.user) redirect(303, '/entrar');

		const form = await request.formData();
		const clanId = Number(form.get('clanId'));
		if (!Number.isSafeInteger(clanId) || clanId <= 0) {
			return fail(400, { message: 'Identificador de alianza inválido.' });
		}
		const userClan = await getUserClan(locals.user.id);

		if (!userClan || userClan.id !== clanId) {
			return fail(403, { message: 'No perteneces a esta alianza militar.' });
		}

		try {
			const newHealth = await healClan(clanId, 25);
			return {
				success: true,
				message: `¡Fortaleza comunal reparada! Salud actual: ${newHealth}/${userClan.max_health} HP.`
			};
		} catch (e: any) {
			return fail(400, { message: e?.message ?? 'No se pudo reparar la fortaleza.' });
		}
	},

	/** Simular y ejecutar batalla táctica PvP contra un amigo */
	battle: async ({ request, locals }) => {
		if (!locals.user) redirect(303, '/entrar');

		const form = await request.formData();
		const opponentUsername = String(form.get('opponent') ?? '').trim();
		const target = await findByUsername(opponentUsername);

		if (!target) {
			return fail(404, { message: 'El oponente no existe.' });
		}

		if (target.id === locals.user.id) {
			return fail(400, { message: 'No puedes combatir en duelo táctico contra ti mismo.' });
		}

		const state = await fetchPlayerState(request, locals.user.zid);
		const stored = await getProgress(locals.user.id);
		const playerLevel = state?.level ?? stored?.level ?? 1;

		const oppProgress = await getProgress(target.id);
		const opponentLevel = oppProgress?.level ?? 10;

		const battleReport: BattleReport = simulateBattle(
			locals.user.username,
			playerLevel,
			target.username,
			opponentLevel
		);

		// 1. Registro de actividad para el atacante
		await recordBattleActivity(locals.user.id, target.username, battleReport.won, {
			role: 'attack',
			xpGained: battleReport.xpGained,
			coinsGained: battleReport.coinsLooted,
			summary: battleReport.summary,
			playerCasualties: battleReport.playerCasualties,
			opponentCasualties: battleReport.opponentCasualties
		});

		// 2. Registro de actividad defensiva para el oponente
		await recordBattleActivity(target.id, locals.user.username, !battleReport.won, {
			role: 'defense',
			xpGained: !battleReport.won ? 100 : 25,
			coinsGained: 0,
			summary: !battleReport.won
				? `Tus defensas insulares repelieron el asalto táctico de ${locals.user.username}.`
				: `Tus defensas sufrieron bajas durante el asalto de ${locals.user.username}.`,
			playerCasualties: battleReport.opponentCasualties,
			opponentCasualties: battleReport.playerCasualties
		});

		// 3. Actualizar progreso persistente de XP en la base de datos
		await updateProgress(locals.user.id, {
			xp: (stored?.xp ?? 0) + battleReport.xpGained
		});

		// 4. Acreditar inmediatamente recursos y XP en la partida viva del gateway / servidor de juego
		try {
			const headers = new Headers({ [PLAYER_ZID_HEADER]: String(locals.user.zid) });
			const cookie = request.headers.get('cookie');
			if (cookie) headers.set('cookie', cookie);

			await fetch(`${config.gateway.origin}/api/pvp/reward`, {
				method: 'POST',
				headers,
				body: new URLSearchParams({
					xp: String(battleReport.xpGained),
					coins: String(battleReport.coinsLooted)
				}),
				signal: AbortSignal.timeout(5_000)
			});
		} catch {}

		// 5. Impacto en la guerra comunal de clanes si ambos pertenecen a alianzas rivales
		try {
			const userClan = await getUserClan(locals.user.id);
			const targetClan = await getUserClan(target.id);
			if (userClan && targetClan && userClan.id !== targetClan.id) {
				if (battleReport.won) {
					await awardClanXp(userClan.id, 50);
					await applyClanWarDamage(targetClan.id, 10);
				} else {
					await awardClanXp(targetClan.id, 25);
					await applyClanWarDamage(userClan.id, 5);
				}
			}
		} catch {}

		return {
			success: true,
			battleReport
		};
	}
};
