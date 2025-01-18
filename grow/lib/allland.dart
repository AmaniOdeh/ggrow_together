import 'package:flutter/material.dart';

// نموذج بيانات الأراضي
class Land {
  final String username;
  final String location;
  final String governorate;
  final String town;
  final String plotNumber;
  final String basinNumber;
  final String workType;
  final String description;
  final String imageUrl;
  final double? guaranteePercentage; // نسبة الضمان

  Land({
    required this.username,
    required this.location,
    required this.governorate,
    required this.town,
    required this.plotNumber,
    required this.basinNumber,
    required this.workType,
    required this.description,
    required this.imageUrl,
    this.guaranteePercentage,
  });
}

// قائمة الأراضي (بيانات أمثلة)
final List<Land> allLands = [
  Land(
    username: "ExampleUser",
    location: "الشارع الرئيسي",
    governorate: "المحافظة أ",
    town: "البلدة أ",
    plotNumber: "123",
    basinNumber: "456",
    workType: "ضمان",
    description: "تحتاج إلى ضمان لمدة سنة",
    imageUrl: "https://via.placeholder.com/150",
    guaranteePercentage: 10.0,
  ),
  Land(
    username: "ExampleUser",
    location: "شارع فرعي",
    governorate: "المحافظة ب",
    town: "البلدة ب",
    plotNumber: "789",
    basinNumber: "101",
    workType: "بحث عن عمال",
    description: "تحتاج إلى عمال للحصاد",
    imageUrl: "https://via.placeholder.com/150",
  ),
  Land(
    username: "AnotherUser",
    location: "حي الزيتون",
    governorate: "المحافظة ج",
    town: "المخيم",
    plotNumber: "654",
    basinNumber: "321",
    workType: "ضمان",
    description: "ضمان لمدة سنتين",
    imageUrl: "https://via.placeholder.com/150",
    guaranteePercentage: 15.0,
  ),
];

// صفحة عرض الأراضي
class LandListPage extends StatelessWidget {
  final String username;

  const LandListPage({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    // تصفية الأراضي بناءً على اسم المستخدم
    final userLands = allLands.where((land) {
      print("Checking land for username: ${land.username}");
      return land.username == username;
    }).toList();

    print("Number of lands for $username: ${userLands.length}");

    return Scaffold(
      appBar: AppBar(
        title: Text('أراضي $username'),
        backgroundColor: const Color(0xFF556B2F), // لون زيتوني
      ),
      body: userLands.isNotEmpty
          ? ListView.builder(
              itemCount: userLands.length,
              itemBuilder: (context, index) {
                final land = userLands[index];
                return _buildLandCard(land);
              },
            )
          : const Center(
              child: Text(
                "لا توجد أراضٍ مرتبطة بهذا المستخدم",
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
            ),
    );
  }

  Widget _buildLandCard(Land land) {
    return Card(
      margin: const EdgeInsets.all(10),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // صورة الأرض
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                land.imageUrl,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Image.asset(
                  'lands/ads1.png',
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 10),
            // تفاصيل الأرض
            Text(
              "الموقع: ${land.location}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text("المحافظة: ${land.governorate}"),
            Text("البلدة/القرية/المخيم: ${land.town}"),
            Text("رقم القطعة: ${land.plotNumber}"),
            Text("رقم الحوض: ${land.basinNumber}"),
            Text("نوع العمل: ${land.workType}"),
            Text("الوصف: ${land.description}"),
            // عرض نسبة الضمان إذا كان العمل "ضمان"
            if (land.workType == "ضمان" && land.guaranteePercentage != null)
              Text(
                "نسبة الضمان: ${land.guaranteePercentage}%",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
