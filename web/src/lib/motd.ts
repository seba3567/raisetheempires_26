/**
 * Message of the Day art for the loading screen.
 *
 * The 2013 player painted a random one of 139 behind the EA frame while the
 * game booted. The art lives in `static/img/` and is served directly by the
 * web front door alongside all other static assets.
 */

/** The remastered EA border drawn over the art. */
export const MOTD_FRAME_URL = '/img/loading_frame_remastered.png';

/** The spinning loader the 2013 markup had commented out, kept for the error state. */
export const LOADING_GIF_URL = '/img/loading.gif';

/** Gateway-relative path for one MOTD. */
export function motdUrl(file: string): string {
	return `/img/motds/${encodeURIComponent(file)}`;
}