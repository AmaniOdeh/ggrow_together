const express = require('express');
const contractController = require('./contractcontroller');
const router = express.Router();

router.post('/create', contractController.createContract); // إنشاء عقد جديد
router.get('/all', contractController.getAllContracts); // جلب جميع العقود
router.get('/:id', contractController.getContractById); // جلب عقد بالـ ID
router.put('/:id', contractController.updateContract); // تحديث عقد
router.delete('/:id', contractController.deleteContract); // حذف عقد
router.post('/sendPushNotificationDirectly', contractController.sendPushNotificationDirectly);

module.exports = router;