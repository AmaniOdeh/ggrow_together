import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class LandWorkersPage extends StatefulWidget {
  @override
  _LandWorkersPageState createState() => _LandWorkersPageState();
}

class _LandWorkersPageState extends State<LandWorkersPage> {
  final List<Map<String, dynamic>> lands = [
    {
      "name": "أرض أحمد",
      "location": "المنطقة الشرقية",
      "workers": [
        {
          "name": "أحمد محمد",
          "startHour": "08:00 AM",
          "endHour": "04:00 PM",
          "date": "2024-12-19",
          "service": "زراعة",
          "rating": 4.5,
        },
        {
          "name": "محمد علي",
          "startHour": "09:00 AM",
          "endHour": "05:00 PM",
          "date": "2024-12-19",
          "service": "حرث",
          "rating": 3.0,
        },
      ],
    },
    {
      "name": "أرض سارة",
      "location": "المنطقة الشمالية",
      "workers": [
        {
          "name": "خالد سالم",
          "startHour": "07:00 AM",
          "endHour": "03:00 PM",
          "date": "2024-12-19",
          "service": "تسميد",
          "rating": 5.0,
        },
      ],
    },
  ];
  void _showAddWorkerDialog(Map<String, dynamic> land) {
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
                  decoration: const InputDecoration(labelText: "اسم العامل"),
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
              child: const Text(
                "إلغاء",
                style: TextStyle(color: Color(0xFF556B2F)),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  land["workers"].add({
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
              child: const Text(
                "إضافة",
                style: TextStyle(color: Color(0xFF556B2F)),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showEditWorkerDialog(
      Map<String, dynamic> worker, Map<String, dynamic> land) {
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
                  decoration: const InputDecoration(labelText: "اسم العامل"),
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
              child: const Text(
                "إلغاء",
                style: TextStyle(color: Color(0xFF556B2F)),
              ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "الأراضي والعمال",
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
      body: ListView.builder(
        itemCount: lands.length,
        itemBuilder: (context, index) {
          final land = lands[index];
          return ExpansionTile(
            title: Text(
              land["name"],
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF556B2F),
              ),
            ),
            subtitle: Text("الموقع: ${land["location"]}"),
            children: [
              ...land["workers"].map<Widget>((worker) {
                return _buildWorkerCard(context, worker, land);
              }).toList(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  onPressed: () => _showAddWorkerDialog(land),
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text("إضافة عامل جديد",
                      style: const TextStyle(
                        color: Colors.white,
                      )),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF556B2F),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildWorkerCard(BuildContext context, Map<String, dynamic> worker,
      Map<String, dynamic> land) {
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
                          _showEditWorkerDialog(worker, land);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            land["workers"].remove(worker);
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
}
