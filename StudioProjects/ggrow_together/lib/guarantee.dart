import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart'; // مكتبة السلايدر
import 'addlandforguarantee.dart';
import 'updatelandforgurantee.dart';

class GuaranteePage extends StatefulWidget {
  const GuaranteePage({super.key});

  @override
  _GuaranteePageState createState() => _GuaranteePageState();
}

class _GuaranteePageState extends State<GuaranteePage> {
  List<Map<String, dynamic>> lands = [
    {"name": "Land A", "area": 0.5}, // المساحة بالكيلومتر المربع
    {"name": "Land B", "area": 0.3},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Guarantee Page",
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // عبارة ترحيبية
            const Text(
              "Welcome to Guarantee Page",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // أزرار التحكم
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  context,
                  title: "Add",
                  icon: Icons.add_circle,
                  color: Colors.green,
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddLandForGuarantee(
                          onLandAdded: (Map<String, dynamic> newLand) {
                            setState(() {
                              lands.add(newLand);
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
                _buildActionButton(
                  context,
                  title: "Update",
                  icon: Icons.edit,
                  color: Colors.blue,
                  onPressed: () async {
                    if (lands.isNotEmpty) {
                      Map<String, dynamic> selectedLand = lands[0]; // مثال
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UpdateLandPage(
                            initialLandData: selectedLand,
                            onLandUpdated: (updatedLandData) {
                              setState(() {
                                lands[0] = updatedLandData;
                              });
                            },
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("No lands available to update."),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    }
                  },
                ),
                _buildActionButton(
                  context,
                  title: "Delete",
                  icon: Icons.delete,
                  color: Colors.red,
                  onPressed: () {
                    if (lands.isNotEmpty) {
                      _showDeleteConfirmation(context, () {
                        setState(() {
                          lands.removeAt(0);
                        });
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Land deleted successfully."),
                            backgroundColor: Colors.red,
                          ),
                        );
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("No lands available to delete."),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            // سلايدر الكروت
            const Text(
              "Lands:",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: lands.isEmpty
                  ? const Center(
                      child: Text(
                        "No lands available.",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    )
                  : CarouselSlider(
                      options: CarouselOptions(
                        height: 200, // ارتفاع السلايدر
                        enlargeCenterPage: true,
                        autoPlay: true,
                        autoPlayInterval: const Duration(seconds: 3),
                        aspectRatio: 16 / 9,
                        viewportFraction: 0.8, // حجم الكارد بالنسبة للشاشة
                      ),
                      items: lands.map((land) {
                        return Builder(
                          builder: (BuildContext context) {
                            return Card(
                              color: Colors.white.withOpacity(0.9),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              margin: const EdgeInsets.all(10),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      land['name'],
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Area: ${land['area']} km²",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),
            ),
          ],
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
      icon: Icon(icon, size: 20, color: Colors.white),
      label: Text(
        title,
        style: const TextStyle(fontSize: 14, color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, VoidCallback onDelete) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Delete"),
          content: const Text(
              "Are you sure you want to delete this land from the guarantee list?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: onDelete,
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
