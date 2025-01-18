import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'map.dart';
import 'package:latlong2/latlong.dart' as latlng;

class MyAdsPage extends StatefulWidget {
  final String serviceType;

  const MyAdsPage({Key? key, required this.serviceType}) : super(key: key);

  @override
  _MyAdsPageState createState() => _MyAdsPageState();
}

class _MyAdsPageState extends State<MyAdsPage> {
  File? _selectedImage;
  List<dynamic> _ads = [];
  bool _isLoading = false;
  final String _apiBaseUrl = 'http://192.168.1.10:2000';

  @override
  void initState() {
    super.initState();
    _fetchUserAds();
  }

  Future<void> _fetchUserAds() async {
    setState(() {
      _isLoading = true;
    });
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      _showErrorDialog("Token not found, please login again");
      setState(() {
        _isLoading = false;
      });
      return;
    }
    final apiUrl = '$_apiBaseUrl/ad/${widget.serviceType}/myAds';
    print('Fetching ads from: $apiUrl');

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        setState(() {
          _ads = decodedResponse['ads'];
          _isLoading = false;
        });
      } else {
        _handleApiError(response.statusCode, response.body);
      }
    } catch (e) {
      _handleException(e);
    }
  }

  String _mapServiceType(String serviceType) {
    switch (serviceType) {
      case 'service1':
        return 'معاصر';
      case 'service2':
        return 'مطاحن';
      case 'service3':
        return 'الحسبة';
      case 'service4':
        return 'نقليات';
      case 'service5':
        return 'منتجات زراعية';
      default:
        return '';
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("إعلاناتي"),
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
          : _ads.isEmpty
              ? const Center(child: Text("لا يوجد إعلانات"))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView.builder(
                    itemCount: _ads.length,
                    itemBuilder: (context, index) {
                      return _buildAdCard(context, _ads[index]);
                    },
                  ),
                ),
    );
  }

  Widget _buildAdCard(BuildContext context, Map<String, dynamic> ad) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (ad["imageData"] != null)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Image.memory(
                base64Decode(ad["imageData"]),
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (BuildContext context, Object exception,
                    StackTrace? stackTrace) {
                  print('Error loading image: ${ad["imageData"]}');
                  print('Exception: $exception');
                  print('Stack Trace: $stackTrace');
                  return const SizedBox(
                    height: 200,
                    child: Center(
                        child: Icon(Icons.image_not_supported,
                            size: 60, color: Colors.grey)),
                  );
                },
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow("اسم الشركة:", ad["companyName"] ?? ''),
                _buildDetailRow("رقم التواصل:", ad["contactNumber"] ?? ''),
                _buildDetailRow(
                    "نوع الخدمة:", _mapServiceType(ad["serviceType"] ?? '')),
                _buildDetailRow("سعر الخصم:", ad["discountPrice"] ?? ''),
                _buildDetailRow("تفاصيل الإعلان:", ad["adDetails"] ?? ''),
                InkWell(
                  onTap: () {
                    _navigateToMapPage(
                      context,
                      ad['latitude'] != null
                          ? double.tryParse(ad['latitude'].toString())
                          : null,
                      ad['longitude'] != null
                          ? double.tryParse(ad['longitude'].toString())
                          : null,
                      ad["serviceAddress"],
                    );
                  },
                  child: _buildDetailRow(
                    "عنوان الخدمة:",
                    ad["serviceAddress"] ?? '',
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        _editAd(ad);
                      },
                      icon: const Icon(Icons.edit, color: Colors.white),
                      label: const Text(
                        "تعديل",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF556B2F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        _deleteAd(ad);
                      },
                      icon: const Icon(Icons.delete, color: Colors.white),
                      label: const Text(
                        "حذف",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              label,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF556B2F),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _editAd(Map<String, dynamic> ad) {
    showDialog(
      context: context,
      builder: (context) {
        File? selectedImage;
        String? tempServiceType = ad['serviceType'];
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text("تعديل الإعلان"),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildEditableField(
                    label: "اسم الشركة",
                    initialValue: ad["companyName"] ?? '',
                    onChanged: (value) => ad["companyName"] = value,
                  ),
                  const SizedBox(height: 10),
                  _buildEditableField(
                    label: "رقم التواصل",
                    initialValue: ad["contactNumber"] ?? '',
                    onChanged: (value) => ad["contactNumber"] = value,
                  ),
                  const SizedBox(height: 10),
                  _buildEditableField(
                    label: "نوع الخدمة",
                    initialValue: _mapServiceType(ad["serviceType"] ?? ''),
                    onChanged: (value) {
                      tempServiceType = _getServiceTypeKey(value);
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildEditableField(
                    label: "سعر الخصم",
                    initialValue: ad["discountPrice"] ?? '',
                    onChanged: (value) => ad["discountPrice"] = value,
                  ),
                  const SizedBox(height: 10),
                  _buildEditableField(
                    label: "تفاصيل الإعلان",
                    initialValue: ad["adDetails"] ?? '',
                    maxLines: 3,
                    onChanged: (value) => ad["adDetails"] = value,
                  ),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MapTestPage(
                            initialPosition: ad['latitude'] != null &&
                                    ad['longitude'] != null
                                ? latlng.LatLng(
                                    double.tryParse(ad['latitude'].toString())!,
                                    double.tryParse(
                                        ad['longitude'].toString())!)
                                : null,
                            initialAddress: ad["serviceAddress"],
                          ),
                        ),
                      );
                      if (result != null && result is Map<String, dynamic>) {
                        ad["latitude"] = result['latitude'].toString();
                        ad["longitude"] = result['longitude'].toString();
                        ad["serviceAddress"] = result['address'];
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: "عنوان الخدمة",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        child: Text(
                          ad["serviceAddress"] ?? '',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      final pickedFile = await ImagePicker()
                          .pickImage(source: ImageSource.gallery);
                      if (pickedFile != null) {
                        setState(() {
                          selectedImage = File(pickedFile.path);
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF556B2F),
                    ),
                    child: const Text(
                      "تغيير الصورة",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  if (selectedImage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Image.file(
                        selectedImage!,
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("إلغاء"),
              ),
              ElevatedButton(
                onPressed: () {
                  ad['serviceType'] = tempServiceType;
                  _updateAd(ad, selectedImage);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF556B2F),
                ),
                child: const Text(
                  "حفظ",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        });
      },
    );
  }

  Widget _buildEditableField({
    required String label,
    required String initialValue,
    required Function(String) onChanged,
    int maxLines = 1,
  }) {
    String initialText =
        label == "نوع الخدمة" ? _mapServiceType(initialValue) : initialValue;
    return TextFormField(
      initialValue: initialText,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      onChanged: onChanged,
    );
  }

  Future<void> _navigateToMapPage(BuildContext context, double? initialLatitude,
      double? initialLongitude, String? initialAddress) async {
    try {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MapTestPage(
            initialPosition: initialLatitude != null && initialLongitude != null
                ? latlng.LatLng(initialLatitude, initialLongitude)
                : null,
            initialAddress: initialAddress,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ: $e')),
      );
    }
  }

  Future<void> _updateAd(Map<String, dynamic> ad, File? image) async {
    setState(() {
      _isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      _showErrorDialog("Token not found, please login again");
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final apiUrl = '$_apiBaseUrl/ad/${ad["_id"]}/updateAd';

    try {
      // تجهيز البيانات المحدثة فقط
      Map<String, dynamic> fieldsToUpdate = {};
      ad.forEach((key, value) {
        if (value != null) {
          fieldsToUpdate[key] = value;
        }
      });

      print("Fields to Update: $fieldsToUpdate");

      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(fieldsToUpdate), // ترميز البيانات إلى JSON
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        _fetchUserAds();
        _showSuccessPopup('تم تعديل الإعلان بنجاح');
      } else {
        _handleApiError(response.statusCode, response.body);
      }
    } catch (e) {
      _handleException(e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteAd(Map<String, dynamic> ad) async {
    setState(() {
      _isLoading = true;
    });
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      _showErrorDialog("Token not found, please login again");
      setState(() {
        _isLoading = false;
      });
      return;
    }
    final apiUrl = '$_apiBaseUrl/ad/${ad["_id"]}/deleteAd';
    print("delete ad url: $apiUrl");
    try {
      final response = await http.delete(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        _fetchUserAds();
        _showSuccessPopup('تم حذف الإعلان بنجاح');
      } else {
        _handleApiError(response.statusCode, response.body);
      }
    } catch (e) {
      _handleException(e);
    } finally {
      setState(() {
        _isLoading = false;
      });
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

  void _handleApiError(int statusCode, String errorBody) {
    setState(() {
      _isLoading = false;
    });
    _showErrorDialog('Failed to perform operation: $statusCode, $errorBody');
  }

  void _handleException(e) {
    setState(() {
      _isLoading = false;
    });
    _showErrorDialog('Error communicating with server: $e');
  }
}
