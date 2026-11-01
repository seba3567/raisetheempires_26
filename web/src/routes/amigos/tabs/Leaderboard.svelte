<script lang="ts">
	import { enhance } from '$app/forms';
	import { DEFAULT_AVATAR, avatarUrl } from '#lib/avatar';
	import { formatAmount } from '#lib/resources';
	import type { BattleReport } from '#lib/combat';
	import { GIFT_DEFINITIONS } from '#lib/gifts';

	let { data, form, activeTab = $bindable('friends'), startBattleWith } = $props();
</script>

	{#if activeTab === 'leaderboard'}
		<div class="space-y-6">
			<div>
				<h2 class="text-xl font-bold text-white flex items-center gap-2">
					<span>🏆 Tablas de Clasificación Global</span>
				</h2>
				<p class="text-xs text-slate-400 mt-0.5">
					Los mejores comandantes, tácticos PvP y alianzas militares de Raise the Empires.
				</p>
			</div>

			<div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
				<!-- 1. Ranking de Imperio / Experiencia -->
				<div class="panel space-y-4 border-empire-800 bg-empire-900/60">
					<div class="flex items-center justify-between border-b border-empire-800 pb-3">
						<div class="flex items-center gap-2">
							<span class="text-xl">🎖️</span>
							<h3 class="font-bold text-white text-base">Imperio &amp; Campaña (XP)</h3>
						</div>
						<span class="text-xs text-gold-400 font-mono font-bold">Top {data.leaderboard.length}</span>
					</div>

					<div class="space-y-2">
						{#each data.leaderboard as entry}
							<div class="flex items-center justify-between p-2.5 rounded-lg border {entry.username === data.user.username ? 'bg-gold-500/10 border-gold-500/40' : 'bg-empire-950/40 border-empire-800/80'}">
								<div class="flex items-center gap-3">
									<div class="w-7 text-center font-bold text-sm font-mono">
										{#if entry.rank === 1}
											<span class="text-xl">🥇</span>
										{:else if entry.rank === 2}
											<span class="text-xl">🥈</span>
										{:else if entry.rank === 3}
											<span class="text-xl">🥉</span>
										{:else}
											<span class="text-slate-400">#{entry.rank}</span>
										{/if}
									</div>
									<img
										src={avatarUrl(DEFAULT_AVATAR)}
										alt={entry.username}
										class="h-9 w-9 rounded border border-empire-700 bg-empire-950 shrink-0"
									/>
									<div>
										<div class="flex items-center gap-2">
											<span class="font-bold text-sm text-white">{entry.username}</span>
											{#if entry.username === data.user.username}
												<span class="rounded bg-gold-400/20 text-gold-400 text-[10px] font-bold px-1.5 py-0.2">Tú</span>
											{/if}
										</div>
										<p class="text-xs text-slate-400">{entry.worldName}</p>
									</div>
								</div>

								<div class="flex items-center gap-3">
									<span class="rounded bg-empire-900 border border-empire-700 px-2 py-0.5 text-xs font-bold text-gold-400">
										Nvl {entry.level}
									</span>
									<span class="text-xs font-mono text-slate-300 font-semibold min-w-16 text-right">
										{entry.xp.toLocaleString()} XP
									</span>
									{#if entry.username !== data.user.username}
										<button
											type="button"
											onclick={() => startBattleWith(entry.username)}
											class="rounded bg-red-600 hover:bg-red-500 text-white p-1.5 text-xs transition-colors"
											title="Duelo táctico"
										>
											⚔️
										</button>
									{/if}
								</div>
							</div>
						{/each}
					</div>
				</div>

				<!-- 2. Ranking de Duelos PvP -->
				<div class="panel space-y-4 border-empire-800 bg-empire-900/60">
					<div class="flex items-center justify-between border-b border-empire-800 pb-3">
						<div class="flex items-center gap-2">
							<span class="text-xl">⚔️</span>
							<h3 class="font-bold text-white text-base">Arena PvP (Victorias)</h3>
						</div>
						<span class="text-xs text-red-400 font-mono font-bold">Top {data.pvpLeaderboard.length}</span>
					</div>

					<div class="space-y-2">
						{#each data.pvpLeaderboard as entry}
							<div class="flex items-center justify-between p-2.5 rounded-lg border {entry.username === data.user.username ? 'bg-gold-500/10 border-gold-500/40' : 'bg-empire-950/40 border-empire-800/80'}">
								<div class="flex items-center gap-3">
									<div class="w-7 text-center font-bold text-sm font-mono">
										{#if entry.rank === 1}
											<span class="text-xl">🥇</span>
										{:else if entry.rank === 2}
											<span class="text-xl">🥈</span>
										{:else if entry.rank === 3}
											<span class="text-xl">🥉</span>
										{:else}
											<span class="text-slate-400">#{entry.rank}</span>
										{/if}
									</div>
									<img
										src={avatarUrl(DEFAULT_AVATAR)}
										alt={entry.username}
										class="h-9 w-9 rounded border border-empire-700 bg-empire-950 shrink-0"
									/>
									<div>
										<div class="flex items-center gap-2">
											<span class="font-bold text-sm text-white">{entry.username}</span>
											{#if entry.username === data.user.username}
												<span class="rounded bg-gold-400/20 text-gold-400 text-[10px] font-bold px-1.5 py-0.2">Tú</span>
											{/if}
										</div>
										<p class="text-xs text-emerald-400 font-semibold">{entry.wins}V - {entry.losses}D</p>
									</div>
								</div>

								<div class="flex items-center gap-3">
									<span class="rounded bg-empire-900 border border-empire-700 px-2 py-0.5 text-xs font-bold text-red-400">
										{entry.pvpScore} pts
									</span>
									{#if entry.username !== data.user.username}
										<button
											type="button"
											onclick={() => startBattleWith(entry.username)}
											class="rounded bg-red-600 hover:bg-red-500 text-white p-1.5 text-xs transition-colors"
											title="Duelo táctico"
										>
											⚔️
										</button>
									{/if}
								</div>
							</div>
						{/each}
					</div>
				</div>
			</div>
		</div>
	{/if}
