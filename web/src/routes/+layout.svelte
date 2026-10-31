<script lang="ts">
	import '../app.css';
	import { page } from '$app/state';
	import { avatarUrl, DEFAULT_AVATAR } from '#lib/avatar';

	let { children } = $props();

	import { onMount } from 'svelte';

	const user = $derived(page.data.user ?? null);
	const userAvatar = $derived(page.data.avatar?.current ?? DEFAULT_AVATAR);

	onMount(() => {
		if (typeof window !== 'undefined' && 'serviceWorker' in navigator) {
			navigator.serviceWorker.register('/service-worker.js').catch((err) => {
				console.debug('ServiceWorker registration skipped:', err);
			});
		}
	});
</script>

<svelte:head>
	<meta charset="utf-8" />
	<meta name="viewport" content="width=device-width, initial-scale=1" />
</svelte:head>

<div class="flex min-h-dvh flex-col bg-empire-950 text-slate-200">
	<header class="sticky top-0 z-50 border-b border-empire-800 bg-empire-900/90 backdrop-blur shadow-md">
		<div class="mx-auto flex max-w-7xl items-center justify-between gap-4 px-4 py-2.5 sm:px-6">
			<!-- Logo & Branding -->
			<a href="/" class="flex items-center gap-2.5 text-lg font-bold tracking-tight hover:opacity-90 transition-opacity">
				<img src="/img/logo.png" alt="Empires & Allies" class="h-8 w-auto object-contain" />
				<span class="hidden sm:inline">Raise the <span class="text-gold-400">Empires</span></span>
			</a>

			<!-- Navigation & Account Info -->
			<nav class="flex items-center gap-2 sm:gap-4 text-sm">
				{#if user}
					<!-- ID ZID Pill -->
					<div
						class="hidden md:flex items-center gap-1.5 px-2.5 py-1 rounded-md bg-empire-950/80 border border-empire-800 text-xs font-mono text-slate-400"
						title="ID de cuenta (ZID)"
					>
						<span>ZID:</span>
						<code class="text-gold-400 font-semibold">{user.zid}</code>
					</div>

					<!-- Admin: Editor de Imperio Link -->
					{#if user.role === 'admin'}
						<a
							href="/admin/editor"
							class="hidden sm:flex items-center gap-1.5 rounded-md border border-gold-500/40 bg-gold-500/10 px-2.5 py-1 text-xs font-medium text-gold-400 hover:bg-gold-500/20 hover:border-gold-400 transition-colors"
							title="Editor de Imperio Administrativo"
						>
							<span>🛠️ Editor</span>
						</a>
					{/if}

					<!-- Social & Battle Hub -->
					<a
						href="/amigos"
						class="flex items-center gap-1.5 rounded-md border border-empire-800 bg-empire-900/50 px-2.5 py-1 text-xs font-semibold text-slate-200 hover:bg-empire-800 hover:border-gold-500/50 transition-colors"
						title="Centro de Alianzas y Combate PvP"
					>
						<span>⚔️ Alianzas &amp; PvP</span>
					</a>

					<!-- Profile with Avatar -->
					<a
						href="/cuenta"
						class="flex items-center gap-2 rounded-md px-2.5 py-1 border border-empire-800 hover:bg-empire-800/80 hover:border-slate-700 transition-colors"
						title="Mi cuenta"
					>
						<img
							src={avatarUrl(userAvatar)}
							alt=""
							class="size-6 rounded-full object-cover border border-gold-500/50 bg-empire-950"
						/>
						<span class="max-w-[120px] truncate font-medium text-slate-200">{user.username}</span>
					</a>

					<!-- Logout -->
					<form method="POST" action="/salir" class="m-0">
						<button
							class="rounded-md border border-empire-800 px-2.5 py-1.5 text-xs text-slate-400 hover:bg-empire-800 hover:text-slate-200 transition-colors"
							title="Cerrar sesión"
						>
							Salir
						</button>
					</form>
				{:else}
					<a href="/entrar" class="rounded px-3 py-1.5 hover:bg-empire-800 transition-colors">Entrar</a>
					<a
						href="/registro"
						class="rounded bg-gold-500 px-3 py-1.5 font-semibold text-empire-950 hover:bg-gold-400 transition-colors"
					>
						Crear cuenta
					</a>
				{/if}
			</nav>
		</div>
	</header>

	<main class="mx-auto w-full max-w-7xl flex-1 px-4 py-6 sm:px-6">
		{@render children()}
	</main>

	<footer class="border-t border-empire-800/80 py-5 text-xs text-slate-500">
		<div class="mx-auto flex max-w-7xl flex-col sm:flex-row items-center justify-between gap-2 px-4 sm:px-6 text-center sm:text-left">
			<p>
				<span class="font-semibold text-slate-400">Raise the Empires</span> &bull; Preservación de <em>Empires &amp; Allies</em> (Zynga, 2011).
			</p>
			<p class="text-slate-500 text-[11px]">
				WebAssembly &bull; Ruffle WASM &bull; Gateway AMF0
			</p>
		</div>
	</footer>
</div>