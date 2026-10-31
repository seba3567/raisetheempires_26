/**
 * The admin gate on the gateway's cheat and editing routes.
 *
 * These routes existed before accounts: with nothing but a Flask game session,
 * anyone could hand themselves 10,000 Empire Points or open another player's
 * save. Now that this service owns accounts, the gate is asserted here.
 */
import { beforeEach, describe, expect, test } from 'bun:test';

import { accessDenied, adminDecision, adminOnlyPaths, safeDecodePath } from '#lib/access';
import { createUser, isAdmin } from '#lib/server/models/accounts';
import { createSessionValue, readSession } from '#lib/server/session';
import { resetDb } from './helpers.ts';

const ORIGIN = 'http://localhost:8080';

// Awaited for the same reason as in accounts.test.ts: an un-awaited hook lets
// the test body race the TRUNCATE.
beforeEach(async () => {
	await resetDb();
});

describe('accessDenied classification', () => {
	/**
	 * An encoded path used to walk straight past the gate.
	 *
	 * `event.url.pathname` is the raw path, still encoded, while Werkzeug --
	 * which routes the request on the other side -- decodes it before matching
	 * a rule. So `/gazillionaire` was refused and `/%67azillionaire` was not,
	 * and that one reached the route that adds ten thousand coins to the
	 * caller's empire. `/list%5Fsession` handed over every player's session
	 * id, and `/editor%2Fsave` replaced a save outright.
	 */
	test('an encoded path cannot walk past the gate', () => {
		for (const path of [
			'/%67azillionaire',
			'/g%61zillionaire',
			'/list%5Fsession',
			'/%73ave',
			'/editor%2Fsave',
			'/editor%2Frestore',
			'/d%65progress',
			'/wipe%5Fsession',
			'/%61dmin/editor',
			'/api%2Fgift%2Fsend',
			'/patch%2Fplayer%2Fname%2Fstring%2Fbob',
		]) {
			expect(`${path}: ${accessDenied(path)}`).toBe(`${path}: true`);
		}
	});

	test('a doubly encoded path cannot walk past the gate either', () => {
		// %252F is %25 encoded twice: one pass is not enough to see the slash.
		expect(accessDenied('/editor%252Fsave')).toBe(true);
		expect(accessDenied('/%2567azillionaire')).toBe(true);
	});

	test('a path that will not decode is refused', () => {
		// The gate cannot classify what it cannot read, and the safe reading
		// of "cannot tell" is "no".
		expect(accessDenied('/%')).toBe(true);
		expect(accessDenied('/%zz')).toBe(true);
		expect(safeDecodePath('/%')).toBeNull();
	});

	test('an ordinary path is still left open', () => {
		for (const path of ['/juego', '/assets/img/logo.png', '/flashservices/gateway.php']) {
			expect(`${path}: ${accessDenied(path)}`).toBe(`${path}: false`);
		}
	});

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
			'/save',
			'/api/pvp/reward',
			'/api/gift/claim',
			'/api/gift/send',
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
		expect(isAdmin(user)).toBe(true);
		const plain = await createUser('ana', 'hunter2hunter2');
		expect(isAdmin(plain)).toBe(false);
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
	// Awaited: a floating UPDATE let the assertion below read the role before
	// the demotion landed, and the admin kept access he had just lost.
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