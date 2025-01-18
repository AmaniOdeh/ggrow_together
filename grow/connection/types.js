const mongoose = require('mongoose');

// موديل المعاصر
const userSchema = new mongoose.Schema({
    pressName: { type: String, required: true, trim: true },
    ownerName: { type: String, required: true, trim: true },
    phoneNumber: { type: String, required: true, trim: true },
    pressAddress: { type: String, required: true, trim: true },
    latitude: { type: Number, required: true },
    longitude: { type:Number, required: true },
    facebookLink: { type: String, required: false, trim: true },
    password: { type: String, required: true },
    imageData: { type: String, default: '' }  // إضافة حقل الصورة
}, { timestamps: true });

const service1 = mongoose.model('service1', userSchema);


// موديل المطاحن
const millSchema = new mongoose.Schema({
    millName: { type: String, required: true, trim: true },
    ownerName: { type: String, required: true, trim: true },
    phoneNumber: { type: String, required: true, trim: true },
    millAddress: { type: String, required: true, trim: true },
    latitude: { type: Number, required: true },
    longitude: { type: Number, required: true },
    facebookLink: { type: String, required: false, trim: true },
    password: { type: String, required: true },
    imageData: { type: String, default: '' } // إضافة حقل الصورة
}, { timestamps: true });

const service2 = mongoose.model('service2', millSchema);





// موديل النقليات
const transportSchema = new mongoose.Schema({
    transportCompanyName: { type: String, required: true, trim: true },
    ownerName: { type: String, required: true, trim: true },
    phoneNumber: { type: String, required: true, trim: true },
    latitude: { type:Number, required: true },
    longitude: { type: Number, required: true },
    facebookLink: { type: String, required: false, trim: true },
    password: { type: String, required: true },
    imageData: { type: String, default: '' } // إضافة حقل الصورة
}, { timestamps: true });

const service4 = mongoose.model('service4', transportSchema);


// موديل المنتجات الزراعية
const productSchema = new mongoose.Schema({
    storeName: { type: String, required: true, trim: true },
    ownerName: { type: String, required: true, trim: true },
    phoneNumber: { type: String, required: true, trim: true },
    storeAddress: { type: String, required: true, trim: true },
    latitude: { type:Number, required: true },
    longitude: { type: Number, required: true },
    facebookLink: { type: String, required: false, trim: true },
    password: { type: String, required: true },
    imageData: { type: String, default: '' } // إضافة حقل الصورة
}, { timestamps: true });

const service5 = mongoose.model('service5', productSchema);


const adSchema = new mongoose.Schema({
    userId: { type: mongoose.Schema.Types.ObjectId, required: true },
    serviceType: { type: String, required: true, enum: ['service1', 'service2', 'service3', 'service4', 'service5'] },
    companyName: { type: String, required: true, trim: true },
    contactNumber: { type: String, required: true, trim: true },
    discountPrice: { type: String, required: false, trim: true },
    adDetails: { type: String, required: true, trim: true },
    imageData: { type: String, default: '' },  // تخزين بيانات الصورة
    serviceAddress: { type: String, trim: true },
    latitude: { type: Number },
    longitude: { type: Number },
    openingHours: { type: String, required: true }, // بداية الوقت بصيغة نص
    workingHours: { type: String, required: true },   // نهاية الوقت بصيغة نص
}, { timestamps: true });

const Ad = mongoose.model('Ad', adSchema);



const tokenSchema = new mongoose.Schema({
    userId: { type: mongoose.Schema.Types.ObjectId, required: true },
    token: { type: String, required: true },
    userType: { type: String, required: true },
    serviceType: { type: String }, // يمكن أن تكون اختيارية إذا لم تكن ضرورية
    phoneNumber: { type: String, trim: true, required: true }
}, { timestamps: true });

const Token = mongoose.model('Token', tokenSchema);


const userSchemaGeneric = new mongoose.Schema({
    phoneNumber: { type: String, required: true, trim: true, unique: true },
    password: { type: String, required: true }
}, { timestamps: true });

const User = mongoose.model('User', userSchemaGeneric);


const chatSchema = new mongoose.Schema(
    {
    participants: [{ type: mongoose.Schema.Types.ObjectId, ref: "User" }],
    messages: [
        {
        sender: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
        text: { type: String, required: true },
          timestamp: { type: Date, default: Date.now }
        },
      ],
    },
    { timestamps: true }
    );
 const Chat = mongoose.model("Chat", chatSchema);
const ownerSchema = new mongoose.Schema({
    email: { type: String, required: true, unique: true },
    password: { type: String, required: true },
  

    ownerName: { type: String, required: true },
    contactNumber: { type: String, required: true },
    role: { type: String, default: 'Owner' },  // إضافة حقل role
    Status: { type: String, default: 'active' }, // إضافة حقل role

}, { collection: 'Owner' });

const Owner = mongoose.model('Owner', ownerSchema);
const workerSchema = new mongoose.Schema(
    {
        email: {
            type: String,
            required: true,
            unique: true,
            lowercase: true
        },
        password: {
            type: String,
            required: true
        },
        userName: {
            type: String,
            required: true
        },
        skills: {
            type: [String],
            validate: {
                validator: function (value) {
                    return value.every(skill => allowedSkills.includes(skill));
                },
                message: 'بعض المهارات غير صحيحة أو غير مرتبطة بالزراعة.'
            }
        },
        contactNumber: {
            type: String,
            required: true
        },
        role: {
            type: String,
            default: 'Worker'
        },
        status: {
            type: String,
            default: 'active'
        },
        isGuarantor: {
            type: Boolean,
            default: false
        },
        registrationCompleted: {
            type: Boolean,
            default: false
        },
        tools: {
            type: [String],
            validate: {
                validator: function (value) {
                    return value.every(tool => allowedTools.includes(tool));
                },
                message: 'بعض الأدوات غير صحيحة أو غير مرتبطة بالزراعة.'
            }
        },
        // الحقول الجديدة لخطوة التسجيل الثانية
        streetName: {
            type: String,
            required: false // اختياري في حال كان إدخال الموقع يتم في خطوة ثانية
        },
        town: {
            type: String,
            required: false
        },
        city: {
            type: String,
            required: false
        },
        areas: {
            type: [String], // قائمة بالمناطق الجغرافية
            required: false
        },
        location: { // إضافة حقل الموقع
            type: { type: String, enum: ['Point'], required: false }, // نوع الموقع (نقطة)
            coordinates: {
                type: [Number], // مصفوفة تحتوي على خط العرض والطول
                required: true
            }
        }
    },
    { collection: 'Worker' }
);

const Worker = mongoose.model('Worker', workerSchema);

module.exports = { service1, service2, service4, service5, Ad, Token, User ,Chat,Owner,Worker};