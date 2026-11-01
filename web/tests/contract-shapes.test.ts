/**
 * The payload shapes, checked against the runtime contract.
 *
 * The gateway produces these payloads and this service consumes them, and
 * they cross the seam as JSON. A shape is exactly the kind of thing that
 * drifts: somebody renames a key on one side, or adds a field to an interface
 * and forgets the producer, and the other side finds out at runtime.
 *
 * The SNAPI one is the sharpest case. The client has no social network of its
 * own: during setup it calls `getUserInfo()` and reads fields off what comes
 * back. If the user object arrives without `zid`, the client does not degrade,
 * it dies with Error #1009 before anything is playable -- and the symptom
 * appears in the browser console with nothing on the server to explain it.
 *
 * So the shapes are written down once, in `contract/runtime.json`, and both
 * sides are checked against it. The gateway's producer is checked in
 * `test/test_contract.py`; this file checks the consumer.
 */
import { describe, expect, test } from 'bun:test';

import { contract } from '#lib/server/contract';
import { RESOURCE_KEYS } from '#lib/resources';
import { DEFAULT_CREST, VALID_CRESTS } from '#lib/server/models/clans';
import { PLAYER_STATE_KEYS } from '#lib/server/player';
import { SNAPI_PAYLOAD_KEYS, SNAPI_USER_KEYS } from '#lib/snapi';

describe('the SNAPI payload', () => {
	test('the user object has the keys the contract names', () => {
		expect([...SNAPI_USER_KEYS]).toEqual([...contract.snapi.userKeys]);
	});

	test('the payload has the keys the contract names', () => {
		expect([...SNAPI_PAYLOAD_KEYS]).toEqual([...contract.snapi.payloadKeys]);
	});

	test('the client can read its identity off it', () => {
		// The two the client actually reads, and the two that break it when
		// they are missing or of the wrong type.
		expect(SNAPI_USER_KEYS).toContain('zid');
		expect(SNAPI_USER_KEYS).toContain('uid');
		expect(SNAPI_PAYLOAD_KEYS).toContain('friends');
		expect(SNAPI_PAYLOAD_KEYS).toContain('appFriends');
	});
});

describe('the player state', () => {
	test('it has the keys the contract names', () => {
		expect([...PLAYER_STATE_KEYS]).toEqual([...contract.playerState.keys]);
	});

	test('the account page can read the empire off it', () => {
		for (const key of ['hasSave', 'level', 'xp', 'empirePoints', 'resources'] as const) {
			expect(PLAYER_STATE_KEYS).toContain(key);
		}
	});
});

describe('the resources', () => {
	test('they are in the order the gateway counts them', () => {
		expect([...RESOURCE_KEYS]).toEqual([...contract.resources.order]);
	});

	test('the first one is the coins, which is what the client shows first', () => {
		expect(RESOURCE_KEYS[0]).toBe('coins');
	});
});

/**
 * The alliance rules.
 *
 * An alliance can be made from the page or from inside the game, and the two
 * have to start the same way. The gateway used to accept any shield, so an
 * alliance made in the game could carry one this page had never heard of.
 */
describe('the clan rules', () => {
	test('the shields are the ones the contract names', () => {
		expect([...VALID_CRESTS]).toEqual([...contract.clans.crests]);
	});

	test('a new alliance starts with the contracted values', () => {
		expect(contract.clans.defaults).toEqual({
			level: 1,
			xp: 0,
			health: 100,
			maxHealth: 100,
			slots: 10
		});
	});

	test('the default shield is one of them', () => {
		expect(VALID_CRESTS).toContain(DEFAULT_CREST);
	});
});
