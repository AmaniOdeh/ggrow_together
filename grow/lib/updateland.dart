import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UpdateLandPage extends StatefulWidget {
  final Map<String, dynamic> initialLandData;
  final Function(Map<String, dynamic>) onLandUpdated;

  const UpdateLandPage({
    super.key,
    required this.initialLandData,
    required this.onLandUpdated,
    required List<Map<String, dynamic>> lands,
  });

  @override
  _UpdateLandPageState createState() => _UpdateLandPageState();
}

class _UpdateLandPageState extends State<UpdateLandPage> {
  late TextEditingController _workTypeController;
  late TextEditingController _descriptionController;
  late TextEditingController _specificAreaController;
  String? selectedGovernorate;
  String? selectedTown;
  String? selectedPlot;
  String? selectedPiece;
  File? _selectedImage;
  bool isSpecificArea = false;

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

  final List<String> plots =
      List.generate(20, (index) => (index + 1).toString());
  final List<String> pieces =
      List.generate(30, (index) => (index + 1).toString());

  @override
  void initState() {
    super.initState();
    _workTypeController =
        TextEditingController(text: widget.initialLandData['workType'] ?? '');
    _descriptionController = TextEditingController(
        text: widget.initialLandData['description'] ?? '');
    _specificAreaController = TextEditingController(
        text: widget.initialLandData['specificArea'] ?? '');
    selectedGovernorate = widget.initialLandData['governorate'];
    selectedTown = widget.initialLandData['town'];
    selectedPlot = widget.initialLandData['plotNumber'];
    selectedPiece = widget.initialLandData['pieceNumber'];

    if (widget.initialLandData['image'] != null) {
      _selectedImage = File(widget.initialLandData['image']);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Widget _buildTextField({
    required String labelText,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("تعديل بيانات الأرض"),
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
                  items: governorateData[selectedGovernorate!]!
                      .map((town) => DropdownMenuItem(
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
              _buildTextField(
                labelText: "نوع العمل",
                controller: _workTypeController,
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
                _buildTextField(
                  labelText: "المساحة المحددة (متر مربع)",
                  controller: _specificAreaController,
                  keyboardType: TextInputType.number,
                ),
              const SizedBox(height: 16),
              _buildTextField(
                labelText: "وصف الأرض",
                controller: _descriptionController,
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
                icon: const Icon(Icons.photo_library),
                label: const Text("تحميل صورة جديدة"),
                onPressed: _pickImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF556B2F),
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF556B2F),
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  final updatedLand = {
                    "governorate": selectedGovernorate,
                    "town": selectedTown,
                    "plotNumber": selectedPlot,
                    "pieceNumber": selectedPiece,
                    "workType": _workTypeController.text,
                    "specificArea":
                        isSpecificArea ? _specificAreaController.text : null,
                    "description": _descriptionController.text,
                    "image":
                        _selectedImage?.path ?? widget.initialLandData['image'],
                  };
                  widget.onLandUpdated(updatedLand);
                  Navigator.pop(context);
                },
                child: const Text("حفظ التعديلات"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
