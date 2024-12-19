import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'messageworker.dart';
import 'profileworker.dart';
import 'notificationworker.dart';

class WorkerHomePage extends StatefulWidget {
  @override
  _WorkerHomePageState createState() => _WorkerHomePageState();
}

class _WorkerHomePageState extends State<WorkerHomePage> {
  final List<Map<String, String>> recentMessages = [
    {"name": "أحمد", "message": "مرحبًا، كيف حالك؟", "time": "10:00 ص"},
    {"name": "فاطمة", "message": "هل يمكنك إرسال التقرير؟", "time": "09:30 ص"},
    {"name": "عمر", "message": "لنلتقي غدًا.", "time": "08:15 ص"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'صفحة العامل الرئيسية',
          style: GoogleFonts.cairo(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF556B2F),
        elevation: 5,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildWelcomeBanner(),
            const SizedBox(height: 20),
            _buildSectionTitle('المحادثات الأخيرة'),
            _buildRecentMessagesList(),
            const SizedBox(height: 20),
            _buildSectionTitle('إعلانات الأراضي'),
            _buildAdvertisementList(),
            const SizedBox(height: 20),
            _buildSectionTitle('الإجراءات'),
            _buildActionButtons(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildWelcomeBanner() {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF8FBC8F), const Color(0xFF556B2F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '!مرحبًا بك',
              style: GoogleFonts.tajawal(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'اكتشف فرص العمل في الأراضي الزراعية\nوكن جزءًا من نجاح ينمو معك!',
              textAlign: TextAlign.center,
              style: GoogleFonts.tajawal(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: GoogleFonts.tajawal(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF556B2F),
        ),
      ),
    );
  }

  Widget _buildRecentMessagesList() {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: recentMessages.length,
        itemBuilder: (context, index) {
          final message = recentMessages[index];
          return GestureDetector(
            onTap: () {
              // الانتقال إلى صفحة المحادثة
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WorkerMessagingPage(),
                ),
              );
            },
            child: Container(
              width: 250,
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message['name']!,
                    style: GoogleFonts.tajawal(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF556B2F),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    message['message']!,
                    style: GoogleFonts.tajawal(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      message['time']!,
                      style: GoogleFonts.tajawal(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAdvertisementList() {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, index) {
          return _buildAdvertisementCard(index + 1);
        },
      ),
    );
  }

  Widget _buildAdvertisementCard(int adNumber) {
    return Container(
      margin: const EdgeInsets.all(10),
      width: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.landscape,
            size: 50,
            color: const Color(0xFF556B2F),
          ),
          const SizedBox(height: 10),
          Text(
            'إعلان أرض رقم $adNumber',
            style: GoogleFonts.tajawal(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF556B2F),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 5),
          ElevatedButton(
            onPressed: () {
              // Show land details
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF556B2F),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              'عرض التفاصيل',
              style: GoogleFonts.tajawal(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      children: [
        _buildActionButton(
          title: 'إضافة إعلان',
          icon: Icons.add_box,
          onPressed: () {
            // Add advertisement
          },
        ),
        _buildActionButton(
          title: 'أراضيي',
          icon: Icons.map,
          onPressed: () {
            // Navigate to "My Lands"
          },
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String title,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF556B2F),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      icon: Icon(icon, size: 24),
      label: Text(title, style: GoogleFonts.tajawal(fontSize: 16)),
      onPressed: onPressed,
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      selectedItemColor: const Color(0xFF556B2F),
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'الرئيسية',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'الملف الشخصي',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications),
          label: 'الإشعارات',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.message),
          label: 'المحادثات',
        ),
      ],
      onTap: (index) {
        if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const WorkerProfilePage(),
            ),
          );
        } else if (index == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const WorkerNotificationsPage(
                notifications: [],
              ),
            ),
          );
        } else if (index == 3) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WorkerMessagingPage(),
            ),
          );
        }
      },
    );
  }
}
