const jwt = require('jsonwebtoken');

const authenticateJWT = (req, res, next) => {
    try {
        // استخراج التوكن من الهيدر
        const authHeader = req.headers['authorization'];
        if (!authHeader) {
            console.error('No Authorization header provided.');
            return res.status(401).json({ message: 'Authorization header is missing.' });
        }

        const token = authHeader.split(' ')[1];
        if (!token) {
            console.error('No token found in Authorization header.');
            return res.status(401).json({ message: 'Authentication token is required.' });
        }

        // التحقق من التوكن باستخدام المفتاح السري
        const decodedToken = jwt.verify(token, process.env.JWT_SECRET);

        // التحقق من الحقول المطلوبة
        if (!decodedToken.id) {
            console.error('Invalid token payload: Missing id:', decodedToken);
            return res.status(400).json({ message: 'Invalid token payload. Missing required id field.' });
        }

        // إضافة بيانات المستخدم إلى الطلب (مع إعادة تسمية الحقل id إلى userId)
        req.user = { ...decodedToken, userId: decodedToken.id };

        console.log('Token verified successfully:', req.user);

        // الانتقال إلى الخطوة التالية
        next();
    } catch (error) {
        console.error('Token verification failed:', error.message);

        // التعامل مع الأخطاء بناءً على نوعها
        if (error.name === 'TokenExpiredError') {
            return res.status(403).json({ message: 'Token has expired. Please log in again.' });
        } else if (error.name === 'JsonWebTokenError') {
            return res.status(403).json({ message: 'Invalid token. Please provide a valid token.' });
        } else {
            return res.status(500).json({ message: 'An internal error occurred during token verification.' });
        }
    }
};

module.exports = { authenticateJWT };
