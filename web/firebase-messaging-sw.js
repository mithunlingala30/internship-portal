importScripts("https://www.gstatic.com/firebasejs/9.10.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/9.10.0/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyCw4uzBLe1ACIlqkxMZ1d9-yaivceE8vao",
  authDomain: "portal-5bd26.firebaseapp.com",
  projectId: "portal-5bd26",
  storageBucket: "portal-5bd26.firebasestorage.app",
  messagingSenderId: "992545342972",
  appId: "1:992545342972:web:4307c7de07378ac88b5e79",
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log("Received background message: ", payload);
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: "/icons/Icon-192.png",
  };

  return self.registration.showNotification(notificationTitle, notificationOptions);
});
