const admin = require('firebase-admin');

// إعداد متغير البيئة
process.env.GOOGLE_APPLICATION_CREDENTIALS = "./config/groww-b9a54-firebase-adminsdk-ctfdu-67eed7236a.json";

// تهيئة Firebase Admin SDK
if (!admin.apps.length) {
    try{
        admin.initializeApp({
          credential: admin.credential.cert(require(process.env.GOOGLE_APPLICATION_CREDENTIALS)),
          databaseURL: process.env.DATABASE_URL || "https://groww-b9a54-default-rtdb.firebaseio.com"
        });
      console.log('Firebase Admin SDK initialized successfully'); // تسجيل النجاح
    } catch(error){
      console.error('Failed to initialize Firebase Admin SDK', error)
     }
}

// دالة لإرسال الإشعارات (مثال)
const sendFirebaseNotification = async (fcmToken, title, body) => {
    try {
        const message = {
            notification: { title, body }, // محتوى الإشعار
            token: fcmToken, // FCM Token الخاص بالجهاز
        };
        const response = await admin.messaging().send(message); // إرسال الإشعار
        console.log('Notification sent successfully:', response); // عرض النتيجة إذا تم الإرسال بنجاح
    } catch (error) {
        console.error('Error sending notification:', error.code, error.message); // عرض الخطأ إذا حدث
    }
};

module.exports = { admin, sendFirebaseNotification };