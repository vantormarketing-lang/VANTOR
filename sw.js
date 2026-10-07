const CACHE_NAME = 'mr-fluent-offline-v1';

const scopeUrl = new URL('./', self.registration.scope);

const SHELL = [
  scopeUrl.href,
  new URL('./index.html', self.registration.scope).href,
  new URL('./manifest.webmanifest', self.registration.scope).href,
  new URL('./mr-fluent-icon-192.png', self.registration.scope).href,
  new URL('./mr-fluent-icon-512.png', self.registration.scope).href
];

self.addEventListener('install', event => {
  event.waitUntil(
    caches
      .open(CACHE_NAME)
      .then(cache => cache.addAll(SHELL))
      .then(() => self.skipWaiting())
  );
});

self.addEventListener('activate', event => {
  event.waitUntil(
    caches
      .keys()
      .then(keys =>
        Promise.all(
          keys
            .filter(
              key =>
                key !== CACHE_NAME &&
                key.startsWith('mr-fluent-offline-')
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
        const res = await fetch(req);

        const copyable =
          res && (res.ok || res.type === 'opaque');

        if (copyable) {
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
