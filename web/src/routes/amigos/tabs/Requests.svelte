<script lang="ts">
	import { enhance } from '$app/forms';
	import { DEFAULT_AVATAR, avatarUrl } from '#lib/avatar';
	import { formatAmount } from '#lib/resources';
	import type { BattleReport } from '#lib/combat';
	import { GIFT_DEFINITIONS } from '#lib/gifts';

	let { data, form, activeTab = $bindable('friends') } = $props();
</script>

	{#if activeTab === 'requests'}
		<div class="space-y-6">
			<div>
				<h2 class="text-xl font-bold text-white flex items-center gap-2">
					<span>📬 Solicitudes de Amistad</span>
				</h2>
				<p class="text-xs text-slate-400 mt-0.5">
					Acepta solicitudes recibidas para convertiros en amigos inmediatamente.
				</p>
			</div>

			<!-- Incoming Requests -->
			<div class="space-y-3">
				<h3 class="text-sm font-bold text-gold-400 uppercase tracking-wider">
					Solicitudes Recibidas ({data.incoming.length})
				</h3>
				{#if data.incoming.length === 0}
					<p class="panel text-xs text-slate-400 py-4">No tienes solicitudes pendientes por responder.</p>
				{:else}
					<div class="space-y-2">
						{#each data.incoming as req}
							<div class="panel flex items-center justify-between gap-4 py-3 bg-empire-900/60 border-empire-800">
								<div class="flex items-center gap-3">
									<div class="size-10 rounded-lg bg-empire-800 flex items-center justify-center text-lg">
										🎖️
									</div>
									<div>
										<div class="font-bold text-white text-sm">{req.username}</div>
										<div class="text-xs text-slate-400">
											{req.world_name ?? 'Imperio'} &bull; Nv. {formatAmount(req.level ?? 1)}
										</div>
									</div>
								</div>

								<div class="flex items-center gap-2">
									<form method="POST" action="?/accept" use:enhance class="m-0">
										<input type="hidden" name="userId" value={req.userId} />
										<button
											type="submit"
											class="rounded-md bg-gold-500 hover:bg-gold-400 text-empire-950 font-bold px-3 py-1.5 text-xs transition-colors"
										>
											Aceptar
										</button>
									</form>

									<form method="POST" action="?/reject" use:enhance class="m-0">
										<input type="hidden" name="userId" value={req.userId} />
										<button
											type="submit"
											class="rounded-md border border-empire-700 hover:bg-empire-800 text-slate-400 px-3 py-1.5 text-xs transition-colors"
										>
											Rechazar
										</button>
									</form>
								</div>
							</div>
						{/each}
					</div>
				{/if}
			</div>

			<!-- Outgoing Requests -->
			{#if data.outgoing.length > 0}
				<div class="space-y-3 pt-4 border-t border-empire-800">
					<h3 class="text-sm font-bold text-slate-400 uppercase tracking-wider">
						Solicitudes Enviadas ({data.outgoing.length})
					</h3>
					<div class="space-y-2">
						{#each data.outgoing as req}
							<div class="panel flex items-center justify-between gap-4 py-2.5 bg-empire-900/30 border-empire-800 text-xs">
								<div class="flex items-center gap-2">
									<span class="text-slate-400">Esperando respuesta de:</span>
									<span class="font-bold text-white">{req.username}</span>
									<span class="text-slate-500">(Nv. {formatAmount(req.level ?? 1)})</span>
								</div>

								<form method="POST" action="?/reject" use:enhance class="m-0">
									<input type="hidden" name="userId" value={req.userId} />
									<button
										type="submit"
										class="text-red-400 hover:text-red-300 hover:underline"
									>
										Cancelar
									</button>
								</form>
							</div>
						{/each}
					</div>
				</div>
			{/if}
		</div>
	{/if}
