/**
 * The player page's load() contract.
 *
 * These options live in a Svelte component's markup, not in an exported
 * constant, so nothing else checks them. They used to be asserted against the
 * rendered HTML of the 2013 `templates/ruffle.html`, back when that template was
 * the player; `/juego` replaced it and the assertions went with the template.
 * They are load-bearing, so they are pinned here instead, at the source.
 *
 * The failure mode is what makes this worth keeping: every option checked here
 * fails silently. With `allowScriptAccess` off the SWF throws Error #2067 and
 * the game hangs on the loading screen with no console error; with the wrong
 * FlashVars the client talks straight to Flask and every write lands nowhere.
 */
import { describe, expect, test } from 'bun:test';

import { SWF_PATH, RUFFLE_SCRIPT_URL } from '#lib/ruffle';

const playerPage = await Bun.file(
	new URL('../src/routes/juego/+page.svelte', import.meta.url)
).text();

describe('the player mount', () => {
	test('keeps allowScriptAccess on', () => {
		// MOTDManager::MessageOfTheDayManager calls
		// ExternalInterface.addCallback during config load. Without this the SWF
		// throws "Error #2067: The ExternalInterface is not available in this
		// container", aborts init::GameSettingsInit/onConfigXmlLoaded, and the
		// game never leaves the loading screen.
		expect(playerPage).toContain('allowScriptAccess: true');
	});

	test('loads the archived SWF this project ships', () => {
		expect(playerPage).toContain('url: SWF_PATH');
		expect(SWF_PATH).toBe(
			'/files/empire-s.assets.zgncdn.com/assets/109338/ZGame.109338.swf'
		);
	});

	test('passes the FlashVars through instead of rebuilding them in the page', () => {
		// buildFlashVars() owns these. A second copy here is how app_url and
		// serverTime drift apart from what the tests in flashvars.test.ts pin.
		expect(playerPage).toContain('parameters: data.flashVars');
	});

	test('does not go back to loading the emulator from a CDN', () => {
		// Ruffle is served from static/ruffle/. A CDN URL here would put an
		// archived game at the mercy of unpkg staying up.
		expect(playerPage).not.toContain('unpkg.com');
		expect(playerPage).not.toContain('cdn.jsdelivr.net');
		expect(RUFFLE_SCRIPT_URL).toBe('/ruffle/ruffle.js');
	});
});