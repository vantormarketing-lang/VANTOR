const CACHE_NAME = 'mr-fluent-offline-student-v203';
const BRAND_VERSION = 'doma-glass-v40';
const scopeUrl = new URL('./', self.registration.scope);
const indexUrl = new URL('./index.html', self.registration.scope);
const appStartUrl = new URL('./?doma-app=student&launch=v203', self.registration.scope);
const versioned = (path) => new URL(path + '?v=' + BRAND_VERSION, self.registration.scope).href;
const kidsHubUrl = new URL('./MR_FLUENT_KIDS_HUB.html', self.registration.scope);
const kidsYoungerUrl = new URL('./MR_FLUENT_KIDS_YOUNGER.html', self.registration.scope);
const kidsOlderUrl = new URL('./MR_FLUENT_KIDS_OLDER.html', self.registration.scope);
const kidsA1Url = new URL('./MR_FLUENT_KIDS_A1.html', self.registration.scope);
const kidsEntryRouteUrl = new URL('./?kids=entry', self.registration.scope);
const kidsHubRouteUrl = new URL('./?kids=hub', self.registration.scope);
const kidsYoungerRouteUrl = new URL('./?kids=younger', self.registration.scope);
const kidsOlderRouteUrl = new URL('./?kids=older', self.registration.scope);
const kidsSubscribeRouteUrl = new URL('./?kids=subscribe', self.registration.scope);
const kidsA1RouteUrl = new URL('./?kids=a1', self.registration.scope);
const kidsA2Url = new URL('./?kids=a2', self.registration.scope);
const kidsB1RouteUrl = new URL('./?kids=b1', self.registration.scope);
const kidsB2Url = new URL('./?kids=b2', self.registration.scope);
const kidsC1RouteUrl = new URL('./?kids=c1', self.registration.scope);
const kidsC2RouteUrl = new URL('./?kids=c2', self.registration.scope);
const kidsReviewUrl = new URL('./?kids=review', self.registration.scope);
const kidsComingSoonUrl = new URL('./MR_FLUENT_KIDS_COMING_SOON.html', self.registration.scope);
const englishLevelPages = [
  new URL('./MR_FLUENT_A1_COURSE.html', self.registration.scope),
  new URL('./MR_FLUENT_A2_COURSE.html', self.registration.scope),
  new URL('./MR_FLUENT_B1_COURSE.html', self.registration.scope),
  new URL('./MR_FLUENT_B2_COURSE.html', self.registration.scope),
  new URL('./MR_FLUENT_C1_COURSE.html', self.registration.scope),
  new URL('./MR_FLUENT_C2_COURSE.html', self.registration.scope)
];
const SHELL = [
  scopeUrl.href,
  indexUrl.href,
  appStartUrl.href,
  kidsHubUrl.href,
  kidsYoungerUrl.href,
  kidsOlderUrl.href,
  kidsA1Url.href,
  kidsEntryRouteUrl.href,
  kidsHubRouteUrl.href,
  kidsYoungerRouteUrl.href,
  kidsOlderRouteUrl.href,
  kidsSubscribeRouteUrl.href,
  kidsA1RouteUrl.href,
  kidsA2Url.href,
  kidsB1RouteUrl.href,
  kidsB2Url.href,
  kidsC1RouteUrl.href,
  kidsC2RouteUrl.href,
  kidsReviewUrl.href,
  kidsComingSoonUrl.href,
  ...englishLevelPages.map(url => url.href),
  versioned('./manifest.webmanifest'),
  versioned('./doma-student-app-icon.svg'),
  versioned('./mrfluent-auth-photo-v113.webp')
];

function normalizeShellUrl(input) {
  const url = new URL(input, self.registration.scope);
  const rootPath = new URL(self.registration.scope).pathname;
  const indexPath = new URL('./index.html', self.registration.scope).pathname;

  // The root and index route serve the same app shell. Collapse query routes to
  // one cache entry so a large single-page app is not copied many times offline.
  if (url.origin === scopeUrl.origin && (url.pathname === rootPath || url.pathname === indexPath)) {
    url.pathname = rootPath;
    url.search = '';
    url.hash = '';
    return url.href;
  }

  // Query parameters drive client-side routing, but are not needed in a cached
  // document. Never persist route tokens or query-string data in document caches.
  if (url.origin === scopeUrl.origin && url.pathname.toLowerCase().endsWith('.html')) {
    url.search = '';
    url.hash = '';
  }
  return url.href;
}

const SHELL_CACHE_URLS = [...new Set(SHELL.map(normalizeShellUrl))];
const SHELL_CACHE_URL_SET = new Set(SHELL_CACHE_URLS);
const SHELL_DOCUMENT_PATHS = new Set([
  ...SHELL_CACHE_URLS.map(value => new URL(value).pathname),
  scopeUrl.pathname,
  indexUrl.pathname
]);

function hasSensitiveQuery(url) {
  return [...url.searchParams.keys()].some(key =>
    /^(?:access_token|refresh_token|token|code|state|signature|sig|password|email|otp|api_key)$/i.test(key)
  );
}

function isSafeSameOriginUrl(url) {
  if (url.origin !== self.location.origin) return false;
  if (hasSensitiveQuery(url)) return false;
  return !/^\/(?:rest\/v1|auth\/v1|storage\/v1|functions\/v1|realtime\/v1|api|rpc)(?:\/|$)/i.test(url.pathname);
}

function isCacheableStaticAssetUrl(url) {
  if (!isSafeSameOriginUrl(url)) return false;

  // Keep the runtime cache for small, same-origin presentation assets only.
  // Do not cache API payloads, documents, recordings, audio, or video files.
  if (!/\.(?:css|m?js|svg|png|jpe?g|webp|gif|avif|ico|woff2?|ttf|otf|webmanifest)$/i.test(url.pathname)) {
    return false;
  }

  // Versioned assets are safe to key by URL; unknown query parameters may carry
  // user/session data, so they are deliberately excluded from the runtime cache.
  for (const key of url.searchParams.keys()) {
    if (!/^(?:v|version|ver)$/i.test(key)) return false;
  }
  return true;
}

function isShellDocument(url) {
  return isSafeSameOriginUrl(url) && SHELL_DOCUMENT_PATHS.has(url.pathname);
}

async function hasUsableShell(cache) {
  const rootResponse = await cache.match(scopeUrl.href);
  if (rootResponse && rootResponse.ok) return true;
  const indexResponse = await cache.match(normalizeShellUrl(indexUrl.href));
  return Boolean(indexResponse && indexResponse.ok);
}

async function navigationFallback(requestedUrl) {
  const cache = await caches.open(CACHE_NAME);
  if (requestedUrl) {
    const requested = await cache.match(normalizeShellUrl(requestedUrl));
    if (requested && requested.ok) return requested;
  }

  // The index/root fallback is safe because only known static shell documents
  // are stored here. The original browser URL (including route query) is kept.
  const rootFallback = await cache.match(scopeUrl.href);
  if (rootFallback && rootFallback.ok) return rootFallback;

  const indexFallback = await cache.match(normalizeShellUrl(indexUrl.href));
  if (indexFallback && indexFallback.ok) return indexFallback;

  return Response.error();
}

self.addEventListener('install', event => {
  event.waitUntil((async () => {
    const cache = await caches.open(CACHE_NAME);

    // Normalize duplicate root/index route variants to a single document, then
    // cache each known shell item independently so one failed asset can't block
    // the full install.
    await Promise.all(SHELL_CACHE_URLS.map(async url => {
      try {
        const parsed = new URL(url);
        if (parsed.origin !== self.location.origin) return;
        const response = await fetch(url, {cache:'no-store'});
        if (!response || !response.ok) return;

        if (SHELL_DOCUMENT_PATHS.has(parsed.pathname) &&
            /text\/html/i.test(response.headers.get('content-type') || '')) {
          await cache.put(url, response.clone());
        } else if (isCacheableStaticAssetUrl(parsed)) {
          await cache.put(url, response.clone());
        }
      } catch (_) {}
    }));

    // Only take over immediately when the new version contains a usable shell.
    if (await hasUsableShell(cache)) await self.skipWaiting();
  })());
});

self.addEventListener('activate', event => {
  event.waitUntil((async () => {
    const cache = await caches.open(CACHE_NAME);

    // Clean up entries created by the prior cache-first worker, including
    // previously cached dynamic/API responses and duplicate query-route copies.
    const currentKeys = await cache.keys();
    await Promise.all(currentKeys.map(async request => {
      const url = new URL(request.url);
      const canonicalUrl = normalizeShellUrl(url.href);
      const keep = SHELL_CACHE_URL_SET.has(request.url) ||
        (canonicalUrl === request.url && isCacheableStaticAssetUrl(url));
      if (!keep) await cache.delete(request);
    }));

    const shellReady = await hasUsableShell(cache);
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

  const url = new URL(req.url);

  // This worker must never intercept cross-origin requests such as Supabase
  // Auth, REST, Storage, Edge Functions, or third-party CDNs.
  if (url.origin !== self.location.origin) return;

  // Network-first for known static documents prevents installed PWAs from
  // opening stale HTML after a deploy. Cache only successful document responses.
  if (req.mode === 'navigate' && isShellDocument(url) && !hasSensitiveQuery(url)) {
    event.respondWith((async () => {
      try {
        const fresh = await fetch(req, {cache:'no-store'});
        const contentType = fresh?.headers?.get('content-type') || '';
        if (fresh && fresh.ok && /text\/html/i.test(contentType)) {
          const cache = await caches.open(CACHE_NAME);
          await cache.put(normalizeShellUrl(url.href), fresh.clone());
          return fresh;
        }
        return await navigationFallback(url.href);
      } catch (_) {
        return await navigationFallback(url.href);
      }
    })());
    return;
  }

  // Dynamic same-origin requests and URLs with sensitive query parameters are
  // network-only. No stale profile, subscription, quiz, or request data is cached.
  if (!isCacheableStaticAssetUrl(url)) {
    event.respondWith(fetch(req, {cache:'no-store'}));
    return;
  }

  // Network-first for static assets: users get current assets when online and a
  // cache fallback only when the network is unavailable.
  event.respondWith((async () => {
    const cache = await caches.open(CACHE_NAME);
    try {
      const fresh = await fetch(req, {cache:'no-cache'});
      if (fresh && fresh.ok && fresh.type !== 'opaque') {
        await cache.put(req, fresh.clone()).catch(() => {});
        return fresh;
      }
      const cached = await cache.match(req);
      return cached || fresh || Response.error();
    } catch (_) {
      return (await cache.match(req)) || Response.error();
    }
  })());
});
