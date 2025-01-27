const express = require("express");
const router = express.Router();
const {
    createChat,
    addMessage,
    getMessages,
    getChatsByUser,
    updateMessage,
    deleteMessage,
} = require("./messageController"); // استيراد messageController بشكل صحيح

// إنشاء محادثة جديدة
router.post("/", createChat);

// إضافة رسالة إلى محادثة
router.post("/:chatId/messages", addMessage); // تمرير addMessage كـ callback function

// جلب الرسائل من محادثة معينة
router.get("/:chatId/messages", getMessages);

// جلب المحادثات الخاصة بمستخدم معين
router.get("/", getChatsByUser);

// تعديل رسالة محددة
router.put("/:chatId/messages/:messageId", updateMessage);

// حذف رسالة محددة
router.delete("/:chatId/messages/:messageId", deleteMessage);

module.exports = router;