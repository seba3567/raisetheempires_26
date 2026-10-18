/**
 * The admin gate on the gateway's cheat and editing routes.
 *
 * These routes existed before accounts: with nothing but a Flask game session,
 * anyone could hand themselves 10,000 Empire Points or open another player's
 * save. Now that this service owns accounts, the gate is asserted here.
 */
import { beforeEach, describe, expect, test } from 'bun:test';

import { accessDenied, adminDecision, adminOnlyPaths } from '#lib/access';
import { createUser, isAdmin } from '#lib/server/models/accounts';
import { createSessionValue, readSession } from '#lib/server/session';
import { resetDb } from './helpers.ts';

const ORIGIN = 'http://localhost:8080';

beforeEach(() => {
	resetDb();
});

describe('accessDenied classification', () => {
	test('gates every route that mutates game state', () => {
		for (const path of [
			'/save-editor',
			'/gazillionaire',
			'/deprogress',
			'/list_session',
			'/language_editor',
			// Destroys the save; it sat in the reachable list until now.
			'/wipe_session',
			// The editor's own gateway endpoints. They replace the session's
			// user_object wholesale, so leaving them open let any player POST a
			// hand-built save and grant themselves an empire.
			'/editor/save',
			'/editor/restore',
			// The 2013 standalone launcher. /juego is the player now.
			'/ruffle.html',
			'/nodebug.html',
			// The 2013 avatar picker. /registro has no avatar step yet, so
			// deleting this would drop the capability rather than migrate it.
			'/new.html',
			'/chooseavatar/blank.png',
			'/unlock_quest/quest_0100',
			'/complete_quest/quest_0100',
			'/remove_quest/quest_0100',
			// This service's own empire editor and session list, not gateway paths,
			// but they read and write the save exactly like /patch does.
			'/admin/editor',
			'/admin/sessions',
			'/patch/player/name/string/bob',
			'/seed/w/3/z/2',
		]) {
			expect(`${path}: ${accessDenied(path)}`).toBe(`${path}: true`);
		}
	});

	test('leaves the whole game reachable', () => {
		// A client that asks for a path nobody remembered to allow must still work.
		for (const path of [
			'/',
			'/juego',
			'/entrar',
			'/registro',
			'/cuenta',
			'/flashservices/gateway.php',
			'/record_stats.php',
			'/en_US.xml',
			'/questSettings.xml',
			'/gameSettings.xml',
			'/changelog.txt',
			'/assets/game/main.swf',
			'/js/empires.js',
			'/css/zbar.css',
			'/img/avatars/blank.png',
			'/socket.io/',
			// The 2013 friends page used to be open to anyone and dumped every
			// player's world name, level and xp. It is now a redirect into the
			// admin area, so the gate catches the path itself.
			'/friends.html',
		]) {
			expect(`${path}: ${accessDenied(path)}`).toBe(`${path}: false`);
		}
	});

	test('does not gate a prefix that merely looks similar', () => {
		expect(accessDenied('/patchery')).toBe(false);
		expect(accessDenied('/unlock_quests')).toBe(false);
		expect(accessDenied('/save-editor-help')).toBe(false);
		// /editor.json only reads the caller's own save back to them; it is what
		// the editor page loads and a player has no reason to be refused it.
		expect(accessDenied('/editor.json')).toBe(false);
	});
});

describe('adminDecision', () => {
	test('opens admin routes to admins only', () => {
		expect(adminDecision('/save-editor', { role: 'admin' })).toBe('allow');
		expect(adminDecision('/save-editor', { role: 'player' })).toBe('forbid');
		expect(adminDecision('/save-editor', null)).toBe('redirect-login');
	});

	test('leaves ordinary routes alone whatever the role is', () => {
		for (const user of [{ role: 'admin' }, { role: 'player' }, null]) {
			expect(adminDecision('/juego', user)).toBe('allow');
			expect(adminDecision('/home.html', user)).toBe('allow');
		}
	});

	test('an unknown role is not an admin', () => {
		expect(adminDecision('/save-editor', { role: 'superuser' })).toBe('forbid');
		expect(adminDecision('/save-editor', { role: '' })).toBe('forbid');
	});
});

describe('role and session round trip', () => {
	test('a forged cookie does not grant admin', async () => {
		const forged = new Request(`${ORIGIN}/save-editor`, {
			headers: { cookie: 'rte_session=1.forged' },
		});
		expect(await readSession(forged)).toBeNull();
		expect(adminDecision('/save-editor', await userFor(forged))).toBe('redirect-login');
	});

	test('a demoted admin loses access on the next request', async () => {
		const { user, cookie } = await makeUser('root', 'admin');
		expect(adminDecision('/save-editor', { role: user.role })).toBe('allow');

		await demote(user.id);

		const refreshed = await userFor(new Request(`${ORIGIN}/save-editor`, { headers: { cookie } }));
		expect(adminDecision('/save-editor', refreshed)).toBe('forbid');
	});

	test('isAdmin agrees with the decision', async () => {
		const { user } = await makeUser('root', 'admin');
		expect(await isAdmin(user)).toBe(true);
		const plain = await createUser('ana', 'hunter2hunter2');
		expect(await isAdmin(plain)).toBe(false);
	});
});

async function makeUser(username: string, role: 'player' | 'admin') {
	const user = await createUser(username, 'hunter2hunter2', role);
	const cookie = await createSessionValue(user.id);
	const request = new Request(`${ORIGIN}/`, { headers: { cookie: `rte_session=${cookie}` } });
	return { user, cookie: request.headers.get('cookie') ?? '' };
}

/** Resolve a request's cookie to the account it belongs to. */
async function userFor(request: Request) {
	const id = await readSession(request);
	if (id === null) return null;
	const { findById } = await import('#lib/server/models/accounts');
	return await findById(id);
}

async function demote(userId: number) {
	const { run } = await import('#lib/server/db/client');
	await run('UPDATE users SET role = ? WHERE id = ?', 'player', userId);
}

describe('adminOnlyPaths', () => {
	test('lists every gated family', () => {
		const listed = adminOnlyPaths().join(' ');
		for (const needle of [
			'/save-editor',
			'/gazillionaire',
			'/patch/',
			'/list_session',
			'/editor/save',
			'/editor/restore'
		]) {
			expect(`${needle}: ${listed.includes(needle)}`).toBe(`${needle}: true`);
		}
	});
});