// Redirect to the flutter service worker
// This file exists to handle any references to serviceworker.js
// while the actual service worker functionality is in flutter_service_worker.js

self.addEventListener('install', (event) => {
  // Skip waiting to activate this service worker immediately
  self.skipWaiting();
  
  console.log('Redirecting serviceworker.js to flutter_service_worker.js');
  
  // We could include the actual flutter service worker logic here
  // but for simplicity we'll just let this service worker handle basic caching
});

self.addEventListener('activate', (event) => {
  // Claim clients immediately
  event.waitUntil(self.clients.claim());
});

// Basic fetch handler
self.addEventListener('fetch', (event) => {
  // Pass through to network and cache
  event.respondWith(
    fetch(event.request)
      .catch((error) => {
        console.error('Fetch error:', error);
        throw error;
      })
  );
}); 