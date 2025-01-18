import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geocoding/geocoding.dart';
import 'map.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'dart:ui'; // Required for TextDirection.rtl

class CreateAdPage extends StatefulWidget {
  final String serviceType;
  final String userId;

  const CreateAdPage(
      {Key? key, required this.serviceType, required this.userId})
      : super(key: key);

  @override
  _CreateAdPageState createState() => _CreateAdPageState();
}

class _CreateAdPageState extends State<CreateAdPage> {
  final _formKey = GlobalKey<FormState>();
  late String companyName;
  late String contactNumber;
  late String discountPrice;
  late String adDetails;
  late String serviceAddress;
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  double? _latitude;
  double? _longitude;
  File? _selectedImage;
  bool _isLoading = false;
  String _fetchedServiceType = "";

  @override
  void initState() {
    super.initState();
    companyName = "";
    contactNumber = "";
    adDetails = "";
    serviceAddress = "";
    _fetchCompanyData();
  }

  String _getServiceTypeKey(String serviceType) {
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
        return '';
    }
  }

  Future<void> _fetchCompanyData() async {
    setState(() {
      _isLoading = true;
    });
    String apiUrl =
        'http://192.168.1.10:2000/${widget.serviceType}/myServiceDetails';

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      print('Token: $token');
      if (token == null || token.isEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showErrorDialog("Token not found, Please login again");
        });
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final response = await http
          .get(Uri.parse(apiUrl), headers: {"Authorization": "Bearer $token"});

      print('Response Body: ${response.body}');
      print('Response Status Code: ${response.statusCode}');
      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          setState(() {
            companyName = data['companyName']?.toString() ?? "";
            contactNumber = data['contactNumber']?.toString() ?? "";
            _latitude = data['latitude'];
            _longitude = data['longitude'];
            serviceAddress = data['serviceAddress']?.toString() ?? "";
            _addressController.text = data['serviceAddress']?.toString() ?? "";
            _fetchedServiceType = data['serviceType']?.toString() ?? "";
            print('Fetched _fetchedServiceType: $_fetchedServiceType');
          });
          if (_latitude != null &&
              _longitude != null &&
              (serviceAddress.isEmpty || serviceAddress.trim().isEmpty)) {
            await _getAddressFromCoordinates();
          }
        } catch (e) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showErrorDialog("فشل تحليل البيانات: $e");
          });
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showErrorDialog(
              "فشل جلب البيانات: ${response.statusCode} - ${response.body}");
        });
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorDialog("تعذر الاتصال بالخادم: $e");
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getAddressFromCoordinates() async {
    if (_latitude == null || _longitude == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorDialog("لا يمكن جلب العنوان لعدم وجود إحداثيات");
      });
      return;
    }
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(_latitude!, _longitude!);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          serviceAddress =
              "${place.street ?? ''}, ${place.locality ?? ''}, ${place.administrativeArea ?? ''}, ${place.country ?? ''}";
          _addressController.text =
              "${place.street ?? ''}, ${place.locality ?? ''}, ${place.administrativeArea ?? ''}, ${place.country ?? ''}";
        });
        print("العنوان: $serviceAddress");
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showErrorDialog("لم يتم العثور على عنوان");
        });
      }
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorDialog("خطأ أثناء جلب العنوان: $e");
      });
    }
  }

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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildDecoratedField(
                      label: 'اسم الشركة',
                      icon: Icons.business,
                      hintText: 'اسم الشركة',
                      initialValue: companyName,
                      onChanged: (value) => companyName = value,
                    ),
                    const SizedBox(height: 10),
                    _buildDecoratedField(
                      label: 'رقم التواصل',
                      icon: Icons.phone,
                      hintText: 'رقم الهاتف',
                      initialValue: contactNumber,
                      keyboardType: TextInputType.phone,
                      onChanged: (value) => contactNumber = value,
                    ),
                    if (widget.serviceType != 'نقليات')
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: _buildAddressTextField(),
                      ),
                    if (widget.serviceType != 'نقليات')
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5.0),
                              child: _buildTimePickerField(
                                label: 'بداية الدوام',
                                icon: Icons.access_time,
                                controller: _startTimeController,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5.0),
                              child: _buildTimePickerField(
                                label: 'نهاية الدوام',
                                icon: Icons.access_time,
                                controller: _endTimeController,
                              ),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 10),
                    _buildDecoratedField(
                      label: 'تفاصيل الإعلان',
                      icon: Icons.description,
                      hintText: 'تفاصيل الإعلان',
                      maxLines: 3,
                      onChanged: (value) => adDetails = value,
                    ),
                    const SizedBox(height: 20),
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
                    ElevatedButton.icon(
                      onPressed: _submitAd,
                      icon: const Icon(Icons.check_circle_outline,
                          color: Colors.white),
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

  Widget _buildAddressTextField() {
    return InkWell(
        onTap: () {
          _navigateToMapPage(context, _latitude, _longitude);
        },
        child: IgnorePointer(
          child: TextFormField(
            controller: _addressController,
            decoration: InputDecoration(
              labelText: 'عنوان الخدمة',
              prefixIcon:
                  const Icon(Icons.location_on, color: Color(0xFF556B2F)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            readOnly: true,
          ),
        ));
  }

  Future<void> _navigateToMapPage(BuildContext context, double? initialLatitude,
      double? initialLongitude) async {
    try {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MapTestPage(
            initialPosition: initialLatitude != null && initialLongitude != null
                ? latlng.LatLng(initialLatitude, initialLongitude)
                : null,
            initialAddress: _addressController.text,
          ),
        ),
      );

      if (result != null && result is Map<String, dynamic>) {
        setState(() {
          _latitude = result['latitude'];
          _longitude = result['longitude'];
          serviceAddress = result['address'];
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

  Widget _buildTimePickerField({
    required String label,
    IconData? icon,
    required TextEditingController controller,
  }) {
    return GestureDetector(
      onTap: () async {
        try {
          // Show the time picker
          final TimeOfDay? pickedTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
            builder: (BuildContext context, Widget? child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.light(
                    primary: const Color(0xFF556B2F), // Selection color
                  ),
                  buttonTheme: const ButtonThemeData(
                    textTheme: ButtonTextTheme.primary,
                  ),
                ),
                child: child ?? const SizedBox.shrink(), // Handle null safely
              );
            },
          );

          if (pickedTime != null) {
            // Format the picked time to HH:mm (24-hour format)
            final String formattedTime =
                "${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}";
            setState(() {
              controller.text = formattedTime; // Update the controller
            });
          }
        } catch (e) {
          print("Error picking time: $e"); // Debugging error
        }
      },
      child: AbsorbPointer(
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: icon != null
                ? Icon(icon, color: const Color(0xFF556B2F))
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "هذا الحقل مطلوب"; // Field is required
            }
            return null;
          },
          readOnly: true, // Make the field read-only
        ),
      ),
    );
  }

  Widget _buildDecoratedField({
    required String label,
    IconData? icon,
    String? hintText,
    TextEditingController? controller,
    String? initialValue,
    int maxLines = 1,
    TextInputType? keyboardType,
    required Function(String) onChanged,
  }) {
    String initialText = initialValue ?? "";
    return TextFormField(
      maxLines: maxLines,
      controller: controller,
      initialValue: initialText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon:
            icon != null ? Icon(icon, color: const Color(0xFF556B2F)) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "هذا الحقل مطلوب";
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

  void _showSuccessPopup(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: Text(
            message,
            style: const TextStyle(fontWeight: FontWeight.bold),
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

  Future<void> _submitAd() async {
    if (_formKey.currentState!.validate()) {
      if (widget.serviceType.isEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showErrorDialog("نوع الخدمة غير معروف. يرجى المحاولة مرة أخرى.");
        });
        return;
      }
      print('widget.serviceType: ${widget.serviceType}');
      setState(() {
        _isLoading = true;
      });
      String apiUrl = 'http://192.168.1.10:2000/ad/createAd';
      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        if (token == null || token.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showErrorDialog("Token not found, Please login again");
          });
          setState(() {
            _isLoading = false;
          });
          return;
        }
        final Map<String, dynamic> data = {
          '_fetchedServiceType': widget.serviceType,
          'companyName': companyName,
          'contactNumber': contactNumber,
          'adDetails': adDetails,
          'address': serviceAddress,
          'latitude': _latitude,
          'longitude': _longitude,
        };
        if (widget.serviceType != 'نقليات') {
          data['openingHours'] = _startTimeController.text;
          data['workingHours'] = _endTimeController.text;
        }
        String? base64Image;
        if (_selectedImage != null) {
          List<int> imageBytes = await _selectedImage!.readAsBytes();
          base64Image = base64Encode(imageBytes);
          data['imageData'] = base64Image;
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showErrorDialog("يرجى إضافة صورة للإعلان.");
          });
          setState(() {
            _isLoading = false;
          });
          return;
        }
        print('Data before send: $data');
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
          body: jsonEncode(data),
        );
        if (response.statusCode == 201) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showSuccessPopup("تم إضافة الإعلان بنجاح.");
          });
        } else {
          String error = response.body;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showErrorDialog("حدث خطأ: ${response.statusCode}, $error");
          });
        }
      } catch (e) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showErrorDialog("تعذر الاتصال بالخادم: $e");
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
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
}
