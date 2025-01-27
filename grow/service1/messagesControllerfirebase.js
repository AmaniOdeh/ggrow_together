const admin = require("firebase-admin");
const serviceAccount = require("../groww-b9a54-firebase-adminsdk-ctfdu-3aee1800d6.json");
const {
    service1,
    service2,
    service4,
    service5,
    Worker,
    Owner,
} = require("../connection/types");



const db = admin.firestore();
const messagesCollection = db.collection("messages");
const chatsCollection = db.collection("chats");
const usersCollection = db.collection("users");

function applyFilter(message) {
    const blockedWords = ["spam", "badword"];
    const sanitizedMessage = message
        .toLowerCase()
        .split(" ")
        .filter((word) => !blockedWords.includes(word))
        .join(" ");
    return sanitizedMessage.trim() === "" ? null : sanitizedMessage;
}

exports.sendMessage = async (req, res) => {
    const { text, chatId, senderId, receiverId, type } = req.body;
    if (!chatId || !senderId || !receiverId) {
        return res.status(400).json({ error: "chatId, senderId, and receiverId are required" });
    }

    const filteredMessage = type === 'text' ? applyFilter(text) : text;
    if (type === 'text' && !filteredMessage) {
        return res.status(400).json({ error: "Message contains blocked words" });
    }

    try {
        const messageData = {
            chatId,
            text: filteredMessage,
            senderId,
            receiverId: receiverId,
            type: type || 'text',
            timestamp: admin.firestore.FieldValue.serverTimestamp(),
        };
        const messageRef = await messagesCollection.add(messageData);
        await chatsCollection.doc(chatId).update({
            lastMessage: filteredMessage,
            lastMessageTime: admin.firestore.FieldValue.serverTimestamp(),
        });

        try {
            await sendPushNotification(receiverId, filteredMessage, senderId, chatId);
        } catch (error) {
            console.error("Error sending push notification:", error);
        }

        res.status(200).json({ message: "Message sent successfully", messageId: messageRef.id });
    } catch (error) {
        res.status(500).json({ error: "Failed to send message", message: error.message });
    }
};

exports.editMessage = async (req, res) => {
    const { messageId, newText, senderId } = req.body;
    if (!messageId || !newText) {
        return res.status(400).json({ error: "Message ID and new text are required" });
    }

    try {
        const messageDoc = await messagesCollection.doc(messageId).get();
        if (!messageDoc.exists) {
            return res.status(404).json({ error: "Message not found" });
        }

        const messageData = messageDoc.data();
        if (messageData.senderId !== senderId) {
            return res.status(403).json({ error: "Unauthorized" });
        }

        const editHistory = messageData.editHistory || [];
        await messagesCollection.doc(messageId).update({
            text: newText,
            editHistory: [...editHistory, messageData.text],
            timestamp: admin.firestore.FieldValue.serverTimestamp()
        });

        res.status(200).json({ message: "Message edited successfully" });
    } catch (error) {
        res.status(500).json({ error: "Failed to edit message", message: error.message });
    }
};

exports.deleteMessage = async (req, res) => {
    const { messageId } = req.params;

    if (!messageId) {
        return res.status(400).json({ error: "Message ID is required" });
    }

    try {
        await messagesCollection.doc(messageId).delete();
        res.status(200).json({ message: "Message deleted successfully" });
    } catch (error) {
        res.status(500).json({ error: "Failed to delete message", message: error.message });
    }
};

async function sendPushNotification(receiverId, message, senderId, chatId) {
    if (!receiverId) {
        console.log("receiverId is missing, cannot send push notification");
        return;
    }
    try {
        const userDoc = await usersCollection.doc(receiverId).get();
        if (!userDoc.exists) {
            console.log("User not found");
            return;
        }
        const user = userDoc.data();
        const registrationToken = user.fcmToken;
        if (!registrationToken) {
            console.log("fcmToken not found");
            return;
        }

        const senderInfo = await getUserInfo(senderId);
        const payload = {
            notification: {
                title: `New message from ${senderInfo.name}`,
                body: message,
            },
            data: {
                chatId: chatId,
                senderId: senderId,
            },
            token: registrationToken,
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

exports.getMessages = async (req, res) => {
  const { chatId } = req.params;
  if (!chatId) {
    return res.status(400).json({ error: "chatId is required" });
  }

  try {
    const snapshot = await messagesCollection
      .where("chatId", "==", chatId)
      .orderBy("timestamp", "asc")
      .get();

    const messages = snapshot.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
    }));
    res.status(200).json(messages);
  } catch (error) {
    res.status(500).json({ error: "Failed to fetch messages", message: error.message });
  }
};

async function getUserInfo(userId) {
    const collections = [
        { name: "Worker", nameField: "userName", idField: "_id", model: Worker },
        { name: "Owner", nameField: "ownerName", idField: "_id", model: Owner },
        { name: "service1", nameField: "ownerName", idField: "_id", model: service1 },
        { name: "service2", nameField: "ownerName", idField: "_id", model: service2 },
        { name: "service4", nameField: "ownerName", idField: "_id", model: service4 },
        { name: "service5", nameField: "ownerName", idField: "_id", model: service5 },
    ];

    for (const collectionInfo of collections) {
        const { name, nameField, idField, model } = collectionInfo;
        try {
            const doc = await model.findOne({ [idField]: userId }).lean();

            if (doc) {
                console.log("Found user in collection:", name, doc[nameField])
                return {
                    id: userId,
                    name: doc[nameField] || "Unknown User",
                };
            }
        } catch (error) {
            console.error(`Error searching in collection ${name}:`, error);
        }
    }
    console.log("User not found for id:", userId)
    return { id: userId, name: "Unknown User" };
}
exports.getUserChats = async (req, res) => {
    const { userId } = req.query;
    if (!userId) {
        return res.status(400).json({ error: "User ID is required" });
    }
    try {
        const snapshot = await chatsCollection
            .where("participants", "array-contains", userId)
            .get();
        const chats = await Promise.all(snapshot.docs.map(async (doc) => {
            const data = doc.data();
            const participantsInfo = await Promise.all(
                data.participants.map((participantId) => getUserInfo(participantId))
            );

            return {
                id: doc.id,
                ...data,
                participantsInfo: participantsInfo,
            };
        }));
        res.status(200).json(chats);
    } catch (error) {
        res.status(500).json({ error: "Failed to get user chats", message: error.message });
    }
};
exports.createOrGetChat = async (req, res) => {
    const { participants } = req.body;

    if (!participants || participants.length !== 2) {
        return res.status(400).json({ error: "Both user IDs are required" });
    }

    try {
        const snapshot = await chatsCollection
            .where("participants", "array-contains-any", participants)
            .get();

        let existingChat = null;
        snapshot.forEach(doc => {
            const data = doc.data();
            if (data.participants.sort().join() === participants.sort().join()) {
                existingChat = { id: doc.id, ...data };
            }
        });

        if (existingChat) {
            const participantsInfo = await Promise.all(
                existingChat.participants.map(participantId => getUserInfo(participantId))
            );
            return res.status(200).json({ ...existingChat, participantsInfo });
        }

        const [user1, user2] = await Promise.all([
            getUserInfo(participants[0]),
            getUserInfo(participants[1])
        ]);
        const newChat = {
            participants: participants,
            participantsInfo: [
                { id: user1.id, name: user1.name },
                { id: user2.id, name: user2.name }
            ],
            lastMessage: null,
            lastMessageTime: admin.firestore.FieldValue.serverTimestamp(),
            createdAt: admin.firestore.FieldValue.serverTimestamp()
        };
        const chatRef = await chatsCollection.add(newChat);
        const chatDoc = await chatRef.get();
        res.status(200).json({ id: chatRef.id, ...chatDoc.data() });
    } catch (error) {
        res.status(500).json({ error: "Failed to create chat", details: error.message });
    }
};
exports.searchUsers = async (req, res) => {
    const { query, userId } = req.query;
    if (!query) {
        return res.status(400).json({ error: "Search query is required" });
    }
    try {
        const results = await searchInMultipleCollections(query, userId);
        const uniqueResults = Array.from(
            new Map(results.map((item) => [item.id, item])).values()
        );

        res.status(200).json(uniqueResults);
    } catch (error) {
        res.status(500).json({
            error: "Failed to search users",
            message: error.message,
            details: error.details,
        });
    }
};

async function searchInMultipleCollections(query, userId) {
    const collections = [
        { name: "Worker", nameField: "userName", idField: "_id", model: Worker },
        { name: "Owner", nameField: "ownerName", idField: "_id", model: Owner },
        { name: "service1", nameField: "ownerName", idField: "_id", model: service1 },
        { name: "service2", nameField: "ownerName", idField: "_id", model: service2 },
        { name: "service4", nameField: "ownerName", idField: "_id", model: service4 },
        { name: "service5", nameField: "ownerName", idField: "_id", model: service5 },
    ];

    let allResults = [];

    for (const collectionInfo of collections) {
        const { name, nameField, idField, model } = collectionInfo;
        try {
            const results = await model
                .find({ [nameField]: { $regex: query, $options: "i" } })
                .select({ [nameField]: 1, _id: 1 })
                .lean();
            const modifiedResults = results.map((doc) => ({
                id: doc._id.toString(),
                collection: name,
                displayName: doc[nameField],
            }));
            allResults.push(...modifiedResults);
        } catch (error) {
            console.error(`Error searching in collection ${name}:`, error);
        }
    }
    return allResults.filter((user) => user.id !== userId);
}

exports.updateToken = async (req, res) => {
    const { userId, token } = req.body;
    if (!userId || !token) {
        return res
            .status(400)
            .json({ error: "User ID and token are required" });
    }
    try {
        await usersCollection.doc(userId).set({ fcmToken: token }, { merge: true });
        res.status(200).json({ message: "Token updated successfully" });
    } catch (error) {
        res
            .status(500)
            .json({ error: "Failed to update token", message: error.message });
    }
};