import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class MyAdsPage extends StatefulWidget {
  @override
  _MyAdsPageState createState() => _MyAdsPageState();
}

class _MyAdsPageState extends State<MyAdsPage> {
  File? _selectedImage;

  final List<Map<String, dynamic>> ads = [
    {
      "companyName": "شركة مثالية 1",
      "contactNumber": "123456789",
      "serviceType": "نوع الخدمة 1",
      "discountPrice": "20%",
      "adDetails": "تفاصيل الإعلان الأول",
      "image": "lands/ads1.png"
    },
    {
      "companyName": "شركة مثالية 2",
      "contactNumber": "987654321",
      "serviceType": "نوع الخدمة 2",
      "discountPrice": "30%",
      "adDetails": "تفاصيل الإعلان الثاني",
      "image": "lands/ads2.png"
    },
    {
      "companyName": "شركة مثالية 3",
      "contactNumber": "456123789",
      "serviceType": "نوع الخدمة 3",
      "discountPrice": "40%",
      "adDetails": "تفاصيل الإعلان الثالث",
      "image": "lands/ads3.png"
    },
  ];

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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: ads.length,
          itemBuilder: (context, index) {
            return _buildAdCard(context, ads[index]);
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
          // Image Section
          if (ad["image"] != null)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Image.asset(
                ad["image"],
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow("اسم الشركة:", ad["companyName"]),
                _buildDetailRow("رقم التواصل:", ad["contactNumber"]),
                _buildDetailRow("نوع الخدمة:", ad["serviceType"]),
                _buildDetailRow("سعر الخصم:", ad["discountPrice"]),
                _buildDetailRow("تفاصيل الإعلان:", ad["adDetails"]),
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
                        setState(() {
                          ads.remove(ad);
                        });
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
        return AlertDialog(
          title: const Text("تعديل الإعلان"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildEditableField(
                  label: "اسم الشركة",
                  initialValue: ad["companyName"],
                  onChanged: (value) =>
                      setState(() => ad["companyName"] = value),
                ),
                const SizedBox(height: 10),
                _buildEditableField(
                  label: "رقم التواصل",
                  initialValue: ad["contactNumber"],
                  onChanged: (value) =>
                      setState(() => ad["contactNumber"] = value),
                ),
                const SizedBox(height: 10),
                _buildEditableField(
                  label: "نوع الخدمة",
                  initialValue: ad["serviceType"],
                  onChanged: (value) =>
                      setState(() => ad["serviceType"] = value),
                ),
                const SizedBox(height: 10),
                _buildEditableField(
                  label: "سعر الخصم",
                  initialValue: ad["discountPrice"],
                  onChanged: (value) =>
                      setState(() => ad["discountPrice"] = value),
                ),
                const SizedBox(height: 10),
                _buildEditableField(
                  label: "تفاصيل الإعلان",
                  initialValue: ad["adDetails"],
                  maxLines: 3,
                  onChanged: (value) => setState(() => ad["adDetails"] = value),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _pickImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF556B2F),
                  ),
                  child: const Text(
                    "تغيير الصورة",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                if (_selectedImage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Image.file(
                      _selectedImage!,
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
      },
    );
  }

  Widget _buildEditableField({
    required String label,
    required String initialValue,
    required Function(String) onChanged,
    int maxLines = 1,
  }) {
    return TextFormField(
      initialValue: initialValue,
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

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }
}
