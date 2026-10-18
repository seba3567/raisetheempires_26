import { describe, expect, test } from 'bun:test';

import { parseDotEnv } from '#lib/server/config';

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