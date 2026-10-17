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
		type RufflePlayerHandle
	} from '#lib/ruffle';

	let { data } = $props();

	let mount = $state<HTMLDivElement | null>(null);
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

				/*
				 * Attach before loading, never after.
				 *
				 * Ruffle calls play() on a connected element. Loading into a
				 * detached node leaves it suspended, and the console fills with
				 * "Ignoring attempt to play a disconnected or suspended Ruffle
				 * element" while the game silently never starts. The mount point
				 * is rendered unconditionally for the same reason: putting it
				 * behind an {#if} would mean it does not exist yet at this point.
				 */
				mount?.appendChild(element);

				await handle.load({
					url: SWF_PATH,
					backgroundColor: PLAYER_BACKGROUND,
					// Without this the SWF throws Error #2067 and never finishes
					// loading. See #lib/ruffle for the full explanation.
					allowScriptAccess: true,
					allowFullscreen: true,
					quality: 'high',
					autoplay: true,
					parameters: data.flashVars
				});

				if (cancelled) return;
				phase = 'ready';
			} catch (cause) {
				if (cancelled) return;
				failure = cause instanceof Error ? cause.message : String(cause);
				phase = 'error';
			}
		})();

		return () => {
			cancelled = true;
			// Remove the node rather than calling a method: RufflePlayerHandle
			// exposes no documented teardown, and detaching is what stops the
			// render loop.
			mount?.replaceChildren();
		};
	});
</script>

<svelte:head>
	<title>Juego — Raise the Empires</title>
</svelte:head>

<div class="flex flex-col items-center gap-4">
	<div class="relative" style="width: {PLAYER_WIDTH}px; height: {PLAYER_HEIGHT}px;">
		<!-- Always in the DOM: the player is appended here before it loads. -->
		<div bind:this={mount} class="absolute inset-0"></div>

		{#if phase === 'loading'}
			<div
				class="absolute inset-0 flex items-center justify-center bg-empire-900 text-slate-300"
			>
				<p>Cargando Ruffle…</p>
			</div>
		{:else if phase === 'error'}
			<div
				class="absolute inset-0 flex flex-col items-center justify-center gap-2 border border-red-800 bg-red-950/40 p-8 text-red-200"
			>
				<p class="text-lg font-semibold">No se pudo iniciar el juego</p>
				<p class="text-sm">{failure}</p>
				<p class="text-sm text-red-300/70">
					Revisa que el gateway AMF0 esté corriendo en 127.0.0.1:5005.
				</p>
			</div>
		{/if}
	</div>

	<p class="text-sm text-slate-400">
		zid <code class="text-slate-300">{data.zid ?? '—'}</code>
	</p>
</div>