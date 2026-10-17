<script lang="ts">
	import { page } from '$app/state';
</script>

<div class="mx-auto max-w-lg py-16 text-center">
	<h1 class="text-6xl font-bold text-gold-400">{page.status}</h1>
	<p class="mt-4 text-lg text-slate-300">
		{#if page.status === 403}
			Sin permisos. Esta sección es solo para administradores del servidor.
		{:else if page.status === 404}
			No encontramos esa página.
		{:else if page.status === 501}
			Este despliegue solo proxea HTTP.
		{:else}
			{page.error?.message ?? 'Algo salió mal.'}
		{/if}
	</p>
	<a href="/" class="mt-8 inline-block text-gold-400 hover:underline">Volver al inicio</a>
</div>