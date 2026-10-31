import { beforeEach, describe, expect, test } from 'bun:test';
import {
	sendGift,
	listPendingGifts,
	claimGift,
	GIFT_DEFINITIONS
} from '#lib/server/models/gifts';
import { createUser } from '#lib/server/models/accounts';
import { resetDb } from './helpers.ts';

beforeEach(async () => {
	await resetDb();
});

describe('Gifts Model', () => {
	test('sendGift deposits a pending gift for the receiver', async () => {
		const sender = await createUser('giver_ana', 'hunter2hunter2');
		const receiver = await createUser('receiver_beto', 'hunter2hunter2');

		const giftId = await sendGift(sender.id, receiver.id, 'energy');
		expect(giftId).toBeGreaterThan(0);

		const pending = await listPendingGifts(receiver.id);
		expect(pending).toHaveLength(1);
		expect(pending[0]?.sender_username).toBe('giver_ana');
		expect(pending[0]?.gift_type).toBe('energy');
		expect(pending[0]?.gift_icon).toBe('⚡');
		expect(pending[0]?.claimed).toBe(false);
	});

	test('claimGift marks gift as claimed and records details', async () => {
		const sender = await createUser('giver_carlos', 'hunter2hunter2');
		const receiver = await createUser('receiver_diana', 'hunter2hunter2');

		const giftId = await sendGift(sender.id, receiver.id, 'coins');
		const result = await claimGift(giftId, receiver.id);

		expect(result.success).toBe(true);
		expect(result.giftType).toBe('coins');
		expect(result.senderUsername).toBe('giver_carlos');

		// Gift should no longer appear in pending list
		const pendingAfter = await listPendingGifts(receiver.id);
		expect(pendingAfter).toHaveLength(0);

		// Claiming twice fails
		await expect(claimGift(giftId, receiver.id)).rejects.toThrow('ya ha sido reclamado');
	});

	test('cannot gift yourself', async () => {
		const user = await createUser('lonely_soldier', 'hunter2hunter2');
		await expect(sendGift(user.id, user.id, 'oil')).rejects.toThrow();
	});

	test('rate limiting prevents more than 10 gifts per day to same friend', async () => {
		const sender = await createUser('santa_claus', 'hunter2hunter2');
		const receiver = await createUser('good_kid', 'hunter2hunter2');

		for (let i = 0; i < 10; i++) {
			await sendGift(sender.id, receiver.id, 'wood');
		}

		await expect(sendGift(sender.id, receiver.id, 'wood')).rejects.toThrow('límite diario');
	});
});
