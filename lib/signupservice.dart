import 'package:flutter/material.dart';

import 'homepageservice.dart';

class SignUpPage extends StatefulWidget {
  final String serviceType;

  const SignUpPage({Key? key, required this.serviceType}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
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
            // Welcome Section
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
                  const Icon(Icons.person_outline, size: 60, color: Colors.white),
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

            // Service Type Field (Read-Only)
            _buildTextField(
              label: "نوع الخدمة",
              value: widget.serviceType,
              readOnly: true,
              icon: Icons.category,
            ),
            const SizedBox(height: 20),

            // Dynamic Fields Based on Service Type
            ..._getFieldsForService(widget.serviceType).map((field) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: _buildTextField(
                    label: field,
                    icon: _getIconForField(field),
                  ),
                )),

            const SizedBox(height: 30),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomePage(
                      serviceType: widget.serviceType,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.check_circle_outline, color: Colors.white),
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
  }) {
    return TextField(
      controller: value != null ? TextEditingController(text: value) : null,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon, color: const Color(0xFF556B2F)) : null,
        labelStyle: const TextStyle(color: Color(0xFF556B2F)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  IconData _getIconForField(String field) {
    switch (field) {
      case 'رابط الفيسبوك':
        return Icons.link;
      case 'كلمة السر':
        return Icons.lock;
      case 'رقم الهاتف':
        return Icons.phone;
      case 'عنوان المعصرة':
      case 'عنوان المطحنة':
      case 'عنوان الحسبة':
      case 'عنوان المتجر':
        return Icons.location_on;
      case 'اسم المالك':
        return Icons.person;
      default:
        return Icons.text_fields;
    }
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
