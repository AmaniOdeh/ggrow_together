import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart'; // مكتبة التخزين المحلي
import 'globalstate.dart';
import 'guarantee.dart';

class MyLandsPage extends StatefulWidget {
  const MyLandsPage({super.key});

  @override
  _MyLandsPageState createState() => _MyLandsPageState();
}

class _MyLandsPageState extends State<MyLandsPage> {
  @override
  void initState() {
    super.initState();
    _loadUser(); // تحميل المستخدم الحالي
    _loadLands(); // تحميل الأراضي المحفوظة عند فتح الصفحة
  }

  // تحميل الأراضي المحفوظة من التخزين المحلي
  Future<void> _loadLands() async {
    final prefs = await SharedPreferences.getInstance();
    final String? landsString = prefs.getString('lands');
    if (landsString != null) {
      try {
        setState(() {
          GlobalState.lands = List<Map<String, dynamic>>.from(
            json.decode(landsString),
          );
        });
        print("Lands loaded: ${GlobalState.lands}");
      } catch (e) {
        print("Error loading lands: $e");
      }
    }
  }

  // تحميل المستخدم الحالي من التخزين المحلي
  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final String? username = prefs.getString('currentUser');
    if (username != null) {
      setState(() {
        GlobalState.currentUser = username;
      });
      print("Current User: ${GlobalState.currentUser}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Lands",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF556B2F),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('image/dis.png'), // خلفية الصفحة
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // توسيط العناصر
          children: [
            _buildLandTypeCard(
              context: context,
              title: "All My Lands",
              gradientColors: [Color(0xFF556B2F), Color(0xFF3E5A23)],
              icon: Icons.landscape,
              onTap: () {
                _navigateToLandList(context, "all");
              },
            ),
            const SizedBox(height: 16), // مسافة بين البطاقات
            _buildLandTypeCard(
              context: context,
              title: "Guarantee Lands",
              gradientColors: [Color(0xFF556B2F), Color(0xFF3E5A23)],
              icon: Icons.description,
              onTap: () {
                _navigateToGuaranteePage(context);
              },
            ),
            const SizedBox(height: 16), // مسافة بين البطاقات
            _buildLandTypeCard(
              context: context,
              title: "Worker Request Lands",
              gradientColors: [Color(0xFF556B2F), Color(0xFF3E5A23)],
              icon: Icons.people_alt,
              onTap: () {
                _navigateToLandList(context, "worker_request");
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLandTypeCard({
    required BuildContext context,
    required String title,
    required List<Color> gradientColors,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 130, // تصغير ارتفاع البطاقة
        width: MediaQuery.of(context).size.width * 0.9, // تقليل العرض قليلاً
        margin: const EdgeInsets.symmetric(horizontal: 16), // مسافة جانبية
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15), // زوايا منحنية
          boxShadow: [
            BoxShadow(
              color: Colors.black26, // ظل خفيف
              blurRadius: 5,
              offset: Offset(2, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 50, color: Colors.white), // أيقونة بحجم أصغر قليلاً
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16, // حجم نص أصغر
              ),
            ),
          ],
        ),
      ),
    );
  }

  // التنقل إلى صفحة Guarantee Page
  void _navigateToGuaranteePage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GuaranteePage()),
    );
  }

  void _navigateToLandList(BuildContext context, String type) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Navigation for $type not implemented yet.")),
    );
  }
}
