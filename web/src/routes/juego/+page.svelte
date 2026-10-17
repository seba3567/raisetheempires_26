<script lang="ts">
	/**
	 * The player page.
	 *
	 * The SWF is embedded in this page rather than behind a separate document: no
	 * iframe, no second origin, and the site's own chrome stays around it. The
	 * player options are the ones already proven in templates/ruffle.html.
	 *
	 * This comment has to live inside the script block. At the top level of a
	 * Svelte component, `/** ... *\/` is not a comment -- Svelte reads it as
	 * markup text and renders the whole thing on the page, above the player.
	 */
	import { onMount } from 'svelte';
	import {
		PLAYER_BACKGROUND,
		PLAYER_HEIGHT,
		PLAYER_WIDTH,
		SWF_PATH,
		loadRuffle,
		type RufflePlayerHandle
	} from '#lib/ruffle';
	import { SNAPI_ENDPOINT, installSnapiBridge } from '#lib/snapi';

	let { data } = $props();

	let mount = $state<HTMLDivElement | null>(null);
	// Not `state`: a variable named `state` shadows the `$state` rune for the
	// whole scope and the compiler rejects it.
	//
	// Starts at 'idle', not 'loading', on purpose. See start().
	let phase = $state<'idle' | 'loading' | 'ready' | 'error'>('idle');
	let failure = $state<string | null>(null);

	/** Guards against a double click starting two players. */
	let started = false;

	async function startPlayer() {
		try {
			await loadRuffle();

			/*
			 * Install the ExternalInterface bridge *before* loading the SWF.
			 *
			 * The client calls getUserInfo() during setup and dereferences the
			 * result without checking it, so loading first and bridging after
			 * kills the game with "Error #1009 ... accessing field: zid" before
			 * anything is playable. Fetched here rather than server-side so the
			 * request goes through the proxy exactly like the player does, and
			 * arrives with this browser's cookies and the account's zid.
			 */
			const social = await fetch(SNAPI_ENDPOINT, { credentials: 'same-origin' });
			if (!social.ok) {
				throw new Error(`${SNAPI_ENDPOINT} respondió ${social.status}`);
			}
			installSnapiBridge(await social.json());

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
			 * Ruffle calls play() on a connected element. Loading into a detached
			 * node leaves it suspended, and the console fills with "Ignoring
			 * attempt to play a disconnected or suspended Ruffle element" while
			 * the game silently never starts. The mount point is rendered
			 * unconditionally for the same reason: behind an {#if} it would not
			 * exist yet at this point.
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

			phase = 'ready';
		} catch (cause) {
			failure = cause instanceof Error ? cause.message : String(cause);
			phase = 'error';
		}
	}

	/**
	 * Start on a click, not on mount.
	 *
	 * Chrome's autoplay policy refuses to start an AudioContext without a user
	 * gesture, and Ruffle creates its audio context while the SWF boots. Loading
	 * from onMount therefore gave a game that ran silent and logged
	 *
	 *   The AudioContext was not allowed to start. It must be resumed (or
	 *   created) after a user gesture on the page.
	 *
	 * once per sound, each with a full Rust stack trace.
	 *
	 * One click fixes it at the root: Chrome grants the document *sticky
	 * activation* after any interaction, so the AudioContext Ruffle creates
	 * afterwards is allowed to start and the error never happens at all.
	 * Resuming the context afterwards would be a patch over an error already
	 * thrown, and would still leave the game silent until the player happened to
	 * click something.
	 */
	function start() {
		if (started) return;
		started = true;
		phase = 'loading';
		void startPlayer();
	}

	onMount(() => {
		return () => {
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

		{#if phase === 'idle'}
			<div
				class="absolute inset-0 flex flex-col items-center justify-center gap-4 bg-empire-900 text-slate-300"
			>
				<p class="text-lg font-semibold text-slate-100">Empires &amp; Allies</p>
				<button
					type="button"
					onclick={start}
					class="rounded bg-gold-500 px-6 py-3 text-lg font-semibold text-empire-950 hover:bg-gold-400"
				>
					Jugar
				</button>
				<p class="max-w-md px-6 text-center text-sm text-slate-400">
					El navegador no deja sonar el juego hasta que interactúas con la página, así que hace
					falta este clic para que se escuche.
				</p>
			</div>
		{:else if phase === 'loading'}
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