import 'package:flutter/material.dart';
import 'dart:io';

import 'package:image_picker/image_picker.dart';

class AddLandForGuarantee extends StatefulWidget {
  final Function(Map<String, dynamic>) onLandAdded;

  const AddLandForGuarantee({super.key, required this.onLandAdded});

  @override
  _AddLandForGuaranteeState createState() => _AddLandForGuaranteeState();
}

class _AddLandForGuaranteeState extends State<AddLandForGuarantee> {
  final TextEditingController _workTypeController = TextEditingController();
  final TextEditingController _guaranteeController = TextEditingController();
  final TextEditingController _guaranteeDurationController =
      TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _specificAreaController = TextEditingController();
  File? _selectedImage; // لتخزين الصورة المختارة

  String? selectedGovernorate;
  String? selectedTown;
  String? selectedPlot;
  String? selectedPiece;
  bool isSpecificArea = false;

  // بيانات المحافظات والمدن/البلدات/القرى والمخيمات والأحواض والقطع
  final Map<String, List<String>> governorateData = {
    "القدس": [
      "القدس",
      "العيسوية",
      "سلوان",
      "بيت حنينا",
      "شعفاط",
      "الطور",
      "وادي الجوز",
      "كفر عقب",
      "صور باهر",
      "أم طوبا",
      "بيت صفافا",
      "مخيم شعفاط"
    ],
    "رام الله والبيرة": [
      "رام الله",
      "البيرة",
      "بيتونيا",
      "بيرزيت",
      "دير دبوان",
      "الطيبة",
      "عين يبرود",
      "سلواد",
      "عارورة",
      "عبوين",
      "دورا القرع",
      "نعلين",
      "بلعين",
      "كوبر",
      "أبو شخيدم",
      "أبو فلاح",
      "بيت لقيا",
      "بيت سيرا",
      "مخيم الجلزون"
    ],
    "نابلس": [
      "نابلس",
      "بيت فوريك",
      "بيت دجن",
      "عقربا",
      "عصيرة الشمالية",
      "دير شرف",
      "سبسطية",
      "تل",
      "زواتا",
      "روجيب",
      "جماعين",
      "مادما",
      "عوريف",
      "بورين",
      "عصيرة القبلية",
      "عورتا",
      "حوارة",
      "اللبن الشرقية",
      "ياصيد",
      "الساوية",
      "بيتا",
      "بزاريا",
      "برقة",
      "قوصين",
      "اجنسنيا",
      "قريوت",
      "طلوزة",
      "مخيم بلاطة",
      "مخيم عسكر القديم",
      "مخيم عسكر الجديد",
      "مخيم عين بيت الماء"
    ],
    "الخليل": [
      "الخليل",
      "دورا",
      "يطا",
      "السموع",
      "الظاهرية",
      "بيت أمر",
      "إذنا",
      "ترقوميا",
      "بيت كاحل",
      "الشيوخ",
      "سعير",
      "حلحول",
      "الفوار",
      "مخيم الفوار",
      "مخيم العروب"
    ],
    "جنين": [
      "جنين",
      "قباطية",
      "عرابة",
      "برقين",
      "الزبابدة",
      "يعبد",
      "السيلة الحارثية",
      "جبع",
      "فقوعة",
      "دير أبو ضعيف",
      "مخيم جنين"
    ],
    "طولكرم": [
      "طولكرم",
      "عنبتا",
      "بلعا",
      "قفين",
      "دير الغصون",
      "كفر اللبد",
      "علار",
      "عتيل",
      "مخيم نور شمس",
      "مخيم طولكرم"
    ],
    "قلقيلية": ["قلقيلية", "عزون", "جيوس", "كفر ثلث", "حبلة", "الفندق"],
    "طوباس": ["طوباس", "عقابا", "طمون", "بردلة", "كردلة", "مخيم الفارعة"],
    "أريحا والأغوار": [
      "أريحا",
      "العوجا",
      "النويعمة",
      "مخيم عين السلطان",
      "مخيم عقبة جبر"
    ],
    "سلفيت": [
      "سلفيت",
      "بديا",
      "كفل حارس",
      "دير استيا",
      "قراوة بني حسان",
      "بروقين",
      "مسحة",
      "فرخة"
    ],
    "بيت لحم": [
      "بيت لحم",
      "بيت ساحور",
      "بيت جالا",
      "الخضر",
      "الدوحة",
      "العبيدية",
      "تقوع",
      "نحالين",
      "مخيم عايدة",
      "مخيم الدهيشة",
      "مخيم العزة"
    ],
    "غزة": [
      "غزة",
      "الشجاعية",
      "الرمال",
      "الزيتون",
      "التفاح",
      "الشيخ رضوان",
      "مخيم الشاطئ"
    ],
    "شمال غزة": ["جباليا", "بيت لاهيا", "بيت حانون", "مخيم جباليا"]
  };
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  final List<String> plots =
      List.generate(20, (index) => (index + 1).toString());
  final List<String> pieces =
      List.generate(30, (index) => (index + 1).toString());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Add Land for Guarantee",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF556B2F),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "المحافظة",
                  border: OutlineInputBorder(),
                ),
                value: selectedGovernorate,
                items: governorateData.keys
                    .map((governorate) => DropdownMenuItem(
                          value: governorate,
                          child: Text(governorate),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedGovernorate = value;
                    selectedTown = null;
                    selectedPlot = null;
                    selectedPiece = null;
                  });
                },
              ),
              const SizedBox(height: 16),
              if (selectedGovernorate != null)
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: "المدينة/البلدة/القرية",
                    border: OutlineInputBorder(),
                  ),
                  value: selectedTown,
                  items: governorateData[selectedGovernorate!]
                      ?.map((town) => DropdownMenuItem(
                            value: town,
                            child: Text(town),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedTown = value;
                    });
                  },
                ),
              const SizedBox(height: 16),
              const SizedBox(height: 16),
              if (selectedGovernorate != null)
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: "رقم الحوض",
                    border: OutlineInputBorder(),
                  ),
                  value: selectedPlot,
                  items: plots
                      .map((plot) => DropdownMenuItem(
                            value: plot,
                            child: Text(plot),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedPlot = value;
                    });
                  },
                ),
              const SizedBox(height: 16),
              if (selectedGovernorate != null)
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: "رقم القطعة",
                    border: OutlineInputBorder(),
                  ),
                  value: selectedPiece,
                  items: pieces
                      .map((piece) => DropdownMenuItem(
                            value: piece,
                            child: Text(piece),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedPiece = value;
                    });
                  },
                ),
              const SizedBox(height: 16),
              TextField(
                controller: _workTypeController,
                decoration: const InputDecoration(
                  labelText: "نوع العمل",
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text("هل تريد إدخال مساحة محددة؟"),
                value: isSpecificArea,
                onChanged: (value) {
                  setState(() {
                    isSpecificArea = value ?? false;
                  });
                },
              ),
              if (isSpecificArea)
                TextField(
                  controller: _specificAreaController,
                  decoration: const InputDecoration(
                    labelText: "المساحة المحددة (متر مربع)",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              const SizedBox(height: 16),
              if (_workTypeController.text.trim() == "زراعة")
                TextField(
                  controller: _guaranteeController,
                  decoration: const InputDecoration(
                    labelText: "سعر الضمان (ILS)",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                )
              else if (_workTypeController.text.trim() == "حصاد" ||
                  _workTypeController.text.trim() == "تلقيط")
                TextField(
                  controller: _guaranteeController,
                  decoration: const InputDecoration(
                    labelText: "نسبة الضمان (%)",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              const SizedBox(height: 16),
              TextField(
                controller: _guaranteeDurationController,
                decoration: const InputDecoration(
                  labelText: "مدة الضمان",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: "وصف الأرض",
                  border: OutlineInputBorder(),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8.0),
                color: Colors.white, // خلفية بيضاء لضمان وضوح النص
                child: const Text(
                  "الرجاء تحميل صورة تثبت ملكية الأرض",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF556B2F),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_selectedImage != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    _selectedImage!,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(
                  Icons.photo_library,
                  color: Colors.white,
                ),
                label: const Text("تحميل صورة",
                    style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF556B2F), // لون الزر أخضر فاتح
                ),
                onPressed: _pickImage,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF556B2F),
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  if (selectedGovernorate == null ||
                      selectedTown == null ||
                      selectedPlot == null ||
                      selectedPiece == null ||
                      _workTypeController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("يرجى ملء جميع الحقول المطلوبة")),
                    );
                    return;
                  }

                  final landData = {
                    "governorate": selectedGovernorate,
                    "town": selectedTown,
                    "plotNumber": selectedPlot,
                    "pieceNumber": selectedPiece,
                    "workType": _workTypeController.text.trim(),
                    "specificArea":
                        isSpecificArea ? _specificAreaController.text : null,
                    "guaranteeValue": _guaranteeController.text,
                    "guaranteeDuration": _guaranteeDurationController.text,
                    "description": _descriptionController.text,
                    "image": _selectedImage?.path, // مسار الصورة

                    "type": "guarantee",
                  };

                  widget.onLandAdded(landData);
                  Navigator.pop(context);
                },
                child: const Text("إضافة الأرض"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
