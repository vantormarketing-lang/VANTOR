const CACHE_NAME = 'doma-admin-offline-v8';

const ADMIN_URL = new URL('./admin.html', self.registration.scope).href;
const ADMIN_URL_PREFIX = ADMIN_URL.split('?')[0];
const MANIFEST_URL = new URL(
  './admin-manifest.webmanifest?v=8',
  self.registration.scope
).href;
const ICON192_URL = new URL(
  './mr-fluent-icon-192.png?v=8',
  self.registration.scope
).href;
const ICON512_URL = new URL(
  './mr-fluent-icon-512.png?v=8',
  self.registration.scope
).href;

const SHELL = [
  ADMIN_URL,
  MANIFEST_URL,
  ICON192_URL,
  ICON512_URL
];

self.addEventListener('install', event => {
  event.waitUntil(
    (async () => {
      const cache = await caches.open(CACHE_NAME);

      await Promise.all(
        SHELL.map(async url => {
          try {
            const response = await fetch(url, {
              cache: 'no-store'
            });

            if (response.ok) {
              await cache.put(url, response);
            }
          } catch (_) {}
        })
      );

      await self.skipWaiting();
    })()
  );
});

self.addEventListener('activate', event => {
  event.waitUntil(
    (async () => {
      const keys = await caches.keys();

      await Promise.all(
        keys
          .filter(
            key =>
              key.startsWith('doma-admin-offline-') &&
              key !== CACHE_NAME
          )
          .map(key => caches.delete(key))
      );

      await self.clients.claim();
    })()
  );
});

self.addEventListener('fetch', event => {
  const req = event.request;

  if (req.method !== 'GET') return;

  event.respondWith(
    (async () => {
      const cached = await caches.match(req);

      if (req.mode === 'navigate') {
        try {
          const fresh = await fetch(req, {
            cache: 'no-store'
          });

          if (fresh && fresh.ok) {
            const cache = await caches.open(CACHE_NAME);
            cache.put(req, fresh.clone()).catch(() => {});
          }

          return fresh;
        } catch (_) {
          return (
            cached ||
            caches.match(ADMIN_URL) ||
            caches.match(ADMIN_URL_PREFIX) ||
            Response.error()
          );
        }
      }

      if (cached) {
        return cached;
      }

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
    })()
  );
});
