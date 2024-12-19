import 'package:flutter/material.dart';

import 'homepageservice.dart';

class SignUpPage extends StatefulWidget {
  final String serviceType;

  const SignUpPage({Key? key, required this.serviceType}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final List<TextEditingController> _carNumberControllers = [];

  @override
  void initState() {
    super.initState();
    if (widget.serviceType == 'نقليات') {
      _addCarNumberField(); // Start with one car number field
    }
  }

  void _addCarNumberField() {
    setState(() {
      _carNumberControllers.add(TextEditingController());
    });
  }

  void _removeCarNumberField(int index) {
    setState(() {
      _carNumberControllers.removeAt(index);
    });
  }

  @override
  void dispose() {
    for (var controller in _carNumberControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("تسجيل الخدمة"),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF556B2F), Color(0xFFFFFFFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // العبارة الترحيبية
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF556B2F),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    spreadRadius: 1,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.assignment, size: 60, color: Colors.white),
                  const SizedBox(height: 10),
                  const Text(
                    "مرحبا بك!",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "الخدمة التي اخترتها: ${widget.serviceType}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // حقل نوع الخدمة (معبأ مسبقًا وغير قابل للتعديل)
            _buildTextField(
              label: "نوع الخدمة",
              value: widget.serviceType,
              readOnly: true,
              icon: Icons.category,
            ),
            const SizedBox(height: 20),

            // الحقول الأخرى بناءً على نوع الخدمة
            ..._getFieldsForService(widget.serviceType).map((field) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: _buildTextField(
                    label: field,
                    icon: field == 'رابط الفيسبوك'
                        ? Icons.link
                        : field == 'كلمة السر'
                            ? Icons.lock
                            : Icons.input,
                    isLinkField: field == 'رابط الفيسبوك' &&
                        widget.serviceType != 'منتجات زراعية',
                    isPasswordField: field == 'كلمة السر',
                  ),
                )),

            // حقل أرقام السيارات في حالة النقليات
            if (widget.serviceType == 'نقليات') ...[
              const SizedBox(height: 20),
              const Text(
                "أرقام السيارات:",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF556B2F),
                ),
              ),
              const SizedBox(height: 10),
              ..._carNumberControllers.asMap().entries.map((entry) {
                final index = entry.key;
                final controller = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller,
                          decoration: InputDecoration(
                            labelText: "رقم السيارة ${index + 1}",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        onPressed: () => _removeCarNumberField(index),
                        icon: const Icon(Icons.delete, color: Colors.red),
                      ),
                    ],
                  ),
                );
              }).toList(),
              ElevatedButton.icon(
                onPressed: _addCarNumberField,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text("إضافة رقم سيارة جديد"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF556B2F),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 30),

            ElevatedButton.icon(
              onPressed: () {
                // Navigate to HomePage with user data
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomePage(
                      serviceType: widget.serviceType,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.send, color: Colors.white),
              label: const Text(
                "تسجيل",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                backgroundColor: const Color(0xFF556B2F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    String? value,
    bool readOnly = false,
    IconData? icon,
    bool isLinkField = false,
    bool isPasswordField = false,
  }) {
    return TextField(
      controller: value != null ? TextEditingController(text: value) : null,
      readOnly: readOnly,
      keyboardType:
          isLinkField ? TextInputType.url : TextInputType.text, // نوع الإدخال
      obscureText: isPasswordField, // إخفاء النص إذا كان حقل كلمة السر
      textInputAction: isLinkField
          ? TextInputAction.go
          : TextInputAction.next, // حركة الكيبورد
      decoration: InputDecoration(
        labelText: label,
        prefixIcon:
            icon != null ? Icon(icon, color: const Color(0xFF556B2F)) : null,
        labelStyle: const TextStyle(color: Color(0xFF556B2F)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        filled: true,
        fillColor: Colors.white,
        hintText: isLinkField ? 'https://example.com' : null, // النص التوضيحي
      ),
    );
  }

  List<String> _getFieldsForService(String serviceType) {
    switch (serviceType) {
      case 'معاصر':
        return [
          'اسم المعصرة',
          'اسم المالك',
          'رقم الهاتف',
          'عنوان المعصرة',
          'رابط الفيسبوك',
          'كلمة السر'
        ];
      case 'مطاحن':
        return [
          'اسم المطحنة',
          'اسم المالك',
          'رقم الهاتف',
          'عنوان المطحنة',
          'رابط الفيسبوك',
          'كلمة السر'
        ];
      case 'الحسبة':
        return [
          'اسم الحسبة',
          'اسم المالك',
          'رقم الهاتف',
          'عنوان الحسبة',
          'رابط الفيسبوك',
          'كلمة السر'
        ];
      case 'نقليات':
        return ['اسم شركة النقليات', 'اسم المالك', 'رقم الهاتف', 'كلمة السر'];
      case 'منتجات زراعية':
        return [
          'اسم المتجر',
          'اسم المالك',
          'رقم الهاتف',
          'عنوان المتجر',
          'رابط الفيسبوك',
          'كلمة السر'
        ];
      default:
        return ['كلمة السر'];
    }
  }
}
