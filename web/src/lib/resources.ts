/**
 * The resource catalogue, shared by the account page and the empire editor.
 *
 * The icons are the game's own art, served by the gateway from `img/`. Using the
 * originals rather than emoji or new drawings is the whole point: the player
 * recognises the exact sprite they clicked in 2012, and nothing has to be
 * redrawn.
 *
 * The gateway returns these in `RESOURCE_ORDER`; the order here is the display
 * order and they are expected to line up.
 */
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

/** What the 2012 template called Empire Points: `player.cash`. */
export const EMPIRE_POINTS_ICON = '/img/epoints.png';

/** The XP star, used for the level and the XP readouts. */
export const XP_ICON = '/img/xp.png';

/** Spanish thousands separator, so 2509 does not read as 2.509 million. */
export function formatAmount(value: number | null | undefined): string {
	if (value === null || value === undefined || !Number.isFinite(value)) return '—';
	return new Intl.NumberFormat('es-CL').format(value);
}