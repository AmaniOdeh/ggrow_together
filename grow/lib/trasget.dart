import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'map.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class TransportAdsListPage extends StatefulWidget {
  final String userId;
  final String serviceType;

  TransportAdsListPage(
      {Key? key, required this.userId, required this.serviceType})
      : super(key: key);

  @override
  _TransportAdsListPageState createState() => _TransportAdsListPageState();
}

class _TransportAdsListPageState extends State<TransportAdsListPage> {
  bool _isLoading = true;
  List<dynamic> ads = [];

  // Firebase messaging setup
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  String? _fcmToken;
  @override
  void initState() {
    super.initState();
    _fetchAds();
    _setupFirebase();
    _initLocalNotifications();
  }

  Future<void> _initLocalNotifications() async {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _setupFirebase() async {
    await Firebase.initializeApp();

    // Request permission for iOS
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      await _firebaseMessaging.requestPermission(
          alert: true, badge: true, sound: true);
    }

    // Subscribe to the 'newContracts' topic
    await _firebaseMessaging.subscribeToTopic("newContracts");
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handleFirebaseMessage(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      _handleFirebaseMessage(message);
    });
    _firebaseMessaging.getToken().then((token) {
      print('FCM Token: $token');
      setState(() {
        _fcmToken = token;
      });
    });
  }

  Future<void> _handleFirebaseMessage(RemoteMessage message) async {
    print("message: $message");

    if (message.notification != null) {
      final String? title = message.notification!.title;
      final String? body = message.notification!.body;

      if (title != null && body != null) {
        _showNotification(title, body);
      }
    }
  }

  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: 'item x',
    );
  }

  Future<void> _fetchAds() async {
    setState(() {
      _isLoading = true;
    });
    String apiUrl = 'http://192.168.1.10:2000/api/transportad/all';
    print("Fetching ads from: $apiUrl");
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null || token.isEmpty) {
        print("Token not found, Please login again");
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
            ads = decodedBody;
            _isLoading = false;
          });
          print("Ads fetched successfully");
        } catch (e) {
          print('Error decoding JSON: $e');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showErrorDialog('Error decoding JSON: $e');
          });
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        print('Failed to load ads: ${response.statusCode} - ${response.body}');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showErrorDialog('Failed to load ads: ${response.statusCode}');
        });
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching ads: $e');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorDialog('Error fetching ads: $e');
      });
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> sendNotificationToAdOwner(
      String adOwnerId, String adCompanyName, String contractId) async {
    print("Sending notification to ad owner: $adOwnerId");

    String apiUrl =
        'http://192.168.1.10:2000/api/contract/sendPushNotificationDirectly';
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        print("Token not found, Please login again");
        _showErrorDialog("Token not found, Please login again");
        return;
      }

      final Map<String, dynamic> requestBody = {
        'receiverId': adOwnerId,
        'message': 'تمت الموافقة على إعلانك نن قِبل ${adCompanyName} بنجاح',
        'senderId': widget.userId,
        'chatId': contractId,
        'fcmToken': _fcmToken,
      };
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          "Authorization": "Bearer $token"
        },
        body: jsonEncode(requestBody),
      );
      print('Notification Response Body: ${response.body}');
      print('Notification Response Status Code: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('Notification sent successfully to ad owner');
      } else {
        print(
            'Failed to send notification to ad owner: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error sending notification to ad owner: $e');
    }
  }

  Future<void> _createContract(
      String adId, dynamic ad, Map<String, dynamic> service4Data) async {
    print("Creating contract with adId: $adId");
    final String apiUrl = 'http://192.168.1.10:2000/api/contract/create';

    try {
      setState(() {
        _isLoading = true;
      });
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        print("Token not found, Please login again");
        _showErrorDialog("Token not found, Please login again");
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final Map<String, dynamic> requestBody = {
        'adId': adId,
        'userId': widget.userId,
        'companyName': ad['companyName'],
        'contactNumber': ad['contactNumber'],
        'adDetails': ad['adDetails'],
        'transportCompanyName': service4Data['transportCompanyName'],
        'transportOwnerName': service4Data['ownerName'],
        'transportPhoneNumber': service4Data['phoneNumber'],
        'fcmToken': _fcmToken, // تمرير الـ fcmToken
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          "Authorization": "Bearer $token"
        },
        body: jsonEncode(requestBody),
      );

      print('Contract Response Body: ${response.body}');
      print('Contract Response Status Code: ${response.statusCode}');
      if (response.statusCode == 201) {
        print('Contract created successfully');
        _showSuccessDialog('تم إنشاء العقد بنجاح');
        final decodedBody = jsonDecode(response.body);
        await sendNotificationToAdOwner(
            ad['userId'], ad['companyName'], decodedBody['cont']['_id']);
        await _createCombinedAd(ad, service4Data);
      } else {
        print(
            'Failed to create contract: ${response.statusCode} - ${response.body}');
        _showErrorDialog(
            'فشل انشاء العقد: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error creating the contract: $e');
      _showErrorDialog('Error creating the contract: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _createCombinedAd(
      dynamic ad, Map<String, dynamic> service4Data) async {
    final String apiUrl = 'http://192.168.1.10:2000/api/combinedad/create';
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
        'userId': widget.userId,
        'companyName': ad['companyName'],
        'contactNumber': ad['contactNumber'],
        'adDetails':
            "نقل لـمعصرة ${ad['companyName'] ?? 'معصرة غير محددة'} خلال موسم الزيتون مجاناً",
        'transportCompanyName': service4Data['transportCompanyName'],
        'transportPhoneNumber': service4Data['phoneNumber'],
        'transportOwnerName': service4Data['ownerName'],
        'latitude': _parseLatLng(ad['serviceAddress'])?.latitude,
        'longitude': _parseLatLng(ad['serviceAddress'])?.longitude,
        'serviceAddress': ad['serviceAddress'],
        'serviceType': widget.serviceType,
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
        _showAdDetailsDialog(ad, service4Data);
      } else {
        print('Failed to create ad: ${response.statusCode} - ${response.body}');
        _showErrorDialog(
            'Failed to create ad: ${response.statusCode} - ${response.body} ');
      }
    } catch (e) {
      print('Error creating the ad: $e');
      _showErrorDialog('Error creating the ad: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _showAdDetailsDialog(
      dynamic ad, Map<String, dynamic> service4Data) async {
    showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('تفاصيل الإعلان'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(
                    "اسم شركة النقل: ${service4Data['transportCompanyName'] ?? 'غير متوفر'}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "اسم المالك: ${service4Data['ownerName'] ?? 'غير متوفر'}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "رقم المالك: ${service4Data['phoneNumber'] ?? 'غير متوفر'}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const SizedBox(height: 8),
                  Text(
                    "اسم المعصرة: ${ad['companyName'] ?? 'غير متوفر'}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "وصف الإعلان: نقل لـ ${ad['companyName'] ?? 'معصرة غير محددة'} خلال موسم الزيتون مجاناً",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('تم'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Future.delayed(const Duration(milliseconds: 500), () {
                    _showSuccessDialog('تم إنشاء الإعلان');
                  });
                },
              ),
            ],
          );
        });
  }

  Future<void> _fetchService4Data(String userId, dynamic ad) async {
    print("Fetching service4 data for userId: $userId");
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null || token.isEmpty) {
        print("Token not found, Please login again");
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showErrorDialog("Token not found, Please login again");
        });
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Fetch service4 details
      final service4Response = await http.get(
        Uri.parse('http://192.168.1.10:2000/service4/myServiceDetails'),
        headers: {"Authorization": "Bearer $token"},
      );
      print('Service4 Response: ${service4Response.body}');

      Map<String, dynamic> service4Data = {};

      if (service4Response.statusCode == 200) {
        try {
          final decodedBody = jsonDecode(service4Response.body);
          service4Data = {
            'transportCompanyName': decodedBody['companyName'],
            'ownerName': decodedBody['ownerName'],
            'phoneNumber': decodedBody['contactNumber'],
          };
        } catch (e) {
          print("Error decoding service4 : $e");
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showErrorDialog("Error decoding service 4 json data");
          });
        }
      }
      if (service4Data.isNotEmpty) {
        _showContractDialog(service4Data, ad);
      } else {
        print('No data available from service4');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showErrorDialog('No data available from service4');
        });
      }
    } catch (e) {
      print("Failed to connect to server: $e");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorDialog("Failed to connect to server: $e");
      });
      setState(() {
        _isLoading = false;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showContractDialog(Map<String, dynamic> service4Data, dynamic ad) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("عقد عمل"),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "تفاصيل الإعلان:",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[900]),
              ),
              const SizedBox(height: 8),
              _buildInfoRow("اسم المعصرة", ad['companyName'] ?? 'غير متوفر'),
              _buildInfoRow("رقم التواصل", ad['contactNumber'] ?? 'غير متوفر'),
              _buildInfoRow("اسم المالك", ad['ownerName'] ?? 'غير متوفر'),
              Text(
                "وصف الإعلان:",
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(
                ad['adDetails'] ?? 'لا يوجد وصف للإعلان',
                overflow: TextOverflow.visible,
              ),
              const SizedBox(height: 16),
              Text(
                "معلومات شركة النقل:",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[900]),
              ),
              const SizedBox(height: 8),
              _buildInfoRow("اسم الشركة",
                  service4Data['transportCompanyName'] ?? 'غير متوفر'),
              _buildInfoRow(
                  "اسم المالك", service4Data['ownerName'] ?? 'غير متوفر'),
              _buildInfoRow(
                  "رقم التواصل", service4Data['phoneNumber'] ?? 'غير متوفر'),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _createContract(ad['_id'], ad, service4Data);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF556B2F),
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 30),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: const Text(
                    "إنشاء العقد",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _navigateToMapPage(BuildContext context, double? latitude,
      double? longitude, String? address) async {
    if (latitude == null || longitude == null) {
      _showErrorDialog("الإحداثيات غير متوفرة لهذا الإعلان");
      return;
    }

    try {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MapTestPage(
            initialPosition: latlng.LatLng(latitude, longitude),
            initialAddress: address,
          ),
        ),
      );
    } catch (e) {
      _showErrorDialog("حدث خطأ أثناء فتح الخريطة: $e");
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
      fontSize: 16.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("اعلانات معاصرة"),
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
              ad['companyName'] ?? 'غير متوفر',
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
                  "رقم التواصل: ",
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
                "اسم المالك: ",
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
              ad['adDetails'] ?? 'لا يوجد وصف للإعلان',
              style: const TextStyle(fontSize: 16, color: Colors.black),
              overflow: TextOverflow.visible,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () => _navigateToMapPage(
                    context,
                    ad['latitude'],
                    ad['longitude'],
                    ad['serviceAddress'],
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
                ElevatedButton(
                  onPressed: () => _fetchService4Data(ad['userId'], ad),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF556B2F),
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text("موافق",
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            )
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
