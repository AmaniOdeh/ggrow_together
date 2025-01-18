import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'homepageservice.dart';
import 'package:flutter/services.dart';
import 'signin.dart';
import 'map.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:image_picker/image_picker.dart';

// Constants for colors and styles
const Color primaryColor = Color(0xFF556B2F);
const Color whiteColor = Colors.white;

class SignUpPage extends StatefulWidget {
  final String serviceType;

  const SignUpPage({Key? key, required this.serviceType}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  late List<TextEditingController> _controllers;
  late List<Map<String, String>> _fields;
  bool _passwordVisible = false;
  double? _latitude;
  double? _longitude;
  final TextEditingController _addressController = TextEditingController();
  final latlng.LatLng _initialPosition = const latlng.LatLng(31.9539, 35.9106);
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isImageUploading = false;

  @override
  void initState() {
    super.initState();
    _fields = _getFieldsForService(widget.serviceType);
    _controllers =
        List.generate(_fields.length, (index) => TextEditingController());
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildWelcomeSection(),
            const SizedBox(height: 20),
            ..._buildTextFields(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: _buildAddressTextField(),
            ),
            const SizedBox(height: 20),
            _buildImagePickerSection(),
            const SizedBox(height: 20),
            _buildSubmitButton(),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginPage(),
                  ),
                );
              },
              child: const Text(
                "!هل لديك حساب بالفعل؟تسجيل الدخول",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                    decoration: TextDecoration.underline),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text("تسجيل الخدمة"),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor, whiteColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      centerTitle: true,
      elevation: 0,
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            spreadRadius: 1,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_outline, size: 60, color: whiteColor),
          const SizedBox(height: 10),
          const Text(
            "مرحبا بك!",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: whiteColor,
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
    );
  }

  List<Widget> _buildTextFields() {
    return List.generate(
      _fields.length,
      (index) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: _buildTextField(
          label: _fields[index]['label']!,
          controller: _controllers[index],
          icon: _getFieldIcons()[_fields[index]['label']],
          isPassword: _fields[index]['label'] == 'كلمة السر',
        ),
      ),
    );
  }

  Widget _buildAddressTextField() {
    return TextField(
      controller: _addressController,
      onTap: () {
        _navigateToMapPage(context);
      },
      decoration: InputDecoration(
        labelText: 'عنوان الخدمة',
        prefixIcon: const Icon(Icons.location_on, color: primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        filled: true,
        fillColor: whiteColor,
      ),
      readOnly: true,
    );
  }

  Future<void> _navigateToMapPage(BuildContext context) async {
    try {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MapTestPage(
            initialPosition: null,
            initialAddress: _addressController.text,
          ),
        ),
      );

      if (result != null && result is Map<String, dynamic>) {
        setState(() {
          _latitude = result['latitude'];
          _longitude = result['longitude'];
          _addressController.text = result['address'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لم يتم اختيار موقع.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ: $e')),
      );
    }
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    IconData? icon,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType:
          label == 'رقم الهاتف' ? TextInputType.number : TextInputType.text,
      obscureText: isPassword ? !_passwordVisible : false,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon, color: primaryColor) : null,
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _passwordVisible ? Icons.visibility : Icons.visibility_off,
                  color: primaryColor,
                ),
                onPressed: () {
                  setState(() {
                    _passwordVisible = !_passwordVisible;
                  });
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        filled: true,
        fillColor: whiteColor,
      ),
      inputFormatters: label == 'رقم الهاتف'
          ? [FilteringTextInputFormatter.digitsOnly]
          : null,
    );
  }

  Widget _buildImagePickerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 150,
            decoration: BoxDecoration(
              border: Border.all(
                color: primaryColor,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(12),
              color: whiteColor,
            ),
            child: _image != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      _image!,
                      fit: BoxFit.cover,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_alt,
                        size: 40,
                        color: primaryColor,
                      ),
                      Text(
                        "إضغط لإضافة صورة",
                        style: TextStyle(color: primaryColor),
                      ),
                    ],
                  ),
          ),
        ),
        if (_isImageUploading)
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: LinearProgressIndicator(),
          ),
      ],
    );
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } catch (e) {
      _showErrorDialog("حدث خطأ أثناء اختيار الصورة: $e");
    }
  }

  Widget _buildSubmitButton() {
    return ElevatedButton.icon(
      onPressed: _handleSubmit,
      icon: const Icon(Icons.check_circle_outline, color: whiteColor),
      label: const Text(
        "تسجيل",
        style: TextStyle(fontSize: 18, color: whiteColor),
      ),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 15),
        backgroundColor: primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
    );
  }

  Map<String, IconData> _getFieldIcons() {
    return {
      'رابط الفيسبوك': Icons.link,
      'كلمة السر': Icons.lock,
      'رقم الهاتف': Icons.phone,
      'اسم المالك': Icons.person,
      'اسم المعصرة': Icons.factory,
      'اسم المطحنة': Icons.agriculture,
    };
  }

  List<Map<String, String>> _getFieldsForService(String serviceType) {
    switch (serviceType) {
      case 'معاصر':
        return [
          {'label': 'اسم المعصرة', 'key': 'pressName'},
          {'label': 'اسم المالك', 'key': 'ownerName'},
          {'label': 'رقم الهاتف', 'key': 'phoneNumber'},
          {'label': 'رابط الفيسبوك', 'key': 'facebookLink'},
          {'label': 'كلمة السر', 'key': 'password'},
        ];
      case 'مطاحن':
        return [
          {'label': 'اسم المطحنة', 'key': 'millName'},
          {'label': 'اسم المالك', 'key': 'ownerName'},
          {'label': 'رقم الهاتف', 'key': 'phoneNumber'},
          {'label': 'رابط الفيسبوك', 'key': 'facebookLink'},
          {'label': 'كلمة السر', 'key': 'password'},
        ];
      case 'الحسبة':
        return [
          {'label': 'اسم الحسبة', 'key': 'marketName'},
          {'label': 'اسم المالك', 'key': 'ownerName'},
          {'label': 'رقم الهاتف', 'key': 'phoneNumber'},
          {'label': 'رابط الفيسبوك', 'key': 'facebookLink'},
          {'label': 'كلمة السر', 'key': 'password'},
        ];
      case 'نقليات':
        return [
          {'label': 'اسم شركة النقليات', 'key': 'transportCompanyName'},
          {'label': 'اسم المالك', 'key': 'ownerName'},
          {'label': 'رقم الهاتف', 'key': 'phoneNumber'},
          {'label': 'رابط الفيسبوك', 'key': 'facebookLink'},
          {'label': 'كلمة السر', 'key': 'password'},
        ];
      case 'منتجات زراعية':
        return [
          {'label': 'اسم المتجر', 'key': 'storeName'},
          {'label': 'اسم المالك', 'key': 'ownerName'},
          {'label': 'رقم الهاتف', 'key': 'phoneNumber'},
          {'label': 'رابط الفيسبوك', 'key': 'facebookLink'},
          {'label': 'كلمة السر', 'key': 'password'},
        ];
      default:
        return [
          {'label': 'كلمة السر', 'key': 'password'},
        ];
    }
  }

  Future<void> _handleSubmit() async {
    final Map<String, String> data = {};

    for (int i = 0; i < _fields.length; i++) {
      final controller = _controllers[i];
      final fieldKey = _fields[i]['key']!;
      final fieldLabel = _fields[i]['label']!;
      if (controller.text.isEmpty) {
        _showErrorDialog("يرجى تعبئة الحقل: $fieldLabel");
        return;
      }
      data[fieldKey] = controller.text.trim();
    }

    final address = _addressController.text.trim();
    if (address.isEmpty) {
      _showErrorDialog("يرجى تعبئة حقل العنوان.");
      return;
    }
    if (_latitude == null || _longitude == null) {
      _showErrorDialog("الرجاء التأكد من تعبئة العنوان بشكل صحيح.");
      return;
    }

    data['latitude'] = _latitude.toString();
    data['longitude'] = _longitude.toString();
    data['address'] = address;

    String? base64Image;
    if (_image != null) {
      List<int> imageBytes = await _image!.readAsBytes();
      base64Image = base64Encode(imageBytes);
    }
    if (base64Image != null) {
      data['imageData'] = base64Image;
    } else {
      _showErrorDialog("يرجى اضافة صورة للخدمة.");
      return;
    }

    String url =
        'http://192.168.1.10:2000/${_mapServiceType(widget.serviceType)}/signup';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        if (responseData['user'] != null &&
            responseData['user']['userId'] != null) {
          final String userId = responseData['user']['userId'];

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(
                serviceType: widget.serviceType,
                userId: userId,
              ),
            ),
          );
        } else {
          _showErrorDialog("بيانات المستخدم غير صحيحة.");
        }
      } else {
        _showErrorDialog("حدث خطأ أثناء التسجيل: ${response.body}");
      }
    } catch (e) {
      _showErrorDialog("تعذر الاتصال بالخادم: $e");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("خطأ"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("موافق"),
          ),
        ],
      ),
    );
  }

  String _mapServiceType(String serviceType) {
    switch (serviceType) {
      case 'معاصر':
        return 'service1';
      case 'مطاحن':
        return 'service2';
      case 'الحسبة':
        return 'service3';
      case 'نقليات':
        return 'service4';
      case 'منتجات زراعية':
        return 'service5';
      default:
        return 'unknown';
    }
  }
}
