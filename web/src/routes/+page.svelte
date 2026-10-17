<script lang="ts">
	import { EMPIRE_POINTS_ICON, RESOURCES, XP_ICON } from '#lib/resources';

	let { data } = $props();
</script>

<svelte:head>
	<title>Raise the Empires — servidor de preservación</title>
	<meta
		name="description"
		content="Un servidor público y jugable para Empires & Allies, el juego que Gazillion cerró en 2013. El cliente es el SWF original, bajo Ruffle."
	/>
</svelte:head>

<!-- Hero -->
<section class="panel relative overflow-hidden">
	<div
		class="pointer-events-none absolute -top-24 -right-16 size-72 rounded-full bg-gold-500/10 blur-3xl"
	></div>

	<div class="relative">
		<img src="/img/logo.png" alt="Empires &amp; Allies" class="h-16 w-auto" />

		<h1 class="mt-6 max-w-3xl text-4xl font-bold tracking-tight sm:text-5xl">
			Raise the <span class="text-gold-400">Empires</span>
		</h1>
		<p class="mt-4 max-w-2xl text-lg text-slate-400">
			Un servidor público y jugable para <em>Empires &amp; Allies</em>, el juego que Gazillion
			cerró en 2013. El cliente es el SWF original; lo que faltaba era un servidor que todavía
			respondiera.
		</p>

		<div class="mt-8 flex flex-wrap items-center gap-3">
			{#if data.user}
				<a href="/juego" class="btn-primary">Entrar al juego</a>
				<a href="/cuenta" class="rounded-lg border border-empire-700 px-6 py-3 hover:bg-empire-800">
					Mi cuenta
				</a>
			{:else}
				<a href="/registro" class="btn-primary">Crear cuenta gratis</a>
				<a
					href="/entrar"
					class="rounded-lg border border-empire-700 px-6 py-3 hover:bg-empire-800"
				>
					Ya tengo cuenta
				</a>
			{/if}
		</div>
	</div>
</section>

<!-- The resources, with the game's own art -->
<section class="mt-6">
	<h2 class="text-sm tracking-wide text-slate-400 uppercase">Los mismos recursos de 2013</h2>
	<div class="mt-3 grid grid-cols-4 gap-3 sm:grid-cols-8">
		{#each RESOURCES as resource (resource.key)}
			<div class="panel flex flex-col items-center gap-2 !p-3 text-center">
				<img src={resource.icon} alt={resource.label} class="size-8" />
				<span class="text-[11px] tracking-wide text-slate-400 uppercase">{resource.label}</span>
			</div>
		{/each}
	</div>
</section>

<!-- What changed -->
<h2 class="mt-14 text-xl font-semibold">Qué cambió</h2>
<div class="mt-4 grid gap-4 sm:grid-cols-2">
	<div class="panel">
		<strong class="flex items-center gap-2">
			<img src={EMPIRE_POINTS_ICON} alt="" class="size-5" />
			Cuentas propias
		</strong>
		<p class="mt-1 text-sm text-slate-400">
			Registro y progreso guardados aquí, sin Facebook y sin OAuth.
		</p>
	</div>

	<div class="panel">
		<strong class="flex items-center gap-2">
			<img src={XP_ICON} alt="" class="size-5" />
			Identidad estable
		</strong>
		<p class="mt-1 text-sm text-slate-400">
			Tu zid se deriva de la cuenta, no de una cookie: cerrar sesión ya no parte la partida en
			dos.
		</p>
	</div>

	<div class="panel">
		<strong>Ruffle local y pineado</strong>
		<p class="mt-1 text-sm text-slate-400">
			Emulador {data.ruffleVersion} servido desde este servidor, con hash verificado. No depende
			que unpkg siga en pie.
		</p>
	</div>

	<div class="panel">
		<strong>Vecinos reales, más los de serie</strong>
		<p class="mt-1 text-sm text-slate-400">
			Tu lista mezcla jugadores con cuenta con las islas horneadas que trae el juego. Las que no
			son tuyas no cuentan como amigos hasta que lo son de verdad.
		</p>
	</div>
</div>

<!-- How it works -->
<h2 class="mt-14 text-xl font-semibold">Cómo se juega</h2>
<div class="panel mt-4 max-w-2xl">
	<ol class="space-y-3 text-slate-300">
		<li><strong class="text-slate-100">Crea una cuenta.</strong> Es el único dato que te identifica.</li>
		<li>
			<strong class="text-slate-100">Entra al juego.</strong> El SWF original corre bajo Ruffle,
			embebido en esta misma página.
		</li>
		<li>
			<strong class="text-slate-100">Tu cuenta es la partida.</strong> Nivel, tropas y territorio
			se guardan contra ella, no contra una cookie del navegador.
		</li>
	</ol>
</div>