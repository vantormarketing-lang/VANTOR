const CACHE_NAME = 'mr-fluent-offline-v2';

const scopeUrl = new URL('./', self.registration.scope);
const indexUrl = new URL('./index.html', self.registration.scope);

const SHELL = [
  scopeUrl.href,
  indexUrl.href,
  new URL('./manifest.webmanifest', self.registration.scope).href,
  new URL('./mr-fluent-icon-192.png', self.registration.scope).href,
  new URL('./mr-fluent-icon-512.png', self.registration.scope).href
];

self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(cache =>
        Promise.all(
          SHELL.map(async url => {
            try {
              const res = await fetch(url, { cache: 'no-store' });

              if (res && res.ok) {
                await cache.put(url, res);
              }
            } catch (_) {}
          })
        )
      )
      .then(() => self.skipWaiting())
  );
});

self.addEventListener('activate', event => {
  event.waitUntil(
    caches.keys()
      .then(keys =>
        Promise.all(
          keys
            .filter(
              key =>
                key.startsWith('mr-fluent-offline-') &&
                key !== CACHE_NAME
            )
            .map(key => caches.delete(key))
        )
      )
      .then(() => self.clients.claim())
  );
});

self.addEventListener('fetch', event => {
  const req = event.request;

  if (req.method !== 'GET') return;

  event.respondWith(
    (async () => {
      const cached = await caches.match(req);

      // Navigation requests:
      // Try the live page first, then fall back to cached app shell.
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
            caches.match(scopeUrl.href) ||
            caches.match(indexUrl.href) ||
            Response.error()
          );
        }
      }

      // Return cached resource immediately when available.
      if (cached) {
        return cached;
      }

      // Otherwise try the network and cache the successful response.
      try {
        const res = await fetch(req);

        if (
          res &&
          (res.ok || res.type === 'opaque')
        ) {
          const cache = await caches.open(CACHE_NAME);
          cache.put(req, res.clone()).catch(() => {});
        }

        return res;
      } catch (_) {
        return cached || Response.error();
      }
    })()
  );
});
