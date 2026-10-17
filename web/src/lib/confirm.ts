/**
 * What the empire editor asks before it does something irreversible.
 *
 * These live here rather than in the component because the risky part is not
 * the dialog -- it is the mapping. Each of the three writes that can cost a
 * player their empire has to name the form it submits and, for the danger
 * action, the value that selects it. Getting that pairing wrong does not throw;
 * it silently posts the wrong operation, which is how a click on "borrar" ends
 * up rewinding the battle map instead.
 *
 * Pure data so it can be asserted without a browser.
 */

/** One confirmation, and the form it submits when confirmed. */
export interface PendingConfirm {
	title: string;
	/** What is about to happen, in the second person. */
	body: string;
	/** The safety net, if there is one worth naming. */
	note?: string;
	/** Label for the button that goes ahead. */
	confirm: string;
	/** id of the form on the page to submit. */
	form: string;
	/** value for the danger action's `what` field. */
	what?: string;
}

/** Replaces the whole save from the raw JSON textarea. */
export const RAW_REPLACE: PendingConfirm = {
	title: '¿Reemplazar la partida?',
	body: 'Todo lo que hay en el editor crudo se escribirá sobre la partida, tal cual.',
	note: 'El gateway guarda un respaldo antes de aplicar, y se puede volver desde la lista de respaldos.',
	confirm: 'Reemplazar',
	form: 'raw-form'
};

/** Steps the active battle-map island back one. */
export const DEPROGRESS: PendingConfirm = {
	title: '¿Rebobinar el mapa de batalla?',
	body: 'La isla activa retrocede una.',
	note: 'Guarda un respaldo antes de hacerlo.',
	confirm: 'Rebobinar',
	form: 'danger-form',
	what: 'deprogress'
};

/** Throws the game session away. */
export const WIPE: PendingConfirm = {
	title: '¿Borrar la partida?',
	body: 'Se elimina la sesión de juego de este navegador: nivel, recursos, misiones y flotas.',
	note: 'La cuenta y su identidad siguen existiendo, y los respaldos permiten deshacerlo, pero la partida empieza de cero.',
	confirm: 'Borrar',
	form: 'danger-form',
	what: 'wipe'
};

/** Every confirmation the editor can raise, for exhaustiveness checks. */
export const ALL_CONFIRMS: readonly PendingConfirm[] = [RAW_REPLACE, DEPROGRESS, WIPE];