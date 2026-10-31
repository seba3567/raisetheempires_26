import { all, now, one, run, transact } from '../db/client.ts';
import { recordActivity } from './accounts.ts';
import { GIFT_DEFINITIONS, type GiftView } from '#lib/gifts';

export { GIFT_DEFINITIONS, type GiftView };

export async function sendGift(
	senderId: number,
	receiverId: number,
	giftType = 'energy'
): Promise<number> {
	if (senderId === receiverId) throw new RangeError('No puedes enviarte un regalo a ti mismo.');

	if (!GIFT_DEFINITIONS[giftType]) {
		throw new Error(`Tipo de regalo "${giftType}" no reconocido.`);
	}

	const target = await one<{ username: string }>('SELECT username FROM users WHERE id = ?', receiverId);
	if (!target) throw new Error('El destinatario no existe.');

	const todayGifts = await one<{ count: number }>(
		"SELECT COUNT(*) as count FROM gifts WHERE sender_id = ? AND receiver_id = ? AND created_at >= CURRENT_DATE",
		senderId,
		receiverId
	);
	if (Number(todayGifts?.count ?? 0) >= 10) {
		throw new Error('Has alcanzado el límite diario de suministros (10) para este comandante.');
	}

	const stamp = now();
	await run(
		'INSERT INTO gifts (sender_id, receiver_id, gift_type, claimed, created_at) VALUES (?, ?, ?, FALSE, ?)',
		senderId,
		receiverId,
		giftType,
		stamp
	);

	await recordActivity(senderId, 'gift.send', JSON.stringify({ to: target.username, type: giftType }));

	const row = await one<{ id: number }>('SELECT id FROM gifts WHERE sender_id = ? AND receiver_id = ? ORDER BY id DESC LIMIT 1', senderId, receiverId);
	return row?.id ?? 0;
}

export async function listPendingGifts(receiverId: number): Promise<GiftView[]> {
	const rows = await all<{
		id: number;
		sender_id: number;
		sender_username: string;
		receiver_id: number;
		gift_type: string;
		claimed: boolean;
		created_at: string;
		claimed_at: string | null;
	}>(
		`SELECT g.id, g.sender_id, u.username AS sender_username, g.receiver_id, g.gift_type,
            g.claimed, g.created_at, g.claimed_at
       FROM gifts g
       JOIN users u ON u.id = g.sender_id
      WHERE g.receiver_id = ? AND g.claimed = FALSE
      ORDER BY g.id DESC`,
		receiverId
	);

	return rows.map((r) => {
		const def = GIFT_DEFINITIONS[r.gift_type] ?? {
			label: r.gift_type,
			icon: '🎁',
			rewardDesc: r.gift_type
		};
		return {
			...r,
			gift_label: def.label,
			gift_icon: def.icon
		};
	});
}

export async function claimGift(
	giftId: number,
	receiverId: number
): Promise<{ success: boolean; giftType: string; rewardDesc: string; senderUsername: string }> {
	return transact(async () => {
		const gift = await one<{
			id: number;
			sender_id: number;
			gift_type: string;
			claimed: boolean;
		}>('SELECT id, sender_id, gift_type, claimed FROM gifts WHERE id = ? AND receiver_id = ? FOR UPDATE', giftId, receiverId);

		if (!gift) throw new Error('El regalo no existe o no te pertenece.');
		if (gift.claimed) throw new Error('Este regalo ya ha sido reclamado.');

		const sender = await one<{ username: string }>('SELECT username FROM users WHERE id = ?', gift.sender_id);
		const senderUsername = sender?.username ?? 'un amigo';

		await run('UPDATE gifts SET claimed = TRUE, claimed_at = ? WHERE id = ?', now(), giftId);

		const def = GIFT_DEFINITIONS[gift.gift_type] ?? {
			label: gift.gift_type,
			icon: '🎁',
			rewardDesc: gift.gift_type
		};

		await recordActivity(
			receiverId,
			'gift.claim',
			JSON.stringify({ from: senderUsername, type: gift.gift_type, reward: def.rewardDesc })
		);

		return {
			success: true,
			giftType: gift.gift_type,
			rewardDesc: def.rewardDesc,
			senderUsername
		};
	});
}
