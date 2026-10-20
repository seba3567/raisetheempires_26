<script lang="ts">
	/**
	 * The player page.
	 *
	 * Embeds the original Empires & Allies SWF via Ruffle WASM (WebGPU/WebGL),
	 * behind the 2012 loading screen: a Message of the Day drawn as the
	 * backdrop, the remastered EA frame over it, and a gold bar driven by the
	 * ExternalInterface callbacks the client makes while it boots.
	 */
	import { onMount } from 'svelte';
	import {
		PLAYER_BACKGROUND,
		SWF_PATH,
		loadRuffle,
		type RufflePlayerHandle
	} from '#lib/ruffle';
	import { avatarUrl, DEFAULT_AVATAR } from '#lib/avatar';
	import { MOTD_FRAME_URL, motdUrl } from '#lib/motd';
	import {
		LOAD_MESSAGES,
		LOAD_STAGES,
		SNAPI_ENDPOINT,
		installSnapiBridge,
		type LoadStage
	} from '#lib/snapi';

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
	const avatarCatalog = $derived(Array.from(new Set(data.avatar?.avatars ?? [])));
	const chosenAvatar = $derived(data.avatar?.current ?? DEFAULT_AVATAR);
	const canChooseAvatar = $derived(avatarCatalog.length > 0);

	/* ---------------------------------------------------- the loading screen -- */

	/*
	 * `templates/js/empires.js` drove a bar from the client's setup callbacks:
	 * getUserInfo 30%, getFriendData 50%, getAppFriendIds 70%, onGameLoaded
	 * 100% and hide. Those callbacks are the ones in `#lib/snapi`, so the same
	 * sequence runs here -- this is the original progress, not an invented one.
	 *
	 * The frame and the art sit behind the bar and are sized to the 750x500
	 * canvas the 2013 markup used, letterboxed into the player box.
	 */
	/*
	 * Only the *re-roll* lives here, not the chosen art.
	 *
	 * Copying `data.motd.current` into state would capture it once, and the
	 * avatar action redirects back to /juego, which re-runs load and hands over
	 * a fresh `data` -- the screen would then paint the art from the previous
	 * visit. Null means "use what the server picked"; set only by rerollMotd.
	 */
	let rerolledMotd = $state<string | null>(null);

	const motdArt = $derived(rerolledMotd ?? data.motd?.current ?? null);

	let progress = $state(0);
	let stage = $state<LoadStage | 'boot'>('boot');
	let watchdog: ReturnType<typeof setTimeout> | null = null;

	/**
	 * How long the loading screen may stay up after the SWF finished loading
	 * without the client saying it is ready. Long enough for a world build on
	 * a slow machine, short enough that a callback that never arrives is not a
	 * permanently stuck page.
	 */
	const LOAD_WATCHDOG_MS = 20_000;

	function onProgress(next: LoadStage) {
		// Never move backwards: the client can call these in any order it
		// likes, and a bar that slides back reads as a fault.
		progress = Math.max(progress, LOAD_STAGES[next]);
		stage = next;
		// The client's own "I am up" is the signal the 2013 screen waited for.
		if (next === 'loaded') finishLoading();
	}

	/** The one random pick, then re-roll from the catalogue on click. */
	function rerollMotd() {
		const pool = data.motd?.motds ?? [];
		if (pool.length < 2) return;
		const rest = pool.filter((name) => name !== motdArt);
		rerolledMotd = rest[Math.floor(Math.random() * rest.length)];
	}

	/** The backdrop, sized to the player box; null paints the plain blue. */
	const motdBackground = $derived(
		motdArt
			? `url('${motdUrl(motdArt)}')`
			: `linear-gradient(${PLAYER_BACKGROUND}, #1a1a5e)`
	);

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
			// The bridge is also what moves the loading bar: the client calls
			// getUserInfo/getFriendData/getAppFriendIds/onGameLoaded as it boots,
			// and each one reports its stage.
			installSnapiBridge(await social.json(), onProgress);

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
				quality: 'medium',
				autoplay: true,
				parameters: data.flashVars
			});

			/*
			 * `load()` resolving only means the SWF finished *loading*, not that
			 * the world is up -- the 2013 page kept the screen until the client
			 * called onGameLoaded, which arrives later and is what the player
			 * actually remembers. But that callback is the one piece of this
			 * sequence we cannot prove fires on this build, so the overlay also
			 * comes down on a watchdog rather than trusting it forever.
			 */
			progress = Math.max(progress, LOAD_STAGES.appFriends);
			watchdog = setTimeout(() => finishLoading(), LOAD_WATCHDOG_MS);
		} catch (cause) {
			failure = cause instanceof Error ? cause.message : String(cause);
			phase = 'error';
		}
	}

	/**
	 * Take the loading screen down.
	 *
	 * Also called when the client reports it is ready, and by the watchdog when
	 * it never does. Guarded so a late callback cannot re-enter it.
	 */
	function finishLoading() {
		if (watchdog) {
			clearTimeout(watchdog);
			watchdog = null;
		}
		progress = LOAD_STAGES.loaded;
		if (phase === 'loading') phase = 'ready';
	}

	function start() {
		if (started) return;
		started = true;
		phase = 'loading';
		void startPlayer();
	}

	// The service worker is deliberately NOT registered here. SvelteKit already
	// registers it on every page, from src/service-worker.ts, and it does so with
	// `{ type: 'module' }` -- which it has to, because the file is served as an ES
	// module (`import '/@fs/.../service-worker.ts'`).
	//
	// This block registered the same URL as a *classic* worker, so the browser
	// refused to evaluate it: "Uncaught SyntaxError: Cannot use import statement
	// outside a module (at service-worker.js:1:1)". Registering a script URL twice
	// is not a harmless no-op here; whichever registration loses is the one that
	// throws, and it throws on every load of the game page.
	//
	// It was also registering only here, so offline asset caching was a property
	// of this route rather than of the site.
	/*
	 * ------------------------------------------------------- is it frozen, or slow?
	 *
	 * A stalled tab and a throttled one look identical from the outside, and
	 * that ambiguity is what made this expensive to diagnose: "se queda pegado"
	 * could have meant a crash, a hang, or a browser doing exactly what
	 * browsers do. It is measurable, so measure it.
	 *
	 * `requestAnimationFrame` is what the browser stops scheduling when a tab is
	 * not in front -- Chrome clamps timers in hidden pages to one per second,
	 * and Ruffle's background tick goes through a Worker that gets clamped the
	 * same way. So counting rAF callbacks per second gives the truth: near zero
	 * means the browser is throttling, not that the game has died.
	 */
	let fps = $state<number | null>(null);
	let backgrounded = $state(false);
	/** Below this, the page is visible, so the slowness is ours, not the browser's. */
	const SLOW_FPS = 12;

	function resume() {
		/*
		 * The Page Visibility API has no "wake me" call -- a hidden tab can only
		 * be brought back by the user focusing the window. Asking for it is
		 * still worth it: it raises the window on platforms that honour it, and
		 * where it does nothing it costs nothing and misleads nobody.
		 */
		window.focus();
	}

	onMount(() => {
		let frames = 0;
		let windowStart = performance.now();
		const countFrame = () => {
			frames++;
			requestAnimationFrame(countFrame);
		};
		requestAnimationFrame(countFrame);

		const sampler = setInterval(() => {
			const now = performance.now();
			const elapsed = now - windowStart;
			if (elapsed > 0) fps = Math.round((frames * 1000) / elapsed);
			frames = 0;
			windowStart = now;
		}, 1000);

		const syncVisibility = () => {
			backgrounded = document.hidden;
		};
		document.addEventListener('visibilitychange', syncVisibility);
		syncVisibility();

		return () => {
			clearInterval(sampler);
			document.removeEventListener('visibilitychange', syncVisibility);
		};
	});

	onMount(() => {
		return () => {
			if (watchdog) clearTimeout(watchdog);
			watchdog = null;
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

		<!--
			The honest answer to "it is stuck". Only ever shown once the game is
			actually up, so it can never be mistaken for part of loading, and it
			says which of the two very different situations is happening.
		-->
		{#if phase === 'ready' && backgrounded}
			<div
				class="absolute inset-x-0 bottom-0 z-10 flex items-center justify-between gap-3 rounded-t-lg bg-empire-950/95 px-4 py-2 text-left text-sm text-empire-100 shadow-[0_-2px_8px_rgba(0,0,0,0.45)]"
				role="status"
			>
				<span>
					El juego sigue en marcha, pero el navegador lo ralentiza cuando esta pestaña no está al
					frente. Vuelve a esta ventana para ir a velocidad normal.
				</span>
				<button
					type="button"
					class="shrink-0 rounded border border-empire-500 px-3 py-1 hover:bg-empire-800"
					onclick={resume}
				>
					Volver al juego
				</button>
			</div>
		{:else if phase === 'ready' && fps !== null && fps < SLOW_FPS}
			<div
				class="absolute inset-x-0 bottom-0 z-10 rounded-t-lg bg-empire-950/95 px-4 py-2 text-left text-sm text-empire-100 shadow-[0_-2px_8px_rgba(0,0,0,0.45)]"
				role="status"
			>
				El juego va a {fps} fps con esta ventana al frente. Si responde lento, prueba el build
				de producción en lugar del servidor de desarrollo.
			</div>
		{/if}

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
							{#each avatarCatalog as avatar, i (avatar ? `${avatar}-${i}` : i)}
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
			<!--
				The 2012 loading screen, rebuilt from templates/ruffle.html: the
				MOTD as the backdrop with the same bottom vignette, the remastered
				EA frame over it, and the gold bar underneath.

				The artwork is kept as background layers rather than <img> elements
				so the whole thing scales into the responsive player box instead of
				sitting at the original fixed 750x500.
			-->
			<div
				class="absolute inset-0 flex items-center justify-center bg-cover bg-center bg-no-repeat"
				style={`background-image: ${motdBackground};`}
			>
				<div
					class="relative w-full h-full max-w-[750px] flex flex-col items-center justify-end pb-[18%] bg-cover bg-center bg-no-repeat"
					style="background-image: linear-gradient(to top, rgba(0,0,0,0.85) 0%, rgba(0,0,0,0) 55%);"
				>
					<img
						src={MOTD_FRAME_URL}
						alt=""
						class="absolute inset-0 w-full h-full object-contain opacity-95"
						aria-hidden="true"
					/>

					<div class="relative flex flex-col items-center gap-3 px-6 text-center">
						<p
							class="text-lg font-bold text-white"
							style="text-shadow: 0 0 6px black, 0 0 12px black;"
						>
							{stage === 'boot' ? 'Detecting flash…' : LOAD_MESSAGES[stage]}
						</p>

						<!--
							The 2013 bar: a dark trough with a gold fill and an inset
							highlight, advancing one second per step like the original's
							`transition: width 1s linear`.
						-->
						<div
							class="flex w-[45%] min-w-[160px] max-w-[300px] h-[18px] overflow-hidden rounded-[10px]"
							style="background-color:#6d5554; box-shadow: inset 0 4px 9px -1px #4c4635;"
							role="progressbar"
							aria-valuemin="0"
							aria-valuemax="100"
							aria-valuenow={progress}
							aria-label="Cargando el juego"
						>
							<div
								class="h-full"
								style={`width:${progress}%; background-color:#e6b104; box-shadow: inset 0 4px 9px -1px #fae361; transition: width 1s linear;`}
							></div>
						</div>

						{#if (data.motd?.motds.length ?? 0) > 1}
							<button
								type="button"
								onclick={rerollMotd}
								class="mt-1 text-xs text-white/70 hover:text-white underline"
								style="text-shadow: 0 0 6px black;"
							>
								otra imagen
							</button>
						{/if}
					</div>
				</div>
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