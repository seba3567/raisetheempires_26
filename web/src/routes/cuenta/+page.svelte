<script lang="ts">
	import { enhance } from '$app/forms';

	import { avatarUrl, DEFAULT_AVATAR } from '#lib/avatar';
	import {
		EMPIRE_POINTS_ICON,
		RESOURCES,
		XP_ICON,
		formatAmount
	} from '#lib/resources';

	let { data, form } = $props();

	const level = $derived(data.progress.level);
	const xp = $derived(data.progress.xp);
	const empirePoints = $derived(data.progress.empirePoints);
	const hasSave = $derived(data.state?.hasSave ?? false);

	/*
	 * The picture the game shows. It comes from the save, not from the account
	 * row, because that is where the client reads it from -- so changing it here
	 * changes what the game draws, with no second copy to keep in step.
	 */
	const chosenAvatar = $derived(data.avatar?.current ?? DEFAULT_AVATAR);
	const canChooseAvatar = $derived((data.avatar?.avatars.length ?? 0) > 0);
	let editingAvatar = $state(false);
</script>

<svelte:head>
	<title>Mi cuenta — Raise the Empires</title>
</svelte:head>

<div class="py-6">
	<!-- Empire header -->
	<div class="panel flex flex-wrap items-center gap-5">
		<!--
			`use:enhance` keeps the page from reloading, so the avatar header stays
			where it is while the new one is chosen. Without it every pick is a full
			page load and the grid closes under the cursor.
		-->
		<form
			method="POST"
			action="?/pickAvatar"
			use:enhance={() => {
				return async ({ update }) => {
					await update({ reset: false });
					editingAvatar = false;
				};
			}}
			class="shrink-0"
		>
			<!--
				Always a plain button: it opens the grid. Submitting here would post
				the avatar that is already chosen, which is a pointless write to the
				save every time the header is clicked.
			-->
			<button
				type="button"
				onclick={() => (editingAvatar = !editingAvatar)}
				disabled={!canChooseAvatar}
				class="relative block rounded-lg border border-empire-700 disabled:cursor-default {editingAvatar
					? 'border-gold-500'
					: 'hover:border-gold-600/60'}"
				title={canChooseAvatar ? 'Cambiar avatar' : 'El servidor del juego no respondió'}
				aria-expanded={editingAvatar}
			>
				<img
					src={avatarUrl(chosenAvatar)}
					alt="Avatar de {data.user.username}"
					class="size-20 rounded-lg object-cover"
				/>
				{#if canChooseAvatar}
					<span
						class="absolute -bottom-1 -right-1 rounded-full border border-empire-700 bg-empire-900 px-1.5 py-0.5 text-[10px] font-medium text-gold-400"
					>
						cambiar
					</span>
				{/if}
			</button>

			{#if editingAvatar}
				<div
					class="panel mt-3 grid w-80 grid-cols-5 gap-1.5 p-2 shadow-xl"
					role="group"
					aria-label="Elegir avatar"
				>
					{#each Array.from(new Set(data.avatar?.avatars ?? [])) as avatar, i (avatar ? `${avatar}-${i}` : i)}
						<button
							type="submit"
							name="avatar"
							value={avatar}
							title={avatar}
							aria-label={`Elegir avatar ${avatar}`}
							aria-pressed={avatar === chosenAvatar}
							class="rounded border-2 p-0.5 transition-colors {avatar === chosenAvatar
								? 'border-gold-400 bg-gold-500/20'
								: 'border-transparent hover:border-slate-500'}"
						>
							<img src={avatarUrl(avatar)} alt="" height="40" loading="lazy" />
						</button>
					{/each}
				</div>
			{/if}

			{#if form?.avatarMessage}
				<p class="mt-2 max-w-80 text-xs text-red-300">{form.avatarMessage}</p>
			{/if}
		</form>

		<div class="min-w-0">
			<h1 class="flex flex-wrap items-center gap-3 text-3xl font-bold">
				{data.user.username}
				{#if data.user.role === 'admin'}
					<span
						class="rounded-full border border-gold-600/60 bg-gold-500/15 px-3 py-0.5 align-middle text-xs font-medium tracking-wide text-gold-400 uppercase"
					>
						admin
					</span>
				{/if}
			</h1>
			<p class="mt-1 truncate text-slate-400">
				{data.progress.worldName}
				<span class="text-slate-600">·</span>
				<span class="font-mono text-xs">zid {data.user.zid}</span>
			</p>
			<p class="mt-1 text-xs text-slate-500">
				El avatar es el que ve el juego y tu lista de amigos.
			</p>
		</div>
		<a href="/juego" class="btn-primary ml-auto">Entrar al juego</a>
	</div>

	<!-- Level, XP and Empire Points, from the save -->
	<div class="mt-6 grid gap-4 sm:grid-cols-3">
		<div class="panel flex items-center gap-4">
			<img src={XP_ICON} alt="" class="size-10" />
			<div>
				<div class="text-xs tracking-wide text-slate-400 uppercase">Nivel</div>
				<div class="text-3xl font-bold">{formatAmount(level)}</div>
			</div>
		</div>

		<div class="panel">
			<div class="text-xs tracking-wide text-slate-400 uppercase">XP</div>
			<div class="text-3xl font-bold">{formatAmount(xp)}</div>
		</div>

		<div class="panel flex items-center gap-4">
			<img src={EMPIRE_POINTS_ICON} alt="" class="size-10" />
			<div>
				<div class="text-xs tracking-wide text-slate-400 uppercase">Empire Points</div>
				<div class="text-3xl font-bold">{formatAmount(empirePoints)}</div>
			</div>
		</div>
	</div>

	<!-- Resources -->
	<h2 class="mt-10 text-xl font-semibold">Recursos</h2>
	{#if hasSave}
		<div class="mt-3 grid grid-cols-2 gap-3 sm:grid-cols-4">
			{#each RESOURCES as resource (resource.key)}
				<div class="panel flex items-center gap-3">
					<img src={resource.icon} alt="" class="size-9 shrink-0" />
					<div class="min-w-0">
						<div class="truncate text-xs tracking-wide text-slate-400 uppercase">
							{resource.label}
						</div>
						<div class="text-lg font-semibold">
							{formatAmount(data.progress.resources[resource.key])}
						</div>
					</div>
				</div>
			{/each}
		</div>
	{:else}
		<p class="panel mt-3 max-w-2xl text-sm text-slate-400">
			Todavía no hay una partida guardada para esta cuenta. Entra al juego para crear una, y
			aquí verás tu nivel y tus recursos.
		</p>
	{/if}

	<!-- Admin -->
	{#if data.user.role === 'admin'}
		<h2 class="mt-12 text-xl font-semibold">Administración</h2>
		<div class="panel mt-3 max-w-2xl">
			<p class="text-sm text-slate-400">
				Estas herramientas cambian el estado del juego o exponen datos de otros jugadores, así
				que solo una cuenta con rol <code>admin</code> puede abrirlas.
			</p>
			<div class="mt-4 flex flex-wrap gap-3">
				<a href="/admin/editor" class="btn-primary !py-2.5 !text-sm">
					Abrir el editor de imperio
				</a>
				<a
					href="/gazillionaire"
					class="rounded-lg border border-empire-700 px-4 py-2.5 text-sm hover:bg-empire-800"
				>
					+10.000 Empire Points
				</a>
				<a
					href="/admin/sessions"
					class="rounded-lg border border-empire-700 px-4 py-2.5 text-sm hover:bg-empire-800"
				>
					Ver sesiones guardadas
				</a>
			</div>
		</div>
	{/if}

	<!-- Alianzas & PvP Hub Callout -->
	<div class="mt-12 panel border-gold-600/40 bg-gradient-to-r from-empire-900 via-empire-950 to-empire-900 flex flex-wrap items-center justify-between gap-4 p-5 shadow-lg">
		<div>
			<div class="flex items-center gap-2">
				<span class="rounded bg-gold-500/20 text-gold-400 text-[11px] font-bold px-2 py-0.5 uppercase border border-gold-500/30">
					Nuevo Sistema Social Web
				</span>
			</div>
			<h2 class="text-xl font-bold text-white mt-1">⚔️ Centro de Alianzas, Duelos PvP y Regalos</h2>
			<p class="text-xs text-slate-300 mt-0.5 max-w-xl">
				Envía suministros a tus amigos, desafía a otros comandantes en la Arena Táctica y recluta aliados sin pasar por Facebook.
			</p>
		</div>
		<a href="/amigos" class="btn-primary !py-2.5 !px-5 text-sm font-bold flex items-center gap-2 shadow-md">
			<span>Abrir Centro de Alianzas</span>
			<span>&rarr;</span>
		</a>
	</div>

	<h2 class="mt-8 text-xl font-semibold">Amigos</h2>
	{#if data.friends.length === 0}
		<p class="mt-2 text-slate-400">Todavía no tienes amigos.</p>
	{:else}
		<table class="panel mt-3 w-full max-w-2xl text-left text-sm">
			<thead class="text-xs tracking-wide text-slate-400 uppercase">
				<tr>
					<th class="px-2 py-2">Jugador</th>
					<th class="px-2 py-2">Nivel</th>
					<th class="px-2 py-2"></th>
				</tr>
			</thead>
			<tbody>
				{#each data.friends as friend, i (friend.zid ? `${friend.zid}-${i}` : i)}
					<tr class="border-t border-empire-800">
						<td class="px-2 py-2">{friend.username}</td>
						<td class="px-2 py-2">{formatAmount(friend.level)}</td>
						<td class="px-2 py-2 text-right">
							<form method="POST" action="?/remove" use:enhance>
								<input type="hidden" name="friend" value={friend.username} />
								<button
									class="rounded border border-empire-700 px-3 py-1 text-xs hover:bg-empire-800"
								>
									Quitar
								</button>
							</form>
						</td>
					</tr>
				{/each}
			</tbody>
		</table>
	{/if}

	{#if data.suggestions.length > 0}
		<h2 class="mt-10 text-xl font-semibold">Sugerencias</h2>
		<table class="panel mt-3 w-full max-w-2xl text-left text-sm">
			<tbody>
				{#each data.suggestions as suggestion, i (suggestion.zid ? `${suggestion.zid}-${i}` : i)}
					<tr class="border-t border-empire-800 first:border-t-0">
						<td class="px-2 py-2">{suggestion.username}</td>
						<td class="px-2 py-2">{formatAmount(suggestion.level)}</td>
						<td class="px-2 py-2 text-right">
							<form method="POST" action="?/add" use:enhance>
								<input type="hidden" name="friend" value={suggestion.username} />
								<button
									class="rounded border border-empire-700 px-3 py-1 text-xs hover:bg-empire-800"
								>
									Agregar
								</button>
							</form>
						</td>
					</tr>
				{/each}
			</tbody>
		</table>
	{/if}
</div>