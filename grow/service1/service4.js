const express = require('express');
const { signup4, getServiceByUser, getMyServiceDetails } = require('./service4controller');
const { authenticateJWT } = require('../middleware/middleware.js');
const router = express.Router();

// Test endpoint
router.get('/', (req, res) => {
  res.json({ message: 'Service 4 is working!' });
});

// Signup endpoint
router.post('/signup', signup4);

// Get service details by user ID
router.get('/createAd', authenticateJWT, getServiceByUser);
//New endpoint to get user info:
router.get('/myServiceDetails', authenticateJWT, getMyServiceDetails);
module.exports = router;