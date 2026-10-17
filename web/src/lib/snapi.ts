/**
 * The ExternalInterface bridge the Flash client expects from its host page.
 *
 * The SWF has no social network of its own. During setup it calls three global
 * JavaScript functions *by name* — `getUserInfo()`, `getFriendData()` and
 * `getAppFriendIds()` — and reads fields off whatever they return
 * (`Engine.Classes.SNAPISocialNetwork`). `templates/ruffle.html` defined them as
 * inline functions; this is the same bridge for the SvelteKit player.
 *
 * Missing them is not a soft failure. `getUser()` leaves its user object null,
 * and `toSocialNetworkUser` immediately does
 * `new SocialNetworkUser(param1.zid)` on it, so setup aborts with
 *
 *     Error #1009: Cannot access a property or method of a null object
 *     reference. (accessing field: zid)
 *
 * before anything is playable. Everything here exists so that never happens.
 *
 * These must be globals on `window`, not module exports: `ExternalInterface.call`
 * resolves the name against the page's global scope.
 */

/** Where the payload comes from. Served by the gateway, proxied like the SWF. */
export const SNAPI_ENDPOINT = '/snapi.json';

export interface SnapiUser {
	/** Must be a JSON number. ActionScript takes it as an int. */
	zid: number;
	uid: number;
	first_name: string;
	name: string;
	sex: string;
	pic_square: string;
}

export interface SnapiPayload {
	user: SnapiUser;
	friends: unknown[];
	appFriends: unknown[];
}

/** Minimal shape of the globals this module installs. */
type BridgeGlobals = Record<string, unknown>;

function globalScope(): BridgeGlobals {
	return globalThis as unknown as BridgeGlobals;
}

/**
 * Reject a payload that would reproduce the crash it is meant to prevent.
 *
 * The client only copies the user object when it `hasOwnProperty("zid")`, and
 * then dereferences it unconditionally. A missing or non-numeric `zid` is the
 * exact thing that produces Error #1009, so it is worth failing loudly here —
 * on the page, with a readable message — instead of inside the player.
 */
export function assertUsablePayload(value: unknown): asserts value is SnapiPayload {
	const payload = value as Partial<SnapiPayload> | null;
	const user = payload?.user;

	if (!user || typeof user !== 'object') {
		throw new Error(`${SNAPI_ENDPOINT} no devolvió un usuario`);
	}
	if (typeof user.zid !== 'number' || !Number.isFinite(user.zid)) {
		// A stringified zid is the subtle one: the client would accept it, then
		// coerce it to NaN somewhere far downstream.
		throw new Error(
			`${SNAPI_ENDPOINT} devolvió zid=${JSON.stringify(user.zid)}; se necesita un número`
		);
	}
	if (!Array.isArray(payload?.friends) || !Array.isArray(payload?.appFriends)) {
		throw new Error(`${SNAPI_ENDPOINT} no devolvió las listas de amigos`);
	}
}

/**
 * Install the bridge on the global scope.
 *
 * Must run before `player.load()`: the client calls these during setup, and a
 * call into a function that does not exist yet returns null rather than waiting.
 */
export function installSnapiBridge(payload: SnapiPayload): void {
	assertUsablePayload(payload);

	const scope = globalScope();

	// The three the client actually reads during setup.
	scope['getUserInfo'] = () => payload.user;
	scope['getFriendData'] = () => payload.friends;
	scope['getAppFriendIds'] = () => payload.appFriends;

	// Reached from toSocialNetworkUser -> getAccessToken(). There is no OAuth
	// here, so there is no token: returning null is the honest answer and the
	// client falls back to using pic_square as-is.
	scope['SNAPI'] = {
		getAllConnections: () => null,
		getSNID: () => 0
	};

	// Social actions the client can fire later (sharing, invites). They used to
	// exist on the 2012 Facebook frame; without them those paths throw.
	const noop = () => undefined;
	scope['snapiStreamPublish'] = noop;
	scope['showStreamPermissions'] = noop;
	scope['showBookmarkDialog'] = noop;
	scope['showEmailPermission'] = noop;
	scope['requestSend'] = noop;
}