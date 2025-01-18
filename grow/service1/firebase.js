const admin = require('firebase-admin');

// إعداد متغير البيئة
process.env.GOOGLE_APPLICATION_CREDENTIALS = "./config/groww-b9a54-firebase-adminsdk-ctfdu-67eed7236a.json";

// تهيئة Firebase Admin SDK
if (!admin.apps.length) {
    admin.initializeApp({
      credential: admin.credential.cert(require(process.env.GOOGLE_APPLICATION_CREDENTIALS)),
      databaseURL: "https://groww-b9a54-default-rtdb.firebaseio.com" // تأكد من صحة URL الخاص بمشروعك
    });
}

// دالة لإرسال الإشعارات
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

// مثال على إرسال إشعار
const fcmToken = 'dPCG64o9SweAEKXEwJv7FM:APA91bHu650J_2ofLi_L0Mcclr9yJxZWCEQIpua2Q5fxjqdQDPv4rnRD9-c2LlxBBTIz-vdyhoXbBhgT0O4A5D-qpNpdH5kH37AtiyBt7QCcO4X56xxw5mE';
sendFirebaseNotification(fcmToken, 'عنوان الإشعار', 'هذا هو نص الإشعار');
