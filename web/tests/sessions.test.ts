/**
 * The admin session list.
 *
 * The two conversions here exist because the save does not hold them in the
 * shape the page wants: xp is a quoted string in some worlds, and the store key
 * carries a `session:` prefix the cookie does not.
 */
import { describe, expect, test } from 'bun:test';

import { cookieValueOf, xpAsNumber } from '#lib/sessions';

describe('xpAsNumber', () => {
	test('accepts the number a fresh world has', () => {
		expect(xpAsNumber(0)).toBe(0);
		expect(xpAsNumber(234462)).toBe(234462);
	});

	test('accepts the string an older save has', () => {
		// The live save reports xp as "234462" while level stays a number.
		expect(xpAsNumber('234462')).toBe(234462);
	});

	test('does not print NaN for a value it cannot read', () => {
		expect(xpAsNumber(null)).toBeNull();
		expect(xpAsNumber('much xp')).toBeNull();
		expect(xpAsNumber('')).toBeNull();
	});
});

describe('cookieValueOf', () => {
	test('strips the store prefix the cookie does not carry', () => {
		// flask-session stores `session:<sid>` and sends a bare `<sid>`.
		expect(cookieValueOf('session:n9dvfzige3zPdDuNl')).toBe('n9dvfzige3zPdDuNl');
	});

	test('leaves a bare id alone', () => {
		expect(cookieValueOf('n9dvfzige3zPdDuNl')).toBe('n9dvfzige3zPdDuNl');
	});
});