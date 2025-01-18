import 'package:flutter/material.dart';
import 'signupservice.dart';

class AdvertisePage extends StatefulWidget {
  @override
  _AdvertisePageState createState() => _AdvertisePageState();
}

class _AdvertisePageState extends State<AdvertisePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Animation Controller for continuous sliding text
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: false);

    // Slide Animation: Moving continuously from right to left
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0), // Start off-screen right
      end: const Offset(-1.0, 0.0), // End off-screen left
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
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
        title: const Text(
          "الإعلانات",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF556B2F),
          ),
        ),
      ),
      body: Stack(
        children: [
          _buildBackground(),
          Column(
            children: [
              const SizedBox(height: 100),
              _buildAnimatedWelcomeText(),
              const SizedBox(height: 20),
              _buildListContent(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF556B2F), Color(0xFF8FBC8F)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  Widget _buildAnimatedWelcomeText() {
    return SlideTransition(
      position: _slideAnimation,
      child: Center(
        child: Card(
          color: const Color(0xFF556B2F),
          elevation: 10,
          shadowColor: Colors.black45,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.star_rate_rounded, size: 50, color: Colors.white),
                SizedBox(height: 10),
                Text(
                  "مرحباً بك في دليل الخدمات",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListContent() {
    final options = [
      {'icon': Icons.local_drink, 'label': 'معاصر'},
      {'icon': Icons.store, 'label': 'مطاحن'},
      {'icon': Icons.local_shipping, 'label': 'نقليات'},
      {'icon': Icons.grass, 'label': 'منتجات زراعية'},
    ];

    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.all(10),
        physics: const BouncingScrollPhysics(),
        itemCount: options.length,
        itemBuilder: (context, index) {
          return _buildListTile(options[index]);
        },
      ),
    );
  }

  Widget _buildListTile(Map<String, dynamic> option) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SignUpPage(serviceType: option['label']),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            splashColor: Colors.green.withOpacity(0.2),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(option['icon'],
                      size: 40, color: const Color(0xFF556B2F)),
                  const SizedBox(width: 15),
                  Text(
                    option['label'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF556B2F),
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
