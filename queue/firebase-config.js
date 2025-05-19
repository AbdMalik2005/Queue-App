// Firebase configuration
const firebaseConfig = {
  apiKey: "AIzaSyAnv5_BQY1E1_JY_NaJ1by__eYJvKAPwKs",
  authDomain: "queueapp-cc500.firebaseapp.com",
  projectId: "queueapp-cc500",
  storageBucket: "queueapp-cc500.firebasestorage.app",
  messagingSenderId: "148951620722",
  appId: "1:148951620722:web:348cb5f36469d9578a76eb",
};

// Initialize Firebase
firebase.initializeApp(firebaseConfig);
const db = firebase.firestore();
const auth = firebase.auth();   