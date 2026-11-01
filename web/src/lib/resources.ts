/**
 * The resource catalogue, shared by the account page and the empire editor.
 *
 * The icons are the game's own art, served by the gateway from `img/`. Using the
 * originals rather than emoji or new drawings is the whole point: the player
 * recognises the exact sprite they clicked in 2012, and nothing has to be
 * redrawn.
 *
 * The gateway counts the resources in the order written down in
 * `contract/runtime.json`; this is the order the player sees them in.
 *
 * The two are the same list, but the wire does not carry the order: Flask
 * sorts the keys of a JSON object, so what arrives is alphabetical. This
 * catalogue is what decides the display.
 */
import type { Equal, Expect } from './type-checks.ts';

export interface ResourceDef {
	key: string;
	label: string;
	icon: string;
}

export const RESOURCES: readonly ResourceDef[] = [
	{ key: 'coins', label: 'Monedas', icon: '/img/Coins_96.png' },
	{ key: 'wood', label: 'Madera', icon: '/img/WoodStack_01_96.png' },
	{ key: 'oil', label: 'Petróleo', icon: '/img/Oil_96.png' },
	{ key: 'aluminum', label: 'Aluminio', icon: '/img/Aluminum_60.png' },
	{ key: 'copper', label: 'Cobre', icon: '/img/Copper_60.png' },
	{ key: 'gold', label: 'Oro', icon: '/img/Gold_60.png' },
	{ key: 'iron', label: 'Hierro', icon: '/img/Iron_60.png' },
	{ key: 'uranium', label: 'Uranio', icon: '/img/Uranium_60.png' }
] as const;

/**
 * The resources, in the order the 2012 editor showed them.
 *
 * The gateway counts them in the same order, and the two lists used to be
 * expected to line up with nothing checking that they did.
 */
export const RESOURCE_KEYS = RESOURCES.map((resource) => resource.key);

/** The catalogue and the key list are the same fact written twice. */
export type _ResourceKeysMatch = Expect<
	Equal<(typeof RESOURCE_KEYS)[number], (typeof RESOURCES)[number]['key']>
>;

/** What the 2012 template called Empire Points: `player.cash`. */
export const EMPIRE_POINTS_ICON = '/img/epoints.png';

/** The XP star, used for the level and the XP readouts. */
export const XP_ICON = '/img/xp.png';

/** Spanish thousands separator, so 2509 does not read as 2.509 million. */
export function formatAmount(value: number | null | undefined): string {
	if (value === null || value === undefined || !Number.isFinite(value)) return '—';
	return new Intl.NumberFormat('es-CL').format(value);
}