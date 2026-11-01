<script lang="ts">
	import { enhance } from '$app/forms';
	import { DEFAULT_AVATAR, avatarUrl } from '#lib/avatar';
	import { formatAmount } from '#lib/resources';
	import type { BattleReport } from '#lib/combat';
	import { GIFT_DEFINITIONS } from '#lib/gifts';

	let { data, form, activeTab = $bindable('friends') } = $props();
</script>

	{#if activeTab === 'explore'}
		<div class="space-y-6">
			<div>
				<h2 class="text-xl font-bold text-white flex items-center gap-2">
					<span>🔍 Búsqueda de Comandantes</span>
				</h2>
				<p class="text-xs text-slate-400 mt-0.5">
					Busca jugadores registrados en el servidor o agrega amigos entre las sugerencias.
				</p>
			</div>

			<!-- Search Bar -->
			<form method="GET" class="panel flex gap-2 p-2.5 bg-empire-900/70 border-empire-800">
				<input
					type="text"
					name="q"
					value={data.query}
					placeholder="Buscar por nombre de usuario..."
					class="flex-1 rounded-md border border-empire-700 bg-empire-950 px-3 py-2 text-sm text-white placeholder-slate-500 focus:border-gold-500 focus:outline-none"
				/>
				<button
					type="submit"
					class="btn-primary !py-2 !px-4 text-xs font-semibold"
				>
					Buscar
				</button>
			</form>

			<!-- Search Results -->
			{#if data.query.trim().length > 0}
				<div class="space-y-3">
					<h3 class="text-sm font-bold text-white">
						Resultados para "{data.query}" ({data.searchResults.length})
					</h3>
					{#if data.searchResults.length === 0}
						<p class="panel text-xs text-slate-400 py-4">No se encontraron comandantes con ese nombre.</p>
					{:else}
						<div class="grid gap-3 sm:grid-cols-2">
							{#each data.searchResults as result}
								<div class="panel flex items-center justify-between gap-3 bg-empire-900/60 border-empire-800">
									<div>
										<div class="font-bold text-white text-sm">{result.username}</div>
										<div class="text-xs text-slate-400">Nv. {formatAmount(result.level ?? 1)} &bull; {result.world_name ?? 'Imperio'}</div>
									</div>

									{#if result.status === 'accepted'}
										<span class="text-xs text-gold-400 font-semibold">✓ Amigo</span>
									{:else if result.status === 'pending'}
										<span class="text-xs text-slate-400">Pendiente</span>
									{:else}
										<form method="POST" action="?/add" use:enhance class="m-0">
											<input type="hidden" name="username" value={result.username} />
											<button
												type="submit"
												class="btn-primary !py-1.5 !px-3 text-xs"
											>
												+ Agregar
											</button>
										</form>
									{/if}
								</div>
							{/each}
						</div>
					{/if}
				</div>
			{/if}

			<!-- Suggested Players -->
			<div class="space-y-3 pt-2">
				<h3 class="text-sm font-bold text-gold-400 uppercase tracking-wider">
					Comandantes Sugeridos del Servidor
				</h3>
				{#if data.suggestions.length === 0}
					<p class="panel text-xs text-slate-400 py-4">No hay más sugerencias en este momento.</p>
				{:else}
					<div class="grid gap-3 sm:grid-cols-2 lg:grid-cols-3">
						{#each data.suggestions as s}
							<div class="panel flex items-center justify-between gap-3 bg-empire-900/40 border-empire-800 hover:border-slate-700 transition-colors">
								<div class="min-w-0">
									<div class="font-bold text-white text-sm truncate">{s.username}</div>
									<div class="text-xs text-slate-400">Nv. {formatAmount(s.level ?? 1)}</div>
								</div>

								<form method="POST" action="?/add" use:enhance class="m-0 shrink-0">
									<input type="hidden" name="username" value={s.username} />
									<button
										type="submit"
										class="rounded-md border border-gold-500/40 bg-gold-500/10 px-3 py-1.5 text-xs font-semibold text-gold-300 hover:bg-gold-500/20 hover:border-gold-400 transition-colors"
									>
										+ Agregar
									</button>
								</form>
							</div>
						{/each}
					</div>
				{/if}
			</div>
		</div>
	{/if}
