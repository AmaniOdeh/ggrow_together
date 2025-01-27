const mongoose = require("mongoose");
const { Chat, User, Worker, Owner } = require("../connection/types");
const jwt = require("jsonwebtoken");

// إنشاء محادثة جديدة
exports.createChat = async (req, res) => {
    try {
        const { participants } = req.body;

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

        if (!participants || !Array.isArray(participants) || participants.length === 0) {
            return res.status(400).json({ error: "Participants are required and must be an array." });
        }
        if (!participants.includes(userId)) {
            participants.push(userId);
        }
        // Ensure there are at least two participants in a chat
        if (participants.length < 2) {
            return res.status(400).json({ error: "A chat must have at least two participants." });
        }

        // التحقق ما إذا كانت المحادثة موجودة بالفعل بين المستخدمين
        const existingChat = await Chat.findOne({
            participants: { $all: participants },
        });

        if (existingChat) {
            return res.status(400).json({ error: "A chat already exists between these users." });
        }

        const newChat = new Chat({ participants });
        const savedChat = await newChat.save();

        res.status(201).json(savedChat);
    } catch (error) {
        console.error("Error creating chat:", error.message);
        res.status(500).json({ error: "An error occurred while creating the chat." });
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
            .populate("participants", "_id") // جلب فقط معرفات المشاركين
            .sort({ updatedAt: -1 });

        if (!chats.length) {
            return res.status(404).json({ error: "No chats found for this user." });
        }

        // تجهيز البيانات المرسلة
        const chatsWithOtherParticipants = await Promise.all(
            chats.map(async (chat) => {
                // استخراج معرف الشخص الآخر
                const otherParticipantId = chat.participants.find(
                    (participant) => participant.toString() !== userId
                );
        
                if (!otherParticipantId) {
                    console.error(`No other participant found for chat ID: ${chat._id}`);
                    return {
                        ...chat.toObject(),
                        otherParticipantName: "غير معروف",
                    };
                }
        
                // البحث عن المشارك الآخر في جدول Owner أو Worker
                let otherParticipantName = "غير معروف";
                let owner = await Owner.findById(otherParticipantId);
                if (owner) {
                    otherParticipantName = owner.name || owner.ownerName || "غير معروف";
                } else {
                    let worker = await Worker.findById(otherParticipantId);
                    if (worker) {
                        otherParticipantName = worker.name || worker.userName || "غير معروف";
                    } else {
                        console.error(`No record found for participant ID: ${otherParticipantId}`);
                    }
                }
        
                return {
                    ...chat.toObject(),
                    otherParticipantName: otherParticipantName,
                };
            })
        );
        

        res.status(200).json(chatsWithOtherParticipants);

    } catch (error) {
        console.error("Error fetching chats:", error.message);
        res.status(500).json({ error: "An error occurred while fetching chats." });
    }
};

// إضافة رسالة إلى محادثة
exports.addMessage = async (req, res) => {
    const { chatId } = req.params;
    const { text } = req.body;

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

    if (!userId || !text) {
        return res
            .status(400)
            .json({ error: "Sender and text are required." });
    }

    try {
        // تحقق من وجود المحادثة
        const chat = await Chat.findById(chatId);

        if (!chat) {
            return res.status(404).json({ error: "Chat not found." });
        }

        // جلب اسم مالك المحادثة
        const user = await User.findById(userId);
        if (!user) {
            return res.status(404).json({ error: "User not found." });
        }

        const senderName = user.name || user.userName || "Unknown User";
        // إضافة الرسالة إلى المحادثة
        const newMessage = { sender: userId, senderName: senderName, text, timestamp: new Date() };
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
