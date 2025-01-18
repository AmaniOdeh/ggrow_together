import 'package:flutter/material.dart';

class SearchForWorkerPage extends StatefulWidget {
  final List<Map<String, dynamic>> lands;
  final int currentIndex; // الفهرس الحالي للأرض

  const SearchForWorkerPage({
    super.key,
    required this.lands,
    required this.currentIndex,
  });

  @override
  _SearchForWorkerPageState createState() => _SearchForWorkerPageState();
}

class _SearchForWorkerPageState extends State<SearchForWorkerPage> {
  List<Map<String, dynamic>> workers = [
    {
      "name": "Worker A",
      "governorate": "نابلس",
      "town": "حوارة",
      "skills": ["Plowing", "Harvesting"],
      "tools": ["Tractor", "Plow"]
    },
    {
      "name": "Worker B",
      "governorate": "Governorate B",
      "town": "Town B",
      "skills": ["Irrigation", "Planting"],
      "tools": ["Irrigation System"]
    },
    {
      "name": "Worker C",
      "governorate": "Governorate A",
      "town": "Town A",
      "skills": ["Harvesting", "Irrigation"],
      "tools": ["Combine Harvester"]
    },
  ];

  List<Map<String, dynamic>> filteredWorkers = [];

  // فلترة العمال بناءً على الأرض المختارة
  void _filterWorkers(Map<String, dynamic> selectedLand) {
    setState(() {
      final selectedGovernorate =
          selectedLand['governorate']?.trim().toLowerCase() ?? "";
      final selectedTown = selectedLand['town']?.trim().toLowerCase() ?? "";

      filteredWorkers = workers
          .where((worker) =>
              (worker['governorate']?.trim().toLowerCase() ==
                  selectedGovernorate) &&
              (worker['town']?.trim().toLowerCase() == selectedTown))
          .toList();
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.currentIndex >= 0 && widget.currentIndex < widget.lands.length) {
      _filterWorkers(widget.lands[widget.currentIndex]);
    } else {
      // إذا كان الفهرس غير صالح
      filteredWorkers = [];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.currentIndex < 0 || widget.currentIndex >= widget.lands.length) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("البحث عن عامل"),
          backgroundColor: const Color(0xFF556B2F),
        ),
        body: const Center(
          child: Text(
            "الفهرس غير صالح أو الأرض المختارة غير متوفرة.",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    final selectedLand = widget.lands[widget.currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "البحث عن عامل",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF556B2F),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "الأرض المختارة: المحافظة ${selectedLand['governorate'] ?? 'غير محددة'}, المدينة ${selectedLand['town'] ?? 'غير محددة'}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              "العمال المتوفرون:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: filteredWorkers.isEmpty
                  ? const Center(
                      child: Text(
                        "لا يوجد عمال مطابقون للموقع المحدد.",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredWorkers.length,
                      itemBuilder: (context, index) {
                        final worker = filteredWorkers[index];
                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Color(0xFF556B2F),
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                            title: Text(worker["name"] ?? "غير معروف"),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (worker['skills'] != null)
                                  Text(
                                      "المهارات: ${worker['skills'].join(", ")}"),
                                if (worker['tools'] != null)
                                  Text(
                                      "الأدوات: ${worker['tools'].join(", ")}"),
                              ],
                            ),
                            trailing: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF556B2F),
                              ),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          "تم إرسال الطلب إلى ${worker['name']}!")),
                                );
                              },
                              child: const Text(
                                "إرسال طلب",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
