const mongoose = require('mongoose');

// موديل المعاصر
const pressSchema = new mongoose.Schema({
    pressName: { type: String, required: true, trim: true },
    ownerName: { type: String, required: true, trim: true },
    phoneNumber: { type: String, required: true, trim: true },
    pressAddress: { type: String, required: true, trim: true },
    latitude: { type: Number, required: true },
    longitude: { type: Number, required: true },
    facebookLink: { type: String, required: false, trim: true },
    password: { type: String, required: true },
    imageData: { type: String, default: '' }  // إضافة حقل الصورة
}, { timestamps: true });

const service1 = mongoose.model('service1', pressSchema);

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
    imageData: { type: String, default: '' }, // إضافة حقل الصورة
    // يمكن إضافة حقول إضافية خاصة بالمطاحن هنا
}, { timestamps: true });

const service2 = mongoose.model('service2', millSchema);

const service4Schema = new mongoose.Schema({
    transportCompanyName: { type: String, required: true },
    ownerName: { type: String, required: true },
    phoneNumber: { type: String, required: true },
    latitude: { type: Number, required: true },
    longitude: { type: Number, required: true },
    transportAddress: { type: String, required: true },
    facebookLink: { type: String, default: '' },
    password: { type: String, required: true },
    imageData: { type: String, required: true }
});

const service4 = mongoose.model('Service4', service4Schema);


// موديل المتاجر (المنتجات الزراعية)
const storeSchema = new mongoose.Schema({
    storeName: { type: String, required: true, trim: true },
    ownerName: { type: String, required: true, trim: true },
    phoneNumber: { type: String, required: true, trim: true },
    storeAddress: { type: String, required: true, trim: true },
    latitude: { type: Number, required: true },
    longitude: { type: Number, required: true },
    facebookLink: { type: String, required: false, trim: true },
    password: { type: String, required: true },
    imageData: { type: String, default: '' }, // إضافة حقل الصورة
    // يمكن إضافة حقول إضافية خاصة بالمتاجر هنا
}, { timestamps: true });

const service5 = mongoose.model('service5', storeSchema);

// موديل الإعلانات
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

// موديل التوكن
const tokenSchema = new mongoose.Schema({
    userId: { type: mongoose.Schema.Types.ObjectId, required: true },
    token: { type: String, required: true },
    userType: { type: String, required: true },
    serviceType: { type: String }, // يمكن أن تكون اختيارية إذا لم تكن ضرورية
    phoneNumber: { type: String, trim: true, required: true }
}, { timestamps: true });

const Tokens = mongoose.model('Tokens', tokenSchema);

// موديل المستخدم العام
const userSchemaGeneric = new mongoose.Schema({
    phoneNumber: { type: String, required: true, trim: true, unique: true },
    password: { type: String, required: true },
    displayName: { type: String, required: true, trim: true } // اسم المستخدم الجديد
}, { timestamps: true });

const User = mongoose.model('User', userSchemaGeneric);


// موديل المحادثات
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

const Chats = mongoose.model("Chats", chatSchema);



// موديل إعلانات النقليات
const transportAdSchema = new mongoose.Schema({
    userId: { type: mongoose.Schema.Types.ObjectId, required: true },
    ownerName: { type: String, required: true, trim: true },
    companyName: { type: String, required: true, trim: true },
    contactNumber: { type: String, required: true, trim: true },
    adDetails: { type: String, required: true, trim: true },
    serviceAddress: { type: String, trim: true },
    latitude: { type: Number },
    longitude: { type: Number },
}, { timestamps: true });

const TransportAd = mongoose.model('TransportAd', transportAdSchema);

// موديل العقود (يجب أن يكون قبل التصدير)

const contractSchema = new mongoose.Schema(
    {
      adId: { type: mongoose.Schema.Types.ObjectId, ref: 'TransportAd', required: true },
      userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
      companyName: { type: String, required: true, trim: true },
      contactNumber: { type: String, required: true, trim: true },
      adDetails: { type: String, required: true, trim: true },
      transportCompanyName: { type: String, required: true, trim: true },
      transportOwnerName: { type: String, required: true, trim: true },
      transportPhoneNumber: { type: String, required: true, trim: true },
    },
    { timestamps: true }
  );
  
  const Cont = mongoose.model('Cont', contractSchema);


  const combinedAdSchema = new mongoose.Schema({
    userId: { type: mongoose.Schema.Types.ObjectId, required: true },
    companyName: { type: String, required: true, trim: true },     // اسم المعصرة
    contactNumber: { type: String, required: true, trim: true },   // رقم المعصرة
    transportCompanyName: { type: String, required: true, trim: true },// اسم شركة النقل
    transportPhoneNumber: { type: String, required: true, trim: true },// رقم شركة النقل
    ownerName:{type:String, required: true, trim: true},  // اسم المالك
    adDetails: { type: String, required: true, trim: true }, // تفاصيل الإعلان
     serviceAddress: { type: String, trim: true },
     latitude: { type: Number },
    longitude: { type: Number },
     openingHours: { type: String }, // بداية الوقت بصيغة نص
    workingHours: { type: String },   // نهاية الوقت بصيغة نص
}, { timestamps: true });

const CombinedAd = mongoose.model('CombinedAd', combinedAdSchema); 


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
const ownerSchema = new mongoose.Schema({
    email: { type: String, required: true, unique: true },
    password: { type: String, required: true },
  

    ownerName: { type: String, required: true },
    contactNumber: { type: String, required: true },
    role: { type: String, default: 'Owner' },  // إضافة حقل role
    Status: { type: String, default: 'active' }, // إضافة حقل role

}, { collection: 'Owner' });

const Owner = mongoose.model('Owner', ownerSchema);
// تصدير جميع الموديلات
module.exports = {
    service1,
    service2,
    service4,
    service5,
    Ad,
    Tokens,
    User,
    Chats,
   
    TransportAd,
    Cont, 
    CombinedAd,
    Worker,
    Owner// تأكد من وجود هذا السطر

};
