import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class CreateAdPage extends StatefulWidget {
  final String serviceType;

  const CreateAdPage({Key? key, required this.serviceType}) : super(key: key);

  @override
  _CreateAdPageState createState() => _CreateAdPageState();
}

class _CreateAdPageState extends State<CreateAdPage> {
  final _formKey = GlobalKey<FormState>();

  String companyName = "";
  String contactNumber = "";
  String serviceType = "";
  String discountPrice = "";
  String adDetails = "";
  File? _selectedImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("إنشاء إعلان"),
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF83A95C), Color(0xFF556B2F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
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
                  children: [
                    const Icon(Icons.campaign, size: 60, color: Colors.white),
                    const SizedBox(height: 10),
                    const Text(
                      "إعلان جديد",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "الخدمة: ${widget.serviceType}",
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

              // Ad Creation Fields
              _buildDecoratedField(
                label: 'اسم الشركة',
                icon: Icons.business,
                hintText: 'أدخل اسم الشركة',
                onChanged: (value) => companyName = value,
              ),
              const SizedBox(height: 10),
              _buildDecoratedField(
                label: 'رقم التواصل',
                icon: Icons.phone,
                hintText: 'أدخل رقم الهاتف',
                onChanged: (value) => contactNumber = value,
              ),
              const SizedBox(height: 10),
              _buildDecoratedField(
                label: 'نوع الخدمة',
                icon: Icons.category,
                hintText: 'أدخل نوع الخدمة',
                onChanged: (value) => serviceType = value,
              ),
              const SizedBox(height: 10),
              _buildDecoratedField(
                label: 'سعر الخصم',
                icon: Icons.attach_money,
                hintText: 'أدخل سعر الخصم',
                onChanged: (value) => discountPrice = value,
              ),
              const SizedBox(height: 10),
              _buildDecoratedField(
                label: 'تفاصيل الإعلان',
                icon: Icons.description,
                hintText: 'أدخل تفاصيل الإعلان',
                maxLines: 3,
                onChanged: (value) => adDetails = value,
              ),

              const SizedBox(height: 20),

              // Add Image Section
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: const Color(0xFF556B2F)),
                  ),
                  child: _selectedImage == null
                      ? const Center(
                          child: Text(
                            "اضغط لإضافة صورة",
                            style: TextStyle(color: Color(0xFF556B2F)),
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.file(
                            _selectedImage!,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 30),

              // Submit Button
              ElevatedButton.icon(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _showSuccessPopup();
                  }
                },
                icon:
                    const Icon(Icons.check_circle_outline, color: Colors.white),
                label: const Text(
                  "إنشاء الإعلان",
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
      ),
    );
  }

  Widget _buildDecoratedField({
    required String label,
    IconData? icon,
    String? hintText,
    int maxLines = 1,
    required Function(String) onChanged,
  }) {
    return TextFormField(
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon:
            icon != null ? Icon(icon, color: const Color(0xFF556B2F)) : null,
        labelStyle: const TextStyle(
            color: Color(0xFF556B2F), fontWeight: FontWeight.bold),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "يرجى ملء هذا الحقل";
        }
        return null;
      },
    );
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _showSuccessPopup() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: const Text(
            "!تم إضافة الإعلان بنجاح",
            style: TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF556B2F),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: const Text(
                  "موافق",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
