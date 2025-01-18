const jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt');
const { service1, service2, service3, service4, service5, User, Token } = require('../connection/types.js');
const mongoose = require('mongoose');

const login = async (req, res) => {
    const { phoneNumber, password } = req.body;

    try {
        let user = null;
        let userType = null;
        let service = null;
        let serviceType = null;
        const services = [
            { model: service1, type: 'service1' },
            { model: service2, type: 'service2' },
            { model: service4, type: 'service4' },
            { model: service5, type: 'service5' }
        ];

        for (const serviceItem of services) {
          const serviceUser = await serviceItem.model.findOne({ phoneNumber: phoneNumber });
          if (serviceUser) {
             user = serviceUser;
             userType = "owner";
             serviceType = serviceItem.type;
                if (!await bcrypt.compare(password, user.password)) {
                    return res.status(400).json({ message: 'Invalid credentials, password does not match' });
                 }

                 const token = generateToken(user,userType, user._id);
                  const tokenData = {
                  userId: user._id,
                   token,
                   userType,
                    phoneNumber: user.phoneNumber,
                      serviceType : serviceType
                 };

                 return res.status(200).json({
                     message: "Login successful!",
                     token: token,
                     role: userType,
                       userId : user._id,
                     serviceType : serviceType,
                       user : user
                  });
          }
        }
         user = await User.findOne({ phoneNumber: phoneNumber });
        if (!user) {
              return res.status(404).json({ message: 'User not found, please signup' });
          }

      if (!await bcrypt.compare(password, user.password)) {
        return res.status(400).json({ message: 'Invalid credentials, password does not match' });
        }

     // Generate a JWT token
       const token = generateToken(user, "worker", user._id);

         res.status(200).json({ message: 'Login successful!', token: token, role: 'worker', userId : user._id , user : user});

  } catch (error) {
      console.error("Error logging in user:", error);
        res.status(500).json({ message: "An error occurred", details : error.message });
  }
};


const generateToken = (user, role, userId) => {
  if (!process.env.JWT_SECRET) {
    throw new Error('JWT_SECRET is not defined in the environment variables');
  }

  return jwt.sign({ id: userId, role }, process.env.JWT_SECRET, { expiresIn: '60d' });
};


module.exports = { login };