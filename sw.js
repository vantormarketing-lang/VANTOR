const CACHE_NAME = 'mr-fluent-offline-student-v174';
const BRAND_VERSION = 'doma-glass-v17';
const scopeUrl = new URL('./', self.registration.scope);
const indexUrl = new URL('./index.html', self.registration.scope);
const appStartUrl = new URL('./?doma-app=student&launch=v174', self.registration.scope);
const versioned = (path) => new URL(path + '?v=' + BRAND_VERSION, self.registration.scope).href;
const kidsHubUrl = new URL('./MR_FLUENT_KIDS_HUB.html', self.registration.scope);
const kidsYoungerUrl = new URL('./MR_FLUENT_KIDS_YOUNGER.html', self.registration.scope);
const kidsOlderUrl = new URL('./MR_FLUENT_KIDS_OLDER.html', self.registration.scope);
const kidsA1Url = new URL('./MR_FLUENT_KIDS_A1.html', self.registration.scope);
const kidsA2Url = new URL('./?kids=a2', self.registration.scope);
const kidsC2Url = new URL('./?kids=c2', self.registration.scope);
const kidsReviewUrl = new URL('./?kids=review', self.registration.scope);
const kidsB2Url = new URL('./?kids=b2', self.registration.scope);
const kidsComingSoonUrl = new URL('./MR_FLUENT_KIDS_COMING_SOON.html', self.registration.scope);
const SHELL = [
  scopeUrl.href,
  indexUrl.href,
  appStartUrl.href,
  kidsHubUrl.href,
  kidsYoungerUrl.href,
  kidsOlderUrl.href,
  kidsA1Url.href,
  kidsA2Url.href,
  kidsB2Url.href,
  kidsC2Url.href,
  kidsReviewUrl.href,
  kidsComingSoonUrl.href,
  versioned('./manifest.webmanifest'),
  versioned('./doma-student-app-icon.svg'),
  versioned('./mrfluent-auth-photo-v113.webp')
];

async function hasUsableShell(cache) {
  const rootResponse = await cache.match(scopeUrl.href);
  if (rootResponse && rootResponse.ok) return true;
  const indexResponse = await cache.match(indexUrl.href);
  return Boolean(indexResponse && indexResponse.ok);
}

async function navigationFallback(cachedRequest) {
  // Only serve successful documents from cache; never turn a cached error page
  // into the app's offline launch screen.
  if (cachedRequest && cachedRequest.ok) return cachedRequest;

  // Await each lookup so the index fallback is tried if the root URL is missing.
  const rootFallback = await caches.match(scopeUrl.href);
  if (rootFallback && rootFallback.ok) return rootFallback;

  const appStartFallback = await caches.match(appStartUrl.href);
  if (appStartFallback && appStartFallback.ok) return appStartFallback;

  const indexFallback = await caches.match(indexUrl.href);
  if (indexFallback && indexFallback.ok) return indexFallback;

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
          return fresh;
        }

        // A 404/500 is not a usable app document. Fall back to a cached shell.
        return navigationFallback(cached);
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