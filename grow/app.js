// backend/firebase.js
const admin = require("firebase-admin");
const serviceAccount = require("./groww-b9a54-firebase-adminsdk-ctfdu-3aee1800d6.json");

// تهيئة Firebase Admin SDK
admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    databaseURL: "https://groww-b9a54-default-rtdb.firebaseio.com",
});

module.exports = { db:admin.firestore(), admin };