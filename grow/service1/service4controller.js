const bcrypt = require('bcrypt');
const { service4 } = require('../connection/types.js');
const mongoose = require('mongoose');

// Signup function for transport services
const signup4 = async (req, res) => {
    try {
        const { transportCompanyName, ownerName, phoneNumber, facebookLink, password, latitude, longitude, address, imageData } = req.body;

        // Validate input data
        if (!transportCompanyName || !ownerName || !phoneNumber || !password || !latitude || !longitude || !address || !imageData) {
            return res.status(400).json({ message: 'Please fill all the required fields' });
        }

        // Hash the password
        const hashedPassword = await bcrypt.hash(password, 10);

        // Create a new transport service object
        const newTransport = new service4({
            transportCompanyName,
            ownerName,
            phoneNumber,
            latitude,
            longitude,
            transportAddress: address,
            facebookLink: facebookLink || '', // Optional Facebook link
            password: hashedPassword,
            imageData: imageData
        });

        // Save the new service to the database
        const savedTransport = await newTransport.save();

        res.status(201).json({
            message: 'Signup successful for transport company!',
            user: {
                userId: savedTransport._id, // Return the user ID
            },
            service: savedTransport,
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
        const service = await service4.findOne({_id : userId});
        if (!service) {
            return res.status(404).json({ message: 'Service not found' });
        }
        res.status(200).json({
           companyName: service.transportCompanyName, // Changed to transportCompanyName
            contactNumber: service.phoneNumber,
            serviceID: service._id,
            serviceType : "service4",
            latitude: service.latitude,
            longitude: service.longitude,
            serviceAddress: service.transportAddress,
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
      const service = await service4.findOne({_id : userId});
      if (!service) {
        return res.status(404).json({ message: 'Service not found' });
      }
        res.status(200).json({
            companyName: service.transportCompanyName, // Changed to transportCompanyName
             contactNumber: service.phoneNumber,
            serviceAddress: service.transportAddress,
             latitude: service.latitude,
            longitude: service.longitude,
           imageData: service.imageData,
            serviceType: 'service4', // Add serviceType
        });
    } catch (error) {
      console.error('Error getting my service details', error);
      res.status(500).json({ message: 'Failed to get service details', details: error.message });
    }
  };

module.exports = { signup4, getServiceByUser, getMyServiceDetails };