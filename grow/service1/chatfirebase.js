const express = require('express');
const router = express.Router();
const chatController = require('./messagesControllerfirebase');

router.post('/send', chatController.sendMessage);
router.get('/messages/:chatId', chatController.getMessages);
router.get('/chats', chatController.getUserChats);
router.post('/chats', chatController.createOrGetChat);
router.get('/users/search', chatController.searchUsers);
router.put('/messages/edit', chatController.editMessage);
router.delete('/messages/:messageId', chatController.deleteMessage);
router.post('/users/updateToken', chatController.updateToken);
module.exports = router;