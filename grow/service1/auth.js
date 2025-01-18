const express = require('express');
const { login } = require('./authcontroller.js');
const router = express.Router();

// نقطة النهاية لتسجيل الدخول
router.post('/login', login);

module.exports = router;
