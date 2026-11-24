const CACHE = 'medcontrol-v1';
const APP_SHELL = ['./', './index.html', './styles.css', './app.js', './manifest.json', './icon.svg'];
self.addEventListener('install', event => event.waitUntil(caches.open(CACHE).then(cache => cache.addAll(APP_SHELL)).then(() => self.skipWaiting())));
self.addEventListener('activate', event => event.waitUntil(self.clients.claim()));
self.addEventListener('fetch', event => {
  if (event.request.method !== 'GET') return;
  event.respondWith(caches.match(event.request).then(cached => cached || fetch(event.request).then(response => {
    const copy = response.clone(); caches.open(CACHE).then(cache => cache.put(event.request, copy)); return response;
  }).catch(() => caches.match('./index.html'))));
});
self.addEventListener('push', event => {
  let data = { title: 'MedControl', body: 'Você tem uma atualização do seu tratamento.', url: './' };
  try { data = event.data ? { ...data, ...event.data.json() } : data; } catch (_) {}
  event.waitUntil(self.registration.showNotification(data.title, {
    body: data.body, icon: './icon.svg', badge: './icon.svg', tag: data.tag || 'medcontrol', data: { url: data.url || './' }, vibrate: [120, 60, 120]
  }));
});
self.addEventListener('notificationclick', event => { event.notification.close(); event.waitUntil(clients.matchAll({ type: 'window', includeUncontrolled: true }).then(list => list.length ? list[0].focus() : clients.openWindow(event.notification.data.url))); });
