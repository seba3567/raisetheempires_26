<script lang="ts">
	import { enhance } from '$app/forms';
	import { DEFAULT_AVATAR, avatarUrl } from '#lib/avatar';
	import { formatAmount } from '#lib/resources';
	import type { BattleReport } from '#lib/combat';
	import { GIFT_DEFINITIONS } from '#lib/gifts';

	let { data, form, activeTab = $bindable('friends'), startBattleWith } = $props();
</script>

	{#if activeTab === 'friends'}
		<div class="space-y-4">
			<div class="flex items-center justify-between">
				<h2 class="text-xl font-bold text-white flex items-center gap-2">
					<span>👥 Lista de Amigos Reales ({data.friends.length})</span>
				</h2>
				<button
					type="button"
					onclick={() => (activeTab = 'explore')}
					class="text-xs text-gold-400 hover:underline flex items-center gap-1"
				>
					<span>+ Añadir nuevos comandantes</span>
				</button>
			</div>

			{#if data.friends.length === 0}
				<div class="panel py-12 text-center space-y-3">
					<div class="text-4xl">🏝️</div>
					<h3 class="text-lg font-semibold text-white">Aún no tienes amigos agregados</h3>
					<p class="text-sm text-slate-400 max-w-md mx-auto">
						Los amigos que agregues aquí aparecerán en tu juego Flash, podrás enviarles regalos diarios, ayudarlos en sus islas y desafiar sus ejércitos.
					</p>
					<button
						type="button"
						onclick={() => (activeTab = 'explore')}
						class="btn-primary !py-2 !px-4 text-xs font-semibold"
					>
						Buscar y Reclutar Amigos
					</button>
				</div>
			{:else}
				<div class="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
					{#each data.friends as friend (friend.username)}
						<div class="panel border-empire-800 hover:border-slate-700 bg-empire-900/60 transition-all flex flex-col justify-between space-y-4">
							<div class="flex items-start gap-3.5">
								<img
									src={avatarUrl(DEFAULT_AVATAR)}
									alt=""
									class="size-14 rounded-lg object-cover border border-gold-600/40 bg-empire-950 shrink-0"
								/>
								<div class="min-w-0 flex-1">
									<div class="flex items-center justify-between gap-1">
										<h3 class="text-base font-bold text-white truncate">{friend.username}</h3>
										<span class="rounded bg-empire-800 px-1.5 py-0.5 text-[10px] font-mono text-gold-400 font-semibold shrink-0">
											Nv. {formatAmount(friend.level ?? 1)}
										</span>
									</div>
									<p class="text-xs text-slate-400 truncate mt-0.5">{friend.world_name ?? 'Imperio Insular'}</p>
									<p class="text-[11px] font-mono text-slate-500 mt-0.5">ZID: {friend.zid}</p>
								</div>
							</div>

							<!-- Action Buttons -->
							<div class="border-t border-empire-800/80 pt-3 space-y-2">
								<div class="grid grid-cols-2 gap-2">
									<!-- Challenge PvP Button -->
									<button
										type="button"
										onclick={() => startBattleWith(friend.username)}
										class="rounded-md border border-red-500/40 bg-red-500/10 px-2.5 py-1.5 text-xs font-semibold text-red-300 hover:bg-red-500/20 hover:border-red-400 transition-colors flex items-center justify-center gap-1.5"
									>
										<span>⚔️ Duelo PvP</span>
									</button>

									<!-- Send Gift Form -->
									<form method="POST" action="?/sendGift" use:enhance class="m-0 flex">
										<input type="hidden" name="username" value={friend.username} />
										<select
											name="giftType"
											class="w-full rounded-md border border-gold-500/40 bg-gold-500/10 px-1 py-1.5 text-[11px] font-semibold text-gold-300 hover:bg-gold-500/20 focus:outline-none cursor-pointer"
											onchange={(e) => (e.target as HTMLSelectElement).form?.requestSubmit()}
										>
											<option value="" disabled selected>🎁 Regalar...</option>
											<option value="energy">⚡ Energía (+1)</option>
											<option value="coins">🪙 Monedas (+2.5k)</option>
											<option value="oil">🛢️ Petróleo (+1k)</option>
											<option value="wood">🪵 Madera (+1k)</option>
											<option value="blueprint">📐 Planos (B01)</option>
										</select>
									</form>
								</div>

								<div class="flex items-center justify-between pt-1 text-[11px]">
									<a
										href="/juego"
										class="text-slate-400 hover:text-white flex items-center gap-1"
									>
										<span>🏝️ Visitar en juego</span>
									</a>

									<form method="POST" action="?/remove" use:enhance class="m-0">
										<input type="hidden" name="username" value={friend.username} />
										<button
											type="submit"
											class="text-red-400 hover:text-red-300 hover:underline"
											onclick={(e) => {
												if (!confirm(`¿Disolver amistad con ${friend.username}?`)) e.preventDefault();
											}}
										>
											Quitar
										</button>
									</form>
								</div>
							</div>
						</div>
					{/each}
				</div>
			{/if}
		</div>
	{/if}
