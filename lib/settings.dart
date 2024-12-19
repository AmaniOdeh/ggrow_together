import 'package:flutter/material.dart';
import 'discription.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "الإعدادات",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF66BB6A),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildAccountInfoSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountInfoSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "معلومات الحساب",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF66BB6A),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 25,
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, size: 25, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Amani Odeh",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "amaniodeh225@gmail.com",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  _showDeactivateAccountDialog(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF81C784),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
                child: const Text(
                  "تعطيل الحساب",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeactivateAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "تعطيل الحساب",
          ),
          content: const Text(
              "هل أنت متأكد أنك تريد تعطيل حسابك؟ سيتم تسجيل خروجك ولا يمكنك الوصول إلى الحساب مرة أخرى."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("إلغاء"),
            ),
            ElevatedButton(
              onPressed: () {
                _deactivateAccount(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF81C784),
              ),
              child: const Text(
                "تعطيل",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deactivateAccount(BuildContext context) {
    // قم بإضافة الكود المطلوب لتعطيل الحساب هنا
    print("تم تعطيل الحساب بنجاح");

    Navigator.of(context).pop(); // إغلاق النافذة
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const ProjectInfoPage(
          baseUrl: '',
        ),
      ),
    );
  }
}
