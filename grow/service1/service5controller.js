const bcrypt = require('bcrypt');
const { service5 } = require('../connection/types.js');
const mongoose = require('mongoose');

// Signup function for agricultural store services
const signup5 = async (req, res) => {
    try {
        const { storeName, ownerName, phoneNumber, facebookLink, password, address, latitude, longitude, imageData } = req.body;

        // Validate input data
        if (!storeName || !ownerName || !phoneNumber || !password || !latitude || !longitude || !address || !imageData) {
            return res.status(400).json({ message: 'Please fill all the fields' });
        }

        // Hash the password
        const hashedPassword = await bcrypt.hash(password, 10);

        // Create a new store service object
        const newService = new service5({
            storeName,
            ownerName,
            phoneNumber,
            storeAddress: address,
            latitude,
            longitude,
            facebookLink: facebookLink || '', // Optional Facebook link
            password: hashedPassword,
            imageData: imageData
        });

        // Save the new service to the database
        const savedService = await newService.save();

        res.status(201).json({
            message: 'Signup successful for store!',
            user: {
                userId: savedService._id, // Return the user ID
            },
            service: savedService
        });
    } catch (error) {
        console.error('Error during signup:', error);
        res.status(500).json({
            message: 'An error occurred while processing the request',
            details: error.message,
        });
    }
};

// Get service details by user ID
const getServiceByUser = async (req, res) => {
    try {
        const userId = req.user.id;
        const service = await service5.findOne({_id: userId});
        if (!service) {
            return res.status(404).json({ message: 'Service not found' });
        }

        res.status(200).json({
            companyName: service.storeName, // Changed to storeName
            contactNumber: service.phoneNumber,
            serviceID : service._id,
            serviceType : "service5",
            serviceAddress: service.storeAddress,
             latitude: service.latitude,
            longitude: service.longitude,
            imageData: service.imageData,
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
      const service = await service5.findOne({_id : userId});
      if (!service) {
        return res.status(404).json({ message: 'Service not found' });
      }
        res.status(200).json({
             companyName: service.storeName, // Changed to storeName
             contactNumber: service.phoneNumber,
            serviceAddress: service.storeAddress,
            latitude: service.latitude,
            longitude: service.longitude,
             imageData: service.imageData,
              serviceType: 'service5', // Add serviceType
        });
    } catch (error) {
      console.error('Error getting my service details', error);
      res.status(500).json({ message: 'Failed to get service details', details: error.message });
    }
  };
module.exports = { signup5, getServiceByUser , getMyServiceDetails};