const mongoose = require("mongoose");
const { Chat } = require("../connection/types");
const jwt = require("jsonwebtoken");

// إنشاء محادثة جديدة أو إيجاد محادثة موجودة
exports.createChat = async (req, res) => {
  const { participants } = req.body;

  if (!participants || participants.length < 2) {
    return res
      .status(400)
      .json({ error: "Participants are required and should be at least two." });
  }

  const uniqueParticipants = [...new Set(participants)];
  if (uniqueParticipants.length < 2) {
    return res
      .status(400)
      .json({ error: "Participants must be unique and at least two." });
  }

  try {
    let chat = await Chat.findOne({
      participants: { $all: uniqueParticipants },
    });

    if (!chat) {
      chat = new Chat({ participants: uniqueParticipants, messages: [] });
      await chat.save();
    }

    res.status(200).json(chat);
  } catch (error) {
    console.error("Error creating chat:", error.message);
    res
      .status(500)
      .json({ error: "An error occurred while creating the chat." });
  }
};

// إضافة رسالة إلى محادثة
// إضافة رسالة إلى محادثة
exports.addMessage = async (req, res) => {
  const { chatId } = req.params;
  const { sender, text } = req.body;

  if (!sender  || !text) {
    return res
      .status(400)
      .json({ error: "Sender, receiver, and text are required." });
  }

  try {
    // تحقق من وجود المحادثة
    const chat = await Chat.findById(chatId);

    if (!chat) {
      return res.status(404).json({ error: "Chat not found." });
    }

    // إضافة الرسالة إلى المحادثة
    const newMessage = { sender, text, timestamp: new Date() };
    chat.messages.push(newMessage);
    await chat.save();

    res.status(201).json(newMessage);
  } catch (error) {
    console.error("Error adding message:", error.message);
    res
      .status(500)
      .json({ error: "An error occurred while adding the message." });
  }
};

// جلب الرسائل من محادثة معينة
exports.getMessages = async (req, res) => {
  const { chatId } = req.params;

  if (!mongoose.Types.ObjectId.isValid(chatId)) {
    return res.status(400).json({ error: "Invalid chat ID." });
  }

  try {
    const chat = await Chat.findById(chatId);

    if (!chat) {
      return res.status(404).json({ error: "Chat not found." });
    }

    res.status(200).json(chat.messages);
  } catch (error) {
    console.error("Error fetching messages:", error.message);
    res
      .status(500)
      .json({ error: "An error occurred while fetching messages." });
  }
};

// جلب المحادثات الخاصة بالمستخدم
exports.getChatsByUser = async (req, res) => {
    try {
        // استخراج التوكن من الهيدر
        const authHeader = req.headers.authorization;
        if (!authHeader) {
            return res.status(401).json({ error: "Authorization token is required." });
        }

        const token = authHeader.split(" ")[1];

        let decoded;
        try {
            decoded = jwt.verify(token, process.env.JWT_SECRET);
        } catch (jwtError) {
            console.error("JWT Verification Error:", jwtError.message);
            return res.status(401).json({ error: "Invalid authorization token" });
        }

        // استخراج userId من التوكن
        const userId = decoded.id;
        if (!userId) {
            return res.status(400).json({ error: "Invalid token payload: userId is missing." });
        }

         // Query to find chats where the userId exists in the participants array
        const query = { participants: { $in: [userId] } };

        const chats = await Chat.find(query)
            .populate("participants", "name email")
            .sort({ updatedAt: -1 });

        if (!chats.length) {
            return res.status(404).json({ error: "No chats found for this user." });
        }

        res.status(200).json(chats);

    } catch (error) {
        console.error("Error fetching chats:", error);
        res.status(500).json({ error: "An error occurred while fetching chats." });
    }
};
// تعديل رسالة محددة
exports.updateMessage = async (req, res) => {
  const { chatId, messageId } = req.params;
  const { text } = req.body;

  if (!text) {
    return res.status(400).json({ error: "Text is required to update the message." });
  }

  try {
    const chat = await Chat.findById(chatId);

    if (!chat) {
      return res.status(404).json({ error: "Chat not found." });
    }

    const message = chat.messages.id(messageId);

    if (!message) {
      return res.status(404).json({ error: "Message not found." });
    }

    message.text = text;
    await chat.save();

    res.status(200).json({ success: true, message: "Message updated successfully." });
  } catch (error) {
    console.error("Error updating message:", error.message);
    res.status(500).json({ error: "An error occurred while updating the message." });
  }
};

// حذف رسالة محددة
exports.deleteMessage = async (req, res) => {
  const { chatId, messageId } = req.params;

  try {
    const chat = await Chat.findById(chatId);

    if (!chat) {
      return res.status(404).json({ error: "Chat not found." });
    }

    // Use Mongoose's array update mechanism to remove the message
     await Chat.updateOne(
            { _id: chatId },
            { $pull: { messages: { _id: messageId } } }
        );

    res
      .status(200)
      .json({ success: true, message: "Message deleted successfully." });
  } catch (error) {
    console.error("Error deleting message:", error.message);
    res
      .status(500)
      .json({ error: "An error occurred while deleting the message." });
  }
};