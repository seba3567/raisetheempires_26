<script lang="ts">
	import { enhance } from '$app/forms';
	import { page } from '$app/state';
	import { Modal } from 'flowbite-svelte';

	import { EMPIRE_POINTS_ICON, RESOURCES, XP_ICON, formatAmount } from '#lib/resources';
	import { xpAsNumber } from '#lib/sessions';
	import { DEPROGRESS, RAW_REPLACE, WIPE, type PendingConfirm } from '#lib/confirm';

	let { data, form } = $props();

	const empire = $derived(data.state);
	const hasSave = $derived(data.hasSave);
	const raw = $derived(empire ? JSON.stringify(empire.raw, null, 2) : '');

	const saved = $derived(page.url.searchParams.get('ok'));

	/** The player's primary ore: aluminum 3, copper 4, gold 5, iron 6, uranium 7. */
	const ORES = [
		{ id: 3, label: 'Aluminio', icon: '/img/Aluminum_60.png' },
		{ id: 4, label: 'Cobre', icon: '/img/Copper_60.png' },
		{ id: 5, label: 'Oro', icon: '/img/Gold_60.png' },
		{ id: 6, label: 'Hierro', icon: '/img/Iron_60.png' },
		{ id: 7, label: 'Uranio', icon: '/img/Uranium_60.png' }
	] as const;

	const NUMBERS = $derived([
		{ field: 'level', label: 'Nivel', icon: XP_ICON, value: empire?.level ?? 0 },
		{ field: 'xp', label: 'XP', icon: XP_ICON, value: xpAsNumber(empire?.xp ?? null) ?? 0 },
		{
			field: 'empirePoints',
			label: 'Empire Points',
			icon: EMPIRE_POINTS_ICON,
			value: empire?.empirePoints ?? 0
		}
	]);

	/**
	 * Sorted for reading, and safe against the catalogue's untitled quests.
	 *
	 * `quest_titles` has entries with a null name, so the title cannot be
	 * assumed to be a string -- sorting on it directly threw a TypeError that
	 * took the whole page down as a 500.
	 */
	function label(entry: [string, string | null]): string {
		return entry[1] ?? entry[0];
	}

	function sorted(quests: Record<string, string | null> | undefined) {
		return Object.entries(quests ?? {}).sort((a, b) => label(a).localeCompare(label(b)));
	}

	const locked = $derived(sorted(empire?.quests.locked));
	const incomplete = $derived(sorted(empire?.quests.incomplete));
	const complete = $derived(sorted(empire?.quests.complete));

	/**
	 * Backups, newest first.
	 *
	 * A world that has been played for weeks stacks well over a hundred, so the
	 * list is capped for reading and the rest are counted in the heading. The
	 * cap is on what is *shown*, not on the indices: the buttons post the
	 * backup's own index, so restoring one never depends on its row position.
	 */
	const BACKUP_PREVIEW = 25;
	const backups = $derived(empire?.backupList ?? []);
	const shownBackups = $derived(backups.slice(0, BACKUP_PREVIEW));
	const hiddenBackups = $derived(backups.length - shownBackups.length);

	/**
	 * Confirmation for the three writes that can cost a player their empire.
	 *
	 * None of them is undoable from the page -- wiping takes the session with
	 * it and a bad raw paste leaves a save the client cannot load -- so each one
	 * goes through a dialog that names the action and what it costs. The form
	 * to submit lives on the page and is referenced by id, which is what keeps
	 * the raw JSON visible while you write it.
	 *
	 * The wording and the form each one targets are in #lib/confirm, where the
	 * action/form pairing can be asserted without a browser.
	 */
	let pending = $state<PendingConfirm | null>(null);
	let confirmOpen = $state(false);

	function ask(next: PendingConfirm) {
		pending = next;
		confirmOpen = true;
	}

	function cancel() {
		confirmOpen = false;
		pending = null;
	}
</script>

<svelte:head>
	<title>Editor de imperio — Raise the Empires</title>
</svelte:head>

<div class="py-6">
	<nav class="text-sm text-slate-400">
		<a href="/cuenta" class="hover:text-gold-400">← Volver a mi cuenta</a>
	</nav>

	<h1 class="mt-2 text-3xl font-bold">Editor de imperio</h1>
	<p class="mt-1 text-slate-400">
		zid <code class="font-mono text-slate-300">{empire?.zid ?? '—'}</code>
		{#if empire?.worldName}
			· {empire.worldName}
		{/if}
		{#if empire}
			· {empire.backups} respaldo{empire.backups === 1 ? '' : 's'}
		{/if}
	</p>

	{#if form?.message}
		<p class="panel mt-4 border-red-800 bg-red-950/40 text-sm text-red-200">{form.message}</p>
	{/if}
	{#if saved}
		<p class="panel mt-4 border-emerald-800 bg-emerald-950/30 text-sm text-emerald-200">
			Guardado. Los valores de abajo ya vienen de la partida.
		</p>
	{/if}

	{#if !data.reachable}
		<p class="panel mt-6 max-w-2xl border-red-800 bg-red-950/40 text-red-200">
			No se pudo contactar el gateway AMF0. Revisa que esté corriendo en
			<code>127.0.0.1:5005</code>.
		</p>
	{:else if !hasSave}
		<p class="panel mt-6 max-w-2xl text-slate-300">
			No hay partida guardada en este navegador. Entra al juego una vez para crearla, y vuelve
			aquí: el editor escribe sobre la partida que tiene esta sesión.
		</p>
	{:else}
		<!--
			Bulk write: one form covering every number on the page, so fixing a
			world is one submit instead of nine round trips that can stop halfway.
		-->
		<h2 class="mt-8 text-xl font-semibold">Valores</h2>
		<form method="POST" action="?/setMany" use:enhance>
			<div class="mt-3 grid gap-4 sm:grid-cols-3">
				{#each NUMBERS as item (item.field)}
					<div class="panel">
						<input type="hidden" name="field" value={item.field} />
						<div class="flex items-center gap-3">
							<img src={item.icon} alt="" class="size-8" />
							<span class="text-xs tracking-wide text-slate-400 uppercase">{item.label}</span>
							<span class="ml-auto text-sm text-slate-500">era {formatAmount(item.value)}</span>
						</div>
						<input
							class="field mt-3 !py-1.5 text-sm"
							type="number"
							name="value"
							value={item.value}
							min="0"
							required
						/>
					</div>
				{/each}
			</div>

			<div class="mt-3 grid grid-cols-2 gap-3 sm:grid-cols-4">
				{#each RESOURCES as resource (resource.key)}
					<div class="panel">
						<input type="hidden" name="field" value={resource.key} />
						<div class="flex items-center gap-3">
							<img src={resource.icon} alt="" class="size-7 shrink-0" />
							<span class="truncate text-xs tracking-wide text-slate-400 uppercase">
								{resource.label}
							</span>
						</div>
						<input
							class="field mt-2 !py-1.5 text-sm"
							type="number"
							name="value"
							value={empire?.resources?.[resource.key] ?? 0}
							min="0"
							required
						/>
					</div>
				{/each}
			</div>

			<div class="mt-4 flex flex-wrap items-center gap-3">
				<button class="btn-primary !py-2.5 !text-sm">Guardar todo</button>
				<span class="text-xs text-slate-500">
					Se valida todo antes de escribir nada: un valor malo no deja la partida a medias.
				</span>
			</div>
		</form>

		<!-- Primary ore: a single choice, so its own small form. -->
		<h2 class="mt-10 text-xl font-semibold">Mineral principal</h2>
		<div class="mt-3 flex flex-wrap gap-2">
			{#each ORES as ore (ore.id)}
				<form method="POST" action="?/set" use:enhance>
					<input type="hidden" name="field" value="ore" />
					<input type="hidden" name="value" value={ore.id} />
					<button
						class="flex items-center gap-2 rounded-lg border px-3 py-2 text-sm hover:bg-empire-800
							{empire?.ore === ore.id ? 'border-gold-500 text-gold-400' : 'border-empire-700'}"
					>
						<img src={ore.icon} alt="" class="size-6" />
						{ore.label}
					</button>
				</form>
			{/each}
		</div>

		<!-- Quests -->
		<h2 class="mt-10 text-xl font-semibold">Quests</h2>
		<div class="mt-3 grid gap-4 lg:grid-cols-3">
			{#each [{ title: 'Desbloquear', items: locked, action: 'unlock', hint: 'No empezadas' }, { title: 'Completar', items: incomplete, action: 'complete', hint: 'En curso' }, { title: 'Quitar', items: complete, action: 'remove', hint: 'Terminadas' }] as column (column.title)}
				<div class="panel flex flex-col !p-0">
					<div class="border-b border-empire-800 px-4 py-3">
						<div class="font-semibold">{column.title}</div>
						<div class="text-xs text-slate-500">
							{column.hint} · {column.items.length}
						</div>
					</div>
					<div class="max-h-72 overflow-y-auto p-2">
						{#if column.items.length === 0}
							<p class="p-2 text-sm text-slate-500">Ninguna.</p>
						{:else}
							{#each column.items as [key, title] (key)}
								<form method="POST" action="?/quest" use:enhance class="flex items-center gap-2 rounded px-2 py-1 hover:bg-empire-800/60">
									<input type="hidden" name="action" value={column.action} />
									<input type="hidden" name="name" value={key} />
									<span class="min-w-0 flex-1 truncate text-sm" title={`${label([key, title])} (${key})`}>
										{label([key, title])}
									</span>
									<code class="text-[11px] text-slate-500">{key}</code>
									<button class="shrink-0 rounded border border-empire-700 px-2 py-0.5 text-xs hover:bg-empire-800">
										{column.action === 'remove' ? '✕' : '✓'}
									</button>
								</form>
							{/each}
						{/if}
					</div>
				</div>
			{/each}
		</div>

		<!-- Raw editor: the escape hatch for anything the typed fields miss. -->
		<h2 class="mt-10 text-xl font-semibold">Editor crudo</h2>
		<form id="raw-form" method="POST" action="?/raw" use:enhance class="mt-3">
			<textarea
				name="savegame"
				rows="24"
				class="field font-mono text-xs"
				spellcheck="false">{raw}</textarea
			>
			<div class="mt-3 flex flex-wrap items-center gap-3">
				<button
					type="button"
					class="rounded-lg border border-red-800 px-4 py-2 text-sm text-red-300 hover:bg-red-950/40"
					onclick={() => ask(RAW_REPLACE)}
				>
					Reemplazar la partida
				</button>
				<p class="text-xs text-red-400/80">
					Puede corromper la partida. El gateway guarda un respaldo antes de aplicar.
				</p>
			</div>
		</form>

		<!-- Backups: the way back from a bad paste or a wipe. -->
	<h2 class="mt-10 text-xl font-semibold">Respaldos</h2>
	<div class="panel mt-3">
		{#if backups.length === 0}
			<p class="text-sm text-slate-500">Esta partida todavía no tiene respaldos.</p>
		{:else}
			<p class="text-xs text-slate-500">
				{backups.length} en total. El primero es la partida anterior a la actual. Restaurar
				guarda el estado actual antes de reemplazarlo, así que también se puede deshacer.
				{#if backups.length >= (empire?.maxBackups ?? Infinity)}
					Se guardan los {empire?.maxBackups} más recientes: cada respaldo es una copia
					completa de la partida, así que mantenerlos todos hacía que el juego cargara cada
					menú más lento.
				{/if}
			</p>
			<ul class="mt-3 max-h-96 divide-y divide-empire-800 overflow-y-auto text-sm">
				{#each shownBackups as backup, i (backup.revision !== undefined ? `${backup.revision}-${i}` : i)}
					<li class="flex flex-wrap items-center gap-3 py-2">
						<span class="w-16 shrink-0 font-mono text-xs text-slate-500">
							r{backup.revision}
						</span>
						<span class="shrink-0 text-xs text-empire-300">
							nivel {backup.level ?? '?'} · {formatAmount(backup.coins ?? 0)} coins
						</span>
						<span class="min-w-0 flex-1 truncate text-xs text-slate-500" title={backup.label}>
							{backup.message || backup.label}
						</span>
						<form method="POST" action="?/restore" use:enhance>
							<!--
								By revision, not by position. History is trimmed as
								writes land and the page can sit open for a while,
								so an index would restore a different save than the
								one the row showed.
							-->
							<input type="hidden" name="revision" value={backup.revision} />
							<button class="rounded border border-empire-700 px-3 py-1 text-xs hover:bg-empire-800">
								Restaurar
							</button>
						</form>
					</li>
				{/each}
			</ul>
			{#if hiddenBackups > 0}
				<p class="mt-3 text-xs text-slate-500">
					y {hiddenBackups} más antiguos, fuera de la vista previa.
				</p>
			{/if}
		{/if}
	</div>

	<!-- Danger zone -->
		<h2 class="mt-10 text-xl font-semibold">Zona de peligro</h2>
		<div class="panel mt-3 border-red-900/60 max-w-2xl">
			<div class="flex flex-wrap gap-3">
				<a
					href="/gazillionaire"
					class="flex items-center gap-2 rounded-lg border border-empire-700 px-4 py-2 text-sm hover:bg-empire-800"
				>
					<img src={EMPIRE_POINTS_ICON} alt="" class="size-5" />
					Añadir 10.000 Empire Points
				</a>
				<button
					type="button"
					class="rounded-lg border border-empire-700 px-4 py-2 text-sm hover:bg-empire-800"
					onclick={() => ask(DEPROGRESS)}
				>
					Rebobinar el mapa de batalla
				</button>
				<button
					type="button"
					class="rounded-lg border border-red-800 px-4 py-2 text-sm text-red-300 hover:bg-red-950/40"
					onclick={() => ask(WIPE)}
				>
					Borrar la partida
				</button>
			</div>
			<p class="mt-3 text-xs text-slate-500">
				Borrar la partida elimina la sesión de juego de este navegador. La cuenta y su
				identidad siguen existiendo.
			</p>
		</div>
	{/if}

	<!--
		The confirmation for the three things that can cost a player their empire.

		Each dangerous button opens this instead of posting directly. The forms
		stay on the page and are submitted from here through the `form` attribute,
		so the raw editor is not hidden behind a dialog the admin has to open and
		close to get at the JSON.
	-->
	<Modal bind:open={confirmOpen} title={pending?.title ?? ''} size="md" dismissable>
		<p class="text-sm text-slate-300">{pending?.body}</p>
		{#if pending?.note}
			<p class="mt-2 text-xs text-slate-500">{pending.note}</p>
		{/if}
		<div class="mt-5 flex justify-end gap-3">
			<button
				type="button"
				class="rounded-lg border border-empire-700 px-4 py-2 text-sm hover:bg-empire-800"
				onclick={cancel}
			>
				Cancelar
			</button>
			<button
				type="submit"
				form={pending?.form ?? ''}
				class="rounded-lg border border-red-800 px-4 py-2 text-sm text-red-300 hover:bg-red-950/40"
			>
				{pending?.confirm}
			</button>
		</div>
	</Modal>

	<!-- The two destructive forms, submitted from the dialog above. -->
	<form id="danger-form" method="POST" action="?/danger" use:enhance hidden>
		<input type="hidden" name="what" value={pending?.what ?? ''} />
	</form>
</div>