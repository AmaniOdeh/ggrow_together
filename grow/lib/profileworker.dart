import 'package:flutter/material.dart';
import 'acoountworker.dart';
import 'main.dart';

class WorkerProfilePage extends StatelessWidget {
  const WorkerProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFE8F5E9), // Same background as MyAccountPage
      appBar: AppBar(
        backgroundColor: const Color(0xFF66BB6A), // Same color as MyAccountPage
        elevation: 0,
        title: const Text(
          'ملف العامل',
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
                    builder: (context) => const WorkerAccountPage(
                      name: 'محمد أحمد',
                      email: 'worker@example.com',
                      contactNumber: '0599999999',
                      password: '******',
                      skills: ['حراثة', 'حصاد', 'ري'],
                      tools: ['محراث', 'منجل', 'خراطيم ري'],
                      location: 'رام الله - فلسطين',
                    ),
                  ),
                );
              },
            ),
            _buildProfileOption(
              icon: Icons.history,
              title: "سجل العمل",
              onTap: () {
                print("Navigating to Work History...");
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
              icon: Icons.logout,
              title: "تسجيل الخروج",
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyApp(), // Main page
                  ),
                  (route) => false, // Removes all other pages from the stack
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
                    'profilephoto/default-profile-photo.jpg'), // Replace with actual image path
                backgroundColor: Colors.grey.shade300,
              ),
              const CircleAvatar(
                radius: 15,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.camera_alt,
                  size: 18,
                  color: Color(0xFF66BB6A), // Same icon color as MyAccountPage
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            "محمد خليل", // Replace with dynamic name
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.green, // Same color as MyAccountPage
            ),
          ),
          const Text(
            "mohammedkhalil123@gmail.com", // Replace with dynamic email
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
                size: 28), // Same icon color as MyAccountPage
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
