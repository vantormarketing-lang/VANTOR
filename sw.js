const CACHE_NAME = 'mr-fluent-offline-v2';

const scopeUrl = new URL('./', self.registration.scope);

const SHELL = [
  scopeUrl.href,
  new URL('./index.html', self.registration.scope).href,
  new URL('./manifest.webmanifest', self.registration.scope).href,
  new URL('./mr-fluent-icon-192(1).png', self.registration.scope).href,
  new URL('./mr-fluent-icon-512(1).png', self.registration.scope).href
];

self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(cache => cache.addAll(SHELL))
      .then(() => self.skipWaiting())
  );
});

self.addEventListener('activate', event => {
  event.waitUntil(
    caches.keys()
      .then(keys =>
        Promise.all(
          keys
            .filter(key =>
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

      if (req.mode === 'navigate') {
        try {
          const fresh = await fetch(req);

          const cache = await caches.open(CACHE_NAME);
          cache.put(req, fresh.clone()).catch(() => {});

          return fresh;
        } catch (_) {
          return (
            cached ||
            caches.match(scopeUrl.href) ||
            caches.match(
              new URL('./index.html', self.registration.scope).href
            )
          );
        }
      }

      if (cached) return cached;

      try {
        const response = await fetch(req);

        if (response.ok || response.type === 'opaque') {
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
