import 'package:flutter/material.dart';
import 'package:ggrow_together/accountservice.dart';
import 'main.dart';

class ServiceProviderProfilePage extends StatelessWidget {
  final String serviceType; // استلام نوع الخدمة

  const ServiceProviderProfilePage({super.key, required this.serviceType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF6B8E23), // نفس اللون الأخضر
        elevation: 0,
        title: const Text(
          'ملف مزود الخدمة',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildProfileHeader(),
            const SizedBox(height: 30),
            _buildProfileOption(
              icon: Icons.person_outline,
              title: "حسابي",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyAccountPageService(
                      name: 'مزود الخدمة', // الاسم ديناميكي بناءً على البيانات
                      email:
                          'serviceprovider@example.com', // بريد إلكتروني ديناميكي
                      contactNumber: '0599689793', // رقم هاتف ديناميكي
                      password: '', // كلمة مرور ديناميكية
                      username: 'مزود الخدمة',
                      serviceType: '', // اسم المستخدم هنا
                    ),
                  ),
                );
              },
            ),
            _buildProfileOption(
              icon: Icons.assignment_outlined,
              title: "سجل الخدمات",
              onTap: () {
                print("Navigating to Service History...");
              },
            ),
            _buildProfileOption(
              icon: Icons.support_agent_outlined,
              title: "مركز الدعم",
              onTap: () {
                print("Navigating to Support Center...");
              },
            ),
            _buildProfileOption(
              icon: Icons.home_outlined,
              title: "تسجيل الخروج",
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const MyApp(), // العودة إلى الصفحة الرئيسية
                  ),
                  (route) => false, // إزالة جميع الصفحات الأخرى من المكدس
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Center(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: const AssetImage(
                    'profilephoto/default-profile-photo.jpg'), // مسار الصورة
                backgroundColor: Colors.grey.shade300,
              ),
              const CircleAvatar(
                radius: 15,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.camera_alt,
                  size: 18,
                  color: Color(0xFF6B8E23), // نفس اللون
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            "مزود الخدمة", // تغيير الاسم بناءً على بيانات الخدمة
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black, // لون النص
            ),
          ),
          const Text(
            "serviceprovider@example.com", // تغيير البريد الإلكتروني إذا لزم الأمر
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 3,
          child: ListTile(
            leading: Icon(icon,
                color: const Color(0xFF6B8E23), size: 28), // نفس اللون
            title: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
          ),
        ),
      ),
    );
  }
}
