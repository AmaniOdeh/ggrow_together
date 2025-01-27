const Ad = require('../connection/types').Ad;
const { User } = require('../connection/types');
const mongoose = require('mongoose');

// Helper method to find an ad and validate the user.
const findAdAndValidateUser = async (adId, userId) => {
    const ad = await Ad.findOne({ _id: adId, userId });
    if (!ad) {
        throw new Error('Ad not found or not authorized.');
    }
    return ad;
};

// Create Ad
const createAd = async (req, res) => {
    try {
        console.log("Request Body:", req.body);
        console.log("Headers:", req.headers);
        console.log("User ID from token:", req.user?.id);

        const {
            _fetchedServiceType,
            companyName,
            contactNumber,
            adDetails,
            address,
            latitude,
            longitude,
            imageData,
            openingHours, // New field
            workingHours // New field
        } = req.body;

        console.log("Received _fetchedServiceType:", _fetchedServiceType);

        // Validate service type
        const supportedServices = ['service1', 'service2', 'service3', 'service4', 'service5'];
        if (!supportedServices.includes(_fetchedServiceType)) {
            return res.status(400).json({ message: 'Invalid service type.' });
        }

        // Validate required fields
        if (!_fetchedServiceType || !companyName || !contactNumber || !adDetails || !address || !imageData) {
            return res.status(400).json({ message: 'All fields are required.' });
        }

        // Additional validation for specific services
        if (['service1', 'service2', 'service5'].includes(_fetchedServiceType)) {
            if (!openingHours && !workingHours) {
                return res.status(400).json({ message: 'Opening hours or working hours are required for this service type.' });
            }
        }

        const userId = req.user.id;

        // Create new Ad
        const newAd = new Ad({
            userId,
            serviceType: _fetchedServiceType,
            companyName,
            contactNumber,
            adDetails,
            serviceAddress: address,
            latitude,
            longitude,
            imageData,
            openingHours,
            workingHours
        });

        const savedAd = await newAd.save();
        res.status(201).json({ message: 'Ad created successfully!', ad: savedAd });
    } catch (error) {
        console.error('Error creating ad:', error);
        res.status(500).json({ message: 'Internal server error', details: error.message });
    }
};

const updateAd = async (req, res) => {
    try {
        const { adId } = req.params;
        const updateFields = req.body;

        console.log("Request Body:", updateFields);
        if (Object.keys(updateFields).length === 0) {
            return res.status(400).json({ message: "No fields to update." });
        }

        const ad = await Ad.findOne({ _id: adId });
        if (!ad) {
            return res.status(404).json({ message: "Ad not found or not authorized." });
        }

        console.log("Ad before update:", ad);

        // Update only the modified fields
        for (const key in updateFields) {
            if (ad.schema.paths.hasOwnProperty(key)) {
                ad[key] = updateFields[key];
            }
        }

        await ad.save();

        const updatedAd = await Ad.findById(adId);
        return res.status(200).json({ message: "Ad updated successfully!", ad: updatedAd });
    } catch (error) {
        console.error("Error updating ad:", error);
        res.status(500).json({ message: "Internal server error", details: error.message });
    }
};

// Delete Ad
const deleteAd = async (req, res) => {
    try {
        const { adId } = req.params;
        console.log('req.params delete :', req.params);
        const userId = req.user.id;

        // Validate and delete ad
        const ad = await findAdAndValidateUser(adId, userId);
        if (!ad) {
            return res.status(404).json({ message: "Ad not found or not authorized." });
        }

        await Ad.findByIdAndDelete(adId);
        res.status(200).json({ message: 'Ad deleted successfully!' });
    } catch (error) {
        if (error.message === 'Ad not found or not authorized.') {
            return res.status(404).json({ message: error.message });
        }
        console.error('Error deleting ad:', error);
        res.status(500).json({ message: 'Internal server error', details: error.message });
    }
};

module.exports = {
    createAd,
    updateAd,
    deleteAd,
};