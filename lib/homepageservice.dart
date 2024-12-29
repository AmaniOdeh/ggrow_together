import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'adsservice.dart';
import 'allmyworkerser.dart';
import 'createads.dart';
import 'messageservice.dart';
import 'myorderservice.dart';
import 'notificationservice.dart';
import 'profileservice.dart';

class HomePage extends StatelessWidget {
  final String serviceType;
  final Map<String, String>? prefilledData;

  HomePage({required this.serviceType, this.prefilledData});
  final List<Map<String, String>> ads = [
    {"title": "عامل 1 ", "image": "lands/ads1.png"},
    {"title": "عامل 2 ", "image": "lands/ads2.png"},
    {"title": "عامل 3 ", "image": "lands/ads3.png"},
    {"title": "عامل 4", "image": "lands/ads4.png"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("الرئيسية"),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.message, color: Color(0xFF556B2F)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ServiceProviderMessagingPage()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Ad Sections
            _buildSectionHeader("إعلانات العمال"),
            _buildAdSection(context),
            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CreateAdPage(
                            serviceType: '',
                          )),
                );
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                "أنشئ إعلانك الخاص",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF556B2F),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Orders with Progress Circles
            _buildSectionHeader("الطلبات"),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildOrderProgress(
                  title: "مكتملة",
                  count: 4309,
                  progress: 4309 / (4309 + 1302),
                  color: Colors.green,
                ),
                _buildOrderProgress(
                  title: "قيد التنفيذ",
                  count: 1302,
                  progress: 1302 / (4309 + 1302),
                  color: Colors.lightGreen,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Icons for My Orders and My Lands
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildIconButton(
                  title: "طلباتي",
                  icon: Icons.shopping_cart,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MyOrderPage()),
                    );
                  },
                ),
                _buildIconButton(
                  title: "العُمال",
                  icon: Icons.group,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MyWorkerPage()),
                    );
                  },
                ),
                _buildIconButton(
                  title: "إعلاناتي",
                  icon: Icons.campaign,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              MyAdsPage()), // أنشئ صفحة MyAdsPage
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Color(0xFF556B2F),
        ),
      ),
    );
  }

  Widget _buildOrderProgress({
    required String title,
    required int count,
    required double progress,
    required Color color,
  }) {
    return Column(
      children: [
        CircularPercentIndicator(
          radius: 70.0,
          lineWidth: 13.0,
          animation: true,
          percent: progress,
          center: Text(
            count.toString(),
            style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.black),
          ),
          footer: Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Text(
              title,
              style:
                  const TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600),
            ),
          ),
          circularStrokeCap: CircularStrokeCap.round,
          progressColor: color,
          backgroundColor: Colors.grey[300]!,
        ),
      ],
    );
  }

  Widget _buildAdSection(BuildContext context) {
    return SizedBox(
      height: 260,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: ads.length,
        itemBuilder: (context, index) {
          return _buildAdCard(context, ads[index]);
        },
      ),
    );
  }

  Widget _buildAdCard(BuildContext context, Map<String, String> ad) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      width: 230,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            spreadRadius: 2,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 25.0),
            child: ClipOval(
              child: Image.asset(
                ad["image"]!,
                height: 100,
                width: 100,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            ad["title"]!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF556B2F),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: ElevatedButton(
              onPressed: () => _showAdDetails(context, ad["title"]!),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF556B2F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "عرض التفاصيل",
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required String title,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, color: const Color(0xFF556B2F), size: 40),
          onPressed: onPressed,
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF556B2F),
          ),
        ),
      ],
    );
  }

  void _showAdDetails(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("تفاصيل $title"),
          content: Text("تفاصيل حول $title ..."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("إغلاق"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
        selectedItemColor: const Color(0xFF556B2F),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'بحث',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'الإشعارات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'الحساب',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0: // الرئيسية
              // البقاء في الصفحة الحالية (لا تفعل شيئًا)
              break;
            case 2: // الإشعارات
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      NotificationsPage(), // استبدل بنوع الخدمة
                ),
              );
              break;
            case 3: // الإشعارات
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ServiceProviderProfilePage(
                    serviceType: '',
                  ), // استبدل بنوع الخدمة
                ),
              );
              break;
          }
        });
  }
}
