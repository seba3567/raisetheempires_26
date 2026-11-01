<script lang="ts">
	import { enhance } from '$app/forms';
	import { DEFAULT_AVATAR, avatarUrl } from '#lib/avatar';
	import { formatAmount } from '#lib/resources';
	import type { BattleReport } from '#lib/combat';
	import { GIFT_DEFINITIONS } from '#lib/gifts';

	let { data, form, activeTab = $bindable('friends'), startBattleWith } = $props();
</script>

	{#if activeTab === 'history'}
		<div class="space-y-4">
			<div>
				<h2 class="text-xl font-bold text-white flex items-center gap-2">
					<span>📜 Historial Táctico de Batallas</span>
				</h2>
				<p class="text-xs text-slate-400 mt-0.5">
					Registro de todos tus enfrentamientos PvP recientes contra otros comandantes.
				</p>
			</div>

			{#if data.battles.length === 0}
				<div class="panel py-10 text-center space-y-2">
					<div class="text-3xl">⚔️</div>
					<h3 class="text-sm font-semibold text-white">No hay batallas registradas todavía</h3>
					<p class="text-xs text-slate-400">
						Entra a la pestaña de Arena PvP para desafiar a tu primer rival.
					</p>
				</div>
			{:else}
				<div class="space-y-2.5">
					{#each data.battles as b}
						<div class="panel flex flex-wrap items-center justify-between gap-3 py-3 border-empire-800 bg-empire-900/50">
							<div class="flex items-center gap-3">
								<span class="text-2xl">{b.won ? '🏆' : '💀'}</span>
								<div>
									<div class="flex items-center gap-2">
										<span class="font-bold text-sm text-white">
											{b.role === 'defense' ? '🛡️ Defensa ante' : '⚔️ Asalto a'} {b.opponent}
										</span>
										<span class="rounded px-1.5 py-0.2 text-[10px] font-bold uppercase {b.won ? 'bg-emerald-500/20 text-emerald-400 border border-emerald-500/30' : 'bg-red-500/20 text-red-400 border border-red-500/30'}">
											{b.won ? 'Victoria' : 'Derrota'}
										</span>
										<span class="rounded bg-empire-800 px-1.5 py-0.2 text-[10px] text-slate-400 font-mono">
											{b.role === 'defense' ? 'Defensa' : 'Ataque'}
										</span>
									</div>
									{#if b.summary}
										<p class="text-xs text-slate-400 mt-0.5 max-w-xl">{b.summary}</p>
									{/if}
									<p class="text-[10px] text-slate-500 mt-0.5 font-mono">{b.date}</p>
								</div>
							</div>

							<div class="flex items-center gap-2 shrink-0">
								{#if b.xpGained > 0}
									<span class="rounded bg-empire-950 px-2 py-1 text-xs font-mono text-gold-400 font-bold border border-empire-800">
										+{b.xpGained} XP
									</span>
								{/if}
								{#if b.coinsGained > 0}
									<span class="rounded bg-empire-950 px-2 py-1 text-xs font-mono text-emerald-400 font-bold border border-empire-800">
										+{b.coinsGained.toLocaleString()} 🪙
									</span>
								{/if}

								<button
									type="button"
									onclick={() => startBattleWith(b.opponent)}
									class="rounded border border-red-500/40 bg-red-500/10 hover:bg-red-500/20 text-red-300 px-2.5 py-1 text-xs font-semibold transition-colors flex items-center gap-1"
								>
									<span>⚔️ Revancha</span>
								</button>
							</div>
						</div>
					{/each}
				</div>
			{/if}
		</div>
	{/if}
