const { CombinedAd } = require('../connection/types');
const mongoose = require('mongoose');

// إنشاء إعلان مشترك
exports.createCombinedAd = async (req, res) => {
    console.log("Received data:", req.body);

    try {
        const {
            userId,
            companyName,
            contactNumber,
            adDetails,
            transportCompanyName,
            transportPhoneNumber,
            transportOwnerName,
            latitude,
            longitude,
            serviceAddress,
            serviceType, // استقبال serviceType من body

        } = req.body;

        if (!userId || !companyName || !contactNumber || !adDetails || !transportCompanyName || !transportPhoneNumber || !transportOwnerName || !serviceType) {
            return res.status(400).json({ message: 'All fields are required.' });
        }

        const newCombinedAd = new CombinedAd({
            userId,
            serviceType,
            companyName: companyName,
            contactNumber: contactNumber,
            adDetails: adDetails,
            transportCompanyName: transportCompanyName,
            transportPhoneNumber: transportPhoneNumber,
            ownerName: transportOwnerName,
            latitude: latitude,
            longitude: longitude,
            serviceAddress: serviceAddress,
        });

        const savedAd = await newCombinedAd.save();
        res.status(201).json({ message: 'Combined ad created successfully.', ad: savedAd });
    } catch (error) {
        console.error('Error creating combined ad:', error);
        res.status(500).json({ message: 'Failed to create combined ad.', error: error.message });
    }
};

// جلب جميع الإعلانات المشتركة
exports.getAllCombinedAds = async (req, res) => {
    try {
        const { page = 1, limit = 10 } = req.query; // دعم التصفح
        const ads = await CombinedAd.find()
            .skip((page - 1) * limit)
            .limit(parseInt(limit))
            .sort({ createdAt: -1 });
        const totalAds = await CombinedAd.countDocuments();

        res.status(200).json({
            totalAds,
            totalPages: Math.ceil(totalAds / limit),
            currentPage: parseInt(page),
            ads,
        });
    } catch (error) {
        console.error('Error fetching combined ads:', error);
        res.status(500).json({ message: 'Failed to fetch combined ads.', error: error.message });
    }
};

// جلب إعلان مشترك بواسطة الـ ID
exports.getCombinedAdById = async (req, res) => {
    try {
        const { id } = req.params;

        if (!mongoose.Types.ObjectId.isValid(id)) {
            return res.status(400).json({ message: 'Invalid ad ID.' });
        }

        const ad = await CombinedAd.findById(id);
        if (!ad) {
            return res.status(404).json({ message: 'Ad not found.' });
        }

        res.status(200).json(ad);
    } catch (error) {
        console.error('Error fetching combined ad by ID:', error);
        res.status(500).json({ message: 'Failed to fetch combined ad.', error: error.message });
    }
};
// تحديث إعلان مشترك موجود
exports.updateCombinedAd = async (req, res) => {
    try {
        const { id } = req.params;

        if (!mongoose.Types.ObjectId.isValid(id)) {
            return res.status(400).json({ message: 'Invalid ad ID.' });
        }

        const updatedAd = await CombinedAd.findByIdAndUpdate(id, req.body, {
            new: true,
            runValidators: true,
        });

        if (!updatedAd) {
            return res.status(404).json({ message: 'Ad not found.' });
        }

        res.status(200).json({ message: 'Ad updated successfully.', ad: updatedAd });
    } catch (error) {
        console.error('Error updating combined ad:', error);
        res.status(500).json({ message: 'Failed to update ad.', error: error.message });
    }
};

// حذف إعلان مشترك
exports.deleteCombinedAd = async (req, res) => {
    try {
        const { id } = req.params;

        if (!mongoose.Types.ObjectId.isValid(id)) {
            return res.status(400).json({ message: 'Invalid ad ID.' });
        }

        const deletedAd = await CombinedAd.findByIdAndDelete(id);
        if (!deletedAd) {
            return res.status(404).json({ message: 'Ad not found.' });
        }

        res.status(200).json({ message: 'Ad deleted successfully.', ad: deletedAd });
    } catch (error) {
        console.error('Error deleting combined ad:', error);
        res.status(500).json({ message: 'Failed to delete ad.', error: error.message });
    }
};