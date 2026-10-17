const CACHE_NAME = 'mr-fluent-offline-student-v126';
const BRAND_VERSION = 'doma-glass-v7';
const scopeUrl = new URL('./', self.registration.scope);
const indexUrl = new URL('./index.html', self.registration.scope);
const versioned = (path) => new URL(path + '?v=' + BRAND_VERSION, self.registration.scope).href;
const SHELL = [
  scopeUrl.href,
  indexUrl.href,
  versioned('./manifest.webmanifest'),
  versioned('./doma-student-app-icon.svg'),
  versioned('./mrfluent-auth-photo-v113.webp')
];

self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(cache => Promise.all(SHELL.map(async url => {
        try {
          const res = await fetch(url, {cache:'no-store'});
          if (res && res.ok) await cache.put(url, res);
        } catch (_) {}
      })))
      .then(() => self.skipWaiting())
  );
});

self.addEventListener('activate', event => {
  event.waitUntil(
    caches.keys()
      .then(keys => Promise.all(
        keys
          .filter(k => k.startsWith('mr-fluent-offline-') && k !== CACHE_NAME)
          .map(k => caches.delete(k))
      ))
      .then(() => self.clients.claim())
  );
});

self.addEventListener('fetch', event => {
  const req = event.request;
  if (req.method !== 'GET') return;

  event.respondWith((async () => {
    const cached = await caches.match(req);

    if (req.mode === 'navigate') {
      try {
        const fresh = await fetch(req, {cache:'no-store'});
        if (fresh && fresh.ok) {
          const cache = await caches.open(CACHE_NAME);
          cache.put(req, fresh.clone()).catch(() => {});
        }
        return fresh;
      } catch (_) {
        return cached || caches.match(scopeUrl.href) || caches.match(indexUrl.href) || Response.error();
      }
    }

    if (cached) return cached;

    try {
      const res = await fetch(req, {cache:'no-cache'});
      if (res && (res.ok || res.type === 'opaque')) {
        const cache = await caches.open(CACHE_NAME);
        cache.put(req, res.clone()).catch(() => {});
      }
      return res;
    } catch (_) {
      return cached || Response.error();
    }
  })());
});
