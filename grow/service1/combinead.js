const express = require('express');
const combinedAdController = require('./combinedAdController');
const router = express.Router();

router.post('/create', combinedAdController.createCombinedAd); // إنشاء إعلان مشترك
router.get('/all', combinedAdController.getAllCombinedAds); // جلب جميع الإعلانات المشتركة
router.get('/:id', combinedAdController.getCombinedAdById); // جلب إعلان مشترك بواسطة الـ ID
router.put('/:id', combinedAdController.updateCombinedAd); // تحديث إعلان مشترك
router.delete('/:id', combinedAdController.deleteCombinedAd); // حذف إعلان مشترك

module.exports = router;