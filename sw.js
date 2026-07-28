const CACHE_NAME = "gilmuffler-shell-v1";
const SHELL_FILES = ["index.html", "app.js", "styles.css", "logo-muffler.svg"];

self.addEventListener("install", (event) => {
  event.waitUntil(caches.open(CACHE_NAME).then((cache) => cache.addAll(SHELL_FILES)));
  self.skipWaiting();
});

self.addEventListener("activate", (event) => {
  event.waitUntil(
    caches.keys().then((keys) => Promise.all(keys.filter((k) => k !== CACHE_NAME).map((k) => caches.delete(k))))
  );
  self.clients.claim();
});

// Red primero (para no servir la app vieja después de un deploy);
// si no hay internet, usa lo último que se guardó en caché.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== "GET") return;
  event.respondWith(
    fetch(event.request)
      .then((res) => {
        const copia = res.clone();
        caches.open(CACHE_NAME).then((cache) => cache.put(event.request, copia));
        return res;
      })
      .catch(() => caches.match(event.request))
  );
});
