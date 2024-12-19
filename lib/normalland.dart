import 'package:flutter/material.dart';
import 'searchforworker.dart';
import 'updateland.dart';
import 'addnewland.dart';
import 'workrequest.dart';

class WorkRequestLandPage extends StatefulWidget {
  final String username;

  const WorkRequestLandPage({
    super.key,
    required this.username,
    required List lands,
  });

  @override
  _WorkRequestLandPageState createState() => _WorkRequestLandPageState();
}

class _WorkRequestLandPageState extends State<WorkRequestLandPage> {
  List<Map<String, dynamic>> lands = [
    {
      "area": 0.5,
      "image": "image/land1.jpg",
      "governorate": "Governorate A",
      "town": "Town A",
      "street": "Main Street",
      "workType": "Plowing",
      "location": {"latitude": 30.0444, "longitude": 31.2357},
    },
    {
      "area": 0.3,
      "image": "image/land2.jpg",
      "governorate": "Governorate B",
      "town": "Town B",
      "street": "Secondary Street",
      "workType": "Harvesting",
      "location": {"latitude": 29.9765, "longitude": 31.1313},
    },
  ];

  int currentIndex = 0; // Index for the selected land

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Work Request Land Page",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF7A886A),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("image/normalland.png"),
            fit: BoxFit.cover,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildWelcomeCard(), // Welcome card reintroduced
            const SizedBox(height: 10),
            _buildTotalLandsText(),
            const SizedBox(height: 10),
            if (lands.isNotEmpty) _buildLandDetailsView(),
            const SizedBox(height: 20),
            _buildButtonSection(), // Buttons section
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      color: Colors.white.withOpacity(0.8),
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          "Welcome ${widget.username}! Submit work requests for your lands and track your requests easily.",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildTotalLandsText() {
    return Text(
      "Total Lands: ${lands.length}",
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildLandDetailsView() {
    return Expanded(
      flex: 6,
      child: PageView.builder(
        itemCount: lands.length,
        onPageChanged: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          final land = lands[index];
          return _buildLandCard(land);
        },
      ),
    );
  }

  Widget _buildLandCard(Map<String, dynamic> land) {
    final location = land["location"];
    final latitude = location?["latitude"]?.toStringAsFixed(5) ?? "N/A";
    final longitude = location?["longitude"]?.toStringAsFixed(5) ?? "N/A";

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.asset(
              land['image'] ?? 'image/defaultland.png',
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.5),
                  Colors.transparent,
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Governorate: ${land['governorate'] ?? 'N/A'}",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    "Town: ${land['town'] ?? 'N/A'}",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    "Street: ${land['street'] ?? 'N/A'}",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    "Area: ${land['area']} km²",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    "Work Type: ${land['workType']}",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  if (latitude != "N/A" && longitude != "N/A")
                    Text(
                      "Location: ($latitude, $longitude)",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtonSection() {
    return Wrap(
      spacing: 16, // Horizontal spacing between buttons
      runSpacing: 16, // Vertical spacing between buttons
      alignment: WrapAlignment.center,
      children: [
        _buildActionButton(
          context,
          title: "إضافة أرض",
          icon: Icons.add_circle,
          color: const Color(0xFF556B2F),
          onPressed: _navigateToAddLand,
        ),
        _buildActionButton(
          context,
          title: "تعديل أرض",
          icon: Icons.edit,
          color: const Color(0xFF556B2F),
          onPressed: _navigateToUpdateLand,
        ),
        _buildActionButton(
          context,
          title: "حذف أرض",
          icon: Icons.delete,
          color: Colors.red,
          onPressed: _deleteLand,
        ),
        _buildActionButton(
          context,
          title: "بحث عن عامل",
          icon: Icons.search,
          color: const Color(0xFF556B2F),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SearchForWorkerPage(
                  lands: [],
                ),
              ),
            );
          },
        ),
        _buildActionButton(
          context,
          title: "طلب عامل",
          icon: Icons.person_add,
          color: const Color(0xFF556B2F),
          onPressed: _navigateToWorkerRequest,
        ),
      ],
    );
  }

  Future<void> _navigateToAddLand() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddLandPage(
          onLandAdded: (newLand) {
            setState(() {
              lands.add(newLand);
            });
          },
        ),
      ),
    );
  }

  Future<void> _navigateToUpdateLand() async {
    if (lands.isNotEmpty) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UpdateLandPage(
            initialLandData: lands[currentIndex],
            onLandUpdated: (updatedLand) {
              setState(() {
                lands[currentIndex] = updatedLand;
              });
            },
            lands: lands,
          ),
        ),
      );
    }
  }

  void _deleteLand() {
    if (lands.isNotEmpty) {
      setState(() {
        lands.removeAt(currentIndex);
        currentIndex = lands.isNotEmpty ? currentIndex % lands.length : 0;
      });
    }
  }

  void _navigateToWorkerRequest() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkerRequestPage(
          lands: lands,
          landDetails: {},
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 24, color: Colors.white),
      label: Text(
        title,
        style: const TextStyle(fontSize: 14, color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
