import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'adsservice.dart';
import 'combine.dart';
import 'contractpage.dart';
import 'createads.dart';
import 'messageservice.dart';
import 'myorderservice.dart';
import 'notificationservice.dart';
import 'profileservice.dart';
import 'showali.dart';
import 'transportads.dart';
import 'trasget.dart';

class HomePage extends StatefulWidget {
  final String serviceType;
  final String userId;

  HomePage({required this.serviceType, required this.userId});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("الرئيسية (${widget.serviceType})"),
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
                  builder: (context) => MessagesPage(  userId: widget.userId),
                ),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildWelcomeCard(),
                  const SizedBox(height: 20),
                  SizedBox(
                    // استخدمنا SizedBox هنا لضبط حجم الزر
                    width: double.infinity, // اجعل الزر يأخذ كامل العرض
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CreateAdPage(
                                      serviceType: widget.serviceType,
                                      userId: widget.userId,
                                    )));
                      },
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text(
                        "أنشئ إعلانك الخاص",
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.white), // تصغير حجم الخط قليلاً
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF556B2F),
                        padding: const EdgeInsets.symmetric(
                            vertical: 12), // تقليل الحجم العامودي
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (widget.serviceType ==
                      "service1") // اظهار الزر الخاص بالمعصرة فقط
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          width: 150, // تحديد عرض الزر
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TransportAdsPage(
                                    serviceType: widget.serviceType,
                                    userId: widget.userId,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.local_shipping,
                                color: Colors.white, size: 20),
                            label: const Text(
                              "إعلان خاص للنقليات",
                              style:
                                  TextStyle(fontSize: 14, color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF556B2F),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  if (widget.serviceType ==
                      "service1") // زر عرض اعلانات النقليات الخاصة بي (المعصرة)
                    SizedBox(
                      width: double.infinity, // اجعل الزر يأخذ كامل العرض
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AdsManagementPage(userId: widget.userId
                                      //عرض اعلانات النقليات الخاصة بي
                                      ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.local_shipping,
                            color: Colors.white, size: 20),
                        label: const Text(
                          "إعلاناتي للنقليات",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF556B2F),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                      ),
                    ),
                  if (widget.serviceType ==
                      "service4") // زر عرض اعلانات النقليات (المعصرة)
                    SizedBox(
                      width: double.infinity, // اجعل الزر يأخذ كامل العرض
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TransportAdsListPage(
                                serviceType: 'service4', // عرض إعلانات النقل
                                userId: widget.userId,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.local_shipping,
                            color: Colors.white, size: 20),
                        label: const Text(
                          "عرض إعلانات المعاصر",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF556B2F),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  if (widget.serviceType == "service4" ||
                      widget.serviceType == "service1")
                    SizedBox(
                      width: double.infinity, // اجعل الزر يأخذ كامل العرض
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CombinedAdsListPage(
                                serviceType: widget.serviceType,
                                userId: widget.userId,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.announcement,
                            color: Colors.white, size: 20),
                        label: const Text(
                          "عرض الإعلانات المشتركة",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF556B2F),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  if (widget.serviceType == "service4" ||
                      widget.serviceType == "service1")
                    SizedBox(
                      width: double.infinity, // اجعل الزر يأخذ كامل العرض
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ContractListPage(
                                serviceType: widget.serviceType,
                                userId: widget.userId,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.assignment,
                            color: Colors.white, size: 20),
                        label: const Text(
                          "عرض عقود العمل",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF556B2F),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  _buildSectionHeader("الطلبات"),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildIconButton(
                        title: "طلباتي",
                        icon: Icons.shopping_cart,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MyOrderPage()),
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
                                builder: (context) => MyAdsPage(
                                      serviceType: widget.serviceType,
                                    )),
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

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
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
          const Text(
            'أهلاً بك في تطبيقنا!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF556B2F),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            'نحن سعداء بانضمامك. ابدأ الآن في استكشاف خدماتنا وتلبية احتياجاتك.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
        ],
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
            case 0:
              break;
           
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationsPage(),
                ),
              );
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ServiceProviderProfilePage(
                    serviceType: '',
                  ),
                ),
              );
              break;
          }
        });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("خطأ"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("موافق"),
          ),
        ],
      ),
    );
  }
}
