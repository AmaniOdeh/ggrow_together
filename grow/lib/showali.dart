import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AdsManagementPage extends StatefulWidget {
  final String userId;

  const AdsManagementPage({Key? key, required this.userId}) : super(key: key);

  @override
  _AdsManagementPageState createState() => _AdsManagementPageState();
}

class _AdsManagementPageState extends State<AdsManagementPage> {
  bool _isLoading = true;
  List<dynamic> ads = [];

  @override
  void initState() {
    super.initState();
    _fetchAds();
  }

  Future<void> _fetchAds() async {
    setState(() {
      _isLoading = true;
    });
    String apiUrl = 'http://192.168.1.10:2000/api/transportad/all';

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null || token.isEmpty) {
        _showErrorDialog("Token not found, Please login again");
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        setState(() {
          ads = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        _showErrorDialog('Failed to load ads: ${response.statusCode}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      _showErrorDialog('Error fetching ads: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteAd(String adId) async {
    String apiUrl = 'http://192.168.1.10:2000/api/transportad/$adId';
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

      final response = await http.delete(
        Uri.parse(apiUrl),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        setState(() {
          ads.removeWhere((ad) => ad['_id'] == adId);
          _isLoading = false;
        });
        _showSuccessDialog("تم حذف الإعلان بنجاح");
      } else {
        _showErrorDialog('Failed to delete ad: ${response.statusCode}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      _showErrorDialog('Error deleting ad: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _editAd(String adId, String newDescription) async {
    String apiUrl = 'http://192.168.1.10:2000/api/transportad/$adId';
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

      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json"
        },
        body: jsonEncode({'adDetails': newDescription}),
      );

      if (response.statusCode == 200) {
        _fetchAds();
        _showSuccessDialog("تم تعديل الإعلان بنجاح");
      } else {
        _showErrorDialog('Failed to edit ad: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorDialog('Error editing ad: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showEditDialog(String adId, String currentDescription) {
    final TextEditingController descriptionController =
        TextEditingController(text: currentDescription);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("تعديل الإعلان"),
        content: TextField(
          controller: descriptionController,
          decoration: const InputDecoration(
            labelText: "الوصف الجديد",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إلغاء"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _editAd(adId, descriptionController.text);
            },
            child: const Text("حفظ"),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showErrorDialog(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("إعلانات النقل"),
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
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: ads.length,
              itemBuilder: (context, index) {
                final ad = ads[index];
                return _buildAdCard(ad);
              },
            ),
    );
  }

  Widget _buildAdCard(dynamic ad) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ad['companyName'] ?? 'غير متوفر',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF556B2F),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'اسم المالك: ${ad['ownerName'] ?? 'غير متوفر'}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              'رقم التواصل: ${ad['contactNumber'] ?? 'غير متوفر'}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              'عنوان الخدمة: ${ad['serviceAddress'] ?? 'غير متوفر'}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              'وصف الإعلان: ${ad['adDetails'] ?? 'لا يوجد وصف للإعلان'}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () => _showEditDialog(ad['_id'], ad['adDetails']),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF556B2F),
                      foregroundColor: Colors.white),
                  child: const Text(
                    'تعديل',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _deleteAd(ad['_id']),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF556B2F),
                    foregroundColor: Colors.white,
                  ),
                  child:
                      const Text('حذف', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
