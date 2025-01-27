const { TransportAd } = require('../connection/types'); // افتراض أن TransportAd هو النموذج الخاص بالإعلانات
const mongoose = require('mongoose');
const createTransportAd = async (req, res) => {
    const { description, openingHours, workingHours } = req.body;
    const companyId = req.user.id;
    const serviceType = 'service1'; // Since it's for transportation

    if (!description || !companyId) {
        return res.status(400).json({ message: "All fields are required" });
    }
    if (!openingHours || !workingHours) {
           return res.status(400).json({ message: "Please provide the opening and working hours." });
    }
    try {
        // Fetch service details from service1 model
        const service1 = await mongoose.model('service1').findById(companyId);

        if (!service1) {
            return res.status(404).json({ message: "Company not found" });
        }
         const newTransportAd = new TransportAd({
          userId: companyId,
          serviceType,
          companyName: service1.pressName,
            contactNumber: service1.phoneNumber,
             ownerName:service1.ownerName,
           adDetails: description,
            serviceAddress: service1.pressAddress,
            latitude: service1.latitude,
           longitude: service1.longitude,
           openingHours: openingHours,
           workingHours: workingHours,
        });

        const savedAd = await newTransportAd.save();
        res.status(201).json({ message: 'Ad created successfully', ad: savedAd });
    } catch (error) {
        console.error('Error creating transport ad:', error);
        res.status(500).json({ message: 'Error creating the ad', details: error.message });
    }
};

// Get ads for service4 users
const getTransportAdsForService4 = async (req, res) => {
    try {
        // جلب جميع الإعلانات من جدول TransportAd
        const ads = await TransportAd.find({});
        
        // إرجاع الإعلانات كاستجابة
        res.status(200).json(ads);
    } catch (error) {
        console.error('Error fetching transport ads:', error);
        res.status(500).json({ message: 'Error fetching transport ads', details: error.message });
    }
};
// تعديل الإعلان
const updateTransportAd = async (req, res) => {
    const { adId } = req.params; // ID الإعلان المراد تعديله
    const updateFields = req.body; // الحقول الجديدة للتحديث

    if (!adId) {
        return res.status(400).json({ message: "Ad ID is required" });
    }

    try {
        const ad = await TransportAd.findById(adId);

        if (!ad) {
            return res.status(404).json({ message: "Ad not found" });
        }

        // تحديث الحقول فقط إذا تم إرسالها
        for (const key in updateFields) {
            if (TransportAd.schema.paths.hasOwnProperty(key)) {
                ad[key] = updateFields[key];
            }
        }

        const updatedAd = await ad.save();
        res.status(200).json({ message: "Ad updated successfully", ad: updatedAd });
    } catch (error) {
        console.error('Error updating transport ad:', error);
        res.status(500).json({ message: 'Error updating the ad', details: error.message });
    }
};

// حذف الإعلان
const deleteTransportAd = async (req, res) => {
    const { adId } = req.params; // ID الإعلان المراد حذفه

    if (!adId) {
        return res.status(400).json({ message: "Ad ID is required" });
    }

    try {
        // Find the ad
        const ad = await TransportAd.findById(adId);

        if (!ad) {
            return res.status(404).json({ message: "Ad not found" });
        }

        // Delete the ad using deleteOne
        await TransportAd.deleteOne({ _id: adId });

        res.status(200).json({ message: "Ad deleted successfully" });
    } catch (error) {
        console.error('Error deleting transport ad:', error);
        res.status(500).json({ message: 'Error deleting the ad', details: error.message });
    }
};
module.exports = {
    createTransportAd,
    getTransportAdsForService4,
    updateTransportAd,
    deleteTransportAd,
};
