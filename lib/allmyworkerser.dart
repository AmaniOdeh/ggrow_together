import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class MyWorkerPage extends StatefulWidget {
  @override
  _MyWorkerPageState createState() => _MyWorkerPageState();
}

class _MyWorkerPageState extends State<MyWorkerPage> {
  final List<Map<String, dynamic>> workers = [
    {
      "name": "أحمد محمد",
      "startHour": "08:00 AM",
      "endHour": "04:00 PM",
      "date": "2024-12-19",
      "service": "زراعة",
      "rating": 0.0,
    },
    {
      "name": "محمد علي",
      "startHour": "09:00 AM",
      "endHour": "05:00 PM",
      "date": "2024-12-19",
      "service": "حرث",
      "rating": 0.0,
    },
    {
      "name": "خالد سالم",
      "startHour": "07:00 AM",
      "endHour": "03:00 PM",
      "date": "2024-12-19",
      "service": "تسميد",
      "rating": 0.0,
    },
  ];

  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredWorkers = workers.where((worker) {
      return worker["name"]!
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
          worker["service"]!.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "العُمال",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF556B2F), Color(0xFFA8D5BA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          const SizedBox(height: 10),
          Expanded(
            child: filteredWorkers.isNotEmpty
                ? ListView.builder(
                    itemCount: filteredWorkers.length,
                    itemBuilder: (context, index) {
                      return _buildWorkerCard(context, filteredWorkers[index]);
                    },
                  )
                : const Center(
                    child: Text(
                      "لا يوجد عمال مطابقين للبحث",
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: Directionality(
        textDirection: TextDirection.rtl,
        child: FloatingActionButton(
          backgroundColor: const Color(0xFFFFFFFF),
          onPressed: () {
            _showAddWorkerDialog();
          },
          child: const Icon(Icons.add, size: 30, color: Color(0xFF556B2F)),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: TextField(
          textAlign: TextAlign.right,
          decoration: InputDecoration(
            hintText: "ابحث عن عامل أو خدمة...",
            prefixIcon: const Icon(Icons.search, color: Color(0xFF556B2F)),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.all(15),
          ),
          onChanged: (value) {
            setState(() {
              searchQuery = value;
            });
          },
        ),
      ),
    );
  }

  Widget _buildWorkerCard(BuildContext context, Map<String, dynamic> worker) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.star, color: Colors.amber),
                        onPressed: () {
                          _showRatingDialog(worker);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Color(0xFF4CAF50)),
                        onPressed: () {
                          _showEditWorkerDialog(worker);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            workers.remove(worker);
                          });
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Color(0xFF556B2F),
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        worker["name"]!,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF556B2F),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(color: Colors.grey),
              _buildDetailRow(
                icon: Icons.access_time,
                label: "ساعات العمل",
                value: "${worker["startHour"]} - ${worker["endHour"]}",
              ),
              _buildDetailRow(
                icon: Icons.calendar_today,
                label: "التاريخ",
                value: worker["date"]!,
              ),
              _buildDetailRow(
                icon: Icons.build,
                label: "نوع الخدمة",
                value: worker["service"]!,
              ),
              _buildDetailRow(
                icon: Icons.star,
                label: "التقييم",
                value: "${worker["rating"]!.toStringAsFixed(1)} / 5.0",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              "$label: $value",
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
          ),
          const SizedBox(width: 10),
          Icon(icon, color: const Color(0xFF556B2F)),
        ],
      ),
    );
  }

  void _showRatingDialog(Map<String, dynamic> worker) {
    double newRating = worker["rating"]!;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "قيم العامل",
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "${worker["name"]}",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF556B2F),
                ),
              ),
              const SizedBox(height: 15),
              RatingBar.builder(
                initialRating: worker["rating"]!,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemSize: 40, // زيادة حجم النجوم
                unratedColor: Colors.grey[300],
                glowColor: Colors.amber,
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  newRating = rating;
                },
              ),
              const SizedBox(height: 10),
              Text(
                "تقييمك الحالي: ${newRating.toStringAsFixed(1)} / 5",
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                "إلغاء",
                style: TextStyle(color: Color(0xFF556B2F)),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  worker["rating"] = newRating;
                });
                Navigator.of(context).pop();
              },
              child: const Text(
                "حفظ",
                style: TextStyle(color: Color(0xFF556B2F)),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAddWorkerDialog() {
    String name = "";
    String startHour = "";
    String endHour = "";
    String date = "";
    String service = "";

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "إضافة عامل جديد",
            textAlign: TextAlign.right,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(labelText: "الاسم"),
                  onChanged: (value) => name = value,
                ),
                TextField(
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(labelText: "بداية العمل"),
                  onChanged: (value) => startHour = value,
                ),
                TextField(
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(labelText: "نهاية العمل"),
                  onChanged: (value) => endHour = value,
                ),
                TextField(
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(labelText: "التاريخ"),
                  onChanged: (value) => date = value,
                ),
                TextField(
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(labelText: "نوع الخدمة"),
                  onChanged: (value) => service = value,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("إلغاء",
                  style: TextStyle(color: Color(0xFF556B2F))),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  workers.add({
                    "name": name,
                    "startHour": startHour,
                    "endHour": endHour,
                    "date": date,
                    "service": service,
                    "rating": 0.0,
                  });
                });
                Navigator.of(context).pop();
              },
              child: const Text("إضافة",
                  style: TextStyle(color: Color(0xFF556B2F))),
            ),
          ],
        );
      },
    );
  }

  void _showEditWorkerDialog(Map<String, dynamic> worker) {
    String name = worker["name"]!;
    String startHour = worker["startHour"]!;
    String endHour = worker["endHour"]!;
    String date = worker["date"]!;
    String service = worker["service"]!;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "تعديل معلومات العامل",
            textAlign: TextAlign.right,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(labelText: "الاسم"),
                  controller: TextEditingController(text: name),
                  onChanged: (value) => name = value,
                ),
                TextField(
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(labelText: "بداية العمل"),
                  controller: TextEditingController(text: startHour),
                  onChanged: (value) => startHour = value,
                ),
                TextField(
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(labelText: "نهاية العمل"),
                  controller: TextEditingController(text: endHour),
                  onChanged: (value) => endHour = value,
                ),
                TextField(
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(labelText: "التاريخ"),
                  controller: TextEditingController(text: date),
                  onChanged: (value) => date = value,
                ),
                TextField(
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(labelText: "نوع الخدمة"),
                  controller: TextEditingController(text: service),
                  onChanged: (value) => service = value,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("إلغاء",
                  style: TextStyle(color: Color(0xFF556B2F))),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  worker["name"] = name;
                  worker["startHour"] = startHour;
                  worker["endHour"] = endHour;
                  worker["date"] = date;
                  worker["service"] = service;
                });
                Navigator.of(context).pop();
              },
              child: const Text("تعديل",
                  style: TextStyle(color: Color(0xFF556B2F))),
            ),
          ],
        );
      },
    );
  }
}
