const CACHE_NAME = 'doma-admin-offline-v72';
const ADMIN_URL = new URL('./admin.html', self.registration.scope).href;
const MANIFEST_URL = new URL('./admin-manifest.webmanifest?v=doma-admin-glass-v11', self.registration.scope).href;
const APP_ICON_URL = new URL('./doma-admin-app-icon.svg?v=doma-admin-glass-v6', self.registration.scope).href;
const GLASS_THEME_URL = new URL('./doma-platform-purple-gold-glass.css?v=doma-glass-v70', self.registration.scope).href;
const SHELL = [ADMIN_URL, MANIFEST_URL, APP_ICON_URL, GLASS_THEME_URL];

self.addEventListener('message', event => {
  if (event.data && event.data.type === 'SKIP_WAITING') self.skipWaiting();
});

self.addEventListener('install', event => {
  event.waitUntil((async () => {
    const cache = await caches.open(CACHE_NAME);
    // Cache the static admin shell and its offline assets. The document contains
    // application code only; authenticated records are fetched separately from Supabase.
    await Promise.all(SHELL.map(async url => {
      try {
        const response = await fetch(url, {cache:'no-store'});
        const type = response.headers.get('content-type') || '';
        if (response.ok && (url !== ADMIN_URL || /text\/html/i.test(type))) {
          await cache.put(url, response);
        }
      } catch (_) {}
    }));
    await self.skipWaiting();
  })());
});

self.addEventListener('activate', event => {
  event.waitUntil((async () => {
    const keys = await caches.keys();
    await Promise.all(keys
      .filter(key => key.startsWith('doma-admin-offline-') && key !== CACHE_NAME)
      .map(key => caches.delete(key))
    );
    await self.clients.claim();
  })());
});

self.addEventListener('fetch', event => {
  const req = event.request;
  if (req.method !== 'GET') return;

  const url = new URL(req.url);

  // Leave Supabase and all third-party requests completely outside this worker.
  if (url.origin !== self.location.origin) return;
  const isAdminDocument = url.pathname.endsWith('/admin.html');

  // Admin HTML is network-first: always prefer the deployed document. Use the
  // last verified shell only when the network is unavailable.
  if (isAdminDocument) {
    const cachePromise = caches.open(CACHE_NAME);
    event.respondWith((async () => {
      try {
        const response = await fetch(req, {cache:'no-store'});
        const type = response.headers.get('content-type') || '';
        if (!response.ok || !/text\\/html/i.test(type)) {
          throw new Error('Admin document refresh failed.');
        }
        const cache = await cachePromise;
        await cache.put(ADMIN_URL, response.clone()).catch(() => {});
        return response;
      } catch (_) {
        const cache = await cachePromise;
        const cached = await cache.match(ADMIN_URL);
        if (cached && cached.ok) return cached;
        return new Response(
          '<!doctype html><html lang="en"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>DOMA Admin offline</title><body style="font-family:Arial;background:#100b0d;color:#fff;padding:24px"><h2>DOMA Admin is offline</h2><p>Reconnect to the internet and refresh this page to load the latest admin version.</p></body></html>',
          {headers:{'Content-Type':'text/html; charset=utf-8','Cache-Control':'no-store'}}
        );
      }
    })());
    return;
  }

  const cachePromise = caches.open(CACHE_NAME);
  const refreshPromise = cachePromise.then(async cache => {
    const response = await fetch(req, {cache:'no-store'});
    if (response && (response.ok || response.type === 'opaque') && SHELL.includes(req.url)) {
      await cache.put(req, response.clone()).catch(() => {});
    }
    return response;
  });
  event.waitUntil(refreshPromise.then(() => undefined).catch(() => undefined));
  event.respondWith(cachePromise.then(cache => cache.match(req)).then(cached => {
    if (cached) return cached;
    return refreshPromise.catch(() => Response.error());
  }));
});
