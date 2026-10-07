const CACHE_NAME = 'mr-fluent-offline-v3';

const SHELL_FILES = [
  './',
  './index.html',
  './manifest.webmanifest',
  './mr-fluent-icon-192.png',
  './mr-fluent-icon-512.png'
];

self.addEventListener('install', event => {
  event.waitUntil((async () => {
    const cache = await caches.open(CACHE_NAME);

    await Promise.allSettled(
      SHELL_FILES.map(async url => {
        try {
          const response = await fetch(url, { cache: 'no-cache' });
          if (response.ok) {
            await cache.put(url, response);
          }
        } catch (_) {}
      })
    );

    await self.skipWaiting();
  })());
});

self.addEventListener('activate', event => {
  event.waitUntil((async () => {
    const keys = await caches.keys();

    await Promise.all(
      keys
        .filter(
          key =>
            key.startsWith('mr-fluent-offline-') &&
            key !== CACHE_NAME
        )
        .map(key => caches.delete(key))
    );

    await self.clients.claim();
  })());
});

self.addEventListener('fetch', event => {
  const req = event.request;

  if (req.method !== 'GET') return;

  event.respondWith((async () => {
    const cached = await caches.match(req);

    if (req.mode === 'navigate') {
      try {
        const fresh = await fetch(req);

        if (fresh && fresh.ok) {
          const cache = await caches.open(CACHE_NAME);
          cache.put(req, fresh.clone()).catch(() => {});
        }

        return fresh;
      } catch (_) {
        return (
          cached ||
          caches.match('./index.html') ||
          Response.error()
        );
      }
    }

    if (cached) return cached;

    try {
      const response = await fetch(req);

      if (
        response &&
        (response.ok || response.type === 'opaque')
      ) {
        const cache = await caches.open(CACHE_NAME);
        cache.put(req, response.clone()).catch(() => {});
      }

      return response;
    } catch (_) {
      return cached || Response.error();
    }
  })());
});
