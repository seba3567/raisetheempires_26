<script lang="ts">
	import { enhance } from '$app/forms';
	import { DEFAULT_AVATAR, avatarUrl } from '#lib/avatar';
	import { formatAmount } from '#lib/resources';
	import type { BattleReport } from '#lib/combat';
	import { GIFT_DEFINITIONS } from '#lib/gifts';

	let {
		data,
		form,
		activeTab = $bindable('friends'),
		selectedOpponent = $bindable(''),
		battling = $bindable(false),
		battleReport = null
	} = $props();
</script>

	{#if activeTab === 'pvp'}
		<div class="space-y-6">
			<!-- Header of the Arena -->
			<div class="panel border-red-900/40 bg-gradient-to-b from-red-950/20 via-empire-950 to-empire-900">
				<div class="flex flex-wrap items-center justify-between gap-4">
					<div>
						<h2 class="text-xl sm:text-2xl font-black text-red-400 flex items-center gap-2">
							<span>⚔️ Arena Táctica de Duelos PvP</span>
						</h2>
						<p class="text-xs sm:text-sm text-slate-300 mt-1 max-w-xl">
							Simula batallas tácticas de infantería, blindados, artillería, cazas y acorazados contra otros comandantes reales con el motor de combate de Raise the Empires.
						</p>
					</div>
					<div class="flex items-center gap-2">
						<span class="rounded bg-empire-900 border border-empire-800 px-3 py-1.5 text-xs font-mono text-gold-400 font-bold">
							Tu Nivel: {data.playerLevel}
						</span>
					</div>
				</div>

				<!-- Opponent Selection -->
				<form
					method="POST"
					action="?/battle"
					use:enhance={() => {
						battling = true;
						return async ({ update }) => {
							await update({ reset: false });
							battling = false;
						};
					}}
					class="mt-6 border-t border-empire-800/80 pt-4 flex flex-wrap items-end gap-3"
				>
					<div class="flex-1 min-w-[220px]">
						<label for="opponent-select" class="block text-xs font-semibold text-slate-300 mb-1.5">
							Elegir Comandante Rival:
						</label>
						<select
							id="opponent-select"
							name="opponent"
							bind:value={selectedOpponent}
							class="w-full rounded-md border border-empire-700 bg-empire-900 px-3 py-2 text-sm text-white focus:border-red-500 focus:outline-none"
						>
							{#if data.friends.length === 0}
								{#each data.suggestions as s}
									<option value={s.username}>{s.username} (Nv. {s.level ?? 1}) — Sugerencia</option>
								{/each}
							{:else}
								<optgroup label="Tus Aliados">
									{#each data.friends as f}
										<option value={f.username}>{f.username} (Nv. {f.level ?? 1})</option>
									{/each}
								</optgroup>
								{#if data.suggestions.length > 0}
									<optgroup label="Otros Comandantes del Servidor">
										{#each data.suggestions as s}
											<option value={s.username}>{s.username} (Nv. {s.level ?? 1})</option>
										{/each}
									</optgroup>
								{/if}
							{/if}
						</select>
					</div>

					<button
						type="submit"
						disabled={battling || !selectedOpponent}
						class="rounded-md bg-gradient-to-r from-red-600 to-red-500 px-6 py-2.5 text-sm font-bold text-white shadow-lg hover:from-red-500 hover:to-red-400 disabled:opacity-50 transition-all flex items-center gap-2"
					>
						{#if battling}
							<span class="animate-spin text-lg">⚙️</span>
							<span>Resolviendo combate...</span>
						{:else}
							<span>🔥 ¡Iniciar Batalla!</span>
						{/if}
					</button>
				</form>
			</div>

			<!-- Battle Results Display -->
			{#if battleReport}
				<div class="panel border-2 {battleReport.won ? 'border-gold-500 bg-gold-950/15' : 'border-red-600 bg-red-950/15'} space-y-6 animate-fade-in shadow-2xl">
					<!-- Headline Banner -->
					<div class="flex flex-wrap items-center justify-between gap-4 border-b border-empire-800 pb-4">
						<div class="flex items-center gap-3">
							<span class="text-4xl">{battleReport.won ? '🏆' : '💀'}</span>
							<div>
								<div class="text-xs font-semibold uppercase tracking-wider {battleReport.won ? 'text-gold-400' : 'text-red-400'}">
									{battleReport.won ? 'Victoria Decisiva' : 'Derrota en Combate'}
								</div>
								<h3 class="text-2xl font-black text-white">{battleReport.headline}</h3>
							</div>
						</div>

						<!-- Loot & XP Pills -->
						<div class="flex items-center gap-3">
							<div class="panel !p-2 !px-3 text-center bg-empire-900/90 border-empire-700">
								<div class="text-[10px] text-slate-400 uppercase font-semibold">XP Ganada</div>
								<div class="text-base font-bold text-gold-400">+{battleReport.xpGained} XP</div>
							</div>
							<div class="panel !p-2 !px-3 text-center bg-empire-900/90 border-empire-700">
								<div class="text-[10px] text-slate-400 uppercase font-semibold">Botín</div>
								<div class="text-base font-bold text-emerald-400">+{battleReport.coinsLooted.toLocaleString()} 🪙</div>
							</div>
						</div>
					</div>

					<p class="text-sm text-slate-200 leading-relaxed bg-empire-950/60 p-3.5 rounded-lg border border-empire-800">
						{battleReport.summary}
					</p>

					<!-- Unit Casualties & Remaining Health -->
					<div class="grid sm:grid-cols-2 gap-4">
						<div class="panel bg-empire-900/50 border-empire-800 space-y-2">
							<h4 class="text-xs font-bold text-slate-400 uppercase tracking-wider flex items-center justify-between">
								<span>Tu Flota de Ataque</span>
								<span class="text-emerald-400">{battleReport.playerTotalHpRemaining} HP restante</span>
							</h4>
							<div class="space-y-1.5 pt-1">
								{#each battleReport.playerArmy as u}
									<div class="flex items-center justify-between text-xs bg-empire-950/50 p-1.5 rounded">
										<span class="flex items-center gap-1.5">
											<span>{u.icon}</span>
											<span class="font-medium text-slate-200">{u.name}</span>
										</span>
										<span class="font-mono {u.hp > 0 ? 'text-emerald-400' : 'text-red-500 font-bold'}">
											{u.hp > 0 ? `${u.hp}/${u.maxHp} HP` : 'DESTRUIDA'}
										</span>
									</div>
								{/each}
							</div>
						</div>

						<div class="panel bg-empire-900/50 border-empire-800 space-y-2">
							<h4 class="text-xs font-bold text-slate-400 uppercase tracking-wider flex items-center justify-between">
								<span>Defensa de {selectedOpponent}</span>
								<span class="text-red-400">{battleReport.opponentTotalHpRemaining} HP restante</span>
							</h4>
							<div class="space-y-1.5 pt-1">
								{#each battleReport.opponentArmy as u}
									<div class="flex items-center justify-between text-xs bg-empire-950/50 p-1.5 rounded">
										<span class="flex items-center gap-1.5">
											<span>{u.icon}</span>
											<span class="font-medium text-slate-200">{u.name}</span>
										</span>
										<span class="font-mono {u.hp > 0 ? 'text-red-400' : 'text-slate-500 font-bold line-through'}">
											{u.hp > 0 ? `${u.hp}/${u.maxHp} HP` : 'ELIMINADA'}
										</span>
									</div>
								{/each}
							</div>
						</div>
					</div>

					<!-- Play-by-Play Turns -->
					<div class="space-y-2">
						<h4 class="text-xs font-bold text-slate-400 uppercase tracking-wider">
							Crónica Táctica del Enfrentamiento ({battleReport.turns.length} Turnos)
						</h4>
						<div class="max-h-60 overflow-y-auto space-y-1.5 rounded-lg border border-empire-800 bg-empire-950/80 p-2.5 font-mono text-xs">
							{#each battleReport.turns as turn}
								<div class="flex items-start gap-2 py-0.5 {turn.attackerSide === 'player' ? 'text-slate-200' : 'text-red-300'}">
									<span class="text-slate-500 shrink-0 font-bold">R{turn.turnNumber}:</span>
									<span>{turn.logMessage}</span>
								</div>
							{/each}
						</div>
					</div>
				</div>
			{/if}
		</div>
	{/if}
