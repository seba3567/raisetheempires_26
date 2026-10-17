<script lang="ts">
	let { data } = $props();
</script>

<svelte:head>
	<title>Raise the Empires — servidor de preservación</title>
</svelte:head>

<div class="py-6">
	<h1 class="max-w-3xl text-4xl font-bold tracking-tight sm:text-5xl">
		Raise the <span class="text-gold-400">Empires</span>
	</h1>
	<p class="mt-4 max-w-2xl text-lg text-slate-400">
		Un servidor público y jugable para <em>Empires &amp; Allies</em>, el juego que Gazillion cerró
		en 2013. El cliente es el SWF original; lo que faltaba era un servidor que todavía respondiera.
	</p>

	<div class="mt-8">
		{#if data.user}
			<a
				href="/juego"
				class="inline-block rounded-lg bg-gold-500 px-6 py-3 font-semibold text-empire-950 hover:bg-gold-400"
			>
				Entrar al juego
			</a>
		{:else}
			<a
				href="/registro"
				class="inline-block rounded-lg bg-gold-500 px-6 py-3 font-semibold text-empire-950 hover:bg-gold-400"
			>
				Crear cuenta gratis
			</a>
		{/if}
	</div>

	<h2 class="mt-14 text-xl font-semibold">Qué cambió</h2>
	<div class="mt-4 grid gap-4 sm:grid-cols-2">
		<div class="panel">
			<strong>Cuentas propias</strong>
			<p class="mt-1 text-sm text-slate-400">
				Registro y progreso guardados aquí, sin Facebook y sin OAuth.
			</p>
		</div>
		<div class="panel">
			<strong>Amigos reales</strong>
			<p class="mt-1 text-sm text-slate-400">
				La lista de vecinos viene de jugadores con cuenta, no de islas horneadas.
			</p>
		</div>
		<div class="panel">
			<strong>Identidad estable</strong>
			<p class="mt-1 text-sm text-slate-400">
				Tu zid se deriva de la cuenta, no de una cookie: cerrar sesión ya no parte la partida
				en dos.
			</p>
		</div>
		<div class="panel">
			<strong>Ruffle local y pineado</strong>
			<p class="mt-1 text-sm text-slate-400">
				Emulador {data.ruffleVersion} servido desde este servidor, con hash verificado. No
				depende de que unpkg siga en pie.
			</p>
		</div>
	</div>

	<h2 class="mt-14 text-xl font-semibold">Cómo se juega</h2>
	<p class="mt-2 max-w-2xl text-slate-400">
		Crea una cuenta y entra al juego. Todo lo que hagas —nivel, tropas, territorio— se guarda
		contra esa cuenta. Puedes cerrar el navegador y volver cuando quieras.
	</p>
</div>