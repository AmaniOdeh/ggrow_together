import 'package:flutter/material.dart';

class SearchForGuarantorPage extends StatefulWidget {
  final List<Map<String, dynamic>> lands;
  final int currentIndex; // الفهرس الحالي للأرض المختارة

  const SearchForGuarantorPage({
    super.key,
    required this.lands,
    required this.currentIndex,
  });

  @override
  _SearchForGuarantorPageState createState() => _SearchForGuarantorPageState();
}

class _SearchForGuarantorPageState extends State<SearchForGuarantorPage> {
  List<Map<String, dynamic>> guarantors = [
    {
      "name": "محمد أحمد",
      "governorate": "نابلس",
      "town": "حوارة",
    },
    {
      "name": "خالد حسن",
      "governorate": "المحافظة ب",
      "town": "المدينة ب",
    },
    {
      "name": "علي عمر",
      "governorate": "المحافظة أ",
      "town": "المدينة أ",
    },
  ];

  List<Map<String, dynamic>> filteredGuarantors = [];

  // فلترة الضامنين بناءً على الأرض المختارة
  void _filterGuarantors(Map<String, dynamic> selectedLand) {
    setState(() {
      final selectedGovernorate =
          selectedLand['governorate']?.trim().toLowerCase() ?? "";
      final selectedTown = selectedLand['town']?.trim().toLowerCase() ?? "";

      filteredGuarantors = guarantors
          .where((guarantor) =>
              (guarantor['governorate']?.trim().toLowerCase() ==
                  selectedGovernorate) &&
              (guarantor['town']?.trim().toLowerCase() == selectedTown))
          .toList();
    });
  }

  // إظهار نافذة منبثقة عند إرسال الطلب
  void _showRequestDialog(String guarantorName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            "تم إرسال الطلب",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF556B2F),
            ),
          ),
          content: Text(
            "تم إرسال الطلب بنجاح إلى $guarantorName.",
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF556B2F),
              ),
              child: const Text(
                "حسناً",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _filterGuarantors(widget.lands[widget.currentIndex]);
  }

  @override
  Widget build(BuildContext context) {
    final selectedLand = widget.lands[widget.currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "البحث عن ضامن",
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
              "الأرض المختارة: ${selectedLand['governorate'] ?? 'غير محددة'}, ${selectedLand['town'] ?? 'غير محددة'}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              "الضامنون القريبون:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: filteredGuarantors.isEmpty
                  ? Center(
                      child: Text(
                        "لا يوجد ضامنون مطابقون للمحافظة والمدينة المحددة.",
                        style:
                            const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredGuarantors.length,
                      itemBuilder: (context, index) {
                        final guarantor = filteredGuarantors[index];
                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Color(0xFF556B2F),
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                            title: Text(guarantor["name"]),
                            trailing: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF556B2F),
                              ),
                              onPressed: () =>
                                  _showRequestDialog(guarantor["name"]),
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
