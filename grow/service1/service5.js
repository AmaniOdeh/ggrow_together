const express = require('express');
const { signup5, getServiceByUser, getMyServiceDetails } = require('./service5controller');
const { authenticateJWT } = require('../middleware/middleware.js');
const router = express.Router();

// Test endpoint
router.get('/', (req, res) => {
  res.json({ message: 'Service 5 is working!' });
});

// Signup endpoint
router.post('/signup', signup5);

// Get service details by user ID
router.get('/createAd', authenticateJWT, getServiceByUser);
//New endpoint to get user info:
router.get('/myServiceDetails', authenticateJWT, getMyServiceDetails);
module.exports = router;