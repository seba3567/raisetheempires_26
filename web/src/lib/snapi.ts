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

import { logDev } from './dev-log';

/** Where the payload comes from. Served by the gateway, proxied like the SWF. */
export const SNAPI_ENDPOINT = '/snapi.json';

/**
 * How far along the boot was, as the 2013 loading screen tracked it.
 *
 * `templates/js/empires.js` drove a gold progress bar from exactly these three
 * callbacks plus `onGameLoaded`, which is where the loading overlay was hidden.
 * The names and the percentages are kept so the sequence a player sees is the
 * one they saw in 2012.
 */
export type LoadStage = 'user' | 'friends' | 'appFriends' | 'loaded';

/** Percentage the bar reaches at each stage. */
export const LOAD_STAGES: Record<LoadStage, number> = {
	user: 30,
	friends: 50,
	appFriends: 70,
	loaded: 100
};

/** The text the 2013 page put above the bar at each step. */
export const LOAD_MESSAGES: Record<LoadStage, string> = {
	user: 'Loading User info...',
	friends: 'Loading Friends data...',
	appFriends: 'Loading Friends data...',
	loaded: 'Loading game...'
};

/** Told to the host page as the client walks its setup. */
export type OnProgress = (stage: LoadStage) => void;

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
 *
 * `onProgress` is optional and purely cosmetic: it is how the loading screen
 * knows the boot moved, exactly as `templates/js/empires.js` reported it. A
 * host that does not pass one still gets a working bridge.
 */
export function installSnapiBridge(payload: SnapiPayload, onProgress?: OnProgress): void {
	assertUsablePayload(payload);

	const scope = globalScope();

	logDev.snapi('Bridge instalado con usuario táctico', {
		zid: payload.user.zid,
		name: payload.user.name,
		friendsCount: payload.friends.length,
		appFriendsCount: payload.appFriends.length
	});

	/** Report a stage, but never let the page's own error break the boot. */
	const report = (stage: LoadStage) => {
		try {
			logDev.snapi(`Hito de carga alcanzado: ${stage} (${LOAD_STAGES[stage]}%)`);
			onProgress?.(stage);
		} catch (cause) {
			console.debug('onProgress falló en', stage, cause);
		}
	};

	// The three the client actually reads during setup.
	scope['getUserInfo'] = () => {
		logDev.snapi('Flash llamó a getUserInfo()', payload.user);
		report('user');
		return payload.user;
	};
	scope['getFriendData'] = () => {
		logDev.snapi(`Flash llamó a getFriendData() -> ${payload.friends.length} amigos`);
		report('friends');
		return payload.friends;
	};
	scope['getAppFriendIds'] = () => {
		logDev.snapi(`Flash llamó a getAppFriendIds() -> ${payload.appFriends.length} aliados tácticos`);
		report('appFriends');
		return payload.appFriends;
	};

	// The client calls this once it has its world. The 2013 page used it to
	// fill the bar to 100% and take the loading overlay down; here the player
	// page does the same when it sees the stage.
	scope['onGameLoaded'] = () => {
		logDev.snapi('Flash llamó a onGameLoaded() -> ¡Escenario listo!');
		report('loaded');
	};

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

	// In-game transactions & Credits Acquisition (buying Z-Cash / Bundles)
	scope['creditsAcquisition'] = (...args: unknown[]) => {
		logDev.snapi('Flash llamó a creditsAcquisition()', args);
		if (typeof window !== 'undefined') {
			window.dispatchEvent(new CustomEvent('rte:creditsAcquisition', { detail: args }));
		}
		return true;
	};

	scope['openInAppPurchaseAPI'] = (item: unknown, callback?: (resp: unknown) => void) => {
		logDev.snapi('Flash llamó a openInAppPurchaseAPI()', item);
		if (typeof window !== 'undefined') {
			window.dispatchEvent(new CustomEvent('rte:openInAppPurchase', { detail: item }));
		}
		if (typeof callback === 'function') {
			try {
				callback({ success: true, item });
			} catch (e) {
				console.debug(e);
			}
		}
		return { success: true };
	};

	// Popup & Window control
	scope['windowOpen'] = (url?: string, name?: string) => {
		logDev.snapi('Flash llamó a windowOpen()', { url, name });
		if (typeof window !== 'undefined') {
			window.dispatchEvent(new CustomEvent('rte:windowOpen', { detail: { url, name } }));
		}
		return true;
	};

	scope['windowClose'] = () => {
		logDev.snapi('Flash llamó a windowClose()');
		if (typeof window !== 'undefined') {
			window.dispatchEvent(new CustomEvent('rte:windowClose'));
		}
		return true;
	};

	// Ads & Watch-to-Earn
	scope['getNetworkId'] = () => {
		logDev.snapi('Flash llamó a getNetworkId() -> facebook');
		return 'facebook';
	};

	scope['getHasActivities'] = () => {
		logDev.snapi('Flash llamó a getHasActivities() -> false');
		return false;
	};

	scope['startActivity'] = () => {
		logDev.snapi('Flash llamó a startActivity()');
		return false;
	};

	scope['PublishWithCallback'] = (data: unknown, callback?: (resp: unknown) => void) => {
		logDev.snapi('Flash llamó a PublishWithCallback()', data);
		if (typeof callback === 'function') {
			try {
				callback({ success: true });
			} catch (e) {
				console.debug(e);
			}
		}
		return true;
	};

	scope['callExternalInterface'] = (cmd: string, ...args: unknown[]) => {
		logDev.snapi(`Flash llamó a callExternalInterface(${cmd})`, args);
		if (typeof window !== 'undefined') {
			window.dispatchEvent(new CustomEvent('rte:externalInterface', { detail: { cmd, args } }));
		}
		return true;
	};

	// 2012 legacy statTracker bridge (called during SWF init stages)
	scope['statTracker'] = {
		logLoadApp: (...args: unknown[]) => {
			logDev.snapi('Flash statTracker.logLoadApp', args);
		},
		logInitActions: (...args: unknown[]) => {
			logDev.snapi('Flash statTracker.logInitActions', args);
		},
		logInteractive: (...args: unknown[]) => {
			logDev.snapi('Flash statTracker.logInteractive', args);
		},
		logLoadComplete: (...args: unknown[]) => {
			logDev.snapi('Flash statTracker.logLoadComplete', args);
		},
		logWorldObjectCount: (...args: unknown[]) => {
			logDev.snapi('Flash statTracker.logWorldObjectCount', args);
		}
	};

	// 2012 legacy ZYFrameManager bridge (tabs, app reload, navigation)
	scope['ZYFrameManager'] = {
		reloadApp: () => {
			logDev.snapi('Flash ZYFrameManager.reloadApp');
			if (typeof window !== 'undefined') window.location.reload();
		},
		navigateTo: (...args: unknown[]) => {
			logDev.snapi('Flash ZYFrameManager.navigateTo', args);
		},
		openTab: (...args: unknown[]) => {
			logDev.snapi('Flash ZYFrameManager.openTab', args);
		},
		switchToTab: (...args: unknown[]) => {
			logDev.snapi('Flash ZYFrameManager.switchToTab', args);
		},
		showLanguageMenu: (...args: unknown[]) => {
			logDev.snapi('Flash ZYFrameManager.showLanguageMenu', args);
		}
	};

	// 2012 legacy Zynga Ads & Permissions
	scope['zynga'] = {
		ads: {
			WatchToEarn: {
				service: {
					available: () => false,
					initializeFlash: () => false
				}
			}
		}
	};
	scope['hasPermission'] = () => true;
	scope['showPermissions'] = noop;
}
