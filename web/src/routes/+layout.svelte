<script lang="ts">
	import '../app.css';
	import { page } from '$app/state';

	let { children } = $props();

	const user = $derived(page.data.user ?? null);
</script>

<svelte:head>
	<meta charset="utf-8" />
	<meta name="viewport" content="width=device-width, initial-scale=1" />
</svelte:head>

<div class="flex min-h-dvh flex-col bg-empire-950 text-slate-200">
	<header class="border-b border-empire-800 bg-empire-900/80 backdrop-blur">
		<div class="mx-auto flex max-w-6xl items-center gap-4 px-5 py-3">
			<a href="/" class="mr-auto text-lg font-bold tracking-tight">
				Raise the <span class="text-gold-400">Empires</span>
			</a>
			<nav class="flex items-center gap-4 text-sm">
				{#if user}
					<a href="/juego" class="rounded px-3 py-1.5 hover:bg-empire-800">Juego</a>
					<a href="/cuenta" class="rounded px-3 py-1.5 hover:bg-empire-800">{user.username}</a>
					<form method="POST" action="/salir">
						<button
							class="rounded border border-empire-700 px-3 py-1.5 hover:bg-empire-800"
						>
							Salir
						</button>
					</form>
				{:else}
					<a href="/entrar" class="rounded px-3 py-1.5 hover:bg-empire-800">Entrar</a>
					<a
						href="/registro"
						class="rounded bg-gold-500 px-3 py-1.5 font-semibold text-empire-950 hover:bg-gold-400"
					>
						Crear cuenta
					</a>
				{/if}
			</nav>
		</div>
	</header>

	<main class="mx-auto w-full max-w-6xl flex-1 px-5 py-8">
		{@render children()}
	</main>

	<footer class="border-t border-empire-800 py-6 text-sm text-slate-400">
		<div class="mx-auto max-w-6xl px-5">
			Preservación jugable de <em>Empires &amp; Allies</em> (Gazillion, 2011-2013).
			Sin Flash, sin Facebook. Cliente original bajo Ruffle, gateway AMF0 original en Python.
		</div>
	</footer>
</div>