/**
 * The player page.
 *
 * The SWF is embedded in this page rather than behind a separate document: no
 * iframe, no second origin, and the site's own chrome stays around it. The
 * player options are the ones already proven in templates/ruffle.html.
 */
<script lang="ts">
	import { onMount } from 'svelte';
	import {
		PLAYER_BACKGROUND,
		PLAYER_HEIGHT,
		PLAYER_WIDTH,
		SWF_PATH,
		loadRuffle,
		type RufflePlayerHandle,
	} from '#lib/ruffle';

	let { data } = $props();

	let mount = $state<HTMLDivElement | null>(null);
	let player = $state<RufflePlayerHandle | null>(null);
	// Not `state`: a variable named `state` shadows the `$state` rune for the
	// whole scope and the compiler rejects it.
	let phase = $state<'loading' | 'ready' | 'error'>('loading');
	let failure = $state<string | null>(null);

	onMount(() => {
		let cancelled = false;

		void (async () => {
			try {
				await loadRuffle();

				const ruffle = window.RufflePlayer?.newest();
				if (!ruffle) throw new Error('RufflePlayer no está disponible');

				const element = ruffle.createPlayer();
				const handle = element as RufflePlayerHandle;

				handle.width = PLAYER_WIDTH;
				handle.height = PLAYER_HEIGHT;
				handle.style = `width: ${PLAYER_WIDTH}px; height: ${PLAYER_HEIGHT}px; background-color: ${PLAYER_BACKGROUND};`;

				await handle.load({
					url: SWF_PATH,
					backgroundColor: PLAYER_BACKGROUND,
					// Without this the SWF throws Error #2067 and never finishes
					// loading. See #lib/ruffle for the full explanation.
					allowScriptAccess: true,
					allowFullscreen: true,
					quality: 'high',
					autoplay: true,
					parameters: data.flashVars,
				});

				if (cancelled) return;
				player = handle;
				phase = 'ready';
				mount?.appendChild(element);
			} catch (cause) {
				if (cancelled) return;
				failure = cause instanceof Error ? cause.message : String(cause);
				phase = 'error';
			}
		})();

		return () => {
			cancelled = true;
			// Tear the player out of the DOM rather than calling a method on it:
			// RufflePlayerHandle exposes no documented teardown, and removing
			// the node is what actually stops the render loop.
			mount?.replaceChildren();
			player = null;
		};
	});
</script>

<svelte:head>
	<title>Juego — Raise the Empires</title>
</svelte:head>

<div class="flex flex-col items-center gap-4">
	{#if phase === 'loading'}
		<div
			class="flex items-center justify-center bg-empire-900 text-slate-300"
			style="width: {PLAYER_WIDTH}px; height: {PLAYER_HEIGHT}px;"
		>
			<p>Cargando Ruffle…</p>
		</div>
	{:else if phase === 'error'}
		<div
			class="flex flex-col items-center justify-center gap-2 border border-red-800 bg-red-950/40 p-8 text-red-200"
			style="width: {PLAYER_WIDTH}px;"
		>
			<p class="text-lg font-semibold">No se pudo iniciar el juego</p>
			<p class="text-sm">{failure}</p>
			<p class="text-sm text-red-300/70">
				Revisa que el gateway AMF0 esté corriendo en 127.0.0.1:5005.
			</p>
		</div>
	{:else}
		<!-- The player is inserted here on mount; Svelte must not manage it. -->
		<div bind:this={mount}></div>
	{/if}

	<p class="text-sm text-slate-400">
		zid <code class="text-slate-300">{data.zid ?? '—'}</code>
	</p>
</div>