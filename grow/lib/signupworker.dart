import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'workerhomepage.dart';

class SignUpWorker extends StatefulWidget {
  final String baseUrl;

  const SignUpWorker({super.key, required this.baseUrl});

  @override
  _SignUpWorkerState createState() => _SignUpWorkerState();
}

class _SignUpWorkerState extends State<SignUpWorker> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _skillsController = TextEditingController();
  final TextEditingController _toolsController = TextEditingController();
  final TextEditingController _workAreasController = TextEditingController();
  final TextEditingController _governorateController = TextEditingController();
  final TextEditingController _localityController = TextEditingController();
  final TextEditingController _streetNameController = TextEditingController();

  bool isGuarantor = false;
  File? _profileImage;
  bool _isPasswordVisible = false;
  bool showAdditionalFields = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF556B2F)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Align(
                alignment: Alignment.center,
                child: Text(
                  " 👷‍♂️تسجيل العامل ",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey.shade300,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : const AssetImage(
                                  'profilephoto/default-profile-photo.jpg')
                              as ImageProvider,
                    ),
                    Positioned(
                      bottom: 5,
                      right: 5,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: const CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.edit,
                            color: Color(0xFF556B2F),
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (!showAdditionalFields) ...[
                _buildTextField('اسم المستخدم', _usernameController),
                _buildTextField('البريد الإلكتروني', _emailController),
                _buildPasswordField('كلمة المرور', _passwordController),
                _buildPasswordField(
                    'تأكيد كلمة المرور', _confirmPasswordController),
                _buildTextField('رقم الهاتف', _phoneNumberController,
                    keyboardType: TextInputType.phone),
                Row(
                  children: [
                    Checkbox(
                      value: isGuarantor,
                      activeColor: const Color(0xFF556B2F),
                      onChanged: (value) {
                        setState(() {
                          isGuarantor = value ?? false;
                        });
                      },
                    ),
                    const Text(
                      'هل ترغب أن تكون ضامنًا؟',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF556B2F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        showAdditionalFields = true;
                      });
                    }
                  },
                  child: const Text(
                    'التالي',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ] else ...[
                _buildTextField('المهارات', _skillsController),
                _buildTextField('الأدوات', _toolsController),
                _buildTextField(
                    'المناطق التي يمكنك العمل فيها', _workAreasController),
                _buildTextField('المحافظة', _governorateController),
                _buildTextField('البلد/قرية/مخيم', _localityController),
                _buildTextField('اسم الشارع', _streetNameController),
                const SizedBox(height: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF556B2F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              WorkerHomePage(), // قم بتعريف الصفحة هنا
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'إكمال التسجيل',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF556B2F), fontSize: 16),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
          filled: true,
          fillColor: const Color(0xFF2E7D32).withOpacity(0.1),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'الرجاء إدخال $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextFormField(
        controller: controller,
        obscureText: !_isPasswordVisible,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF556B2F), fontSize: 16),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
          filled: true,
          fillColor: const Color(0xFF556B2F).withOpacity(0.1),
          suffixIcon: IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: const Color(0xFF556B2F),
              size: 20,
            ),
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'الرجاء إدخال $label';
          }
          return null;
        },
      ),
    );
  }
}
