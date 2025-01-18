const express = require('express');
const createAdController = require('./createadscontroller.js');
const getAdsController = require('./getAdsController.js');
const { authenticateJWT } = require('../middleware/middleware.js');

const router = express.Router();

// Define the routes for managing ads
router.post('/createAd', authenticateJWT, createAdController.createAd);
router.get('/:serviceType/myAds', authenticateJWT, getAdsController.getAdsByUserId);
router.put('/:adId/updateAd',  createAdController.updateAd); // إزالة المصادقة من هنا
router.delete('/:adId/deleteAd', authenticateJWT, createAdController.deleteAd);

module.exports = router;