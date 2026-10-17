/**
 * The resource catalogue.
 *
 * These assertions are about staying in step with the gateway. The keys here
 * have to be the same ones `RESOURCE_ORDER` in `empires-server.py` lists, and a
 * mismatched key does not fail loudly: the account page just shows a dash where
 * the player's wood count should be.
 */
import { describe, expect, test } from 'bun:test';

import { RESOURCES, formatAmount } from '#lib/resources';

describe('resource catalogue', () => {
	test('covers every resource the save holds', () => {
		// The keys below are the ones `world.resources` actually uses, as
		// pinned by test_gateway_e2e.py and the save schema.
		expect(RESOURCES.map((resource) => resource.key)).toEqual([
			'coins',
			'wood',
			'oil',
			'aluminum',
			'copper',
			'gold',
			'iron',
			'uranium'
		]);
	});

	test('every icon is served through the front door', () => {
		for (const resource of RESOURCES) {
			// Relative to this origin on purpose: an absolute URL would point
			// somewhere the proxy does not guard.
			expect(resource.icon.startsWith('/img/')).toBe(true);
			expect(resource.icon.endsWith('.png')).toBe(true);
			expect(resource.label.length).toBeGreaterThan(0);
		}
	});

	test('keys are unique, so each resource gets its own card', () => {
		const keys = RESOURCES.map((resource) => resource.key);
		expect(new Set(keys).size).toBe(keys.length);
	});
});

describe('formatAmount', () => {
	test('formats a number for a Spanish locale', () => {
		expect(formatAmount(2509)).toBe('2.509');
		expect(formatAmount(0)).toBe('0');
	});

	test('shows a dash rather than a misleading zero', () => {
		// "—" means the gateway has no save, and 0 would read as "you own none".
		expect(formatAmount(null)).toBe('—');
		expect(formatAmount(undefined)).toBe('—');
		expect(formatAmount(Number.NaN)).toBe('—');
	});

	test('handles the large values an editor can set', () => {
		expect(formatAmount(100000)).toBe('100.000');
	});
});