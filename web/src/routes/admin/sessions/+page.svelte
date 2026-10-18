<script lang="ts">
	import { enhance } from '$app/forms';

	import { RESOURCES, XP_ICON, formatAmount } from '#lib/resources';
	import { cookieValueOf, xpAsNumber, type SavedSession } from '#lib/sessions';

	let { data, form } = $props();

	const sessions = $derived(data.sessions ?? []);

	/** Deepest first: the worlds worth looking at are the ones that progressed. */
	const ordered = $derived(
		[...sessions].sort((a, b) => (b.level ?? 0) - (a.level ?? 0))
	);

	function copy(value: string) {
		void navigator.clipboard?.writeText(value);
	}

	/**
	 * Deleting takes the save with it. One confirm step, and the row is named in
	 * it -- a list of identically-named worlds is exactly the case where a
	 * mis-click costs somebody an afternoon.
	 */
	function confirmDelete(row: SavedSession & { owner: string | null }) {
		const who = row.owner ? ` de ${row.owner}` : '';
		const ok = window.confirm(
			`¿Borrar la partida "${row.world_name}"${who}?\n\n` +
				`Nivel ${formatAmount(row.level ?? 0)}, ${formatAmount(xpAsNumber(row.xp))} XP.\n` +
				'Se elimina la partida y su historial. No se puede deshacer.'
		);
		if (ok) document.getElementById(`del-${CSS.escape(row.session_id)}`)?.click();
	}
</script>

<svelte:head>
	<title>Sesiones guardadas — Raise the Empires</title>
</svelte:head>

<div class="py-6">
	<nav class="text-sm text-slate-400">
		<a href="/cuenta" class="hover:text-gold-400">← Volver a mi cuenta</a>
	</nav>

	<h1 class="mt-2 text-3xl font-bold">Sesiones guardadas</h1>
	<p class="mt-1 max-w-2xl text-slate-400">
		Una fila por partida guardada en el servidor. Reemplaza el volcado JSON crudo que vivía
		en <code>/list_session</code>; los datos siguen viniendo de ahí.
	</p>

	{#if !data.reachable}
		<p class="panel mt-6 max-w-2xl border-red-800 bg-red-950/40 text-red-200">
			No se pudo contactar el gateway AMF0. Revisa que esté corriendo en
			<code>127.0.0.1:5005</code>.
		</p>
	{:else if sessions.length === 0}
		<p class="panel mt-6 max-w-2xl text-slate-400">
			No hay ninguna partida guardada todavía.
		</p>
	{:else}
		<div class="panel mt-6 overflow-x-auto !p-0">
			<table class="w-full min-w-[46rem] text-left text-sm">
				<thead class="border-b border-empire-800 text-xs tracking-wide text-slate-400 uppercase">
					<tr>
						<th class="px-4 py-3">Mundo</th>
						<th class="px-4 py-3">Nivel</th>
						<th class="px-4 py-3">XP</th>
						<th class="px-4 py-3">uid</th>
						<th class="px-4 py-3">Cookie de sesión</th>
						<th class="px-4 py-3"><span class="sr-only">Acciones</span></th>
					</tr>
				</thead>
				<tbody>
					{#each ordered as session, i (session.session_id ? `${session.session_id}-${i}` : i)}
						<tr class="border-b border-empire-800/60 last:border-0 hover:bg-empire-800/30">
							<td class="px-4 py-3">
								<div class="flex items-center gap-3">
									<img src={`/${session.profilePic}`} alt="" class="size-8 rounded" />
									<div>
										<div class="font-medium">{session.world_name}</div>
										<div class="text-xs {session.owner ? 'text-gold-400' : 'text-slate-500'}">
											{session.owner ?? 'sin cuenta'}
										</div>
									</div>
								</div>
							</td>
							<td class="px-4 py-3">
								<span class="flex items-center gap-2">
									<img src={XP_ICON} alt="" class="size-5" />
									{formatAmount(session.level)}
								</span>
							</td>
							<td class="px-4 py-3 font-mono text-xs">
								{formatAmount(xpAsNumber(session.xp))}
							</td>
							<td class="px-4 py-3 font-mono text-xs text-slate-400">{session.uid}</td>
							<td class="px-4 py-3">
								<button
									type="button"
									onclick={() => copy(cookieValueOf(session.session_id))}
									class="rounded border border-empire-700 px-2 py-1 font-mono text-xs hover:bg-empire-800"
									title="Copiar"
								>
									{cookieValueOf(session.session_id)}
								</button>
							</td>
							<td class="px-4 py-3 text-right">
								<form
									method="POST"
									action="?/delete"
									use:enhance
									id={`del-${CSS.escape(session.session_id)}`}
								>
									<input type="hidden" name="store_id" value={session.session_id} />
									<button
										type="submit"
										onclick={(event) => {
											event.preventDefault();
											confirmDelete(session);
										}}
										class="rounded border border-red-900/70 px-2 py-1 text-xs text-red-300 hover:bg-red-950/50 hover:border-red-700"
										title="Borrar esta partida"
									>
										Borrar
									</button>
								</form>
							</td>
						</tr>
					{/each}
				</tbody>
			</table>
		</div>

		<p class="mt-3 text-xs text-slate-500">
			La columna de cookie muestra el session id pelado, que es lo que viaja en la cookie
			<span class="font-mono">session</span>; la clave de la base le antepone
			<span class="font-mono">session:</span>. Borrar quita la partida y su historial; la
			cuenta y su inicio de sesión no se tocan.
		</p>

		{#if form?.deleted}
			<p class="panel mt-4 max-w-2xl border-green-800 bg-green-950/30 text-green-200">
				Partida <code class="font-mono">{form.deleted}</code> borrada.
			</p>
		{/if}
		{#if form?.message}
			<p class="panel mt-4 max-w-2xl border-red-800 bg-red-950/40 text-red-200">
				No se pudo borrar: {form.message}
			</p>
		{/if}
	{/if}

	<!-- Resources, as a quick reference of what a world is made of. -->
	<h2 class="mt-12 text-xl font-semibold">Qué se puede editar</h2>
	<div class="mt-3 grid grid-cols-4 gap-3 sm:grid-cols-8">
		{#each RESOURCES as resource (resource.key)}
			<div class="panel flex flex-col items-center gap-2 !p-3 text-center">
				<img src={resource.icon} alt={resource.label} class="size-7" />
				<span class="text-[11px] tracking-wide text-slate-400 uppercase">{resource.label}</span>
			</div>
		{/each}
	</div>
	<a
		href="/admin/editor"
		class="mt-4 inline-block rounded-lg border border-empire-700 px-4 py-2 text-sm hover:bg-empire-800"
	>
		Irir al editor de imperio
	</a>
</div>