/**
 * The Ruffle player, driven from Svelte.
 *
 * This uses the imperative API (`RufflePlayer.newest().createPlayer()` plus
 * `player.load()`) rather than the declarative `<ruffle-player>` custom element.
 * The imperative form is the one already proven against this exact SWF in
 * templates/ruffle.html, and it is the only way to pass `backgroundColor` and a
 * `LogLevel`, both of which the declarative attributes cannot express.
 *
 * Every value below was copied from the working template. Two of them are not
 * decorative and must not be dropped:
 *
 * - `allowScriptAccess: true`. The SWF calls `ExternalInterface.addCallback`
 *   during config load (MOTDManager::MessageOfTheDayManager). Without this it
 *   throws "Error #2067: The ExternalInterface is not available in this
 *   container" and aborts init::GameSettingsInit/onConfigXmlLoaded, so the game
 *   hangs on the loading screen forever. Safe here because the SWF is served by
 *   this project, not loaded from a third party.
 * - `parameters` carrying `app_url`. The client builds its AMF0 gateway URL from
 *   that FlashVar (Config.SERVICES_GATEWAY_PATH). If it points anywhere other
 *   than this origin, the game talks straight to Flask and bypasses this
 *   service, with no error anywhere.
 */

export const RUFFLE_SCRIPT_URL = '/ruffle/ruffle.js';
export const RUFFLE_VERSION = '0.7.1';

export const SWF_PATH = '/files/empire-s.assets.zgncdn.com/assets/109338/ZGame.109338.swf';

export const PLAYER_WIDTH = 1000;
export const PLAYER_HEIGHT = 750;
/** The blue the original frame used behind the movie. */
export const PLAYER_BACKGROUND = '#333399';

export interface RufflePlayerApi {
	version: string;
	createPlayer(): HTMLElement & RufflePlayerHandle;
}

export interface RufflePlayerHandle {
	load(options: {
		url: string;
		backgroundColor?: string;
		allowScriptAccess?: boolean;
		allowFullscreen?: boolean;
		quality?: 'low' | 'medium' | 'high';
		autoplay?: boolean;
		parameters?: string;
	}): Promise<unknown>;
	width: number;
	height: number;
	style: string;
}

declare global {
	interface Window {
		RufflePlayer?: {
			config?: Record<string, unknown>;
			newest(): RufflePlayerApi;
		};
	}
}

/**
 * Load ruffle.js once and resolve when it is ready.
 *
 * It is a plain script, not an ES module, so it cannot be imported. Injecting
 * it on demand also means the 465 KB bundle is only fetched by the page that
 * actually plays the game, instead of on the landing page.
 */
let rufflePromise: Promise<void> | null = null;

export function loadRuffle(url = RUFFLE_SCRIPT_URL): Promise<void> {
	if (rufflePromise) return rufflePromise;

	rufflePromise = new Promise<void>((resolve, reject) => {
		const existing = document.querySelector<HTMLScriptElement>(`script[src="${url}"]`);
		if (existing) {
			if (window.RufflePlayer) resolve();
			else {
				existing.addEventListener('load', () => resolve(), { once: true });
				existing.addEventListener('error', () => reject(new Error(`failed to load ${url}`)), {
					once: true,
				});
			}
			return;
		}

		const script = document.createElement('script');
		script.src = url;
		script.addEventListener('load', () => resolve(), { once: true });
		script.addEventListener('error', () => reject(new Error(`failed to load ${url}`)), { once: true });
		document.head.appendChild(script);
	});

	// A failed load must not poison the promise for the next attempt.
	rufflePromise.catch(() => {
		rufflePromise = null;
	});

	return rufflePromise;
}