const CACHE_NAME = 'doma-admin-offline-v35';
const ADMIN_URL = new URL('./admin.html', self.registration.scope).href;
const MANIFEST_URL = new URL('./admin-manifest.webmanifest?v=doma-admin-v25', self.registration.scope).href;
const ICON64_URL = new URL('./doma-leaf-book-icon.svg?v=doma-admin-v25', self.registration.scope).href;
const ICON192_URL = new URL('./mr-fluent-icon-192.png?v=18', self.registration.scope).href;
const SHELL = [ADMIN_URL, MANIFEST_URL, ICON64_URL, ICON192_URL];

self.addEventListener('message', event => {
  if (event.data && event.data.type === 'SKIP_WAITING') self.skipWaiting();
});

self.addEventListener('install', event => {
  event.waitUntil((async () => {
    const cache = await caches.open(CACHE_NAME);
    // Cache only offline-support assets. The HTML shell is intentionally never cached.
    await Promise.all(SHELL.filter(url => url !== ADMIN_URL).map(async url => {
      try {
        const response = await fetch(url, {cache:'no-store'});
        if (response.ok) await cache.put(url, response);
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
  const isAdminDocument = req.mode === 'navigate' ||
    (url.origin === self.location.origin && url.pathname.endsWith('/admin.html'));

  // Always fetch the admin document from the server, including on ordinary refresh.
  // Never allow a cached HTML response to hide the latest deployed admin changes.
  if (isAdminDocument) {
    event.respondWith(fetch(req, {cache:'no-store'}).catch(async () => {
      return new Response(
        '<!doctype html><html lang="en"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>DOMA Admin offline</title><body style="font-family:Arial;background:#100b0d;color:#fff;padding:24px"><h2>DOMA Admin is offline</h2><p>Reconnect to the internet and refresh this page to load the latest admin version.</p></body></html>',
        {headers:{'Content-Type':'text/html; charset=utf-8','Cache-Control':'no-store'}}
      );
    }));
    return;
  }

  event.respondWith((async () => {
    const cached = await caches.match(req);
    if (cached) return cached;
    try {
      const response = await fetch(req, {cache:'no-store'});
      if (response && (response.ok || response.type === 'opaque')) {
        // Cache only the known offline shell assets, never arbitrary app responses.
        if (SHELL.includes(req.url)) {
          const cache = await caches.open(CACHE_NAME);
          cache.put(req, response.clone()).catch(() => {});
        }
      }
      return response;
    } catch (_) {
      return cached || Response.error();
    }
  })());
});
