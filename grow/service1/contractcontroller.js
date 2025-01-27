const Cont = require('../connection/types').Cont;
const mongoose = require('mongoose');
const admin = require("firebase-admin");

// دالة لإرسال إشعار Firebase
async function sendPushNotification(receiverId, message, senderId, chatId, fcmToken) {
    if (!receiverId) {
        console.log("receiverId is missing, cannot send push notification");
        return;
    }
    try {
        const payload = {
            notification: {
                title: `تمت الموافقة على إعلانك`,
                body: message,
            },
             data: {
                contractId: chatId,
                senderId: senderId,
                 click_action: 'FLUTTER_NOTIFICATION_CLICK',
            },
             token: fcmToken,
             android: {
                 priority: 'high',
                 notification: {
                    sound: 'default',
                  },
                },
                apns: {
                    payload: {
                        aps: {
                            sound: 'default',
                             mutableContent: 1,
                             contentAvailable: 1,
                        }
                    }
                }
        };
        await admin.messaging().send(payload);
        console.log("Notification sent successfully");
    } catch (error) {
        console.error("Error sending notification:", error);
        throw error;
    }
}

// إنشاء عقد جديد وإرسال إشعار
exports.createContract = async (req, res) => {
    console.log("Received data:", req.body);

    try {
        const {
          adId,
          userId,
          companyName,
          contactNumber,
          adDetails,
          transportCompanyName,
          transportOwnerName,
          transportPhoneNumber,
          fcmToken
        } = req.body;

        // التحقق من الحقول المطلوبة
        if (
          !adId ||
          !userId ||
          !companyName ||
          !contactNumber ||
          !adDetails ||
          !transportCompanyName ||
          !transportOwnerName ||
          !transportPhoneNumber ||
            !fcmToken
        ) {
          return res.status(400).json({ message: 'Missing required fields.' });
        }

        // إنشاء العقد الجديد
        const newCont = new Cont({
          adId,
          userId,
          companyName,
          contactNumber,
          adDetails,
          transportCompanyName,
          transportOwnerName,
          transportPhoneNumber,
        });

        await newCont.save();

        // إرسال إشعار Firebase
        try{
            await sendPushNotification(
                userId,
                `تمت الموافقة على إعلانك من قبل ${transportCompanyName}  `,
                req.user.id,
                newCont._id.toString(),
                 fcmToken,
            );
        } catch (error){
             console.error("Error sending push notification:", error);
        }
        res.status(201).json({ message: 'Contract created successfully.', cont: newCont });
      } catch (error) {
        console.error("Error creating contract:", error);
        res.status(500).json({ message: 'Failed to create contract.', error: error.message });
      }
  };

// دالة لإرسال إشعار مباشر
exports.sendPushNotificationDirectly = async (req, res) => {
    console.log("Send directly notification");
  try {
    await sendPushNotification(
      req.body.receiverId,
      req.body.message,
      req.body.senderId,
      req.body.chatId,
        req.body.fcmToken,
    );
    res.status(200).json({ message: 'Notification sent successfully' });
  } catch (error) {
    console.error("Error sending push notification:", error);
    res
      .status(500)
      .json({ message: 'Error sending the notification', details: error.message });
  }
};
// دالة لإرسال اشعار
exports.sendPushNotification = async (req, res) => {
 try{
   await sendPushNotification(
        req.body.receiverId,
         req.body.message,
         req.body.senderId,
       req.body.chatId,
         req.body.fcmToken,
     );
     res.status(200).json({ message: 'Notification sent successfully' });
   } catch (error){
     console.error("Error sending push notification:", error);
     res.status(500).json({ message: 'Error sending the notification', details: error.message });
   }
};

// جلب جميع العقود
exports.getAllContracts = async (req, res) => {
  try {
    const { page = 1, limit = 10 } = req.query; // دعم التصفح
    const contracts = await Cont.find()
      .skip((page - 1) * limit)
      .limit(parseInt(limit))
      .populate('adId userId', 'name email') // ملء بيانات الإعلان والمستخدم
      .sort({ createdAt: -1 }); // ترتيب حسب الأحدث
    const totalContracts = await Cont.countDocuments();

    res.status(200).json({
      totalContracts,
      totalPages: Math.ceil(totalContracts / limit),
      currentPage: parseInt(page),
      contracts,
    });
  } catch (error) {
    res.status(500).json({ message: 'Failed to fetch contracts.', error: error.message });
  }
};

// جلب عقد باستخدام الـ ID
exports.getContractById = async (req, res) => {
  try {
    const { id } = req.params;

    // التحقق من صحة الـ ID
    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({ message: 'Invalid contract ID.' });
    }

    const cont = await Cont.findById(id).populate('adId userId', 'name email');
    if (!cont) {
      return res.status(404).json({ message: 'Contract not found.' });
    }

    res.status(200).json(cont);
  } catch (error) {
    res.status(500).json({ message: 'Failed to fetch contract.', error: error.message });
  }
};

// تحديث عقد موجود
exports.updateContract = async (req, res) => {
  try {
    const { id } = req.params;

    // التحقق من صحة الـ ID
    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({ message: 'Invalid contract ID.' });
    }

    const updatedCont = await Cont.findByIdAndUpdate(id, req.body, {
      new: true,
      runValidators: true,
    });

    if (!updatedCont) {
      return res.status(404).json({ message: 'Contract not found.' });
    }

    res.status(200).json({ message: 'Contract updated successfully.', cont: updatedCont });
  } catch (error) {
    res.status(500).json({ message: 'Failed to update contract.', error: error.message });
  }
};

// حذف عقد
exports.deleteContract = async (req, res) => {
  try {
    const { id } = req.params;

    // التحقق من صحة الـ ID
    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({ message: 'Invalid contract ID.' });
    }

    const deletedCont = await Cont.findByIdAndDelete(id);

    if (!deletedCont) {
      return res.status(404).json({ message: 'Contract not found.' });
    }

    res.status(200).json({ message: 'Contract deleted successfully.', cont: deletedCont });
  } catch (error) {
    res.status(500).json({ message: 'Failed to delete contract.', error: error.message });
  }
};