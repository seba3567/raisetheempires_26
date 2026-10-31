import { describe, expect, test } from 'bun:test';
import { generateArmy, getTacticalAdvantage, simulateBattle } from '#lib/combat';

describe('Tactical Combat Simulator', () => {
	test('generateArmy creates 5 diverse military units scaled by level', () => {
		const army = generateArmy(10, 'test');
		expect(army).toHaveLength(5);

		const types = army.map((u) => u.type);
		expect(types).toContain('infantry');
		expect(types).toContain('armor');
		expect(types).toContain('artillery');
		expect(types).toContain('air');
		expect(types).toContain('naval');

		for (const unit of army) {
			expect(unit.hp).toBeGreaterThan(100);
			expect(unit.maxHp).toBe(unit.hp);
			expect(unit.attack).toBeGreaterThan(25);
			expect(unit.icon).toBeTruthy();
		}
	});

	test('getTacticalAdvantage enforces classic rock-paper-scissors relationships', () => {
		// Infantry vs Artillery advantage
		expect(getTacticalAdvantage('infantry', 'artillery')).toBe(1.5);
		expect(getTacticalAdvantage('artillery', 'infantry')).toBe(0.75);

		// Artillery vs Armor advantage
		expect(getTacticalAdvantage('artillery', 'armor')).toBe(1.5);
		expect(getTacticalAdvantage('armor', 'artillery')).toBe(0.75);

		// Armor vs Infantry advantage
		expect(getTacticalAdvantage('armor', 'infantry')).toBe(1.5);
		expect(getTacticalAdvantage('infantry', 'armor')).toBe(0.75);

		// Air vs Naval advantage
		expect(getTacticalAdvantage('air', 'naval')).toBe(1.4);

		// Same type
		expect(getTacticalAdvantage('infantry', 'infantry')).toBe(1.0);
	});

	test('simulateBattle resolves combat and outputs comprehensive battle report', () => {
		const report = simulateBattle('PlayerOne', 20, 'RivalCommander', 15);

		expect(typeof report.won).toBe('boolean');
		expect(report.turns.length).toBeGreaterThan(0);
		expect(report.playerArmy).toHaveLength(5);
		expect(report.opponentArmy).toHaveLength(5);
		expect(report.xpGained).toBeGreaterThan(0);
		expect(report.coinsLooted).toBeGreaterThan(0);
		expect(report.headline).toBeTruthy();
		expect(report.summary).toBeTruthy();

		// Each turn has valid details
		for (const turn of report.turns) {
			expect(turn.turnNumber).toBeGreaterThan(0);
			expect(turn.damage).toBeGreaterThan(0);
			expect(['player', 'opponent']).toContain(turn.attackerSide);
			expect(turn.logMessage).toBeTruthy();
		}
	});
});
