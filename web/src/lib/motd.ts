/**
 * Message of the Day art for the loading screen.
 *
 * The 2013 player painted a random one of 139 behind the EA frame while the
 * game booted. The art still lives in `templates/img/` and is served by the
 * gateway's `/img/` route rather than copied into `static/`, unlike the avatars:
 * the avatars are 400 KB in total, while this is 139 images and 43 MB. Moving
 * them would put 43 MB into git to fetch exactly one per page load, which is
 * what the gateway route already does.
 *
 * The frame is 3.2 MB for the same reason it stays there too. The service
 * worker caches it after the first boot, so it is paid once per browser.
 */

/** The remastered EA border drawn over the art. */
export const MOTD_FRAME_URL = '/img/loading_frame_remastered.png';

/** The spinning loader the 2013 markup had commented out, kept for the error state. */
export const LOADING_GIF_URL = '/img/loading.gif';

/** Gateway-relative path for one MOTD. */
export function motdUrl(file: string): string {
	return `/img/motds/${encodeURIComponent(file)}`;
}