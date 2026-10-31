/**
 * The Ruffle player, driven from Svelte.
 *
 * This uses the imperative API (`RufflePlayer.newest().createPlayer()` plus
 * `player.load()`) rather than the declarative `<ruffle-player>` custom element.
 * The imperative form is the one already proven against this exact SWF in
 * templates/ruffle.html, and it is the only way to pass `backgroundColor` and a
 * `LogLevel`, both of which the declarative attributes cannot express.
 *
 * Critical runtime requirements:
 * - `allowScriptAccess: true`: The SWF calls `ExternalInterface.addCallback`
 *   during config load (MOTDManager::MessageOfTheDayManager). Without this it
 *   throws "Error #2067: The ExternalInterface is not available in this
 *   container" and aborts init::GameSettingsInit/onConfigXmlLoaded.
 * - `parameters` carrying `app_url`: The client builds its AMF0 gateway URL from
 *   that FlashVar (Config.SERVICES_GATEWAY_PATH).
 * - `frameRate: 30`: Keeps the Flash engine ticking at full 30 FPS even if legacy
 *   AS3 routines try to throttle it.
 */

export const RUFFLE_SCRIPT_URL = '/ruffle/ruffle.js';
export const RUFFLE_VERSION = '0.8.0-nightly';

export const SWF_PATH = '/files/empire-s.assets.zgncdn.com/assets/109338/ZGame.109338.swf';

export const PLAYER_WIDTH = 1000;
export const PLAYER_HEIGHT = 750;
/** The blue the original frame used behind the movie. */
export const PLAYER_BACKGROUND = '#333399';

export interface RuffleConfig {
	preferredRenderer?: 'webgpu' | 'wgpu-webgl' | 'webgl' | 'canvas';
	quality?: 'low' | 'medium' | 'high';
	letterbox?: 'on' | 'off' | 'fullscreen';
	warnOnUnsupportedContent?: boolean;
	logLevel?: 'error' | 'warn' | 'info' | 'debug';
	autoplay?: 'on' | 'off' | 'auto';
	splashScreen?: boolean;
	openUrlMode?: 'allow' | 'confirm' | 'deny';
	maxExecutionDuration?: number | { secs: number; nanos: number };
	frameRate?: number | null;
	backgroundExecutionMode?: 'mainThread' | 'none';
	[key: string]: unknown;
}

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
		parameters?: string | Record<string, unknown>;
		maxExecutionDuration?: number | { secs: number; nanos: number };
		frameRate?: number | null;
		preferredRenderer?: 'webgpu' | 'wgpu-webgl' | 'webgl' | 'canvas';
		logLevel?: 'error' | 'warn' | 'info' | 'debug';
	}): Promise<unknown>;
	enterFullscreen(): void;
	setIsMuted?(isMuted: boolean): void;
	setVolume?(volume: number): void;
	pause?(): void;
	play?(): void;
	isPlaying?(): boolean;
	traceObserver?: ((message: string) => void) | null;
	rendererDebugInfo?: string;
	callExternalInterface?(name: string, args: unknown[]): unknown;
	reloadWithCanvasRenderer?(): Promise<void>;
	width: number | string;
	height: number | string;
	style: string | CSSStyleDeclaration;
}

export interface RufflePlayerGlobal {
	config?: RuffleConfig;
	newest?: () => RufflePlayerApi;
	[key: string]: unknown;
}

declare global {
	interface Window {
		RufflePlayer?: RufflePlayerGlobal;
	}
}

/**
 * Detects the most stable, high-performance renderer for Ruffle.
 * Defaults to 'wgpu-webgl' (WebGL2) for proven stability and zero surface stalls.
 * Allows 'webgpu' if explicitly enabled via localStorage.rte_force_webgpu === '1'.
 */
export async function detectBestRenderer(): Promise<'webgpu' | 'wgpu-webgl'> {
	if (typeof window !== 'undefined' && window.localStorage?.getItem('rte_force_webgpu') === '1') {
		if (typeof navigator !== 'undefined' && 'gpu' in navigator && (navigator as any).gpu) {
			try {
				const adapter = await (navigator as any).gpu.requestAdapter();
				if (adapter) return 'webgpu';
			} catch {
				// Fall back to wgpu-webgl
			}
		}
	}
	return 'wgpu-webgl';
}

/**
 * Load ruffle.js once and resolve when it is ready.
 */
let rufflePromise: Promise<void> | null = null;

export function loadRuffle(
	url = RUFFLE_SCRIPT_URL,
	configOverrides?: Partial<RuffleConfig>
): Promise<void> {
	if (typeof window !== 'undefined') {
		window.RufflePlayer = window.RufflePlayer || {};
		window.RufflePlayer.config = {
			preferredRenderer: 'wgpu-webgl',
			backgroundExecutionMode: 'mainThread',
			letterbox: 'on',
			warnOnUnsupportedContent: false,
			logLevel: 'error',
			autoplay: 'on',
			openUrlMode: 'confirm',
			quality: 'medium',
			maxExecutionDuration: 120,
			frameRate: 30,
			...(window.RufflePlayer.config || {}),
			...(configOverrides || {})
		};
	}

	if (rufflePromise) return rufflePromise;

	rufflePromise = new Promise<void>((resolve, reject) => {
		const existing = document.querySelector<HTMLScriptElement>(`script[src="${url}"]`);
		if (existing) {
			if (window.RufflePlayer?.newest) resolve();
			else {
				existing.addEventListener('load', () => resolve(), { once: true });
				existing.addEventListener('error', () => reject(new Error(`failed to load ${url}`)), {
					once: true
				});
			}
			return;
		}

		const script = document.createElement('script');
		script.src = url;
		script.addEventListener('load', () => resolve(), { once: true });
		script.addEventListener('error', () => reject(new Error(`failed to load ${url}`)), {
			once: true
		});
		document.head.appendChild(script);
	});

	// A failed load must not poison the promise for the next attempt.
	rufflePromise.catch(() => {
		rufflePromise = null;
	});

	return rufflePromise;
}
