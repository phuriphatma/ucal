const CACHE_NAME = "ucal-v3.6.0"; // Fixed PWA redirect for average-calculator.html - preventing redirect to avg-standalone.html
const urlsToCache = [
  "./",
  "./index.html",
  "./ga.html",
  "./avg.html",
  "./ga-calculator.html",
  "./average-calculator.html", 
  "./settings.html",
  "./ga-standalone.html",
  "./avg-standalone.html",
  "./average.html",
  "./calculator.js",
  "./manifest.json",
  "./manifest-ga.json",
  "./manifest-average.json",
  "./manifest-settings.json",
  "./icon-192.png",
  "./icon-512.png",
  "./icon.svg"
];

// External resources to cache separately
const externalResources = [
  "https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.min.css",
  "https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.min.js"
];

// Install: cache files
self.addEventListener("install", event => {
  self.skipWaiting();
  event.waitUntil(
    Promise.all([
      // Cache local resources
      caches.open(CACHE_NAME).then(cache => {
        return cache.addAll(urlsToCache);
      }),
      // Cache external resources with CORS handling
      caches.open(CACHE_NAME + '-external').then(cache => {
        return Promise.all(
          externalResources.map(url => {
            return fetch(url, { mode: 'cors' })
              .then(response => {
                if (response.ok) {
                  return cache.put(url, response);
                }
              })
              .catch(err => {
                console.log('Failed to cache external resource:', url, err);
              });
          })
        );
      })
    ]).catch(err => {
      console.log('Cache install failed:', err);
    })
  );
});

// Activate: clean old caches
self.addEventListener("activate", event => {
  const whitelist = [CACHE_NAME, CACHE_NAME + '-external'];
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
      if (response) {
        return response;
      }

      // Try to fetch from network
      return fetch(event.request).then(fetchResponse => {
        // Don't cache non-successful responses
        if (!fetchResponse || fetchResponse.status !== 200) {
          return fetchResponse;
        }

        // Clone the response
        const responseToCache = fetchResponse.clone();
        const url = event.request.url;

        // Determine which cache to use
        const cacheName = externalResources.includes(url) ? 
          CACHE_NAME + '-external' : CACHE_NAME;

        // Only cache GET requests
        if (event.request.method === 'GET') {
          caches.open(cacheName).then(cache => {
            cache.put(event.request, responseToCache);
          });
        }

        return fetchResponse;
      }).catch(() => {
        // If both cache and network fail
        if (event.request.destination === 'document') {
          return caches.match('./index.html') || caches.match('./');
        }
        // For other resources, just fail gracefully
        return new Response('Offline', { status: 503, statusText: 'Service Unavailable' });
      });
    })
  );
});
