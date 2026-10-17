/**
 * FlashVars, built server-side because they depend on the incoming request.
 */

/**
 * The FlashVars the original client expects.
 *
 * `serverTime` and `app_url` are per-request, which is why this is a function
 * and not a constant.
 *
 * `app_url` must end in a slash: the SWF concatenates the path onto it
 * directly (`Config.BASE_PATH + "flashservices/gateway.php"`), with no joining
 * logic. Without the trailing slash the gateway URL comes out malformed.
 *
 * `publicOrigin` must be the exact origin the browser used, and the same one
 * the proxy puts in the Host header. If the two disagree, Flask renders one
 * `app_url` in ruffle.html while the FlashVars baked into this page say
 * another, and the game talks to the gateway directly without this service.
 */
export function buildFlashVars(publicOrigin: string): string {
	// Normalise first: callers pass an origin in both shapes and a doubled
	// slash would make the SWF request "//flashservices/...".
	const origin = publicOrigin.replace(/\/+$/, '');

	return [
		`serverTime=${Date.now() / 1000}`,
		'is_staging=true',
		'debugMode=true',
		'generateSchema=1',
		`app_url=${origin}/`,
		// Config.SN_APP_URL, a different endpoint this server does not
		// implement. It must stay empty rather than be removed: the client reads
		// it as a string either way.
		'sn_app_url=',
		'stats=1',
	].join('&');
}