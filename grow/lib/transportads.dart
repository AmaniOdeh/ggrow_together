import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'map.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/foundation.dart';

class TransportAdsPage extends StatefulWidget {
  final String userId;
  final String serviceType;

  TransportAdsPage({Key? key, required this.serviceType, required this.userId})
      : super(key: key);

  @override
  _TransportAdsPageState createState() => _TransportAdsPageState();
}

class _TransportAdsPageState extends State<TransportAdsPage> {
  bool _isLoading = true;
  String companyName = "";
  String companyNumber = "";
  String companyAddress = "";
  String ownerName = "";
  final _formKey = GlobalKey<FormState>();
  String _selectedDescription = "";
  final List<String> _descriptionExamples = [
    "النقل مجاني بالكامل ونسبة 15% من الزيتون لكل نقلة ناجحة.",
    "نقل الزيتون مضمون مع مكافأة 15% من المحصول.",
    "النقل مجاني مع مكافآت إضافية للكميات الكبيرة.",
    "نسبة 7% من الزيتون مقابل نقل مدعوم بالكامل.",
    "النقل مجاني طوال موسم الحصاد مع مكافآت إضافية يومية.",
    "نسبة 10% من الزيتون مع كل نقلة ومكافأة للكميات فوق 300 كيلو.",
  ];

  @override
  void initState() {
    super.initState();
    _fetchCompanyData();
  }

  Future<void> _fetchCompanyData() async {
    setState(() {
      _isLoading = true;
    });
    String apiUrl = 'http://192.168.1.10:2000/service1/myServiceDetails';

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

      final response = await http
          .get(Uri.parse(apiUrl), headers: {"Authorization": "Bearer $token"});

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          setState(() {
            companyName = data['companyName']?.toString() ?? "غير متوفر";
            companyNumber = data['contactNumber']?.toString() ?? "غير متوفر";
            companyAddress = data['serviceAddress']?.toString() ?? "غير متوفر";
            ownerName = data['ownerName']?.toString() ?? "غير متوفر";
          });
        } catch (e) {
          _showErrorDialog("فشل تحليل البيانات: $e");
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        _showErrorDialog(
            "فشل جلب البيانات: ${response.statusCode} - ${response.body}");
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog("تعذر الاتصال بالخادم: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _submitAd() async {
    if (_formKey.currentState!.validate()) {
      final String apiUrl = 'http://192.168.1.10:2000/api/transportad';
      try {
        setState(() {
          _isLoading = true;
        });
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');

        if (token == null || token.isEmpty) {
          _showErrorDialog("Token not found, Please login again");
          setState(() {
            _isLoading = false;
          });
          return;
        }

        final Map<String, dynamic> requestBody = {
          'adDetails': _selectedDescription,
          'openingHours': '00:00',
          'workingHours': '23:59',
        };
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            "Authorization": "Bearer $token"
          },
          body: jsonEncode(requestBody),
        );

        if (response.statusCode == 201) {
          _showSuccessDialog('تم إنشاء الإعلان بنجاح');
          setState(() {
            _selectedDescription = "";
          });
        } else {
          _showErrorDialog(
              'Failed to create add: ${response.statusCode} - ${response.body} ');
        }
      } catch (e) {
        _showErrorDialog('Error creating the ad: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        title: Text(
          "نجاح",
          style: GoogleFonts.cairo(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF556B2F),
          ),
          textAlign: TextAlign.center,
        ),
        content: Text(
          message,
          style: GoogleFonts.cairo(
            fontSize: 16,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF556B2F),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: Text(
                "موافق",
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        title: Text(
          "خطأ",
          style: GoogleFonts.cairo(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
          textAlign: TextAlign.center,
        ),
        content: Text(
          message,
          style: GoogleFonts.cairo(
            fontSize: 16,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: Text(
                "موافق",
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "إعلان خاص للنقليات",
          style: GoogleFonts.cairo(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF556B2F), Color(0xFFFFFFFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildInfoCard(
                        title: "تفاصيل العرض",
                        children: [
                          _buildInfoRow("اسم المعصرة", companyName),
                          _buildInfoRow("رقم التواصل", companyNumber),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "عرض العنوان على الخريطة",
                                style: GoogleFonts.cairo(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF556B2F),
                                ),
                                textAlign: TextAlign.right,
                              ),
                              InkWell(
                                onTap: () {
                                  final latLng = _parseLatLng(companyAddress);
                                  if (latLng != null) {
                                    _navigateToMapPage(context, latLng.latitude,
                                        latLng.longitude, companyAddress);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('عنوان غير صالح')),
                                    );
                                  }
                                },
                                child: _buildInfoRow(
                                    "عنوان المعصرة", companyAddress),
                              ),
                            ],
                          ),
                          _buildInfoRow("اسم المالك", ownerName),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildInfoCard(
                        title: "تفاصيل العرض",
                        children: [
                          DropdownButtonFormField<String>(
                            isExpanded: true, // إضافة هذا السطر
                            decoration: InputDecoration(
                                labelText: "وصف العرض",
                                border: const OutlineInputBorder(),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 15)),
                            value: _selectedDescription.isEmpty
                                ? null
                                : _selectedDescription,
                            items: _descriptionExamples.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: GoogleFonts.cairo(),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedDescription = value!;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'الرجاء اختيار او كتابة وصف العرض';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          if (_selectedDescription.isEmpty)
                            TextFormField(
                              maxLines: 3,
                              style: GoogleFonts.cairo(),
                              decoration: InputDecoration(
                                  labelText: "او اكتب وصف العرض هنا",
                                  border: const OutlineInputBorder(),
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 15)),
                              onChanged: (value) {
                                setState(() {
                                  _selectedDescription = value;
                                });
                              },
                              validator: (value) {
                                if (_selectedDescription.isEmpty) {
                                  return 'الرجاء اختيار او كتابة وصف العرض';
                                }
                                return null;
                              },
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          onPressed: _submitAd,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF556B2F),
                            padding: const EdgeInsets.symmetric(
                                vertical: 20, horizontal: 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          child: Text(
                            "إنشاء الإعلان",
                            style: GoogleFonts.cairo(
                                fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF556B2F),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // القيمة (اليسار)
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: GoogleFonts.cairo(fontSize: 16),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              textAlign: TextAlign.left, // محاذاة لليسار
            ),
          ),
          const SizedBox(width: 8),
          // الاسم (اليمين)
          Expanded(
            flex: 1,
            child: Text(
              label,
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              textAlign: TextAlign.right, // محاذاة لليمين
            ),
          ),
        ],
      ),
    );
  }

  latlng.LatLng? _parseLatLng(String address) {
    try {
      final parts = address.split(',');
      if (parts.length == 2) {
        final lat = double.tryParse(parts[0].trim());
        final lng = double.tryParse(parts[1].trim());
        if (lat != null && lng != null) {
          return latlng.LatLng(lat, lng);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
