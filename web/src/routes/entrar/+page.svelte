<script lang="ts">
	import { enhance } from '$app/forms';

	let { form } = $props();
</script>

<svelte:head>
	<title>Entrar — Raise the Empires</title>
</svelte:head>

<div class="max-w-sm py-8">
	<h1 class="text-3xl font-bold">Entrar</h1>

	{#if form?.error}
		<p class="mt-4 rounded-lg border border-red-900 bg-red-950/50 px-4 py-3 text-red-200">
			{form.error}
		</p>
	{/if}

	<form method="POST" use:enhance class="mt-6 panel">
		<label for="username" class="block text-sm text-slate-400">Usuario</label>
		<input
			id="username"
			name="username"
			autocomplete="username"
			required
			minlength="3"
			maxlength="24"
			value={form?.username ?? ''}
			class="field mt-1"
		/>

		<label for="password" class="mt-4 block text-sm text-slate-400">Contraseña</label>
		<input
			id="password"
			name="password"
			type="password"
			autocomplete="current-password"
			required
			class="field mt-1"
		/>

		<button type="submit" class="btn-primary mt-6 w-full">
			Entrar
		</button>
	</form>

	<p class="mt-4 text-sm text-slate-400">
		¿No tienes cuenta? <a href="/registro" class="text-gold-400 hover:underline">Crea una</a>.
	</p>
</div>