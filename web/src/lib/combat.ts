/**
 * Tactical Combat Simulator for Web PvP.
 *
 * Implements the classic rock-paper-scissors unit relationships of Empires & Allies:
 * - Infantry excels against Artillery
 * - Artillery demolishes Armor
 * - Armor crushes Infantry
 * - Fighters intercept and shoot down Bombers
 * - Battleships bombard Naval Gunboats
 */

export interface CombatUnit {
	id: string;
	name: string;
	type: 'infantry' | 'armor' | 'artillery' | 'air' | 'naval';
	hp: number;
	maxHp: number;
	attack: number;
	icon: string;
}

export interface CombatTurn {
	turnNumber: number;
	attackerName: string;
	attackerSide: 'player' | 'opponent';
	defenderName: string;
	damage: number;
	advantageMultiplier: number;
	isCritical: boolean;
	defenderDestroyed: boolean;
	logMessage: string;
}

export interface BattleReport {
	won: boolean;
	playerArmy: CombatUnit[];
	opponentArmy: CombatUnit[];
	turns: CombatTurn[];
	playerTotalHpRemaining: number;
	opponentTotalHpRemaining: number;
	playerCasualties: number;
	opponentCasualties: number;
	xpGained: number;
	coinsLooted: number;
	headline: string;
	summary: string;
}

const UNIT_CATALOGUE: Record<CombatUnit['type'], Array<{ name: string; icon: string; minLevel: number }>> = {
	infantry: [
		{ name: 'Soldados de Asalto', icon: '🪖', minLevel: 1 },
		{ name: 'Comandos Élite', icon: '🎖️', minLevel: 15 },
		{ name: 'Fuerzas Especiales', icon: '🥷', minLevel: 35 }
	],
	armor: [
		{ name: 'Tanque Ligero M-1', icon: '🛡️', minLevel: 1 },
		{ name: 'Tanque Blindado Centurión', icon: '🚜', minLevel: 20 },
		{ name: 'Super Tanque Mamut', icon: '🦾', minLevel: 45 }
	],
	artillery: [
		{ name: 'Obús de Campaña 105mm', icon: '💥', minLevel: 5 },
		{ name: 'Batería de Cohetes Katyusha', icon: '🚀', minLevel: 25 },
		{ name: 'Artillería Pesada Titán', icon: '⚡', minLevel: 50 }
	],
	air: [
		{ name: 'Caza Interceptor Halcón', icon: '✈️', minLevel: 10 },
		{ name: 'Bombardero Táctico B-52', icon: '🛩️', minLevel: 30 },
		{ name: 'Bombardero Furtivo Stealth', icon: '🛸', minLevel: 55 }
	],
	naval: [
		{ name: 'Lancha Torpedera Costera', icon: '🚤', minLevel: 8 },
		{ name: 'Destructor de Misiles Guía', icon: '🚢', minLevel: 28 },
		{ name: 'Acorazado Clase Dreadnought', icon: '⚓', minLevel: 50 }
	]
};

/** Selects an appropriate unit for the given category based on player level. */
function pickUnitTemplate(type: CombatUnit['type'], level: number) {
	const options = UNIT_CATALOGUE[type].filter((u) => u.minLevel <= Math.max(level, 1));
	const chosen = options[options.length - 1] ?? UNIT_CATALOGUE[type][0];
	return chosen;
}

/** Builds an army of 5 units for a commander of the given level. */
export function generateArmy(level: number, prefix: string): CombatUnit[] {
	const types: CombatUnit['type'][] = ['infantry', 'armor', 'artillery', 'air', 'naval'];
	const army: CombatUnit[] = [];

	for (let i = 0; i < types.length; i++) {
		const type = types[i];
		const template = pickUnitTemplate(type, level);
		const baseHp = 100 + level * 15 + Math.floor(Math.random() * 20);
		const baseAtk = 25 + level * 6 + Math.floor(Math.random() * 10);

		army.push({
			id: `${prefix}_unit_${i + 1}`,
			name: template.name,
			type,
			hp: baseHp,
			maxHp: baseHp,
			attack: baseAtk,
			icon: template.icon
		});
	}

	return army;
}

/** Tactical advantage multiplier based on unit type matchup. */
export function getTacticalAdvantage(
	attacker: CombatUnit['type'],
	defender: CombatUnit['type']
): number {
	if (attacker === 'infantry' && defender === 'artillery') return 1.5;
	if (attacker === 'artillery' && defender === 'armor') return 1.5;
	if (attacker === 'armor' && defender === 'infantry') return 1.5;
	if (attacker === 'air' && defender === 'naval') return 1.4;
	if (attacker === 'naval' && defender === 'armor') return 1.4;

	// Inverted disadvantages
	if (attacker === 'artillery' && defender === 'infantry') return 0.75;
	if (attacker === 'armor' && defender === 'artillery') return 0.75;
	if (attacker === 'infantry' && defender === 'armor') return 0.75;

	return 1.0;
}

/**
 * Runs a simulated tactical PvP battle between a player and an opponent.
 */
export function simulateBattle(
	playerName: string,
	playerLevel: number,
	opponentName: string,
	opponentLevel: number
): BattleReport {
	const playerArmy = generateArmy(playerLevel, 'p');
	const opponentArmy = generateArmy(opponentLevel, 'o');
	const turns: CombatTurn[] = [];

	let turnIndex = 1;
	const maxTurns = 12;

	while (turnIndex <= maxTurns) {
		const playerAlive = playerArmy.filter((u) => u.hp > 0);
		const opponentAlive = opponentArmy.filter((u) => u.hp > 0);

		if (playerAlive.length === 0 || opponentAlive.length === 0) {
			break;
		}

		// Player strikes
		const pAttacker = playerAlive[Math.floor(Math.random() * playerAlive.length)];
		const oDefender = opponentAlive[Math.floor(Math.random() * opponentAlive.length)];

		const pAdvantage = getTacticalAdvantage(pAttacker.type, oDefender.type);
		const isCrit = Math.random() < 0.2;
		const critMultiplier = isCrit ? 1.5 : 1.0;
		const damage = Math.round(pAttacker.attack * pAdvantage * critMultiplier);

		oDefender.hp = Math.max(0, oDefender.hp - damage);
		const oDestroyed = oDefender.hp === 0;

		let logMsg = `${pAttacker.icon} ${pAttacker.name} disparó contra ${oDefender.icon} ${oDefender.name} infligiendo ${damage} pts de daño.`;
		if (pAdvantage > 1.0) logMsg += ' ¡Ventaja táctica!';
		if (isCrit) logMsg += ' ¡Impacto crítico!';
		if (oDestroyed) logMsg += ' ¡Unidad enemiga destruida!';

		turns.push({
			turnNumber: turnIndex,
			attackerName: pAttacker.name,
			attackerSide: 'player',
			defenderName: oDefender.name,
			damage,
			advantageMultiplier: pAdvantage,
			isCritical: isCrit,
			defenderDestroyed: oDestroyed,
			logMessage: logMsg
		});

		// Opponent counter-strikes if still has units
		const opponentStillAlive = opponentArmy.filter((u) => u.hp > 0);
		if (opponentStillAlive.length > 0) {
			const oAttacker = opponentStillAlive[Math.floor(Math.random() * opponentStillAlive.length)];
			const pDefender = playerAlive[Math.floor(Math.random() * playerAlive.length)];

			const oAdvantage = getTacticalAdvantage(oAttacker.type, pDefender.type);
			const oIsCrit = Math.random() < 0.18;
			const oCritMult = oIsCrit ? 1.5 : 1.0;
			const oDamage = Math.round(oAttacker.attack * oAdvantage * oCritMult);

			pDefender.hp = Math.max(0, pDefender.hp - oDamage);
			const pDestroyed = pDefender.hp === 0;

			let oLogMsg = `${oAttacker.icon} ${oAttacker.name} enemigo contraatacó a ${pDefender.icon} ${pDefender.name} causando ${oDamage} pts de daño.`;
			if (oAdvantage > 1.0) oLogMsg += ' ¡Flanqueo enemigo!';
			if (oIsCrit) oLogMsg += ' ¡Daño crítico sufrido!';
			if (pDestroyed) oLogMsg += ' ¡Baja en nuestras filas!';

			turns.push({
				turnNumber: turnIndex,
				attackerName: oAttacker.name,
				attackerSide: 'opponent',
				defenderName: pDefender.name,
				damage: oDamage,
				advantageMultiplier: oAdvantage,
				isCritical: oIsCrit,
				defenderDestroyed: pDestroyed,
				logMessage: oLogMsg
			});
		}

		turnIndex++;
	}

	const playerHpRemaining = playerArmy.reduce((sum, u) => sum + u.hp, 0);
	const opponentHpRemaining = opponentArmy.reduce((sum, u) => sum + u.hp, 0);

	const playerCasualties = playerArmy.filter((u) => u.hp === 0).length;
	const opponentCasualties = opponentArmy.filter((u) => u.hp === 0).length;

	const won = playerHpRemaining > opponentHpRemaining;

	const xpGained = won
		? Math.round(200 + opponentLevel * 25 + opponentCasualties * 30)
		: Math.round(50 + opponentCasualties * 15);

	const coinsLooted = won
		? Math.round(2500 + opponentLevel * 450 + Math.random() * 1000)
		: Math.round(500 + Math.random() * 300);

	const headline = won
		? `¡Victoria decisiva sobre ${opponentName}!`
		: `Derrota táctica frente a ${opponentName}`;

	const summary = won
		? `Nuestras fuerzas quebraron las líneas de ${opponentName}. Se neutralizaron ${opponentCasualties} unidades enemigas y se aseguraron ${coinsLooted.toLocaleString()} monedas y ${xpGained} XP.`
		: `Las defensas de ${opponentName} repelieron el asalto. Se perdieron ${playerCasualties} unidades y se recuperaron suministros menores.`;

	return {
		won,
		playerArmy,
		opponentArmy,
		turns,
		playerTotalHpRemaining: playerHpRemaining,
		opponentTotalHpRemaining: opponentHpRemaining,
		playerCasualties,
		opponentCasualties,
		xpGained,
		coinsLooted,
		headline,
		summary
	};
}
