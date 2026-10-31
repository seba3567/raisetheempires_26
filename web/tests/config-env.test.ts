import { describe, expect, test } from 'bun:test';

import {
	adapterServerOptions,
	config,
	parseBytes,
	parseDotEnv,
	resolvePublicOrigin,
	resolveRequestOrigin,
	resolveTrustedOrigins
} from '#lib/server/config';
import { contract, databaseUrl, envValue, gatewayOrigin } from '#lib/server/contract';
import { PLAYER_ZID_HEADER } from '#lib/server/proxy';

// The `.env` lookup exists because the project documents `/web/.env` as the way
// to configure this service, and without it every page answered 500 with
// "SESSION_SECRET is not set". These tests pin the parsing, which is where that
// actually broke: a file with Windows line endings parsed as completely empty.

describe('parseDotEnv', () => {
	test('reads plain KEY=VALUE lines', () => {
		expect(parseDotEnv('A=1\nB=two')).toEqual({ A: '1', B: 'two' });
	});

	// The one that matters. `.` in JavaScript matches everything except a line
	// terminator and `\r` is one, so `(.*)$` could never reach the end of a line
	// that still carried its carriage return -- every entry failed to match, and
	// the file looked empty. PowerShell writes CRLF by default, so this is the
	// normal file on this machine, not an exotic one.
	test('reads a file with Windows line endings', () => {
		expect(parseDotEnv('SESSION_SECRET=abc123\r\nGATEWAY_ORIGIN=http://x\r\n')).toEqual({
			SESSION_SECRET: 'abc123',
			GATEWAY_ORIGIN: 'http://x'
		});
	});

	test('a CRLF file gives the same answer as an LF one', () => {
		const body = 'A=1\nB=2\nC=3';
		expect(parseDotEnv(body.replace(/\n/g, '\r\n'))).toEqual(parseDotEnv(body));
	});

	test('the secret keeps its exact length, so no \r rides along', () => {
		// A trailing \r would still sign and verify, which is what makes this so
		// easy to miss: nothing looks wrong until the value is compared byte for
		// byte, or the HMAC stops matching between machines.
		const value = parseDotEnv('SESSION_SECRET=abcdef\r\n').SESSION_SECRET;
		expect(value).toBe('abcdef');
		expect(value).toHaveLength(6);
	});

	test('ignores blank lines and comments', () => {
		expect(parseDotEnv('\n# a comment\nA=1\n\n   \nB=2\n')).toEqual({ A: '1', B: '2' });
	});

	test('strips one layer of quoting', () => {
		expect(parseDotEnv('A="two words"\nB=\'three words\'')).toEqual({
			A: 'two words',
			B: 'three words'
		});
	});

	test('keeps an empty value rather than dropping the key', () => {
		expect(parseDotEnv('EMPTY=')).toEqual({ EMPTY: '' });
	});

	test('keeps a # that is part of a value', () => {
		expect(parseDotEnv('COLOUR=#ff0000')).toEqual({ COLOUR: '#ff0000' });
	});

	test('trims surrounding whitespace', () => {
		expect(parseDotEnv('  A  =  value  ')).toEqual({ A: 'value' });
	});

	test('an empty file yields nothing', () => {
		expect(parseDotEnv('')).toEqual({});
	});

	test('a line with no equals sign is not a setting', () => {
		expect(parseDotEnv('JUST_A_LINE\nA=1')).toEqual({ A: '1' });
	});

	test('the last line needs no trailing newline', () => {
		expect(parseDotEnv('A=1\r\nB=2')).toEqual({ A: '1', B: '2' });
	});
});

/**
 * The port and the origin have to describe the same server.
 *
 * This is not a style rule. The Bun adapter rewrites every incoming request
 * onto the origin baked into the build, and SvelteKit compares the request's
 * `Origin` header against the origin of the rewritten URL. When the server
 * answers on one port and the build named another, every page still loaded
 * and every form POST -- the login included -- came back 403 "Cross-site
 * POST form submissions are forbidden", which reads like a CSRF problem and
 * not like the port being wrong.
 */
describe('the public origin', () => {
	test('falls back to the port when none is configured', () => {
		expect(resolvePublicOrigin(undefined, 8080)).toBe('http://localhost:8080');
	});

	test('an explicit origin wins', () => {
		expect(resolvePublicOrigin('https://game.example.com', 8080)).toBe(
			'https://game.example.com'
		);
	});

	test('the origin names the port the adapter binds', () => {
		for (const port of [8080, 3000, 9000]) {
			const origin = resolvePublicOrigin(undefined, port);
			expect(new URL(origin).port).toBe(String(port));
			expect(adapterServerOptions(port, '0.0.0.0').port).toBe(port);
		}
	});

	test('the adapter is told the port, so it cannot fall back to 3000', () => {
		// The adapter's own default is 3000. It only reads PORT and HOST from
		// the process environment, and a .env file is not the process
		// environment, so without this the server landed on 3000 while the
		// origin pointed at 8080.
		const options = adapterServerOptions(8080, '0.0.0.0');
		expect(options.port).toBe(8080);
		expect(options.hostname).toBe('0.0.0.0');
	});
});

/**
 * The runtime contract.
 *
 * The two runtimes of this project are separate programs in two languages, and
 * every value that crosses the seam between them is written down once, in
 * `contract/runtime.json`. The Python gateway reads that file through
 * `contract.py`; this service reads it through `#lib/server/contract`.
 *
 * These tests are what makes that a guarantee rather than a habit: if this
 * service stops deriving its configuration from the contract, they fail.
 */
describe('the runtime contract', () => {
	test('the contract-derived defaults match the contract', () => {
		// These are the values the service falls back to when the environment
		// says nothing, so they have to be built from the contract rather than
		// written out again.
		const { host, port, user, password, name } = contract.database;
		expect(databaseUrl()).toBe(`postgres://${user}:${password}@${host}:${port}/${name}`);
		expect(gatewayOrigin()).toBe(`http://${contract.gateway.host}:${contract.gateway.port}`);
	});

	test('the player id header comes from the contract', () => {
		// Nothing overrides this one, so it is a straight comparison: the
		// header name is written down once, and both runtimes read it.
		expect(config.headers.playerZid).toBe(contract.headers.playerZid);
		expect(PLAYER_ZID_HEADER).toBe(contract.headers.playerZid);
	});

	test('the origin the build bakes names the port the server binds', () => {
		// The bug this project shipped once: the server bound one port and
		// the build baked an origin naming another. The adapter rewrites every
		// request onto that baked origin and SvelteKit refuses any form POST
		// whose Origin header names somewhere else, so the login answered 403
		// while every page loaded normally.
		expect(new URL(config.publicOrigin).port).toBe(String(config.port));
	});

	test('the request origin and the built origin agree', () => {
		// The proxy's Host header and the FlashVars' app_url have to be the
		// same value: the first is what Flask builds the game's gateway URL
		// out of, and the second is what the game is told to call.
		const requestUrl = new URL('http://localhost:8080/juego');
		expect(resolveRequestOrigin(requestUrl)).toBe(config.publicOrigin);
	});
});

/**
 * One name per fact, across the two runtimes.
 *
 * The same deployment configures both halves, so a fact that crosses the seam
 * has to have one name. It used to have two: the gateway called the database
 * `SAVE_STORE_PATH` and the front door called it `RTE_DB_URL`; the front door
 * called the origin `PUBLIC_ORIGIN` and the gateway called it `WEB_ORIGIN`.
 * An operator who set one of each pair left the two halves pointing at
 * different places -- the gateway writing saves to a database the front door
 * never read.
 */
describe('the environment names', () => {
	test('the canonical names are the ones the front door ships', () => {
		expect(contract.env.databaseUrl).toBe('RTE_DB_URL');
		expect(contract.env.publicOrigin).toBe('PUBLIC_ORIGIN');
		expect(contract.env.gatewayOrigin).toBe('GATEWAY_ORIGIN');
	});

	test('the old names still work', () => {
		const environment = { SAVE_STORE_PATH: 'postgres://old', WEB_ORIGIN: 'http://old' };
		expect(envValue(contract.env.databaseUrl, environment)).toBe('postgres://old');
		expect(envValue(contract.env.publicOrigin, environment)).toBe('http://old');
	});

	test('the canonical name wins over the alias', () => {
		const environment = { RTE_DB_URL: 'postgres://new', SAVE_STORE_PATH: 'postgres://old' };
		expect(envValue(contract.env.databaseUrl, environment)).toBe('postgres://new');
	});

	test('an unset variable is undefined', () => {
		expect(envValue('NOT_SET_ANYWHERE', {})).toBeUndefined();
	});
});

/**
 * A size in bytes, written the way a human writes one.
 *
 * `Number.parseInt("5MB", 10)` is **5**. The shipped `.env.example` writes
 * `GATEWAY_MAX_BODY=5MB`, so a clean checkout that followed the documented
 * convention got a five-byte limit and the proxy answered 413 "payload too
 * large" to every AMF0 request -- the whole game dead, with a limit nobody
 * could see.
 */
describe('sizes', () => {
	test('reads plain bytes', () => {
		expect(parseBytes('5242880')).toBe(5242880);
	});

	test('reads the suffixes the way they are written', () => {
		expect(parseBytes('5MB')).toBe(5 * 1024 * 1024);
		expect(parseBytes('6MB')).toBe(6 * 1024 * 1024);
		expect(parseBytes('512KB')).toBe(512 * 1024);
		expect(parseBytes('1G')).toBe(1024 ** 3);
	});

	test('is not fooled by a suffix it does not know', () => {
		expect(parseBytes('5 potatoes')).toBeUndefined();
		expect(parseBytes('')).toBeUndefined();
	});
});

/**
 * The trusted origins.
 *
 * The origins allowed to POST a form besides the baked one.
 *
 * The adapter rewrites every request onto the baked origin, so reaching the
 * site under another name leaves the `Origin` header pointing elsewhere and
 * the form is refused. The loopback aliases are the same machine talking to
 * itself, so they are allowed; nothing else is, because a public deployment
 * has to name its own.
 */
describe('trusted origins', () => {
	test('a loopback origin trusts its aliases', () => {
		const trusted = resolveTrustedOrigins('http://localhost:8080');
		expect(trusted).toContain('http://localhost:8080');
		expect(trusted).toContain('http://127.0.0.1:8080');
	});

	test('a public origin trusts nothing by itself', () => {
		expect(resolveTrustedOrigins('https://game.example.com')).toEqual([]);
	});

	test('a public origin trusts only what it was told', () => {
		const trusted = resolveTrustedOrigins('https://game.example.com', ['https://alias.example.com']);
		expect(trusted).toEqual(['https://alias.example.com']);
	});

	test('an unparseable origin trusts only what it was told', () => {
		expect(resolveTrustedOrigins('not an origin', ['https://alias.example.com'])).toEqual([
			'https://alias.example.com'
		]);
	});
});