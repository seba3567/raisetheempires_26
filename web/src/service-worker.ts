/// <reference types="@sveltejs/kit" />
/// <reference no-default-lib="true"/>
/// <reference lib="esnext" />
/// <reference lib="webworker" />

const sw = self as unknown as ServiceWorkerGlobalScope;

const CACHE_NAME = 'rte-game-assets-v1';

// File extensions and URL patterns for game static assets
const GAME_ASSET_EXTENSIONS = /\.(swf|png|jpg|jpeg|gif|mp3|wav|ogg|wasm)(\?.*)?$/i;

sw.addEventListener('install', (event) => {
	// Skip waiting so the service worker activates immediately
	event.waitUntil(sw.skipWaiting());
});

sw.addEventListener('activate', (event) => {
	// Claim clients immediately
	event.waitUntil(
		Promise.all([
			sw.clients.claim(),
			// Clean up old caches
			caches.keys().then((keys) =>
				Promise.all(
					keys.map((key) => {
						if (key !== CACHE_NAME) {
							return caches.delete(key);
						}
					})
				)
			)
		])
	);
});

sw.addEventListener('fetch', (event) => {
	const request = event.request;
	const url = new URL(request.url);

	// Only intercept GET requests
	if (request.method !== 'GET') return;

	// Do NOT cache API/Gateway/AMF requests, player state, auth, or session calls
	if (
		url.pathname.includes('/flashservices/') ||
		url.pathname.includes('/player.json') ||
		url.pathname.includes('/snapi.json') ||
		url.pathname.startsWith('/admin') ||
		url.pathname.startsWith('/cuenta') ||
		url.pathname.startsWith('/salir') ||
		url.pathname.startsWith('/entrar') ||
		url.pathname.startsWith('/registro') ||
		url.pathname.startsWith('/patch/')
	) {
		return;
	}

	// Intercept game binary assets (SWF, Ruffle wasm, game textures, sounds, sprites)
	const isGameAsset =
		url.pathname.startsWith('/files/') ||
		url.pathname.startsWith('/ruffle/') ||
		url.pathname.startsWith('/img/') ||
		GAME_ASSET_EXTENSIONS.test(url.pathname);

	if (isGameAsset) {
		event.respondWith(
			caches.open(CACHE_NAME).then(async (cache) => {
				const cachedResponse = await cache.match(request);
				if (cachedResponse) {
					return cachedResponse;
				}

				try {
					const networkResponse = await fetch(request);
					// Cache successful static asset responses
					if (networkResponse.ok && (networkResponse.type === 'basic' || networkResponse.type === 'cors')) {
						cache.put(request, networkResponse.clone());
					}
					return networkResponse;
				} catch (error) {
					// Fallback to cache if network fails
					if (cachedResponse) return cachedResponse;
					return new Response('Asset not available offline', {
						status: 503,
						statusText: 'Service Unavailable',
						headers: { 'Content-Type': 'text/plain' }
					});
				}
			})
		);
	}
});
