/**
 * The editor's confirmations.
 *
 * The dialog itself is Flowbite's, but the part that can go quietly wrong is
 * the pairing: each confirmation names the form it submits, and the two danger
 * operations also name the value that selects them server-side. A mismatch does
 * not throw -- it posts the wrong operation, so "borrar la partida" would
 * quietly rewind the battle map instead.
 */
import { describe, expect, test } from 'bun:test';

import { ALL_CONFIRMS, DEPROGRESS, RAW_REPLACE, WIPE } from '#lib/confirm';

/** The values the `danger` action accepts, from +page.server.ts. */
const DANGER_OPS = new Set(['wipe', 'deprogress']);

describe('every confirmation names what it does', () => {
	test('each one has a title, a body and a confirm label', () => {
		for (const action of ALL_CONFIRMS) {
			expect(`${action.title} ${action.body} ${action.confirm}`.trim().length > 0).toBe(true);
			// The title is what the admin reads before clicking; a missing one
			// would leave a dialog asking for nothing.
			expect(action.title.startsWith('¿')).toBe(true);
			expect(action.title.endsWith('?')).toBe(true);
		}
	});

	test('each one names a form to submit', () => {
		for (const action of ALL_CONFIRMS) {
			expect(`${action.form}: ${action.form.length > 0}`).toBe(`${action.form}: true`);
		}
	});
});

describe('the danger operations carry a value the action accepts', () => {
	test('deprogress and wipe say what they are', () => {
		expect(DEPROGRESS.what).toBe('deprogress');
		expect(WIPE.what).toBe('wipe');
	});

	test('every confirmation with a form posts to a real operation', () => {
		for (const action of ALL_CONFIRMS) {
			if (action.form !== 'danger-form') continue;
			expect(`${action.what}: ${DANGER_OPS.has(action.what ?? '')}`).toBe(
				`${action.what}: true`
			);
		}
	});

	test('the raw paste is not a danger operation', () => {
		// It has its own action, so it must not carry a `what` value: the
		// server ignores it, and its presence would hide a wrong form id.
		expect(RAW_REPLACE.form).toBe('raw-form');
		expect(RAW_REPLACE.what).toBeUndefined();
	});
});

describe('the confirmations cannot be confused with one another', () => {
	test('titles are distinct', () => {
		const titles = ALL_CONFIRMS.map((a) => a.title);
		expect(new Set(titles).size).toBe(titles.length);
	});

	test('the two danger operations do not share a form and a value', () => {
		// Same form, different value: that is the whole point, and a typo that
		// made them identical would make one of the two buttons do the other.
		expect(DEPROGRESS.form).toBe(WIPE.form);
		expect(DEPROGRESS.what).not.toBe(WIPE.what);
	});
});