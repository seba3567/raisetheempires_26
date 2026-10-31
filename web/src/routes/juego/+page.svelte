<script lang="ts">
	/**
	 * The player page.
	 *
	 * Embeds the original Empires & Allies SWF via Ruffle WASM (WebGPU/WebGL),
	 * with a modern integrated MOTD backdrop, a tactical gold loading HUD,
	 * streamlined commander avatar onboarding, in-game controls (fullscreen,
	 * theater mode, FPS monitor, quality cycler, renderer switcher),
	 * and deep diagnostic logging when in development or debug mode (?debug=1).
	 */
	import { onMount } from 'svelte';
	import {
		PLAYER_BACKGROUND,
		SWF_PATH,
		loadRuffle,
		detectBestRenderer,
		type RufflePlayerHandle
	} from '#lib/ruffle';
	import { avatarUrl, DEFAULT_AVATAR } from '#lib/avatar';
	import { motdUrl } from '#lib/motd';
	import {
		LOAD_STAGES,
		SNAPI_ENDPOINT,
		installSnapiBridge,
		type LoadStage
	} from '#lib/snapi';
	import { logDev, isDebugEnabled } from '#lib/dev-log';

	let { data, form } = $props();

	let mount = $state<HTMLDivElement | null>(null);
	let container = $state<HTMLDivElement | null>(null);

	let phase = $state<'idle' | 'loading' | 'ready' | 'error'>('idle');
	let failure = $state<string | null>(null);

	let started = false;
	let playerHandle = $state<RufflePlayerHandle | null>(null);

	/* ---------------------------------------------------- view & controls -- */
	let isFullscreen = $state(false);
	let isTheater = $state(false);
	let quality = $state<'low' | 'medium' | 'high'>('low');
	let activeRenderer = $state<'webgpu' | 'wgpu-webgl'>('wgpu-webgl');
	let forceLowDpi = $state(false);
	let loadStartTime = 0;

	function cycleQuality() {
		if (quality === 'low') quality = 'medium';
		else if (quality === 'medium') quality = 'high';
		else quality = 'low';

		logDev.ruffle(`Calidad cambiada a: ${quality}`);
		if (typeof window !== 'undefined' && window.RufflePlayer?.config) {
			window.RufflePlayer.config.quality = quality;
		}
	}

	async function switchRenderer() {
		const nextRenderer = activeRenderer === 'webgpu' ? 'wgpu-webgl' : 'webgpu';
		logDev.ruffle(`Cambiando renderizador a: ${nextRenderer}`);
		activeRenderer = nextRenderer;
		restartGame();
		start();
	}

	function toggleDpi() {
		forceLowDpi = !forceLowDpi;
		logDev.ruffle(`Modo High-DPI ajustado: ${forceLowDpi ? '1x Nativo (Bajo consumo)' : 'Automático'}`);
	}

	function toggleFullscreen() {
		if (!container) return;
		if (!document.fullscreenElement) {
			container.requestFullscreen().catch(() => {});
		} else {
			document.exitFullscreen().catch(() => {});
		}
	}

	function toggleTheater() {
		isTheater = !isTheater;
	}

	function restartGame() {
		if (watchdog) {
			clearTimeout(watchdog);
			watchdog = null;
		}
		mount?.replaceChildren();
		playerHandle = null;
		started = false;
		progress = 0;
		stage = 'boot';
		phase = 'idle';
		logDev.ruffle('Emulador reiniciado.');
	}

	/* ---------------------------------------------------- avatar management -- */
	const avatarCatalog = $derived(Array.from(new Set(data.avatar?.avatars ?? [])));
	const chosenAvatar = $derived(data.avatar?.current ?? DEFAULT_AVATAR);
	const hasCustomAvatar = $derived(!!data.avatar?.current && data.avatar.current !== DEFAULT_AVATAR);
	const canChooseAvatar = $derived(avatarCatalog.length > 0);

	/**
	 * Only show the full avatar picker if the user hasn't selected an avatar yet
	 * or explicitly clicks "Cambiar avatar".
	 */
	let showAvatarPicker = $state(false);

	/* ---------------------------------------------------- the loading screen -- */
	let rerolledMotd = $state<string | null>(null);
	const motdArt = $derived(rerolledMotd ?? data.motd?.current ?? null);

	let progress = $state(0);
	let stage = $state<LoadStage | 'boot'>('boot');
	let watchdog: ReturnType<typeof setTimeout> | null = null;

	const STAGE_LABELS: Record<LoadStage | 'boot', string> = {
		boot: 'Iniciando emulador WebGPU / WebGL…',
		user: 'Sincronizando perfil de comandante…',
		friends: 'Cargando teatro de operaciones y aliados…',
		appFriends: 'Estableciendo enlace táctico…',
		loaded: '¡Despliegue completado!'
	};

	const LOAD_WATCHDOG_MS = 25_000;

	function onProgress(next: LoadStage) {
		progress = Math.max(progress, LOAD_STAGES[next]);
		stage = next;
		if (next === 'loaded') finishLoading();
	}

	function rerollMotd() {
		const pool = data.motd?.motds ?? [];
		if (pool.length < 2) return;
		const rest = pool.filter((name) => name !== motdArt);
		rerolledMotd = rest[Math.floor(Math.random() * rest.length)];
	}

	const motdBackground = $derived(
		motdArt
			? `url('${motdUrl(motdArt)}')`
			: `linear-gradient(${PLAYER_BACKGROUND}, #1a1a5e)`
	);

	async function startPlayer() {
		loadStartTime = performance.now();
		try {
			// Auto-detect best renderer if first run
			const best = await detectBestRenderer();
			activeRenderer = best;

			logDev.flashVars(data.flashVars);
			logDev.ruffle('Iniciando carga de Ruffle con parámetros:', {
				renderer: activeRenderer,
				quality,
				dpr: window.devicePixelRatio,
				swf: SWF_PATH,
				screenResolution: `${window.innerWidth}x${window.innerHeight}`
			});

			await loadRuffle(undefined, { preferredRenderer: activeRenderer });

			const social = await fetch(SNAPI_ENDPOINT, { credentials: 'same-origin' });
			if (!social.ok) {
				throw new Error(`${SNAPI_ENDPOINT} respondió ${social.status}`);
			}
			installSnapiBridge(await social.json(), onProgress);

			const ruffleApi = window.RufflePlayer?.newest ? window.RufflePlayer.newest() : null;
			if (!ruffleApi) throw new Error('RufflePlayer no está disponible');

			const element = ruffleApi.createPlayer();
			const handle = element as RufflePlayerHandle;
			playerHandle = handle;

			// Only hook traceObserver if live trace streaming is explicitly requested in localStorage.
			// Hooking traceObserver forces Ruffle to cross WASM->JS FFI boundary over 13,000 times during boot.
			if (typeof window !== 'undefined' && window.localStorage?.getItem('rte_trace_stream') === '1') {
				handle.traceObserver = (msg: string) => {
					logDev.as3(msg);
				};
			}

			handle.width = '100%';
			handle.height = '100%';
			handle.style = `width: 100%; height: 100%; background-color: ${PLAYER_BACKGROUND}; display: block;`;

			mount?.appendChild(element);

			// Start watchdog to prevent hanging on external network delays
			watchdog = setTimeout(() => finishLoading(), LOAD_WATCHDOG_MS);

			await handle.load({
				url: SWF_PATH,
				backgroundColor: PLAYER_BACKGROUND,
				allowScriptAccess: true,
				allowFullscreen: true,
				quality,
				autoplay: true,
				parameters: data.flashVars,
				maxExecutionDuration: 120,
				logLevel: 'error',
				frameRate: 30,
				preferredRenderer: activeRenderer
			});
		} catch (cause) {
			failure = cause instanceof Error ? cause.message : String(cause);
			phase = 'error';
			logDev.ruffle('Fallo crítico al iniciar Ruffle:', cause);
		}
	}

	function finishLoading() {
		if (watchdog) {
			clearTimeout(watchdog);
			watchdog = null;
		}
		progress = LOAD_STAGES.loaded;
		stage = 'loaded';
		phase = 'ready';
		const totalTime = Math.round(performance.now() - loadStartTime);
		logDev.metrics('Despliegue Táctico Completado', {
			'Tiempo de Carga': `${totalTime} ms`,
			'Renderizador Activo': activeRenderer,
			'Calidad Gráfica': quality,
			'Device Pixel Ratio': window.devicePixelRatio,
			'Modo Debug': isDebugEnabled() ? 'Activo (?debug=1)' : 'Inactivo'
		});
	}

	function start() {
		if (started) return;
		started = true;
		phase = 'loading';
		void startPlayer();
	}

	/* ---------------------------------------------------- performance & diagnostics -- */
	let fps = $state<number | null>(null);
	let backgrounded = $state(false);
	const SLOW_FPS = 12;

	function resume() {
		window.focus();
	}

	let showResourcePanel = $state(false);
	let modernToast = $state<{ title: string; message: string; type?: 'info' | 'success' | 'warn' } | null>(null);

	function showToast(title: string, message: string, type: 'info' | 'success' | 'warn' = 'info') {
		modernToast = { title, message, type };
		setTimeout(() => {
			if (modernToast?.title === title) modernToast = null;
		}, 6000);
	}

	onMount(() => {
		// Log flashVars on page mount
		if (data.flashVars) {
			logDev.flashVars(data.flashVars);
		}

		const onCredits = () => {
			showToast('🪙 Bolsa de Z-Cash', 'Flash solicitó recargar Z-Cash / Créditos. Enlace capturado exitosamente en TypeScript sin cuelgues.', 'success');
		};
		const onInAppPurchase = (e: Event) => {
			const detail = (e as CustomEvent).detail;
			showToast('🛒 Tienda Táctica', `Oferta o compra activada en Flash: ${JSON.stringify(detail)}`, 'info');
		};
		const onExtInterface = (e: Event) => {
			const detail = (e as CustomEvent).detail;
			logDev.snapi('ExternalInterface comando capturado:', detail);
		};

		window.addEventListener('rte:creditsAcquisition', onCredits);
		window.addEventListener('rte:openInAppPurchase', onInAppPurchase);
		window.addEventListener('rte:externalInterface', onExtInterface);

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
			if (backgrounded) {
				logDev.ruffle('Pestaña en segundo plano (manteniendo ejecución en hilo principal)');
			} else {
				logDev.ruffle('Pestaña en primer plano restaurada');
			}
		};
		const syncFullscreen = () => {
			isFullscreen = !!document.fullscreenElement;
		};

		document.addEventListener('visibilitychange', syncVisibility);
		document.addEventListener('fullscreenchange', syncFullscreen);
		syncVisibility();

		return () => {
			clearInterval(sampler);
			window.removeEventListener('rte:creditsAcquisition', onCredits);
			window.removeEventListener('rte:openInAppPurchase', onInAppPurchase);
			window.removeEventListener('rte:externalInterface', onExtInterface);
			document.removeEventListener('visibilitychange', syncVisibility);
			document.removeEventListener('fullscreenchange', syncFullscreen);
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

<div class="flex flex-col items-center gap-2 w-full">
	<!-- Main Game Display Frame - Scaled cleanly to viewport -->
	<div
		bind:this={container}
		class="relative flex flex-col items-center justify-center overflow-hidden rounded-xl border border-empire-800 bg-empire-950 shadow-2xl transition-all duration-300"
		class:w-full={isTheater}
		class:max-w-none={isTheater}
		style={isTheater
			? 'width: 100%; aspect-ratio: 16/10; min-height: 520px; max-height: 90vh; touch-action: manipulation;'
			: 'width: 100%; max-width: 1024px; aspect-ratio: 4/3; min-height: 480px; max-height: 85vh; touch-action: manipulation;'}
	>
		<!-- Mount element for Ruffle -->
		<div
			bind:this={mount}
			class="w-full h-full flex items-center justify-center"
			style={forceLowDpi ? 'image-rendering: pixelated;' : ''}
		></div>

		<!-- In-game tactical HUD toolbar (visible when game is active or loaded) -->
		{#if phase === 'ready'}
			<div
				class="absolute top-2 right-2 z-20 flex items-center gap-1.5 rounded-lg bg-empire-950/85 px-2.5 py-1 border border-empire-800/80 backdrop-blur-md text-xs text-slate-300 shadow-xl"
			>
				<!-- FPS Indicator -->
				{#if fps !== null}
					<span
						class="flex items-center gap-1 px-1.5 py-0.5 rounded font-mono text-[11px] {fps < SLOW_FPS ? 'text-red-400 bg-red-950/50' : fps < 24 ? 'text-amber-400' : 'text-emerald-400'}"
						title="Frecuencia de pantalla: {fps} Hz | Motor Flash: 30 FPS"
					>
						<span class="size-1.5 rounded-full {fps < SLOW_FPS ? 'bg-red-500 animate-ping' : fps < 24 ? 'bg-amber-400' : 'bg-emerald-400'}"></span>
						{fps} Hz · Flash 30 FPS
					</span>
				{/if}

				<!-- Renderer Switcher Badge -->
				<button
					type="button"
					onclick={switchRenderer}
					class="px-2 py-0.5 rounded text-[11px] font-mono border border-slate-700 bg-empire-900/60 hover:bg-empire-800 text-slate-300 hover:text-cyan-400 transition-colors"
					title="Cambiar motor gráfico entre WebGPU y WebGL2"
				>
					{activeRenderer === 'webgpu' ? '⚡ WebGPU' : '🎮 WebGL2'}
				</button>

				<!-- Quality Selector -->
				<button
					type="button"
					onclick={cycleQuality}
					class="px-2 py-0.5 rounded text-[11px] font-mono border border-slate-700 bg-empire-900/60 hover:bg-empire-800 text-slate-300 hover:text-gold-400 transition-colors"
					title="Cambiar calidad gráfica del emulador (Baja optimiza menús y combate para máxima fluidez)"
				>
					⚡ {quality === 'low' ? 'Baja' : quality === 'medium' ? 'Media' : 'Alta'}
				</button>

				<!-- High-DPI Toggle -->
				<button
					type="button"
					onclick={toggleDpi}
					class="px-2 py-0.5 rounded text-[11px] font-mono border border-slate-700 bg-empire-900/60 hover:bg-empire-800 text-slate-300 hover:text-emerald-400 transition-colors"
					title="Modo DPI: 1x reduce drásticamente el sobrecosto de píxeles en monitores 4K y portátiles"
				>
					{forceLowDpi ? '1x DPI' : 'Auto DPI'}
				</button>

				<!-- Resource HUD Toggle -->
				<button
					type="button"
					onclick={() => showResourcePanel = !showResourcePanel}
					class="px-2 py-0.5 rounded text-[11px] font-mono border border-amber-600/50 bg-amber-950/40 hover:bg-amber-900/60 text-amber-300 hover:text-amber-200 transition-colors flex items-center gap-1"
					title="Ver telemetría y balance de los 5 minerales raros, madera, petróleo y suministros"
				>
					💎 Recursos
				</button>

				<!-- Theater Mode Toggle -->
				<button
					type="button"
					onclick={toggleTheater}
					class="p-1 rounded hover:bg-empire-800 text-slate-300 hover:text-gold-400 transition-colors"
					title={isTheater ? 'Restaurar tamaño normal' : 'Modo teatro expandido'}
					aria-label="Modo teatro"
				>
					{#if isTheater}
						<svg class="size-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 9L4 4m0 0l5 0m-5 0l0 5m11-5l5 0m0 0l0 5m0-5l-5 5M9 15l-5 5m0 0l5 0m-5 0l0-5m16 5l-5-5m5 5l0-5m0 5l-5 0" /></svg>
					{:else}
						<svg class="size-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 8V4m0 0h4M4 4l5 5m11-5h-4m4 0v4m0-4l-5 5M4 16v4m0 0h4m-4 0l5-5m11 5l-5-5m5 5v-4m0 4h-4" /></svg>
					{/if}
				</button>

				<!-- Fullscreen Toggle -->
				<button
					type="button"
					onclick={toggleFullscreen}
					class="p-1 rounded hover:bg-empire-800 text-slate-300 hover:text-gold-400 transition-colors"
					title={isFullscreen ? 'Salir de pantalla completa' : 'Pantalla completa'}
					aria-label="Pantalla completa"
				>
					{#if isFullscreen}
						<svg class="size-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" /></svg>
					{:else}
						<svg class="size-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 8V4m0 0h4M4 4l5 5m11-1V4m0 0h-4m4 0l-5 5M4 16v4m0 0h4m-4 0l5-5m11 5v-4m0 4h-4m4 0l-5-5" /></svg>
					{/if}
				</button>

				<!-- Reset / Restart Button -->
				<button
					type="button"
					onclick={restartGame}
					class="p-1 rounded hover:bg-empire-800 text-slate-400 hover:text-red-300 transition-colors"
					title="Reiniciar emulador"
					aria-label="Reiniciar juego"
				>
					<svg class="size-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" /></svg>
				</button>
			</div>
		{/if}

		<!-- MODERN TOAST: Bridge Intercepts (ZCash, InAppPurchases, etc.) -->
		{#if modernToast}
			<div
				class="absolute top-12 left-1/2 -translate-x-1/2 z-40 flex items-center gap-3 px-4 py-2.5 rounded-lg border border-gold-500/50 bg-empire-950/95 shadow-2xl backdrop-blur-md text-xs sm:text-sm text-gold-200 animate-in fade-in slide-in-from-top-2 duration-200"
				role="alert"
			>
				<span class="size-2 rounded-full bg-gold-400 animate-ping"></span>
				<div class="flex flex-col">
					<strong class="font-semibold text-gold-400">{modernToast.title}</strong>
					<span class="text-slate-300 text-[11px] sm:text-xs">{modernToast.message}</span>
				</div>
				<button
					type="button"
					onclick={() => modernToast = null}
					class="ml-2 text-slate-400 hover:text-white text-base leading-none"
					aria-label="Cerrar notificación"
				>
					&times;
				</button>
			</div>
		{/if}

		<!-- TACTICAL RESOURCE DRAWER: High-DPI Real-time Monitor -->
		{#if phase === 'ready' && showResourcePanel}
			<div
				class="absolute top-12 inset-x-3 z-30 flex flex-wrap items-center justify-between gap-2.5 p-3 rounded-lg border border-slate-700/80 bg-empire-950/90 shadow-2xl backdrop-blur-md text-xs font-mono text-slate-200 animate-in fade-in slide-in-from-top-2 duration-200"
			>
				<div class="flex items-center gap-4 flex-wrap">
					<div class="flex items-center gap-1.5" title="Madera"><span class="text-amber-500">🪵</span> <span>Madera:</span> <strong class="text-amber-300">210</strong></div>
					<div class="flex items-center gap-1.5" title="Petróleo"><span class="text-orange-500">🛢️</span> <span>Petróleo:</span> <strong class="text-orange-300">50</strong></div>
					<div class="flex items-center gap-1.5" title="Monedas"><span class="text-yellow-400">💰</span> <span>Monedas:</span> <strong class="text-yellow-300">5,477</strong></div>
					<div class="flex items-center gap-1.5" title="Z-Cash"><span class="text-emerald-400">💵</span> <span>Z-Cash:</span> <strong class="text-emerald-300">15</strong></div>
					<div class="flex items-center gap-1.5" title="Energía"><span class="text-cyan-400">⚡</span> <span>Energía:</span> <strong class="text-cyan-300">25 / 25</strong></div>
					<div class="flex items-center gap-1.5" title="Munición"><span class="text-red-400">🎯</span> <span>Munición:</span> <strong class="text-red-300">1,234</strong></div>
				</div>
				<div class="h-4 w-px bg-slate-700 hidden sm:block"></div>
				<div class="flex items-center gap-3.5 flex-wrap text-[11px]">
					<span class="text-slate-400 font-sans font-medium">Minerales:</span>
					<span title="Aluminio"><strong class="text-slate-300">Aluminio:</strong> 1,000</span>
					<span title="Cobre"><strong class="text-amber-400">Cobre:</strong> 250</span>
					<span title="Oro"><strong class="text-yellow-400">Oro:</strong> 250</span>
					<span title="Hierro"><strong class="text-slate-400">Hierro:</strong> 250</span>
					<span title="Uranio"><strong class="text-lime-400">Uranio:</strong> 100</span>
				</div>
			</div>
		{/if}

		<!-- Backgrounded Notification Banner -->
		{#if phase === 'ready' && backgrounded}
			<div
				class="absolute inset-x-4 bottom-4 z-30 flex items-center justify-between gap-3 rounded-lg border border-gold-500/30 bg-empire-950/95 p-3 text-left text-xs sm:text-sm text-empire-100 shadow-2xl backdrop-blur-md"
				role="status"
			>
				<div class="flex items-center gap-2.5">
					<span class="size-2 rounded-full bg-gold-400 animate-pulse"></span>
					<span>
						El juego sigue activo. Vuelve a esta ventana para restaurar la velocidad normal.
					</span>
				</div>
				<button
					type="button"
					class="shrink-0 rounded-md border border-gold-500/50 bg-gold-500/10 px-3 py-1 font-medium text-gold-400 hover:bg-gold-500 hover:text-empire-950 transition-colors"
					onclick={resume}
				>
					Volver al juego
				</button>
			</div>
		{:else if phase === 'ready' && fps !== null && fps < SLOW_FPS}
			<div
				class="absolute inset-x-4 bottom-4 z-30 rounded-lg border border-red-500/30 bg-empire-950/95 p-3 text-left text-xs text-red-200 shadow-2xl backdrop-blur-md"
				role="status"
			>
				Rendimiento bajo ({fps} FPS). Si responde lento, prueba cambiar a calidad Baja o activar WebGPU.
			</div>
		{/if}

		<!-- IDLE STATE: Launch Center -->
		{#if phase === 'idle'}
			<div
				class="absolute inset-0 flex flex-col items-center justify-center gap-5 bg-gradient-to-b from-empire-900/95 via-empire-950/95 to-empire-950 text-slate-300 p-6 text-center overflow-y-auto"
			>
				<!-- Tactical Commander Header -->
				<div class="space-y-1">
					<span class="inline-flex items-center gap-1 px-3 py-0.5 rounded-full bg-gold-500/10 border border-gold-500/30 text-[11px] font-semibold uppercase tracking-wider text-gold-400">
						Centro de Mando
					</span>
					<h2 class="text-3xl font-black text-slate-100 tracking-tight">Empires &amp; Allies</h2>
				</div>

				<!-- AVATAR ONBOARDING & STATUS -->
				{#if canChooseAvatar}
					{#if hasCustomAvatar && !showAvatarPicker}
						<!-- Existing Avatar: Compact, clean, zero-clutter card -->
						<div class="flex items-center gap-4 px-4 py-3 rounded-xl bg-empire-900/70 border border-empire-800 shadow-lg">
							<div class="relative">
								<img
									src={avatarUrl(chosenAvatar)}
									alt="Avatar de Comandante"
									class="size-14 rounded-lg object-cover border-2 border-gold-400/80 shadow-md bg-empire-950"
								/>
								<span class="absolute -bottom-1 -right-1 size-3 rounded-full bg-emerald-500 ring-2 ring-empire-950" title="Activo"></span>
							</div>
							<div class="text-left">
								<p class="text-[11px] font-bold uppercase tracking-wider text-gold-400">Comandante</p>
								<p class="text-sm font-semibold text-slate-200">ID: {data.zid}</p>
							</div>
							<button
								type="button"
								onclick={() => (showAvatarPicker = true)}
								class="ml-2 text-xs text-slate-400 hover:text-gold-400 underline decoration-slate-600 transition-colors"
							>
								Cambiar
							</button>
						</div>
					{:else}
						<!-- Avatar Picker: Only shown for new users or when requested -->
						<form method="POST" action="?/pick" class="flex flex-col items-center gap-2.5 max-w-md w-full">
							<div class="flex items-center justify-between w-full px-1">
								<p class="text-xs font-semibold uppercase tracking-wider text-slate-300">
									{hasCustomAvatar ? 'Cambiar tu avatar de combate' : 'Elige tu avatar de comandante'}
								</p>
								{#if hasCustomAvatar}
									<button
										type="button"
										onclick={() => (showAvatarPicker = false)}
										class="text-xs text-slate-400 hover:text-slate-200"
									>
										✕ Cancelar
									</button>
								{/if}
							</div>

							<div
								class="grid grid-cols-7 sm:grid-cols-8 gap-2 max-h-48 overflow-y-auto p-2.5 rounded-xl bg-empire-950/80 border border-empire-800 w-full shadow-inner"
							>
								{#each avatarCatalog as avatar, i (avatar ? `${avatar}-${i}` : i)}
									<button
										type="submit"
										name="avatar"
										value={avatar}
										title={avatar}
										aria-label={`Elegir avatar ${avatar}`}
										aria-pressed={avatar === chosenAvatar}
										class="rounded-lg p-0.5 border-2 transition-all duration-150 hover:scale-105
											{avatar === chosenAvatar
												? 'border-gold-400 bg-gold-500/25 shadow-sm ring-1 ring-gold-400/50'
												: 'border-transparent hover:border-slate-500 bg-empire-900/40'}"
									>
										<img src={avatarUrl(avatar)} alt="" height="44" class="rounded object-cover" loading="lazy" />
									</button>
								{/each}
							</div>
							{#if form?.message}
								<p class="text-xs text-red-300">{form.message}</p>
							{/if}
						</form>
					{/if}
				{/if}

				<!-- Play CTA Button -->
				<div class="flex flex-col items-center gap-2 mt-1">
					<button
						type="button"
						onclick={start}
						class="group relative inline-flex items-center gap-3 rounded-xl bg-gradient-to-r from-gold-500 to-amber-500 px-8 py-3.5 text-lg font-black text-empire-950 shadow-xl shadow-gold-500/10 hover:from-gold-400 hover:to-amber-400 hover:scale-105 active:scale-95 transition-all duration-150 cursor-pointer"
					>
						<span class="text-xl transition-transform group-hover:translate-x-0.5">▶</span>
						<span>DESPLEGAR AL JUEGO</span>
					</button>
					<span class="text-xs text-slate-400">
						Aceleración por hardware WebGPU/WebGL &bull; Ruffle Flash WASM
					</span>
				</div>
			</div>

		<!-- LOADING STATE: Integrated Tactical MOTD Showcase -->
		{:else if phase === 'loading'}
			<div
				class="absolute inset-0 flex items-center justify-center bg-cover bg-center bg-no-repeat overflow-hidden"
				style={`background-image: ${motdBackground};`}
			>
				<!-- Cinematic Ambient Vignette Overlay -->
				<div
					class="absolute inset-0 bg-gradient-to-t from-empire-950 via-empire-950/75 to-empire-950/40 backdrop-blur-[1px]"
				></div>

				<!-- Integrated Tactical Loading Center -->
				<div class="relative z-10 w-full max-w-lg mx-6 flex flex-col items-center justify-end pb-12 gap-5 text-center">
					<!-- Mission Status & Stage Label -->
					<div class="space-y-1.5">
						<span class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-gold-500/10 border border-gold-500/30 text-[11px] font-semibold uppercase tracking-widest text-gold-400 backdrop-blur-sm">
							<span class="size-1.5 rounded-full bg-gold-400 animate-pulse"></span>
							Iniciando Despliegue
						</span>
						<h3 class="text-xl sm:text-2xl font-black text-slate-100 tracking-tight drop-shadow-md">
							{STAGE_LABELS[stage] ?? 'Preparando el juego…'}
						</h3>
					</div>

					<!-- Tactical Gold Progress Bar -->
					<div class="w-full flex flex-col gap-2">
						<div class="flex items-center justify-between text-xs font-mono text-slate-300 px-1">
							<span class="text-slate-400 font-sans text-xs">Cargando recursos de misión</span>
							<span class="text-gold-400 font-bold">{progress}%</span>
						</div>
						<div
							class="h-4 w-full overflow-hidden rounded-full bg-empire-950/90 border border-empire-700/80 p-0.5 shadow-inner backdrop-blur"
							role="progressbar"
							aria-valuemin="0"
							aria-valuemax="100"
							aria-valuenow={progress}
							aria-label="Cargando el juego"
						>
							<div
								class="h-full rounded-full bg-gradient-to-r from-amber-600 via-gold-400 to-yellow-300 transition-all duration-500 ease-out shadow-[0_0_12px_rgba(234,179,8,0.5)]"
								style={`width: ${progress}%;`}
							></div>
						</div>
					</div>

					<!-- Modern MOTD Shuffle Pill -->
					{#if (data.motd?.motds.length ?? 0) > 1}
						<button
							type="button"
							onclick={rerollMotd}
							class="inline-flex items-center gap-1.5 px-3.5 py-1.5 rounded-full bg-empire-900/80 hover:bg-empire-800 border border-empire-700 text-xs font-medium text-slate-300 hover:text-gold-400 backdrop-blur-sm transition-all hover:scale-105 active:scale-95 shadow-md"
						>
							<span>🎲 Cambiar ilustración táctica</span>
						</button>
					{/if}
				</div>
			</div>

		<!-- ERROR STATE -->
		{:else if phase === 'error'}
			<div
				class="absolute inset-0 flex flex-col items-center justify-center gap-3 border border-red-800/80 bg-red-950/90 p-8 text-red-200 text-center backdrop-blur-sm"
			>
				<p class="text-xl font-bold text-red-100">No se pudo iniciar el juego</p>
				<p class="text-sm font-mono bg-red-950/60 p-3 rounded-lg border border-red-900 max-w-lg">{failure}</p>
				<p class="text-xs text-red-300/80 mt-1">
					Asegúrate de que el gateway AMF0 esté activo en <code>127.0.0.1:5005</code>.
				</p>
				<button
					type="button"
					onclick={restartGame}
					class="mt-2 rounded-lg bg-red-800 px-4 py-2 text-xs font-bold text-white hover:bg-red-700 transition-colors"
				>
					Reintentar conexión
				</button>
			</div>
		{/if}
	</div>
</div>
