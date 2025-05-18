// web/firebase-messaging-sw.js
importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: "AIzaSyDtpHPmAAUZDa6a8_vsw8X12oFBLnq-07Q",
  authDomain: "chat-8f58d.firebaseapp.com",
  projectId: "chat-8f58d",
  storageBucket: "chat-8f58d.firebasestorage.app",
  messagingSenderId: "74097996929",
  appId: "1:74097996929:web:ed17c596f52c0765098980",
  measurementId: "G-QS18Z26J16"
});

const messaging = firebase.messaging();
