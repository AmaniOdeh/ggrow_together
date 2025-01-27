import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

class ContractListPage extends StatefulWidget {
  final String userId;
  final String serviceType;

  ContractListPage({Key? key, required this.userId, required this.serviceType})
      : super(key: key);

  @override
  _ContractListPageState createState() => _ContractListPageState();
}

class _ContractListPageState extends State<ContractListPage> {
  bool _isLoading = true;
  List<dynamic> contracts = [];

  @override
  void initState() {
    super.initState();
    _fetchContracts();
  }

  Future<void> _fetchContracts() async {
    setState(() {
      _isLoading = true;
    });
    String apiUrl =
        'http://192.168.1.10:2000/api/contract/all'; // Replace with your API endpoint

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
            contracts = decodedBody["contracts"];
            _isLoading = false;
          });
          print('Contracts: $contracts');
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
          _showErrorDialog('Failed to load contracts: ${response.statusCode}');
        });
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorDialog('Error fetching contracts: $e');
      });
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteContract(String contractId) async {
    setState(() {
      _isLoading = true;
    });
    final String apiUrl =
        'http://192.168.1.10:2000/api/contract/$contractId'; // Replace with your delete API endpoint
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
        _showSuccessDialog("تم حذف العقد بنجاح");
        _fetchContracts();
      } else {
        _showErrorDialog('Failed to delete contract: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorDialog('Error deleting contract: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _showEditContractDialog(dynamic contract) async {
    TextEditingController adDetailsController =
        TextEditingController(text: contract['adDetails'] ?? '');
    TextEditingController contactNumberController =
        TextEditingController(text: contract['contactNumber'] ?? '');
    TextEditingController companyNameController =
        TextEditingController(text: contract['companyName'] ?? '');

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تعديل بيانات العقد'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: companyNameController,
                  decoration: const InputDecoration(
                    labelText: 'اسم الشركة',
                  ),
                ),
                TextField(
                  controller: contactNumberController,
                  decoration: const InputDecoration(
                    labelText: 'رقم التواصل',
                  ),
                  keyboardType: TextInputType.phone,
                ),
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
                _updateContract(contract['_id'], {
                  'companyName': companyNameController.text,
                  'contactNumber': contactNumberController.text,
                  'adDetails': adDetailsController.text,
                });
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateContract(
      String contractId, Map<String, dynamic> updatedData) async {
    setState(() {
      _isLoading = true;
    });
    final String apiUrl =
        'http://192.168.1.10:2000/api/contract/$contractId'; // Replace with your update API endpoint

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
        _showSuccessDialog('تم تعديل العقد بنجاح');
        _fetchContracts();
      } else {
        _showErrorDialog(
            'Failed to update contract: ${response.statusCode} - ${response.body} ');
      }
    } catch (e) {
      _showErrorDialog('Error updating the contract: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
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
        title: const Text("عقود العمل"),
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
              itemCount: contracts.length,
              itemBuilder: (context, index) {
                final contract = contracts[index];
                return _buildContractCard(contract);
              },
            ),
    );
  }

  Widget _buildContractCard(dynamic contract) {
    String? phoneNumber;
    String? contactLabel;
    if (widget.serviceType == "service4") {
      phoneNumber = contract['contactNumber'] ?? '';
      contactLabel = 'رقم التواصل (المعصرة):';
    } else if (widget.serviceType == "service1") {
      phoneNumber = contract['transportPhoneNumber'] ?? '';
      contactLabel = 'رقم التواصل (شركة النقل):';
    } else {
      phoneNumber = null;
      contactLabel = null;
    }
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
              "اسم الشركة: ${contract['companyName'] ?? 'غير متوفر'}",
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              "رقم التواصل: ${contract['contactNumber'] ?? 'غير متوفر'}",
              style: const TextStyle(fontSize: 16, color: Colors.black),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              "تفاصيل الإعلان: ${contract['adDetails'] ?? 'لا يوجد وصف للإعلان'}",
              style: const TextStyle(fontSize: 16, color: Colors.black),
              overflow: TextOverflow.visible,
            ),
            const SizedBox(height: 8),
            Text(
              "اسم شركة النقل: ${contract['transportCompanyName'] ?? 'غير متوفر'}",
              style: const TextStyle(fontSize: 16, color: Colors.black),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              "اسم مالك شركة النقل: ${contract['transportOwnerName'] ?? 'غير متوفر'}",
              style: const TextStyle(fontSize: 16, color: Colors.black),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            if (contactLabel != null && phoneNumber != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ElevatedButton.icon(
                  onPressed: () => _launchUrl(phoneNumber!),
                  icon: const Icon(Icons.phone, color: Colors.white),
                  label: Text(
                    "تواصل مباشر",
                    style: const TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF556B2F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () => _showEditContractDialog(contract),
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
                  onPressed: () => _deleteContract(contract['_id']),
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
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      _showErrorDialog('Could not launch $phoneUri');
    }
  }
}
