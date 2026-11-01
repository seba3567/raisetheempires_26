<script lang="ts">
	import { enhance } from '$app/forms';
	import { DEFAULT_AVATAR, avatarUrl } from '#lib/avatar';
	import { formatAmount } from '#lib/resources';
	import type { BattleReport } from '#lib/combat';
	import { GIFT_DEFINITIONS } from '#lib/gifts';

	let { data, form, activeTab = $bindable('friends') } = $props();

	// The name, the shield and the message being written to the wall.
	let newClanName = $state('');
	let newClanCrest = $state('crest_01');
	let clanFeedMessage = $state('');
</script>

	{#if activeTab === 'clans'}
		<div class="space-y-6">
			{#if data.userClan}
				<!-- Clan Dashboard -->
				<div class="panel border-gold-600/40 bg-gradient-to-r from-empire-900 via-empire-950 to-empire-900 shadow-xl space-y-5">
					<div class="flex flex-wrap items-center justify-between gap-4">
						<div class="flex items-center gap-4">
							<div class="size-16 rounded-xl bg-empire-800 border-2 border-gold-500/60 flex items-center justify-center text-3xl shadow-inner">
								🛡️
							</div>
							<div>
								<div class="flex items-center gap-2">
									<h2 class="text-2xl font-black text-white">{data.userClan.name}</h2>
									<span class="rounded bg-gold-500 text-empire-950 font-black px-2 py-0.5 text-xs">
										Nv. {data.userClan.level}
									</span>
								</div>
								<p class="text-xs text-slate-400 mt-0.5">
									Blasón: <code class="text-gold-400">{data.userClan.crest}</code> &bull; Miembros: {data.clanMembers.length}/{data.userClan.slots}
								</p>
							</div>
						</div>

						<div class="flex items-center gap-3">
							{#if data.userClan.health < data.userClan.max_health}
								<form method="POST" action="?/healClan" use:enhance class="m-0">
									<input type="hidden" name="clanId" value={data.userClan.id} />
									<button
										type="submit"
										class="rounded-md border border-emerald-500/40 bg-emerald-500/10 hover:bg-emerald-500/20 text-emerald-300 px-3 py-1.5 text-xs font-semibold transition-colors flex items-center gap-1.5"
									>
										<span>🛠️ Reparar (+25 HP)</span>
									</button>
								</form>
							{/if}

							<!-- Leave clan -->
							<form method="POST" action="?/leaveClan" use:enhance class="m-0">
								<input type="hidden" name="clanId" value={data.userClan.id} />
								<button
									type="submit"
									class="rounded-md border border-red-500/40 bg-red-500/10 hover:bg-red-500/20 text-red-300 px-3 py-1.5 text-xs font-semibold transition-colors"
									onclick={(e) => {
										if (!confirm('¿Seguro que deseas abandonar tu alianza militar?')) e.preventDefault();
									}}
								>
									Abandonar Alianza
								</button>
							</form>
						</div>
					</div>

					<!-- Clan Health Bar -->
					<div class="space-y-1">
						<div class="flex justify-between text-xs text-slate-400">
							<span>Fortaleza Comunal</span>
							<span class="font-mono text-emerald-400 font-bold">{data.userClan.health}/{data.userClan.max_health} HP</span>
						</div>
						<div class="w-full bg-empire-950 rounded-full h-2.5 overflow-hidden border border-empire-800">
							<div
								class="bg-gradient-to-r from-emerald-600 to-emerald-400 h-2.5 rounded-full"
								style="width: {(data.userClan.health / data.userClan.max_health) * 100}%"
							></div>
						</div>
					</div>
				</div>

				<div class="grid md:grid-cols-2 gap-6">
					<!-- Members List -->
					<div class="space-y-3">
						<h3 class="text-sm font-bold text-white uppercase tracking-wider flex items-center justify-between">
							<span>Fila de Miembros ({data.clanMembers.length})</span>
						</h3>
						<div class="space-y-2">
							{#each data.clanMembers as member}
								<div class="panel flex items-center justify-between py-2.5 bg-empire-900/40 border-empire-800">
									<div class="flex items-center gap-2.5">
										<span class="text-lg">
											{member.role === 'leader' ? '👑' : member.role === 'officer' ? '⭐' : '🪖'}
										</span>
										<div>
											<div class="font-bold text-white text-xs sm:text-sm">{member.username}</div>
											<div class="text-[11px] text-slate-400">
												Nv. {formatAmount(member.level ?? 1)} &bull; {member.role}
											</div>
										</div>
									</div>
									<span class="text-[10px] text-slate-500 font-mono">Desde {member.joined_at?.slice(0, 10)}</span>
								</div>
							{/each}
						</div>
					</div>

					<!-- Alliance Wall / Feed -->
					<div class="space-y-3">
						<h3 class="text-sm font-bold text-white uppercase tracking-wider">
							Muro de Órdenes Tácticas
						</h3>

						<form method="POST" action="?/postClanFeed" use:enhance class="flex gap-2">
							<input type="hidden" name="clanId" value={data.userClan.id} />
							<input
								type="text"
								name="message"
								bind:value={clanFeedMessage}
								placeholder="Escribir mensaje a los aliados..."
								required
								class="flex-1 rounded-md border border-empire-700 bg-empire-950 px-3 py-1.5 text-xs text-white focus:border-gold-500 focus:outline-none"
							/>
							<button type="submit" class="btn-primary !py-1.5 !px-3 text-xs font-semibold">
								Publicar
							</button>
						</form>

						<div class="max-h-72 overflow-y-auto space-y-2 rounded-lg border border-empire-800 bg-empire-950/70 p-3">
							{#if data.clanMessages.length === 0}
								<p class="text-xs text-slate-500 text-center py-4">No hay mensajes en el muro aún.</p>
							{:else}
								{#each data.clanMessages as msg}
									<div class="text-xs border-b border-empire-800/60 pb-2 last:border-b-0">
										<div class="flex items-center justify-between text-[11px]">
											<span class="font-bold text-gold-400">{msg.username}</span>
											<span class="text-slate-500 font-mono">{msg.created_at?.slice(11, 16)}</span>
										</div>
										<p class="text-slate-200 mt-0.5">{msg.message}</p>
									</div>
								{/each}
							{/if}
						</div>
					</div>
				</div>
			{:else}
				<!-- No Clan: Create or Join -->
				<div class="grid md:grid-cols-2 gap-6">
					<!-- Create Clan -->
					<div class="panel border-gold-600/40 bg-empire-900/50 space-y-4">
						<div class="flex items-center gap-3">
							<span class="text-3xl">⚔️</span>
							<div>
								<h3 class="text-lg font-bold text-white">Fundar Nueva Alianza</h3>
								<p class="text-xs text-slate-400">Reúne a tus aliados bajo un mismo estandarte militar.</p>
							</div>
						</div>

						<form method="POST" action="?/createClan" use:enhance class="space-y-3">
							<div>
								<label for="newClanName" class="block text-xs font-semibold text-slate-300 mb-1">Nombre de la Alianza:</label>
								<input
									id="newClanName"
									type="text"
									name="name"
									bind:value={newClanName}
									placeholder="Ej. Legión Águila"
									required
									minlength="3"
									maxlength="32"
									class="w-full rounded-md border border-empire-700 bg-empire-950 px-3 py-2 text-sm text-white focus:border-gold-500 focus:outline-none"
								/>
							</div>

							<div>
								<label for="newClanCrest" class="block text-xs font-semibold text-slate-300 mb-1">Blasón Heráldico:</label>
								<select
									id="newClanCrest"
									name="crest"
									bind:value={newClanCrest}
									class="w-full rounded-md border border-empire-700 bg-empire-950 px-3 py-2 text-sm text-white focus:border-gold-500 focus:outline-none"
								>
									<option value="crest_01">🦅 Escudo Águila Dorada</option>
									<option value="crest_02">⚓ Ancla de Marina Imperial</option>
									<option value="crest_03">🦁 León Blindado</option>
									<option value="crest_04">🚀 Proyectil Fénix</option>
									<option value="crest_05">⚡ Rayo Centella</option>
								</select>
							</div>

							<button type="submit" class="btn-primary w-full !py-2.5 font-bold text-sm">
								Fundar Alianza Ahora
							</button>
						</form>
					</div>

					<!-- Join Existing Clan -->
					<div class="panel border-empire-800 bg-empire-900/30 space-y-4">
						<h3 class="text-base font-bold text-white uppercase tracking-wider">
							Alianzas en el Servidor ({data.allClans.length})
						</h3>

						{#if data.allClans.length === 0}
							<p class="text-xs text-slate-400 py-6 text-center">Todavía no hay alianzas fundadas en el servidor.</p>
						{:else}
							<div class="space-y-2.5 max-h-80 overflow-y-auto">
								{#each data.allClans as clan}
									<div class="panel flex items-center justify-between p-3 bg-empire-950/60 border-empire-800">
										<div>
											<div class="font-bold text-white text-sm flex items-center gap-2">
												<span>{clan.name}</span>
												<span class="rounded bg-empire-800 text-gold-400 text-[10px] px-1.5 py-0.2 font-mono">
													Nv. {clan.level}
												</span>
											</div>
											<div class="text-xs text-slate-400">
												Líder: {clan.leader_name} &bull; {clan.member_count}/{clan.slots} plazas
											</div>
										</div>

										<form method="POST" action="?/joinClan" use:enhance class="m-0">
											<input type="hidden" name="clanId" value={clan.id} />
											<button
												type="submit"
												class="rounded-md border border-gold-500/40 bg-gold-500/10 hover:bg-gold-500/20 text-gold-300 font-semibold px-3 py-1.5 text-xs transition-colors"
											>
												Unirse
											</button>
										</form>
									</div>
								{/each}
							</div>
						{/if}
					</div>
				</div>
			{/if}
		</div>
	{/if}
