require('dotenv').config();
const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const path = require('path');
const connectDB = require('./connection/DB.js');

// استيراد راوترات الخدمات
const service1 = require('./service1/service1');
const service2 = require('./service1/service2');
const service4 = require('./service1/service4');
const service5 = require('./service1/service5');
const createAdsRouter = require('./service1/createads');
const authRouter = require('./service1/auth');
const messageRoutes = require("./service1/chat.js");

const app = express();
const PORT = 2000;

// إعداد Body parser
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// إعداد CORS
app.use(cors());
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// الاتصال بقاعدة البيانات
connectDB();

// تسجيل راوترات الخدمات
app.use('/service1', service1);
app.use('/service2', service2);
app.use('/service4', service4);
app.use('/service5', service5);
app.use('/ad', createAdsRouter);
app.use('/auth', authRouter);
app.use("/chats", messageRoutes);

// Global Error Handler - Must be the last middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ message: 'Something went wrong!', details: err.message });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server is running on port ${PORT}`);
});

