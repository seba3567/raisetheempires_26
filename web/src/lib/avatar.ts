/**
 * Avatar art, shared by the player page and anything else that shows a face.
 *
 * The images are the 2012 originals, copied out of `templates/img/avatars/`
 * into `static/img/avatars/` so this service serves them alongside the resource
 * icons in `resources.ts`. They used to come from the gateway's `/img/` route,
 * which belongs to the Jinja templates that are being retired.
 *
 * The *list* of available avatars is not here: that lives on the save, and the
 * gateway hands it over in `/avatar.json` (`#lib/server/avatar`). This module
 * only turns a filename into a URL.
 */

/** What the gateway serves for a save that has never chosen one. */
export const DEFAULT_AVATAR = 'blank.png';

/** Public URL for one avatar file. */
export function avatarUrl(file: string): string {
	return `/img/avatars/${encodeURIComponent(file)}`;
}