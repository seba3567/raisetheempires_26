<script lang="ts">
	/**
	 * The player page.
	 *
	 * Embeds the original Empires & Allies SWF via Ruffle WASM (WebGPU/WebGL).
	 * Clean, focused presentation letting the native Flash in-game controls
	 * (sound, music, zoom, fullscreen) take center stage.
	 */
	import { onMount } from 'svelte';
	import {
		PLAYER_BACKGROUND,
		SWF_PATH,
		loadRuffle,
		type RufflePlayerHandle
	} from '#lib/ruffle';
	import { avatarUrl, DEFAULT_AVATAR } from '#lib/avatar';
	import { SNAPI_ENDPOINT, installSnapiBridge } from '#lib/snapi';

	let { data, form } = $props();

	let mount = $state<HTMLDivElement | null>(null);
	let container = $state<HTMLDivElement | null>(null);

	let phase = $state<'idle' | 'loading' | 'ready' | 'error'>('idle');
	let failure = $state<string | null>(null);

	let started = false;
	let playerHandle = $state<RufflePlayerHandle | null>(null);

	/*
	 * The avatar grid from the 2013 /new.html page, which nothing linked to
	 * any more once the player became the front door.
	 *
	 * `data.avatar` is null when the gateway could not be read, so the grid is
	 * hidden and the default avatar is used -- a player who already has an
	 * empire is never blocked from pressing play by an unreachable endpoint.
	 * `?? 'blank.png'` is also what the gateway serves for a save with no
	 * `profilePic`, so "not chosen yet" looks the same in both places.
	 */
	const avatarCatalog = $derived(data.avatar?.avatars ?? []);
	const chosenAvatar = $derived(data.avatar?.current ?? DEFAULT_AVATAR);
	const canChooseAvatar = $derived(avatarCatalog.length > 0);

	async function startPlayer() {
		try {
			await loadRuffle();

			/*
			 * Install the ExternalInterface bridge *before* loading the SWF.
			 */
			const social = await fetch(SNAPI_ENDPOINT, { credentials: 'same-origin' });
			if (!social.ok) {
				throw new Error(`${SNAPI_ENDPOINT} respondió ${social.status}`);
			}
			installSnapiBridge(await social.json());

			const ruffleApi = window.RufflePlayer?.newest ? window.RufflePlayer.newest() : null;
			if (!ruffleApi) throw new Error('RufflePlayer no está disponible');

			const element = ruffleApi.createPlayer();
			const handle = element as RufflePlayerHandle;
			playerHandle = handle;

			handle.width = '100%';
			handle.height = '100%';
			handle.style = `width: 100%; height: 100%; background-color: ${PLAYER_BACKGROUND}; display: block;`;

			mount?.appendChild(element);

			await handle.load({
				url: SWF_PATH,
				backgroundColor: PLAYER_BACKGROUND,
				allowScriptAccess: true,
				allowFullscreen: true,
				quality: 'high',
				autoplay: true,
				parameters: data.flashVars
			});

			phase = 'ready';
		} catch (cause) {
			failure = cause instanceof Error ? cause.message : String(cause);
			phase = 'error';
		}
	}

	function start() {
		if (started) return;
		started = true;
		phase = 'loading';
		void startPlayer();
	}

	onMount(() => {
		// Register service worker for offline game assets caching
		if ('serviceWorker' in navigator) {
			navigator.serviceWorker.register('/service-worker.js').catch((err) => {
				console.debug('ServiceWorker no disponible:', err);
			});
		}

		return () => {
			mount?.replaceChildren();
			playerHandle = null;
		};
	});
</script>

<svelte:head>
	<title>Juego — Raise the Empires</title>
</svelte:head>

<div class="flex flex-col items-center gap-3 w-full">
	<!-- Main Game Display Frame - Scaled cleanly to viewport -->
	<div
		bind:this={container}
		class="relative flex items-center justify-center overflow-hidden rounded-lg border border-empire-800 bg-empire-950 shadow-2xl"
		style="width: 100%; max-width: 1024px; aspect-ratio: 4/3; min-height: 480px; max-height: 85vh;"
	>
		<!-- Mount element for Ruffle -->
		<div bind:this={mount} class="w-full h-full flex items-center justify-center"></div>

		{#if phase === 'idle'}
			<div
				class="absolute inset-0 flex flex-col items-center justify-center gap-4 bg-empire-900/95 text-slate-300 p-6 text-center overflow-y-auto"
			>
				<h2 class="text-2xl font-bold text-slate-100">Empires &amp; Allies</h2>

				{#if canChooseAvatar}
					<!--
						The picker. Selecting posts to the `pick` action, which writes
						`profilePic` on the save and redirects back here, so the choice
						survives a reload and travels with the account rather than with
						this browser.
					-->
					<form method="POST" action="?/pick" class="flex flex-col items-center gap-2">
						<p class="text-sm text-slate-300">Elige tu avatar</p>
						<div
							class="grid grid-cols-8 gap-1.5 max-h-40 overflow-y-auto p-2 rounded bg-empire-950/60 border border-empire-800"
						>
							{#each avatarCatalog as avatar (avatar)}
								<button
									type="submit"
									name="avatar"
									value={avatar}
									title={avatar}
									aria-label={`Elegir avatar ${avatar}`}
									aria-pressed={avatar === chosenAvatar}
									class="rounded p-0.5 border-2 transition-colors
										{avatar === chosenAvatar
											? 'border-gold-400 bg-gold-500/20'
											: 'border-transparent hover:border-slate-500'}"
								>
									<img src={avatarUrl(avatar)} alt="" height="44" loading="lazy" />
								</button>
							{/each}
						</div>
						<button
							type="submit"
							name="avatar"
							value={chosenAvatar}
							class="text-xs text-gold-400 hover:underline"
						>
							Guardar cambio
						</button>
						{#if form?.message}
							<p class="text-xs text-red-300">{form.message}</p>
						{/if}
					</form>
				{/if}

				<p class="max-w-md text-sm text-slate-300">
					Aceleración por hardware WebGPU/WebGL con soporte completo de controles nativos.
				</p>
				<button
					type="button"
					onclick={start}
					class="rounded bg-gold-500 px-8 py-3.5 text-lg font-bold text-empire-950 shadow-lg hover:bg-gold-400 hover:scale-105 transition-all duration-150 cursor-pointer"
				>
					▶ Jugar ahora
				</button>
				<p class="max-w-md text-xs text-slate-400">
					Requiere interacción para activar el sonido del navegador.
				</p>
			</div>
		{:else if phase === 'loading'}
			<div
				class="absolute inset-0 flex flex-col items-center justify-center gap-3 bg-empire-900/95 text-slate-300"
			>
				<div class="h-8 w-8 animate-spin rounded-full border-4 border-gold-400 border-t-transparent"></div>
				<p class="font-medium text-slate-200">Iniciando Ruffle WASM…</p>
				<p class="text-xs text-slate-400">Cargando shaders WebGPU y assets del cliente</p>
			</div>
		{:else if phase === 'error'}
			<div
				class="absolute inset-0 flex flex-col items-center justify-center gap-2 border border-red-800 bg-red-950/80 p-8 text-red-200 text-center"
			>
				<p class="text-lg font-bold text-red-100">No se pudo iniciar el juego</p>
				<p class="text-sm font-mono bg-red-950/60 p-2 rounded border border-red-900 max-w-lg">{failure}</p>
				<p class="text-xs text-red-300/80 mt-2">
					Asegúrate de que el gateway AMF0 esté activo en <code>127.0.0.1:5005</code>.
				</p>
			</div>
		{/if}
	</div>

	<!-- Status Bar -->
	<div class="flex items-center justify-between w-full text-xs text-slate-400 px-2" style="max-width: 1024px;">
		<span class="flex items-center gap-2">
			<img src={avatarUrl(chosenAvatar)} alt="" height="22" class="rounded-sm" />
			ID de cuenta (zid): <code class="text-gold-400">{data.zid ?? '—'}</code>
		</span>
		{#if data.role === 'admin'}
			<a href="/admin/editor" class="text-gold-400 hover:underline">🛠️ Editor de Imperio</a>
		{/if}
	</div>
</div>