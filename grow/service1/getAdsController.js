const { Ad } = require('../connection/types'); // استخدام الـ destructuring هنا افضل

const getAdsByUserId = async (req, res) => {
  try {
    const { serviceType } = req.params; // استخراج serviceType من الـ params
    const userId = req.user.id; // استخراج معرّف المستخدم من التوكن

    // البحث عن جميع الإعلانات التي تطابق معرّف المستخدم
    const ads = await Ad.find({ userId: userId, serviceType: serviceType }).sort({ createdAt: -1 }).lean(); // إضافة lean() هنا

    // التحقق من وجود إعلانات قبل الإرجاع
    if (!ads || ads.length === 0) {
      return res.status(200).json({ message: 'No ads found for this user', ads: [] });
    }

    // إرسال الصورة كـ base64 string
    const adsWithImageData = ads.map(ad => ({
      ...ad,
      imageData: ad.imageData, // إرجاع حقل imageData اللي فيه base64 string
      imagePath: null // عشان ما يظهر الـ path  في الـ response
    }));

    res.status(200).json({ ads: adsWithImageData }); // حذف التكرار هنا
  } catch (error) {
    console.error('Error getting ads by user ID:', error);
    res.status(500).json({ message: 'Internal server error', details: error.message });
  }
};

module.exports = {
  getAdsByUserId,
};
