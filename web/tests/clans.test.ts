import { beforeEach, describe, expect, test } from 'bun:test';
import {
	createClan,
	getClanById,
	getUserClan,
	listClanMembers,
	addClanMember,
	removeClanMember,
	updateClanName,
	updateClanCrest,
	listAllClans,
	postClanMessage,
	listClanMessages,
	applyClanWarDamage,
	awardClanXp,
	healClan
} from '#lib/server/models/clans';
import { createUser } from '#lib/server/models/accounts';
import { resetDb } from './helpers.ts';

beforeEach(async () => {
	await resetDb();
});

describe('Clans Model', () => {
	test('createClan sets up clan and assigns creator as leader', async () => {
		const leader = await createUser('clan_leader', 'hunter2hunter2');
		const clan = await createClan(leader.id, 'Fuerza Élite', 'crest_05');

		expect(clan.id).toBeGreaterThan(0);
		expect(clan.name).toBe('Fuerza Élite');
		expect(clan.crest).toBe('crest_05');
		expect(clan.leader_id).toBe(leader.id);

		const userClan = await getUserClan(leader.id);
		expect(userClan?.id).toBe(clan.id);

		const members = await listClanMembers(clan.id);
		expect(members).toHaveLength(1);
		expect(members[0]?.role).toBe('leader');
		expect(members[0]?.username).toBe('clan_leader');
	});

	test('addClanMember and removeClanMember manages membership', async () => {
		const leader = await createUser('leader_two', 'hunter2hunter2');
		const member = await createUser('soldier_one', 'hunter2hunter2');

		const clan = await createClan(leader.id, 'Legión Delta');
		await addClanMember(clan.id, member.id, 'member');

		let members = await listClanMembers(clan.id);
		expect(members).toHaveLength(2);

		await removeClanMember(clan.id, member.id);
		members = await listClanMembers(clan.id);
		expect(members).toHaveLength(1);
		expect(members[0]?.username).toBe('leader_two');
	});

	test('updateClanName and updateClanCrest require leader privileges', async () => {
		const leader = await createUser('alpha_lead', 'hunter2hunter2');
		const rogue = await createUser('rogue_user', 'hunter2hunter2');

		const clan = await createClan(leader.id, 'Original Name', 'crest_01');

		await expect(updateClanName(clan.id, rogue.id, 'Stolen Name')).rejects.toThrow('Permiso denegado');
		await expect(updateClanCrest(clan.id, rogue.id, 'crest_99')).rejects.toThrow('Permiso denegado');

		await updateClanName(clan.id, leader.id, 'Updated Vanguard');
		await updateClanCrest(clan.id, leader.id, 'crest_08');

		const updated = await getClanById(clan.id);
		expect(updated?.name).toBe('Updated Vanguard');
		expect(updated?.crest).toBe('crest_08');
	});

	test('listAllClans returns clans with counts and leader', async () => {
		const leader = await createUser('top_general', 'hunter2hunter2');
		await createClan(leader.id, 'Alianza Suprema');

		const allClans = await listAllClans();
		expect(allClans.length).toBeGreaterThan(0);
		expect(allClans[0]?.leader_name).toBe('top_general');
		expect(allClans[0]?.member_count).toBe(1);
	});

	test('postClanMessage and listClanMessages manage alliance communication', async () => {
		const leader = await createUser('comm_leader', 'hunter2hunter2');
		const clan = await createClan(leader.id, 'Comando Conjunto');

		await postClanMessage(clan.id, leader.id, '¡Iniciando ofensiva en el sector norte!');
		await postClanMessage(clan.id, leader.id, 'Refuerzos en camino.');

		const messages = await listClanMessages(clan.id);
		expect(messages).toHaveLength(2);
		expect(messages[0]?.message).toBe('¡Iniciando ofensiva en el sector norte!');
		expect(messages[1]?.message).toBe('Refuerzos en camino.');
		expect(messages[0]?.username).toBe('comm_leader');
	});

	test('cannot join multiple clans simultaneously', async () => {
		const leader1 = await createUser('chief_one', 'hunter2hunter2');
		const leader2 = await createUser('chief_two', 'hunter2hunter2');
		const soldier = await createUser('nomad_soldier', 'hunter2hunter2');

		const clan1 = await createClan(leader1.id, 'Clan Alpha');
		const clan2 = await createClan(leader2.id, 'Clan Bravo');

		await addClanMember(clan1.id, soldier.id);
		await expect(addClanMember(clan2.id, soldier.id)).rejects.toThrow('Ya perteneces a una alianza');
	});

	test('leader removal promotes senior member, deletes clan if empty', async () => {
		const leader = await createUser('solo_leader', 'hunter2hunter2');
		const second = await createUser('second_in_command', 'hunter2hunter2');

		const clan = await createClan(leader.id, 'Legión Fénix');
		await addClanMember(clan.id, second.id);

		// Leader leaves: second should be promoted to leader
		await removeClanMember(clan.id, leader.id);
		let updated = await getClanById(clan.id);
		expect(updated?.leader_id).toBe(second.id);

		// Last member leaves: clan should be dissolved
		await removeClanMember(clan.id, second.id);
		updated = await getClanById(clan.id);
		expect(updated).toBeNull();
	});

	test('non-members cannot post to clan tactical wall', async () => {
		const leader = await createUser('wall_lead', 'hunter2hunter2');
		const outsider = await createUser('wall_spy', 'hunter2hunter2');
		const clan = await createClan(leader.id, 'Muralla Blindada');

		await expect(
			postClanMessage(clan.id, outsider.id, 'Espiando las comunicaciones...')
		).rejects.toThrow('Debes ser miembro');
	});

	test('clan war damage, healing, and xp progression', async () => {
		const leader = await createUser('war_general', 'hunter2hunter2');
		const clan = await createClan(leader.id, 'Fuerza Titán');

		// Initial health is 100
		expect(clan.health).toBe(100);

		// Take war damage
		const damagedHp = await applyClanWarDamage(clan.id, 30);
		expect(damagedHp).toBe(70);

		// Heal fortress
		const healedHp = await healClan(clan.id, 20);
		expect(healedHp).toBe(90);

		// Cannot overheat past max_health
		const maxedHp = await healClan(clan.id, 50);
		expect(maxedHp).toBe(100);

		// Award XP and test level-up
		await awardClanXp(clan.id, 1200);
		const leveledClan = await getClanById(clan.id);
		expect(leveledClan?.level).toBe(2);
		expect(Number(leveledClan?.xp)).toBe(200);
	});
});
