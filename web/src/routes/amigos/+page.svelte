<script lang="ts">
	import { enhance } from '$app/forms';
	import { DEFAULT_AVATAR, avatarUrl } from '#lib/avatar';
	import { formatAmount } from '#lib/resources';
	import type { BattleReport } from '#lib/combat';
	import { GIFT_DEFINITIONS } from '#lib/gifts';

	import Arena from './tabs/Arena.svelte';
	import Clans from './tabs/Clans.svelte';
	import Explore from './tabs/Explore.svelte';
	import Friends from './tabs/Friends.svelte';
	import Gifts from './tabs/Gifts.svelte';
	import History from './tabs/History.svelte';
	import Leaderboard from './tabs/Leaderboard.svelte';
	import Requests from './tabs/Requests.svelte';

	let { data, form } = $props();

	type Tab = 'friends' | 'pvp' | 'gifts' | 'clans' | 'leaderboard' | 'requests' | 'explore' | 'history';
	let activeTab = $state<Tab>('friends');

	let selectedOpponent = $state<string>(data.friends[0]?.username ?? '');
	let battling = $state(false);



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
		<Friends {data} {form} {activeTab} {startBattleWith} />

	<!-- ------------------------------------------------------------- -->
	<!-- TAB 2: BANDEJA DE REGALOS REALES -->
	<!-- ------------------------------------------------------------- -->
		<Gifts {data} {form} {activeTab} />

	<!-- ------------------------------------------------------------- -->
	<!-- TAB 3: CLANES Y ALIANZAS -->
	<!-- ------------------------------------------------------------- -->
		<Clans {data} {form} {activeTab} />

	<!-- ------------------------------------------------------------- -->
	<!-- TAB 4: ARENA DE COMBATE PVP -->
	<!-- ------------------------------------------------------------- -->
		<Arena {data} {form} {activeTab} {selectedOpponent} {battling} {battleReport} />

	<!-- ------------------------------------------------------------- -->
	<!-- TAB 5: SOLICITUDES ENTRANTES & SALIENTES -->
	<!-- ------------------------------------------------------------- -->
		<Requests {data} {form} {activeTab} />

	<!-- ------------------------------------------------------------- -->
	<!-- TAB 6: BUSCAR COMANDANTES -->
	<!-- ------------------------------------------------------------- -->
		<Explore {data} {form} {activeTab} />

	<!-- ------------------------------------------------------------- -->
	<!-- TAB: TABLAS DE CLASIFICACIÓN / LEADERBOARD                     -->
	<!-- ------------------------------------------------------------- -->
		<Leaderboard {data} {form} {activeTab} {startBattleWith} />

	<!-- ------------------------------------------------------------- -->
	<!-- TAB 7: HISTORIAL DE BATALLAS -->
	<!-- ------------------------------------------------------------- -->
		<History {data} {form} {activeTab} {startBattleWith} />
</div>
