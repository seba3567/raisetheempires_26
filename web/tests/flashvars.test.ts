/**
 * FlashVars.
 *
 * These are the values the compiled SWF reads out of the page, and two of them
 * are load-bearing: get app_url wrong and the game talks straight to Flask,
 * bypassing this service with no error anywhere.
 */
import { describe, expect, test } from 'bun:test';

import { buildFlashVars } from '#lib/server/flashvars';

function parse(flashVars: string): Record<string, string> {
	return Object.fromEntries(flashVars.split('&').map((pair) => pair.split('=', 2)));
}

describe('buildFlashVars', () => {
	test('app_url points at the public origin with a trailing slash', () => {
		// The SWF concatenates "flashservices/gateway.php" straight onto this
		// value, with no joining logic, so the slash is not optional.
		const parsed = parse(buildFlashVars('http://localhost:8080'));
		expect(parsed['app_url']).toBe('http://localhost:8080/');
	});

	test('a trailing slash on the origin is not doubled', () => {
		const parsed = parse(buildFlashVars('http://localhost:8080/'));
		expect(parsed['app_url']).toBe('http://localhost:8080/');
	});

	test('an origin with a port survives intact', () => {
		const parsed = parse(buildFlashVars('https://game.example.com:8443'));
		expect(parsed['app_url']).toBe('https://game.example.com:8443/');
	});

	test('sn_app_url stays present but empty', () => {
		// Config.SN_APP_URL feeds a different endpoint this server does not
		// implement. Removing the key is not the same as sending it empty.
		const parsed = parse(buildFlashVars('http://localhost:8080'));
		expect('sn_app_url' in parsed).toBe(true);
		expect(parsed['sn_app_url']).toBe('');
	});

	test('keeps the flags the client expects', () => {
		const parsed = parse(buildFlashVars('http://localhost:8080'));
		expect(parsed['is_staging']).toBe('true');
		expect(parsed['debugMode']).toBe('true');
		expect(parsed['generateSchema']).toBe('1');
		expect(parsed['stats']).toBe('1');
	});

	test('serverTime is a recent unix timestamp in seconds', () => {
		const parsed = parse(buildFlashVars('http://localhost:8080'));
		const serverTime = Number(parsed['serverTime']);
		const now = Date.now() / 1000;
		expect(Math.abs(now - serverTime)).toBeLessThan(5);
	});

	test('carries no value that would break the ampersand-separated format', () => {
		const flashVars = buildFlashVars('http://localhost:8080');
		expect(flashVars.split('&')).toHaveLength(7);
		expect(flashVars).not.toContain('&&');
	});
});