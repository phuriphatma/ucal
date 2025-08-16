const CACHE_NAME = "ucal-v1.4.0"; // Fixed average display scrolling
const urlsToCache = [
  "/",
  "/index.html",
  "/calculator.js",
  "/manifest.json",
  "https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.min.css",
  "https://cdn.jsdelivr.net/npm/flatpickr"
];

// Install: cache files
self.addEventListener("install", event => {
  self.skipWaiting();
  event.waitUntil(
    caches.open(CACHE_NAME).then(cache => {
      return cache.addAll(urlsToCache.map(url => {
        // Handle external URLs differently
        if (url.startsWith('http')) {
          return new Request(url, { mode: 'cors' });
        }
        return url;
      }));
    }).catch(err => {
      console.log('Cache install failed:', err);
    })
  );
});

// Activate: clean old caches
self.addEventListener("activate", event => {
  const whitelist = [CACHE_NAME];
  event.waitUntil(
    caches.keys().then(cacheNames =>
      Promise.all(
        cacheNames.map(name => {
          if (!whitelist.includes(name)) {
            return caches.delete(name);
          }
        })
      )
    ).then(() => {
      return self.clients.claim();
    })
  );
});

// Fetch: respond from cache first, then network
self.addEventListener("fetch", event => {
  event.respondWith(
    caches.match(event.request).then(response => {
      // Return cached version or fetch from network
      return response || fetch(event.request).then(fetchResponse => {
        // Don't cache non-successful responses
        if (!fetchResponse || fetchResponse.status !== 200 || fetchResponse.type !== 'basic') {
          return fetchResponse;
        }

        // Clone the response
        const responseToCache = fetchResponse.clone();

        caches.open(CACHE_NAME).then(cache => {
          cache.put(event.request, responseToCache);
        });

        return fetchResponse;
      });
    }).catch(() => {
      // If both cache and network fail, return a basic offline page
      if (event.request.destination === 'document') {
        return caches.match('/index.html');
      }
    })
  );
});
