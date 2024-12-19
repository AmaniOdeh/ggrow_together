import 'package:flutter/material.dart';
import 'main.dart';
import 'myaccount.dart';

class LandOwnerProfilePage extends StatelessWidget {
  const LandOwnerProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9), // نفس خلفية MyAccountPage
      appBar: AppBar(
        backgroundColor: const Color(0xFF66BB6A), // نفس لون MyAccountPage
        elevation: 0,
        title: const Text(
          'ملف المالك',
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
                    builder: (context) => const MyAccountPage(
                      name: 'AMANI ODEH',
                      email: 'amaniodeh225@gmail.com',
                      contactNumber: '0599689793',
                      password: '',
                    ),
                  ),
                );
              },
            ),
            _buildProfileOption(
              icon: Icons.payment_outlined,
              title: "سجل الدفع",
              onTap: () {
                print("Navigating to Payment History...");
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
                    builder: (context) => const MyApp(), // الصفحة الرئيسية
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
                    'profilephoto/default-profile-photo.jpg'), // استبدل بمسار الصورة الخاصة بك
                backgroundColor: Colors.grey.shade300,
              ),
              const CircleAvatar(
                radius: 15,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.camera_alt,
                  size: 18,
                  color: Color(0xFF66BB6A), // نفس لون أيقونات MyAccountPage
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            "أماني عودة", // يمكن تغييره إلى اسم ديناميكي
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.green, // نفس اللون من MyAccountPage
            ),
          ),
          const Text(
            "amaniodeh225@gmail.com", // يمكن تغييره إلى بريد إلكتروني ديناميكي
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
                color: const Color(0xFF66BB6A),
                size: 28), // نفس لون أيقونات MyAccountPage
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
