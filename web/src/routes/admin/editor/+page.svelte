<script lang="ts">
	import { enhance } from '$app/forms';
	import { page } from '$app/state';

	import { EMPIRE_POINTS_ICON, RESOURCES, XP_ICON, formatAmount } from '#lib/resources';

	let { data, form } = $props();

	const state = $derived(data.state);
	const hasSave = $derived(data.hasSave);

	/** The player's primary ore: aluminum 3, copper 4, gold 5, iron 6, uranium 7. */
	const ORES = [
		{ id: 3, label: 'Aluminio', icon: '/img/Aluminum_60.png' },
		{ id: 4, label: 'Cobre', icon: '/img/Copper_60.png' },
		{ id: 5, label: 'Oro', icon: '/img/Gold_60.png' },
		{ id: 6, label: 'Hierro', icon: '/img/Iron_60.png' },
		{ id: 7, label: 'Uranio', icon: '/img/Uranium_60.png' }
	] as const;

	const saved = $derived(form?.message ? null : (page.url.searchParams.get('ok') ?? null));
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
		zid <code class="font-mono text-slate-300">{state?.zid ?? '—'}</code>
		{#if state?.worldName}
			· {state.worldName}
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

	{#if !hasSave}
		<p class="panel mt-6 max-w-2xl text-slate-300">
			No hay partida guardada en este navegador. Entra al juego una vez para crearla, y vuelve
			aquí: el editor escribe sobre la partida que tiene esta sesión.
		</p>
	{:else}
		<!-- Level, XP, Empire Points -->
		<h2 class="mt-8 text-xl font-semibold">Jugador</h2>
		<div class="mt-3 grid gap-4 sm:grid-cols-3">
			{#each [{ key: 'level', label: 'Nivel', icon: XP_ICON, value: state?.level ?? 0 }, { key: 'xp', label: 'XP', icon: XP_ICON, value: state?.xp ?? 0 }, { key: 'empirePoints', label: 'Empire Points', icon: EMPIRE_POINTS_ICON, value: state?.empirePoints ?? 0 }] as item (item.key)}
				<form method="POST" action="?/set" use:enhance class="panel">
					<input type="hidden" name="field" value={item.key} />
					<div class="flex items-center gap-3">
						<img src={item.icon} alt="" class="size-8" />
						<span class="text-xs tracking-wide text-slate-400 uppercase">{item.label}</span>
						<span class="ml-auto text-lg font-semibold">{formatAmount(item.value)}</span>
					</div>
					<div class="mt-3 flex gap-2">
						<input
							class="field !py-1.5 text-sm"
							type="number"
							name="value"
							value={item.value}
							min="0"
							required
						/>
						<button class="rounded-lg border border-empire-700 px-3 text-sm hover:bg-empire-800">
							Guardar
						</button>
					</div>
				</form>
			{/each}
		</div>

		<!-- Resources -->
		<h2 class="mt-10 text-xl font-semibold">Recursos</h2>
		<div class="mt-3 grid grid-cols-2 gap-3 sm:grid-cols-4">
			{#each RESOURCES as resource (resource.key)}
				<form method="POST" action="?/set" use:enhance class="panel">
					<input type="hidden" name="field" value={resource.key} />
					<div class="flex items-center gap-3">
						<img src={resource.icon} alt="" class="size-8 shrink-0" />
						<span class="truncate text-xs tracking-wide text-slate-400 uppercase">
							{resource.label}
						</span>
					</div>
					<div class="mt-3 flex gap-2">
						<input
							class="field !py-1.5 text-sm"
							type="number"
							name="value"
							value={state?.resources?.[resource.key] ?? 0}
							min="0"
							required
						/>
						<button class="rounded-lg border border-empire-700 px-3 text-sm hover:bg-empire-800">
							✎
						</button>
					</div>
				</form>
			{/each}
		</div>

		<!-- Primary ore -->
		<h2 class="mt-10 text-xl font-semibold">Mineral principal</h2>
		<div class="mt-3 flex flex-wrap gap-2">
			{#each ORES as ore (ore.id)}
				<form method="POST" action="?/set" use:enhance>
					<input type="hidden" name="field" value="ore" />
					<input type="hidden" name="value" value={ore.id} />
					<button class="flex items-center gap-2 rounded-lg border border-empire-700 px-3 py-2 text-sm hover:bg-empire-800">
						<img src={ore.icon} alt="" class="size-6" />
						{ore.label}
					</button>
				</form>
			{/each}
		</div>

		<!-- Cheats and the legacy editor -->
		<h2 class="mt-10 text-xl font-semibold">Otras herramientas</h2>
		<div class="panel mt-3 max-w-2xl">
			<div class="flex flex-wrap gap-3">
				<a
					href="/gazillionaire"
					class="flex items-center gap-2 rounded-lg border border-empire-700 px-4 py-2 text-sm hover:bg-empire-800"
				>
					<img src={EMPIRE_POINTS_ICON} alt="" class="size-5" />
					Añadir 10.000 Empire Points
				</a>
				<a
					href="/save-editor"
					class="rounded-lg border border-empire-700 px-4 py-2 text-sm hover:bg-empire-800"
				>
					Editor avanzado (quests y JSON crudo)
				</a>
			</div>
			<p class="mt-3 text-xs text-slate-500">
				El editor avanzado es la plantilla original de 2013. Esta página la reemplaza para lo
				que se usa a diario; las operaciones de quests siguen vivo solo allí.
			</p>
		</div>
	{/if}
</div>