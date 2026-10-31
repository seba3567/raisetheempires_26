import { all, now, one, run, transact } from '../db/client.ts';

export interface Clan {
	id: number;
	name: string;
	crest: string;
	level: number;
	xp: number;
	health: number;
	max_health: number;
	slots: number;
	leader_id: number;
	created_at: string;
	updated_at: string;
}

export interface ClanMemberView {
	user_id: number;
	username: string;
	zid: number;
	role: string;
	level: number | null;
	world_name: string | null;
	joined_at: string;
}

export const VALID_CRESTS = ['crest_01', 'crest_02', 'crest_03', 'crest_04', 'crest_05'];

export async function createClan(
	leaderId: number,
	name: string,
	crest = 'crest_01'
): Promise<Clan> {
	const stamp = now();
	const safeCrest = VALID_CRESTS.includes(crest) ? crest : 'crest_01';
	return transact(async () => {
		const existing = await one<{ id: number }>(
			'SELECT clan_id AS id FROM clan_members WHERE user_id = ?',
			leaderId
		);
		if (existing) {
			throw new Error('Ya perteneces a una alianza o clan.');
		}

		await run(
			`INSERT INTO clans (name, crest, level, xp, health, max_health, slots, leader_id, created_at, updated_at)
       VALUES (?, ?, 1, 0, 100, 100, 10, ?, ?, ?)`,
			name.trim(),
			safeCrest,
			leaderId,
			stamp,
			stamp
		);

		const clan = await one<Clan>('SELECT * FROM clans WHERE leader_id = ? ORDER BY id DESC LIMIT 1', leaderId);
		if (!clan) throw new Error('Error al crear clan en la base de datos.');

		await run(
			'INSERT INTO clan_members (clan_id, user_id, role, joined_at) VALUES (?, ?, ?, ?)',
			clan.id,
			leaderId,
			'leader',
			stamp
		);

		return clan;
	});
}

export async function getClanById(clanId: number): Promise<Clan | null> {
	return one<Clan>('SELECT * FROM clans WHERE id = ?', clanId);
}

export async function getUserClan(userId: number): Promise<Clan | null> {
	return one<Clan>(
		`SELECT c.* FROM clans c
       JOIN clan_members cm ON cm.clan_id = c.id
      WHERE cm.user_id = ?`,
		userId
	);
}

export async function listClanMembers(clanId: number): Promise<ClanMemberView[]> {
	return all<ClanMemberView>(
		`SELECT u.id AS user_id, u.username, u.zid, cm.role, p.level, p.world_name, cm.joined_at
       FROM clan_members cm
       JOIN users u ON u.id = cm.user_id
       LEFT JOIN progress p ON p.user_id = u.id
      WHERE cm.clan_id = ?
      ORDER BY CASE WHEN cm.role = 'leader' THEN 0 WHEN cm.role = 'officer' THEN 1 ELSE 2 END, u.username`,
		clanId
	);
}

export async function addClanMember(
	clanId: number,
	userId: number,
	role = 'member'
): Promise<void> {
	const currentClan = await getUserClan(userId);
	if (currentClan) {
		throw new Error('Ya perteneces a una alianza militar. Debes abandonarla antes de unirte a otra.');
	}

	const clan = await getClanById(clanId);
	if (!clan) throw new Error('El clan no existe.');

	const count = await one<{ count: number }>(
		'SELECT COUNT(*) as count FROM clan_members WHERE clan_id = ?',
		clanId
	);
	if ((count?.count ?? 0) >= clan.slots) {
		throw new Error('El clan ha alcanzado el límite máximo de miembros.');
	}

	await run(
		'INSERT INTO clan_members (clan_id, user_id, role, joined_at) VALUES (?, ?, ?, ?)',
		clanId,
		userId,
		role,
		now()
	);
}

export async function removeClanMember(clanId: number, userId: number): Promise<void> {
	const clan = await getClanById(clanId);
	if (!clan) return;

	await transact(async () => {
		await run('DELETE FROM clan_members WHERE clan_id = ? AND user_id = ?', clanId, userId);

		if (clan.leader_id === userId) {
			const nextLead = await one<{ user_id: number }>(
				'SELECT user_id FROM clan_members WHERE clan_id = ? ORDER BY joined_at ASC LIMIT 1',
				clanId
			);
			if (nextLead) {
				await run('UPDATE clans SET leader_id = ?, updated_at = ? WHERE id = ?', nextLead.user_id, now(), clanId);
				await run("UPDATE clan_members SET role = 'leader' WHERE clan_id = ? AND user_id = ?", clanId, nextLead.user_id);
			} else {
				await run('DELETE FROM clans WHERE id = ?', clanId);
			}
		}
	});
}

export async function updateClanName(clanId: number, leaderId: number, newName: string): Promise<void> {
	const clan = await getClanById(clanId);
	if (!clan || clan.leader_id !== leaderId) throw new Error('Permiso denegado: solo el líder puede cambiar el nombre.');
	await run('UPDATE clans SET name = ?, updated_at = ? WHERE id = ?', newName.trim(), now(), clanId);
}

export async function updateClanCrest(clanId: number, leaderId: number, newCrest: string): Promise<void> {
	const clan = await getClanById(clanId);
	if (!clan || clan.leader_id !== leaderId) throw new Error('Permiso denegado: solo el líder puede cambiar el blasón.');
	await run('UPDATE clans SET crest = ?, updated_at = ? WHERE id = ?', newCrest, now(), clanId);
}

export async function listAllClans(limit = 20): Promise<Array<Clan & { member_count: number; leader_name: string }>> {
	const rows = await all<any>(
		`SELECT c.*, COUNT(cm.user_id) AS member_count, u.username AS leader_name
       FROM clans c
       JOIN users u ON u.id = c.leader_id
       LEFT JOIN clan_members cm ON cm.clan_id = c.id
      GROUP BY c.id, u.username
      ORDER BY c.level DESC, c.xp DESC, member_count DESC
      LIMIT ?`,
		limit
	);
	return rows.map((r) => ({
		...r,
		member_count: Number(r.member_count)
	}));
}

export interface ClanMessageView {
	id: number;
	user_id: number;
	username: string;
	message: string;
	created_at: string;
}

export async function applyClanWarDamage(clanId: number, damage: number): Promise<number> {
	if (!Number.isFinite(damage) || damage <= 0) return 0;
	const safeDmg = Math.floor(damage);
	const clan = await getClanById(clanId);
	if (!clan) return 0;
	const newHealth = Math.max(0, clan.health - safeDmg);
	await run('UPDATE clans SET health = ?, updated_at = ? WHERE id = ?', newHealth, now(), clanId);
	return newHealth;
}

export async function awardClanXp(clanId: number, xpToAdd: number): Promise<void> {
	if (!Number.isFinite(xpToAdd) || xpToAdd <= 0) return;
	const safeXp = Math.floor(xpToAdd);
	const clan = await getClanById(clanId);
	if (!clan) return;
	let newXp = Number(clan.xp) + safeXp;
	let newLevel = Number(clan.level);
	const xpNeededForNext = newLevel * 1000;
	if (newXp >= xpNeededForNext) {
		newLevel += 1;
		newXp -= xpNeededForNext;
	}
	await run('UPDATE clans SET xp = ?, level = ?, updated_at = ? WHERE id = ?', newXp, newLevel, now(), clanId);
}

export async function healClan(clanId: number, healAmount: number): Promise<number> {
	if (!Number.isFinite(healAmount) || healAmount <= 0) return 0;
	const safeHeal = Math.floor(healAmount);
	const clan = await getClanById(clanId);
	if (!clan) return 0;
	const newHealth = Math.min(clan.max_health, clan.health + safeHeal);
	await run('UPDATE clans SET health = ?, updated_at = ? WHERE id = ?', newHealth, now(), clanId);
	return newHealth;
}

export async function postClanMessage(
	clanId: number,
	userId: number,
	message: string
): Promise<void> {
	const cleaned = message.trim();
	if (!cleaned) throw new Error('El mensaje no puede estar vacío.');
	if (cleaned.length > 500) throw new Error('El mensaje no puede superar los 500 caracteres.');

	const member = await one<{ role: string }>(
		'SELECT role FROM clan_members WHERE clan_id = ? AND user_id = ?',
		clanId,
		userId
	);
	if (!member) throw new Error('Debes ser miembro de la alianza para publicar en su muro táctico.');

	await run(
		'INSERT INTO clan_messages (clan_id, user_id, message, created_at) VALUES (?, ?, ?, ?)',
		clanId,
		userId,
		cleaned,
		now()
	);
}

export async function listClanMessages(clanId: number, limit = 20): Promise<ClanMessageView[]> {
	const rows = await all<ClanMessageView>(
		`SELECT cm.id, cm.user_id, u.username, cm.message, cm.created_at
       FROM clan_messages cm
       JOIN users u ON u.id = cm.user_id
      WHERE cm.clan_id = ?
      ORDER BY cm.id DESC
      LIMIT ?`,
		clanId,
		limit
	);
	return rows.reverse();
}
