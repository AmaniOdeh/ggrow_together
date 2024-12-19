import 'package:flutter/material.dart';
import 'choice.dart';
import 'signupworker.dart';
import 'signupowner.dart';

class ProjectInfoPage extends StatefulWidget {
  final String baseUrl;

  const ProjectInfoPage({super.key, required this.baseUrl});

  @override
  _ProjectInfoPageState createState() => _ProjectInfoPageState();
}

class _ProjectInfoPageState extends State<ProjectInfoPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  bool _isHoveringOwner = false;
  bool _isHoveringWorker = false;
  bool _isHoveringAdvertise = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: const Offset(0, 0),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('image/dis.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                const Spacer(),
                _buildAnimatedText(
                  text: "Welcome to 'Grow Together' Project",
                  delay: 0,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF556B2F),
                ),
                const SizedBox(height: 15),
                Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 350),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7A886A).withOpacity(0.85),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: _buildAnimatedText(
                      text:
                          "Grow Together aims to optimize agricultural land use by connecting landowners with skilled laborers.",
                      delay: 300,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                SlideTransition(
                  position: _slideAnimation,
                  child: Card(
                    color: Colors.white.withOpacity(0.9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 6,
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Flexible(
                                child: _buildSignupOption(
                                  icon: Icons.terrain,
                                  label: "Land Owner",
                                  description:
                                      "Register your land and find skilled laborers.",
                                  isHovering: _isHoveringOwner,
                                  onHover: (hovering) => setState(() {
                                    _isHoveringOwner = hovering;
                                  }),
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          SignUpForm(baseUrl: widget.baseUrl),
                                    ),
                                  ),
                                ),
                              ),
                              Flexible(
                                child: _buildSignupOption(
                                  icon: Icons.person,
                                  label: "Worker",
                                  description:
                                      "Register as a worker to offer your skills.",
                                  isHovering: _isHoveringWorker,
                                  onHover: (hovering) => setState(() {
                                    _isHoveringWorker = hovering;
                                  }),
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          SignUpWorker(baseUrl: widget.baseUrl),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          SizedBox(
                            width: 180,
                            child: _buildSignupOption(
                              icon: Icons.campaign,
                              label: "Advertise with Us",
                              description: "Promote your services here.",
                              isHovering: _isHoveringAdvertise,
                              onHover: (hovering) => setState(() {
                                _isHoveringAdvertise = hovering;
                              }),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AdvertisePage(), // اسم الصفحة التي قمت بإنشائها
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedText({
    required String text,
    required int delay,
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
  }) {
    return AnimatedOpacity(
      opacity: 1.0,
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeIn,
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color ?? Colors.black,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildSignupOption({
    required IconData icon,
    required String label,
    required String description,
    required VoidCallback onTap,
    required Function(bool) onHover,
    required bool isHovering,
  }) {
    return MouseRegion(
      onEnter: (_) => onHover(true),
      onExit: (_) => onHover(false),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: isHovering
                    ? const Color(0xFF556B2F).withOpacity(0.3)
                    : const Color(0xFF556B2F).withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF556B2F), width: 3),
              ),
              child: Icon(icon, size: 40, color: const Color(0xFF556B2F)),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF556B2F),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
