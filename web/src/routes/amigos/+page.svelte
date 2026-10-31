<script lang="ts">
	import { enhance } from '$app/forms';
	import { DEFAULT_AVATAR, avatarUrl } from '#lib/avatar';
	import { formatAmount } from '#lib/resources';
	import type { BattleReport } from '#lib/combat';
	import { GIFT_DEFINITIONS } from '#lib/gifts';

	let { data, form } = $props();

	type Tab = 'friends' | 'pvp' | 'gifts' | 'clans' | 'leaderboard' | 'requests' | 'explore' | 'history';
	let activeTab = $state<Tab>('friends');

	let selectedOpponent = $state<string>(data.friends[0]?.username ?? '');
	let battling = $state(false);

	let selectedGiftFriend = $state<string>(data.friends[0]?.username ?? '');
	let selectedGiftType = $state<string>('energy');

	let newClanName = $state('');
	let newClanCrest = $state('crest_01');
	let clanFeedMessage = $state('');

	const battleReport = $derived<BattleReport | null>(
		form?.battleReport ? (form.battleReport as BattleReport) : null
	);

	function startBattleWith(username: string) {
		selectedOpponent = username;
		activeTab = 'pvp';
	}
</script>

<svelte:head>
	<title>Centro de Alianzas, Clanes y Combate — Raise the Empires</title>
</svelte:head>

<div class="py-4 space-y-6">
	<!-- Hero / Command Center Header -->
	<div class="panel border-empire-800 bg-gradient-to-r from-empire-900 via-empire-950 to-empire-900 shadow-xl">
		<div class="flex flex-wrap items-center justify-between gap-4">
			<div>
				<div class="flex items-center gap-2">
					<span class="inline-flex items-center rounded-md bg-gold-500/10 border border-gold-500/30 px-2 py-0.5 text-xs font-semibold text-gold-400 uppercase tracking-wider">
						Comunidad &bull; Sin Facebook
					</span>
					<span class="text-xs text-slate-400">Red Social Moderna de Comandantes</span>
				</div>
				<h1 class="mt-1 text-2xl sm:text-3xl font-extrabold text-white flex items-center gap-3">
					<span>⚔️ Centro de Mando, Clanes &amp; Alianzas</span>
				</h1>
				<p class="mt-1 text-sm text-slate-300 max-w-2xl">
					Coordina con otros jugadores, envía y reclama suministros reales, gestiona tu alianza militar y combate en la arena PvP.
				</p>
			</div>
			<div class="flex items-center gap-2 sm:gap-3">
				<a href="/juego" class="btn-primary !py-2 !px-4 text-sm font-semibold flex items-center gap-1.5 shadow-lg shadow-gold-900/30">
					<span>🎮 Entrar al Juego</span>
				</a>
			</div>
		</div>

		<!-- Sub-Navigation Tabs -->
		<div class="mt-6 flex flex-wrap gap-1.5 border-t border-empire-800/80 pt-4">
			<button
				type="button"
				onclick={() => (activeTab = 'friends')}
				class="flex items-center gap-2 rounded-lg px-3.5 py-2 text-xs sm:text-sm font-medium transition-colors {activeTab === 'friends'
					? 'bg-gold-500 text-empire-950 font-bold shadow'
					: 'text-slate-300 hover:bg-empire-800'}"
			>
				<span>👥 Mis Amigos</span>
				<span class="rounded-full px-1.5 py-0.2 text-[11px] {activeTab === 'friends' ? 'bg-empire-900/30 text-empire-950 font-bold' : 'bg-empire-800 text-gold-400'}">
					{data.friends.length}
				</span>
			</button>

			<button
				type="button"
				onclick={() => (activeTab = 'gifts')}
				class="flex items-center gap-2 rounded-lg px-3.5 py-2 text-xs sm:text-sm font-medium transition-colors {activeTab === 'gifts'
					? 'bg-gold-500 text-empire-950 font-bold shadow'
					: 'text-slate-300 hover:bg-empire-800'}"
			>
				<span>🎁 Regalos</span>
				{#if data.gifts.length > 0}
					<span class="rounded-full bg-emerald-500 text-empire-950 px-1.5 py-0.2 text-[11px] font-extrabold animate-pulse">
						{data.gifts.length}
					</span>
				{/if}
			</button>

			<button
				type="button"
				onclick={() => (activeTab = 'clans')}
				class="flex items-center gap-2 rounded-lg px-3.5 py-2 text-xs sm:text-sm font-medium transition-colors {activeTab === 'clans'
					? 'bg-gold-500 text-empire-950 font-bold shadow'
					: 'text-slate-300 hover:bg-empire-800'}"
			>
				<span>🛡️ Clanes &amp; Alianzas</span>
				{#if data.userClan}
					<span class="rounded bg-gold-400/20 text-gold-400 px-1.5 py-0.2 text-[10px] font-bold">
						{data.userClan.name}
					</span>
				{/if}
			</button>

			<button
				type="button"
				onclick={() => (activeTab = 'pvp')}
				class="flex items-center gap-2 rounded-lg px-3.5 py-2 text-xs sm:text-sm font-medium transition-colors {activeTab === 'pvp'
					? 'bg-gold-500 text-empire-950 font-bold shadow'
					: 'text-slate-300 hover:bg-empire-800'}"
			>
				<span>⚔️ Arena PvP</span>
				{#if battleReport}
					<span class="relative flex h-2 w-2">
						<span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-red-400 opacity-75"></span>
						<span class="relative inline-flex rounded-full h-2 w-2 bg-red-500"></span>
					</span>
				{/if}
			</button>

			<button
				type="button"
				onclick={() => (activeTab = 'requests')}
				class="flex items-center gap-2 rounded-lg px-3.5 py-2 text-xs sm:text-sm font-medium transition-colors {activeTab === 'requests'
					? 'bg-gold-500 text-empire-950 font-bold shadow'
					: 'text-slate-300 hover:bg-empire-800'}"
			>
				<span>📬 Solicitudes</span>
				{#if data.incoming.length > 0}
					<span class="rounded-full bg-red-600 px-1.5 py-0.2 text-[11px] font-bold text-white">
						{data.incoming.length}
					</span>
				{/if}
			</button>

			<button
				type="button"
				onclick={() => (activeTab = 'leaderboard')}
				class="flex items-center gap-2 rounded-lg px-3.5 py-2 text-xs sm:text-sm font-medium transition-colors {activeTab === 'leaderboard'
					? 'bg-gold-500 text-empire-950 font-bold shadow'
					: 'text-slate-300 hover:bg-empire-800'}"
			>
				<span>🏆 Clasificación</span>
			</button>

			<button
				type="button"
				onclick={() => (activeTab = 'explore')}
				class="flex items-center gap-2 rounded-lg px-3.5 py-2 text-xs sm:text-sm font-medium transition-colors {activeTab === 'explore'
					? 'bg-gold-500 text-empire-950 font-bold shadow'
					: 'text-slate-300 hover:bg-empire-800'}"
			>
				<span>🔍 Buscar Comandantes</span>
			</button>

			<button
				type="button"
				onclick={() => (activeTab = 'history')}
				class="flex items-center gap-2 rounded-lg px-3.5 py-2 text-xs sm:text-sm font-medium transition-colors {activeTab === 'history'
					? 'bg-gold-500 text-empire-950 font-bold shadow'
					: 'text-slate-300 hover:bg-empire-800'}"
			>
				<span>📜 Batallas</span>
			</button>
		</div>
	</div>

	<!-- Alert Messages -->
	{#if form?.message}
		<div class="rounded-lg border border-gold-600/40 bg-gold-500/10 px-4 py-3 text-sm text-gold-300 shadow">
			{form.message}
		</div>
	{/if}

	<!-- ------------------------------------------------------------- -->
	<!-- TAB 1: MIS AMIGOS & ALIANZAS -->
	<!-- ------------------------------------------------------------- -->
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

	<!-- ------------------------------------------------------------- -->
	<!-- TAB 2: BANDEJA DE REGALOS REALES -->
	<!-- ------------------------------------------------------------- -->
	{#if activeTab === 'gifts'}
		<div class="space-y-6">
			<div>
				<h2 class="text-xl font-bold text-white flex items-center gap-2">
					<span>🎁 Bandeja de Regalos Recibidos ({data.gifts.length})</span>
				</h2>
				<p class="text-xs text-slate-400 mt-0.5">
					Suministros reales enviados por tus aliados. Puedes reclamarlos aquí o en el juego.
				</p>
			</div>

			{#if data.gifts.length === 0}
				<div class="panel py-12 text-center space-y-3">
					<div class="text-4xl">📦</div>
					<h3 class="text-base font-semibold text-white">No tienes regalos pendientes</h3>
					<p class="text-xs text-slate-400 max-w-sm mx-auto">
						¡Pide a tus amigos que te envíen energía, monedas o planos militares para seguir construyendo tu imperio!
					</p>
				</div>
			{:else}
				<div class="grid gap-3 sm:grid-cols-2">
					{#each data.gifts as gift}
						<div class="panel border-gold-600/30 bg-gradient-to-r from-empire-900 to-empire-950 flex items-center justify-between gap-3 p-4">
							<div class="flex items-center gap-3">
								<span class="text-3xl">{gift.gift_icon}</span>
								<div>
									<div class="font-bold text-white text-sm">{gift.gift_label}</div>
									<div class="text-xs text-slate-400">
										De: <span class="text-gold-300 font-semibold">{gift.sender_username}</span> &bull; {gift.created_at}
									</div>
								</div>
							</div>

							<form method="POST" action="?/claimGift" use:enhance class="m-0">
								<input type="hidden" name="giftId" value={gift.id} />
								<button
									type="submit"
									class="btn-primary !py-1.5 !px-3 text-xs font-bold shadow"
								>
									Reclamar
								</button>
							</form>
						</div>
					{/each}
				</div>
			{/if}
		</div>
	{/if}

	<!-- ------------------------------------------------------------- -->
	<!-- TAB 3: CLANES Y ALIANZAS -->
	<!-- ------------------------------------------------------------- -->
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

	<!-- ------------------------------------------------------------- -->
	<!-- TAB 4: ARENA DE COMBATE PVP -->
	<!-- ------------------------------------------------------------- -->
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

	<!-- ------------------------------------------------------------- -->
	<!-- TAB 5: SOLICITUDES ENTRANTES & SALIENTES -->
	<!-- ------------------------------------------------------------- -->
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

	<!-- ------------------------------------------------------------- -->
	<!-- TAB 6: BUSCAR COMANDANTES -->
	<!-- ------------------------------------------------------------- -->
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

	<!-- ------------------------------------------------------------- -->
	<!-- TAB: TABLAS DE CLASIFICACIÓN / LEADERBOARD                     -->
	<!-- ------------------------------------------------------------- -->
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

	<!-- ------------------------------------------------------------- -->
	<!-- TAB 7: HISTORIAL DE BATALLAS -->
	<!-- ------------------------------------------------------------- -->
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
</div>
