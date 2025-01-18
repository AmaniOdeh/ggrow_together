import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class LandServiceProvidersPage extends StatefulWidget {
  @override
  _LandServiceProvidersPageState createState() =>
      _LandServiceProvidersPageState();
}

class _LandServiceProvidersPageState extends State<LandServiceProvidersPage> {
  final List<Map<String, dynamic>> lands = [
    {
      "name": "أرض أحمد",
      "location": "المنطقة الشرقية",
      "providers": [
        {
          "name": "شركة الزراعة الحديثة",
          "services": [
            {"name": "حصاد القمح", "rating": 4.0},
            {"name": "رش المبيدات", "rating": 3.5},
          ],
        },
        {
          "name": "شركة الحراثة الشاملة",
          "services": [
            {"name": "حراثة الأراضي", "rating": 5.0},
          ],
        },
      ],
    },
    {
      "name": "أرض سارة",
      "location": "المنطقة الشمالية",
      "providers": [
        {
          "name": "شركة الري المثالي",
          "services": [
            {"name": "توزيع المياه", "rating": 4.5},
          ],
        },
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "الشركات والخدمات",
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
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      land["name"],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF556B2F),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "الموقع: ${land["location"]}",
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const Divider(color: Colors.grey),
                    ...land["providers"].map<Widget>((provider) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              provider["name"],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4CAF50),
                              ),
                            ),
                            const SizedBox(height: 5),
                            ...provider["services"].map<Widget>((service) {
                              return Padding(
                                padding: const EdgeInsets.only(left: 16.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      service["name"],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFF556B2F),
                                      ),
                                    ),
                                    RatingBar.builder(
                                      initialRating: service["rating"],
                                      minRating: 1,
                                      direction: Axis.horizontal,
                                      allowHalfRating: true,
                                      itemCount: 5,
                                      itemSize: 20,
                                      unratedColor: Colors.grey[300],
                                      glowColor: Colors.amber,
                                      itemBuilder: (context, _) => const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                      ),
                                      onRatingUpdate: (rating) {
                                        setState(() {
                                          service["rating"] = rating;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
