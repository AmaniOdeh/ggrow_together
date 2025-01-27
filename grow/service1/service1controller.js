const bcrypt = require('bcrypt');
const { service1, User } = require('../connection/types.js');
const mongoose = require('mongoose');
const admin = require('firebase-admin');

const signup1 = async (req, res) => {
    try {
        const { pressName, ownerName, phoneNumber, facebookLink, password, address, latitude, longitude, imageData } = req.body;

        if (!pressName || !ownerName || !phoneNumber || !address || !password || !latitude || !longitude || !imageData) {
            return res.status(400).json({ message: 'Please fill all the required fields' });
        }
      
        // Create a new user in Firebase Authentication
       const userRecord = await admin.auth().createUser({
          phoneNumber: phoneNumber,
         });
          const uid = userRecord.uid;


        // Hash the password
        const hashedPassword = await bcrypt.hash(password, 10);

        const newService = new service1({
            pressName,
            ownerName,
           phoneNumber,
           latitude,
           longitude,
           pressAddress: address,
          facebookLink: facebookLink || '',
          password: hashedPassword,
           imageData: imageData,
           _id:uid
        });
        const savedService = await newService.save();
           const newUser = new User({
         phoneNumber: phoneNumber,
          password: hashedPassword,
         _id: uid
     });
           await newUser.save();

        res.status(201).json({
            message: 'Signup successful for press!',
            user: {
                userId: savedService._id,
             },
            service: savedService,
        });
    } catch (error) {
        console.error('Error during signup:', error);
        res.status(500).json({
            message: 'An error occurred while processing the request',
            details: error.message,
        });
    }
};

const getServiceByUser = async (req, res) => {
    try {
        const userId = req.user.id;
        const service = await service1.findOne({_id: userId});

        if (!service) {
            return res.status(404).json({ message: 'Service not found' });
        }

        res.status(200).json({
            companyName: service.pressName, // Changed to pressName
            contactNumber: service.phoneNumber,
            serviceID: service._id,
            serviceType: 'service1',
            serviceAddress: service.pressAddress,
            latitude: service.latitude,
            longitude: service.longitude,
            imageData: service.imageData,
             ownerName: service.ownerName
        });
    } catch (error) {
        console.error('Error fetching service:', error);
        res.status(500).json({
            message: 'Internal server error',
            details: error.message,
        });
    }
};

const getMyServiceDetails = async (req, res) => {
    try {
        const userId = req.user.id;
        const service = await service1.findOne({_id : userId});
        if (!service) {
            return res.status(404).json({ message: 'Service not found' });
        }
        res.status(200).json({
             companyName: service.pressName, // Changed to pressName
            contactNumber: service.phoneNumber,
            serviceAddress: service.pressAddress,
            latitude: service.latitude,
            longitude: service.longitude,
            imageData: service.imageData,
            serviceType: 'service1', // Add serviceType
            ownerName: service.ownerName,
        });
    } catch (error) {
        console.error('Error getting my service details', error);
        res.status(500).json({ message: 'Failed to get service details', details: error.message });
    }
};

module.exports = { signup1, getServiceByUser, getMyServiceDetails };