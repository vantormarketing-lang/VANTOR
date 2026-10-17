const CACHE_NAME = 'mr-fluent-offline-student-v128';
const BRAND_VERSION = 'doma-glass-v8';
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

async function hasUsableShell(cache) {
  const rootResponse = await cache.match(scopeUrl.href);
  if (rootResponse) return true;
  const indexResponse = await cache.match(indexUrl.href);
  return Boolean(indexResponse);
}

async function navigationFallback(cachedRequest) {
  if (cachedRequest) return cachedRequest;

  // Await each lookup so the index fallback is tried if the root URL is missing.
  const rootFallback = await caches.match(scopeUrl.href);
  if (rootFallback) return rootFallback;

  const indexFallback = await caches.match(indexUrl.href);
  if (indexFallback) return indexFallback;

  return Response.error();
}

self.addEventListener('install', event => {
  event.waitUntil((async () => {
    const cache = await caches.open(CACHE_NAME);

    // Cache each shell asset independently. An unreachable optional asset must not
    // prevent the app shell from being saved.
    await Promise.all(SHELL.map(async url => {
      try {
        const response = await fetch(url, {cache:'no-store'});
        if (response && response.ok) await cache.put(url, response);
      } catch (_) {}
    }));

    // Only take over immediately when the new version contains a usable HTML shell.
    // If the device is offline, keep the old cache available as a fallback.
    if (await hasUsableShell(cache)) await self.skipWaiting();
  })());
});

self.addEventListener('activate', event => {
  event.waitUntil((async () => {
    const cache = await caches.open(CACHE_NAME);
    const shellReady = await hasUsableShell(cache);

    // Never delete the last known-good app cache unless this version has its own
    // root or index document cached successfully.
    if (shellReady) {
      const keys = await caches.keys();
      await Promise.all(keys
        .filter(key => key.startsWith('mr-fluent-offline-') && key !== CACHE_NAME)
        .map(key => caches.delete(key))
      );
    }

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
        const fresh = await fetch(req, {cache:'no-store'});
        if (fresh && fresh.ok) {
          const cache = await caches.open(CACHE_NAME);
          cache.put(req, fresh.clone()).catch(() => {});
        }
        return fresh;
      } catch (_) {
        return navigationFallback(cached);
      }
    }

    if (cached) return cached;

    try {
      const response = await fetch(req, {cache:'no-cache'});
      if (response && (response.ok || response.type === 'opaque')) {
        const cache = await caches.open(CACHE_NAME);
        cache.put(req, response.clone()).catch(() => {});
      }
      return response;
    } catch (_) {
      return cached || Response.error();
    }
  })());
});