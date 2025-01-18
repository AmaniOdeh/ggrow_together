import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'calculatearea.dart';
import 'package:latlong2/latlong.dart';

class AddLandPage extends StatefulWidget {
  final Function(Map<String, dynamic>) onLandAdded;-

  const AddLandPage({super.key, required this.onLandAdded});

  @override
  _AddLandPageState createState() => _AddLandPageState();
}

class _AddLandPageState extends State<AddLandPage> {
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _governorateController = TextEditingController();
  final TextEditingController _townController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  String specificArea = "";
  String description = "";
  String workType = "";
  LatLng? selectedLocation; // الموقع المحدد للأرض
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool useMapForLocation = true; // الافتراضي: استخدام الخريطة للموقع

  Future<void> _navigateToCalculateArea() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LandAreaCalculator(
          onLandAdded: (newArea, location) {},
        ),
      ),
    );

    if (result != null && result is Map) {
      setState(() {
        _areaController.text = result["area"]?.toStringAsFixed(2) ?? "0.0";
        if (useMapForLocation) {
          selectedLocation = result["centroid"];
          _locationController.text =
              "${selectedLocation?.latitude.toStringAsFixed(5)}, ${selectedLocation?.longitude.toStringAsFixed(5)}";
        }
      });
    }
  }

  Widget _buildCustomTextField({
    required String labelText,
    required IconData icon,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    required Function(String) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFF556B2F),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        readOnly: readOnly,
        onChanged: onChanged,
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: labelText,
          labelStyle: const TextStyle(
            color: Color(0xFF556B2F),
            fontWeight: FontWeight.bold,
          ),
          prefixIcon: Icon(
            icon,
            color: const Color(0xFF556B2F),
          ),
          filled: true, // الخلفية البيضاء
          fillColor: Colors.white, // تحديد الخلفية البيضاء
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _selectImage,
      child: Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF556B2F), width: 2),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: _selectedImage == null
            ? const Center(child: Text("Tap to select image"))
            : Image.file(
                File(_selectedImage!.path),
                fit: BoxFit.cover,
              ),
      ),
    );
  }

  Future<void> _selectImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _selectedImage = XFile(pickedFile.path);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No image selected.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to pick image: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Add New Land",
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Use Map for Location:",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Switch(
                    value: useMapForLocation,
                    onChanged: (value) {
                      setState(() {
                        useMapForLocation = value;
                      });
                    },
                    activeTrackColor:
                        const Color(0xFF8FBC8F), // لون المسار عندما يكون مفعلاً
                    activeColor: const Color(0xFF556B2F), // لون زر السويتش
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _navigateToCalculateArea,
                icon: const Icon(Icons.map),
                label: const Text("Calculate Area from Map"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF556B2F),
                  foregroundColor: Colors.white,
                ),
              ),
              _buildCustomTextField(
                labelText: "Total Area (km²)",
                icon: Icons.square_foot,
                controller: _areaController,
                onChanged: (_) {},
              ),
              if (useMapForLocation) ...[
                _buildCustomTextField(
                  labelText: "Location (Latitude, Longitude)",
                  icon: Icons.location_pin,
                  controller: _locationController,
                  readOnly: true,
                  onChanged: (_) {},
                ),
              ] else ...[
                _buildCustomTextField(
                  labelText: "Governorate",
                  icon: Icons.location_city,
                  controller: _governorateController,
                  onChanged: (value) => {},
                ),
                _buildCustomTextField(
                  labelText: "Town/Village/Camp",
                  icon: Icons.location_on,
                  controller: _townController,
                  onChanged: (value) => {},
                ),
                _buildCustomTextField(
                  labelText: "Street Name",
                  icon: Icons.streetview,
                  controller: _streetController,
                  onChanged: (value) => {},
                ),
              ],
              _buildCustomTextField(
                labelText: "Specific Area (km²)",
                icon: Icons.landscape,
                controller: TextEditingController(text: specificArea),
                keyboardType: TextInputType.number,
                onChanged: (value) => specificArea = value,
              ),
              _buildCustomTextField(
                labelText: "Type of Work",
                icon: Icons.work,
                controller: TextEditingController(text: workType),
                onChanged: (value) => workType = value,
              ),
              _buildCustomTextField(
                labelText: "Description",
                icon: Icons.description,
                controller: TextEditingController(text: description),
                onChanged: (value) => description = value,
              ),
              _buildImagePicker(),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFF556B2F),
                ),
                onPressed: () {
                  if (_areaController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please calculate area.")),
                    );
                    return;
                  }

                  final landData = {
                    "area": _areaController.text,
                    "location": useMapForLocation
                        ? selectedLocation
                        : {
                            "governorate": _governorateController.text,
                            "townOrVillage": _townController.text,
                            "streetName": _streetController.text,
                          },
                    "specificArea": specificArea,
                    "workType": workType,
                    "description": description,
                    "image": _selectedImage?.path,
                    "type": "normal", // إضافة النوع هنا
                  };

                  widget.onLandAdded(landData);
                  Navigator.pop(context);
                },
                child: const Text("Add Land"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
