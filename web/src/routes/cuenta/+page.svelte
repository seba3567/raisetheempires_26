<script lang="ts">
	import { enhance } from '$app/forms';

	let { data } = $props();
</script>

<svelte:head>
	<title>Mi cuenta — Raise the Empires</title>
</svelte:head>

<div class="py-6">
	<h1 class="text-3xl font-bold">
		{data.user.username}
		{#if data.user.role === 'admin'}
			<span
				class="ml-2 rounded-full border border-empire-700 bg-empire-800 px-2.5 py-0.5 align-middle text-xs font-normal text-slate-300"
			>
				admin
			</span>
		{/if}
	</h1>

	<div class="mt-6 grid gap-4 sm:grid-cols-3">
		<div class="panel">
			<div class="text-xs uppercase tracking-wide text-slate-400">Nivel</div>
			<div class="text-3xl font-bold">{data.progress.level}</div>
		</div>
		<div class="panel">
			<div class="text-xs uppercase tracking-wide text-slate-400">XP</div>
			<div class="text-3xl font-bold">{data.progress.xp}</div>
		</div>
		<div class="panel">
			<div class="text-xs uppercase tracking-wide text-slate-400">Mundo</div>
			<div class="text-lg font-semibold">{data.progress.worldName}</div>
			<div class="mt-1 text-xs text-slate-500">zid {data.user.zid}</div>
		</div>
	</div>

	<a
		href="/juego"
		class="mt-6 inline-block rounded-lg bg-gold-500 px-6 py-3 font-semibold text-empire-950 hover:bg-gold-400"
	>
		Entrar al juego
	</a>

	{#if data.user.role === 'admin'}
		<h2 class="mt-12 text-xl font-semibold">Administración</h2>
		<div class="panel mt-4 max-w-2xl">
			<p class="text-sm text-slate-400">
				Estas herramientas cambian el estado del juego o exponen datos de otros jugadores, así
				que solo una cuenta con rol <code>admin</code> puede abrirlas.
			</p>
			<p class="mt-4">
				<a href="/save-editor" class="font-medium text-gold-400 hover:underline">
					Abrir el editor de imperio
				</a>
			</p>
			<p class="mt-1 text-sm text-slate-400">
				<a href="/gazillionaire">Añadir 10.000 Empire Points a mi partida</a> ·
				<a href="/list_session">Ver sesiones guardadas</a>
			</p>
		</div>
	{/if}

	<h2 class="mt-12 text-xl font-semibold">Amigos</h2>
	{#if data.friends.length === 0}
		<p class="mt-2 text-slate-400">Todavía no tienes amigos.</p>
	{:else}
		<table class="mt-3 w-full max-w-2xl text-left text-sm">
			<thead class="text-xs uppercase tracking-wide text-slate-400">
				<tr>
					<th class="py-2">Jugador</th>
					<th class="py-2">Nivel</th>
					<th></th>
				</tr>
			</thead>
			<tbody>
				{#each data.friends as friend (friend.zid)}
					<tr class="border-t border-empire-800">
						<td class="py-2">{friend.username}</td>
						<td class="py-2">{friend.level ?? '—'}</td>
						<td class="py-2 text-right">
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
		<table class="mt-3 w-full max-w-2xl text-left text-sm">
			<tbody>
				{#each data.suggestions as suggestion (suggestion.zid)}
					<tr class="border-t border-empire-800">
						<td class="py-2">{suggestion.username}</td>
						<td class="py-2">{suggestion.level ?? '—'}</td>
						<td class="py-2 text-right">
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