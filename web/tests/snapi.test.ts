/**
 * The ExternalInterface bridge.
 *
 * The assertions that matter are the rejections, not the happy path. A bridge
 * that silently installs a user object with no numeric `zid` looks installed and
 * is exactly the thing that makes the client die with "Error #1009 ... accessing
 * field: zid" — so the failure has to happen here, where it can be reported.
 */
import { describe, expect, test } from 'bun:test';

import {
	LOAD_STAGES,
	SNAPI_ENDPOINT,
	assertUsablePayload,
	installSnapiBridge,
	type LoadStage,
	type SnapiPayload
} from '#lib/snapi';

const VALID: SnapiPayload = {
	user: {
		zid: 2361750976462848,
		uid: 2361750976462848,
		first_name: 'Rising Empire',
		name: 'Rising Empire',
		sex: 'F',
		pic_square: 'img/avatars/blank.png'
	},
	friends: [{ zid: 1, name: 'Steele' }],
	appFriends: [1, 111, 123]
};

function installed(): Record<string, unknown> {
	return globalThis as unknown as Record<string, unknown>;
}

describe('installSnapiBridge', () => {
	test('exposes the three functions the client calls by name', () => {
		installSnapiBridge(VALID);

		const scope = installed();
		expect(typeof scope['getUserInfo']).toBe('function');
		expect(typeof scope['getFriendData']).toBe('function');
		expect(typeof scope['getAppFriendIds']).toBe('function');

		const call = scope['getUserInfo'] as () => SnapiPayload['user'];
		expect(call()).toEqual(VALID.user);
		expect((scope['getFriendData'] as () => unknown[])()).toEqual(VALID.friends);
		expect((scope['getAppFriendIds'] as () => unknown[])()).toEqual(VALID.appFriends);
	});

	test('the user object has the fields the client reads', () => {
		installSnapiBridge(VALID);
		const user = (installed()['getUserInfo'] as () => Record<string, unknown>)();

		// toSocialNetworkUser dereferences exactly these, unguarded.
		for (const field of ['zid', 'first_name', 'name', 'pic_square', 'sex']) {
			expect(user).toHaveProperty(field);
		}
		// ActionScript takes it as an int; a string here becomes NaN downstream.
		expect(typeof user['zid']).toBe('number');
	});

	test('answers the OAuth hooks with no token rather than throwing', () => {
		installSnapiBridge(VALID);
		const snapi = installed()['SNAPI'] as Record<string, () => unknown>;

		// toSocialNetworkUser calls getAccessToken() on every load.
		expect(snapi.getAllConnections()).toBeNull();
		expect(snapi.getSNID()).toBe(0);
	});

	test('defines the social actions instead of letting them throw', () => {
		installSnapiBridge(VALID);
		for (const name of [
			'snapiStreamPublish',
			'showStreamPermissions',
			'showBookmarkDialog',
			'showEmailPermission',
			'requestSend'
		]) {
			expect(typeof installed()[name]).toBe('function');
		}
	});
});

describe('load progress', () => {
	/** Call every callback the client makes while booting, in order. */
	function boot(onProgress: (stage: LoadStage) => void): void {
		installSnapiBridge(VALID, onProgress);
		const scope = installed();
		for (const name of ['getUserInfo', 'getFriendData', 'getAppFriendIds', 'onGameLoaded']) {
			(scope[name] as () => unknown)();
		}
	}

	test('reports each stage as the client walks its setup', () => {
		const seen: LoadStage[] = [];

		boot((stage) => seen.push(stage));

		expect(seen).toEqual(['user', 'friends', 'appFriends', 'loaded']);
	});

	test('reaches the same percentages the 2013 loading bar used', () => {
		// templates/js/empires.js set 30/50/70/100 on these same callbacks.
		expect(LOAD_STAGES).toEqual({ user: 30, friends: 50, appFriends: 70, loaded: 100 });
	});

	test('onGameLoaded is a global, or the client cannot reach it', () => {
		boot(() => {});

		expect(typeof installed()['onGameLoaded']).toBe('function');
	});

	test('a failing progress handler does not break the bridge', () => {
		installSnapiBridge(VALID, () => {
			throw new Error('the page went away');
		});

		// The user object still comes back: the client dereferences zid on it.
		const call = installed()['getUserInfo'] as () => SnapiPayload['user'];
		expect(call()).toEqual(VALID.user);
	});

	test('a bridge with no handler still works', () => {
		expect(() => installSnapiBridge(VALID)).not.toThrow();
		expect((installed()['getUserInfo'] as () => unknown)()).toEqual(VALID.user);
	});
});

describe('assertUsablePayload', () => {
	test('accepts a well-formed payload', () => {
		expect(() => assertUsablePayload(VALID)).not.toThrow();
	});

	test('rejects a missing user', () => {
		expect(() => assertUsablePayload({ friends: [], appFriends: [] })).toThrow(/usuario/);
		expect(() => assertUsablePayload(null)).toThrow();
	});

	test('rejects a stringified zid', () => {
		const asString = { ...VALID, user: { ...VALID.user, zid: '2361750976462848' } };
		// The client would accept this and then coerce it to NaN.
		expect(() => assertUsablePayload(asString)).toThrow(/número/);
	});

	test('rejects a missing zid, which is the Error #1009 case', () => {
		const { zid: _dropped, ...user } = VALID.user;
		expect(() => assertUsablePayload({ ...VALID, user })).toThrow(/número/);
	});

	test('rejects missing friend lists', () => {
		expect(() => assertUsablePayload({ user: VALID.user })).toThrow(/amigos/);
	});

	test('the endpoint is proxied like everything else the client needs', () => {
		// An absolute URL would bypass the front door and lose the account's zid.
		expect(SNAPI_ENDPOINT.startsWith('/')).toBe(true);
	});
});