import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'map.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CombinedAdsListPage extends StatefulWidget {
  final String userId;
  final String serviceType;

  CombinedAdsListPage(
      {Key? key, required this.userId, required this.serviceType})
      : super(key: key);

  @override
  _CombinedAdsListPageState createState() => _CombinedAdsListPageState();
}

class _CombinedAdsListPageState extends State<CombinedAdsListPage> {
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
    String apiUrl = 'http://192.168.1.10:2000/api/combinedad/all';

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

      print('Response Body: ${response.body}');
      print('Response Status Code: ${response.statusCode}');
      if (response.statusCode == 200) {
        try {
          final decodedBody = jsonDecode(response.body);
          setState(() {
            ads = decodedBody["ads"].map((ad) {
              return {
                ...ad,
                'transportAddress':
                    "${ad['latitude'] ?? ''},${ad['longitude'] ?? ''}",
              };
            }).toList();
            _isLoading = false;
          });
        } catch (e) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showErrorDialog('Error decoding JSON: $e');
          });
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showErrorDialog('Failed to load ads: ${response.statusCode}');
        });
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorDialog('Error fetching ads: $e');
      });
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteAd(String adId) async {
    setState(() {
      _isLoading = true;
    });
    final String apiUrl =
        'http://192.168.1.10:2000/api/combinedad/$adId'; // Replace with your delete API endpoint
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
      final response = await http.delete(
        Uri.parse(apiUrl),
        headers: {"Authorization": "Bearer $token"},
      );
      if (response.statusCode == 200) {
        _showSuccessDialog("تم حذف الإعلان بنجاح");
        _fetchAds();
      } else {
        _showErrorDialog('Failed to delete ad: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorDialog('Error deleting ad: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _showEditAdDialog(dynamic ad) async {
    TextEditingController adDetailsController =
        TextEditingController(text: ad['adDetails'] ?? '');

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تعديل بيانات الإعلان'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: adDetailsController,
                  decoration: const InputDecoration(
                    labelText: 'تفاصيل الإعلان',
                  ),
                  maxLines: null,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('إلغاء'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('تعديل'),
              onPressed: () async {
                Navigator.of(context).pop();
                _updateAd(ad['_id'], {
                  'adDetails': adDetailsController.text,
                });
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateAd(String adId, Map<String, dynamic> updatedData) async {
    setState(() {
      _isLoading = true;
    });
    final String apiUrl =
        'http://192.168.1.10:2000/api/combinedad/$adId'; // Replace with your update API endpoint
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
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          "Authorization": "Bearer $token"
        },
        body: jsonEncode(updatedData),
      );
      if (response.statusCode == 200) {
        _showSuccessDialog('تم تعديل الإعلان بنجاح');
        _fetchAds();
      } else {
        _showErrorDialog(
            'Failed to update ad: ${response.statusCode} - ${response.body} ');
      }
    } catch (e) {
      _showErrorDialog('Error updating the ad: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _navigateToMapPage(BuildContext context, dynamic ad) async {
    if (ad['latitude'] == null || ad['longitude'] == null) {
      Fluttertoast.showToast(
          msg: "الإحداثيات غير متوفرة لهذا الإعلان",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }
    try {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MapTestPage(
            initialPosition: latlng.LatLng(ad['latitude'], ad['longitude']),
            initialAddress: ad['serviceAddress'],
          ),
        ),
      );
    } catch (e) {
      Fluttertoast.showToast(
          msg: "حدث خطأ أثناء فتح الخريطة: $e",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  void _showSuccessDialog(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  void _showErrorDialog(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("الإعلانات المشتركة"),
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
              padding: const EdgeInsets.all(8),
              itemCount: ads.length,
              reverse: true,
              itemBuilder: (context, index) {
                final ad = ads[index];
                return _buildAdCard(index, ad);
              },
            ),
    );
  }

  Widget _buildAdCard(int index, dynamic ad) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "اسم المعصرة: ${ad['companyName'] ?? 'غير متوفر'}",
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text(
                  "رقم المعصرة: ",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black),
                ),
                Expanded(
                  child: Text(
                    ad['contactNumber'] ?? 'غير متوفر',
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(children: [
              const Text(
                "اسم مالك شركة النقل: ",
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
              Expanded(
                child: Text(
                  ad['ownerName'] ?? 'غير متوفر',
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ]),
            const SizedBox(height: 8),
            Text(
              "وصف الإعلان: ${ad['adDetails'] ?? 'لا يوجد وصف للإعلان'}",
              style: const TextStyle(fontSize: 16, color: Colors.black),
              overflow: TextOverflow.visible,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text(
                  "اسم شركة النقل: ",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black),
                ),
                Expanded(
                  child: Text(
                    ad['transportCompanyName'] ?? 'غير متوفر',
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text(
                  "رقم شركة النقل: ",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black),
                ),
                Expanded(
                  child: Text(
                    ad['transportPhoneNumber'] ?? 'غير متوفر',
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () => _showEditAdDialog(ad),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF556B2F),
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text("تعديل",
                      style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton(
                  onPressed: () => _deleteAd(ad['_id']),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child:
                      const Text("حذف", style: TextStyle(color: Colors.white)),
                ),
                if (ad['latitude'] != null && ad['longitude'] != null)
                  ElevatedButton(
                    onPressed: () => _navigateToMapPage(
                      context,
                      ad,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF556B2F),
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Text("عرض على الخريطة",
                        style: TextStyle(color: Colors.white)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
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
