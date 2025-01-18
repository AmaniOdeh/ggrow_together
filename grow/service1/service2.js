const express = require('express');
const { signup2, getServiceByUser, getMyServiceDetails } = require('./service2controller');
const { authenticateJWT } = require('../middleware/middleware.js');
const router = express.Router();

// نقطة نهاية لاختبار الخدمة
router.get('/', (req, res) => {
  res.json({ message: 'Service 2 is working!' });
});

// نقطة نهاية لتسجيل المستخدمين
router.post('/signup', signup2);

// نقطة نهاية لجلب تفاصيل الخدمة بناءً على معرف المستخدم (userId)
router.get('/createAd', authenticateJWT, getServiceByUser);
//New endpoint to get user info:

router.get('/myServiceDetails', authenticateJWT, getMyServiceDetails);
module.exports = router;