const bcrypt = require('bcrypt');
const { service2 } = require('../connection/types.js');
const mongoose = require('mongoose');

// Signup function for mills
const signup2 = async (req, res) => {
    try {
        const { millName, ownerName, phoneNumber, facebookLink, password, address, latitude, longitude, imageData } = req.body;

        // Validate input data
        if (!millName || !ownerName || !phoneNumber || !address || !password || !latitude || !longitude || !imageData) {
            return res.status(400).json({ message: 'Please fill all the required fields' });
        }

        // Hash the password
        const hashedPassword = await bcrypt.hash(password, 10);

        // Create a new mill service object
        const newMill = new service2({
            millName,
            ownerName,
            phoneNumber,
            millAddress: address,
            latitude,
            longitude,
            facebookLink: facebookLink || '', // Optional Facebook link
            password: hashedPassword,
            imageData: imageData
        });

        // Save the new service to the database
        const savedMill = await newMill.save();

        res.status(201).json({
            message: 'Signup successful for mill!',
            user: {
                userId: savedMill._id, // Return the user ID
            },
            service: savedMill,
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
        const service = await service2.findOne({_id: userId});

        if (!service) {
            return res.status(404).json({ message: 'Service not found' });
        }

        res.status(200).json({
             companyName: service.millName,  // Changed to millName
            contactNumber: service.phoneNumber,
            serviceID : service._id,
            serviceType : "service2",
            serviceAddress: service.millAddress,
            latitude: service.latitude,
            longitude: service.longitude,
            imageData: service.imageData
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
        const service = await service2.findOne({_id : userId});
        if (!service) {
            return res.status(404).json({ message: 'Service not found' });
        }
        res.status(200).json({
             companyName: service.millName, // Changed to millName
            contactNumber: service.phoneNumber,
            serviceAddress: service.millAddress,
            latitude: service.latitude,
            longitude: service.longitude,
             imageData: service.imageData,
            serviceType: 'service2', // Add serviceType
        });
    } catch (error) {
        console.error('Error getting my service details', error);
        res.status(500).json({ message: 'Failed to get service details', details: error.message });
    }
};

module.exports = { signup2, getServiceByUser, getMyServiceDetails };