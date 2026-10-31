/// <reference types="@sveltejs/kit" />
/// <reference no-default-lib="true"/>
/// <reference lib="esnext" />
/// <reference lib="webworker" />

declare const self: ServiceWorkerGlobalScope;

/**
 * Service Worker Purge & Unregister.
 *
 * Removes the Service Worker layer and its IndexedDB CacheStorage overhead so all
 * binary game assets (*.swf, *.png, *.xml) stream directly through the browser's
 * native high-speed C++ disk/memory HTTP cache (max-age=604800, immutable),
 * eliminating the 100+ ms IPC latency and input freezes.
 */
self.addEventListener('install', () => {
	void self.skipWaiting();
});

self.addEventListener('activate', (event) => {
	event.waitUntil(
		caches
			.keys()
			.then((keys) => Promise.all(keys.map((key) => caches.delete(key))))
			.then(() => self.registration.unregister())
			.then(() => self.clients.claim())
	);
});
