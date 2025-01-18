const express = require('express');
const { signup1, getServiceByUser, getMyServiceDetails } = require('./service1controller');
const { authenticateJWT } = require('../middleware/middleware.js');
const router = express.Router();


router.get('/', (req, res) => {
    res.json({ message: 'Service 1 is working!' });
});

router.post('/signup', signup1); // حذف upload middleware

router.get('/createAd', authenticateJWT, getServiceByUser);

router.get('/myServiceDetails', authenticateJWT, getMyServiceDetails);

module.exports = router;