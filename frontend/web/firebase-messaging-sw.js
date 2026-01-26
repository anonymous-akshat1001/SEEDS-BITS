// Firebase Cloud Messaging Service Worker
// This file handles background notifications

// Import Firebase scripts
importScripts('https://www.gstatic.com/firebasejs/9.22.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.22.0/firebase-messaging-compat.js');

// TODO: Replace with your Firebase config from Firebase Console
// For now, use a minimal config to prevent errors
firebase.initializeApp({
    apiKey: 'AIzaSyCsh1P1L4xUCa27IdDJoR9DWlOpHaJf4Uk',
    appId: '1:160635759571:web:8e772fc2990d36f0c39d26',
    messagingSenderId: '160635759571',
    projectId: 'seeds-bits',
    authDomain: 'seeds-bits.firebaseapp.com',
    storageBucket: 'seeds-bits.firebasestorage.app',
    measurementId: 'G-PFEZDRMP5L',
});

// Initialize Firebase Messaging
const messaging = firebase.messaging();

// Handle background messages
messaging.onBackgroundMessage((payload) => {
  console.log('[firebase-messaging-sw.js] Received background message', payload);
  
  const notificationTitle = payload.notification?.title || 'New Notification';
  const notificationOptions = {
    body: payload.notification?.body || '',
    icon: '/icons/Icon-192.png',
    badge: '/icons/Icon-192.png',
    data: payload.data
  };

  return self.registration.showNotification(notificationTitle, notificationOptions);
});

// Handle notification clicks
self.addEventListener('notificationclick', (event) => {
  console.log('[firebase-messaging-sw.js] Notification clicked', event);
  event.notification.close();
  
  // Open the app
  event.waitUntil(
    clients.openWindow('/')
  );
});