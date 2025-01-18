import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

class UpdateLandPage extends StatefulWidget {
  final Map<String, dynamic> initialLandData;
  final Function(Map<String, dynamic>) onLandUpdated;

  const UpdateLandPage({
    super.key,
    required this.initialLandData,
    required this.onLandUpdated,
  });

  @override
  _UpdateLandPageState createState() => _UpdateLandPageState();
}

class _UpdateLandPageState extends State<UpdateLandPage> {
  late TextEditingController _areaController;
  late TextEditingController _locationController;
  late TextEditingController _governorateController;
  late TextEditingController _townController;
  late TextEditingController _streetController;
  late TextEditingController _workTypeController;
  late TextEditingController _guaranteeController;
  late TextEditingController _guaranteeDurationController;
  late TextEditingController _descriptionController;

  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  LatLng? selectedLocation;
  bool useMapForLocation = true;

  @override
  void initState() {
    super.initState();
    _areaController =
        TextEditingController(text: widget.initialLandData['area']);
    _locationController = TextEditingController(
        text: widget.initialLandData['location'] != null
            ? "${widget.initialLandData['location']['latitude']}, ${widget.initialLandData['location']['longitude']}"
            : "");
    _governorateController = TextEditingController(
        text: widget.initialLandData['governorate'] ?? "");
    _townController =
        TextEditingController(text: widget.initialLandData['town'] ?? "");
    _streetController =
        TextEditingController(text: widget.initialLandData['street'] ?? "");
    _workTypeController =
        TextEditingController(text: widget.initialLandData['workType'] ?? "");
    _guaranteeController = TextEditingController(
        text: widget.initialLandData['guaranteeValue'] ?? "");
    _guaranteeDurationController = TextEditingController(
        text: widget.initialLandData['guaranteeDuration'] ?? "");
    _descriptionController = TextEditingController(
        text: widget.initialLandData['description'] ?? "");
    if (widget.initialLandData['image'] != null) {
      _selectedImage = XFile(widget.initialLandData['image']);
    }
    useMapForLocation = widget.initialLandData['location'] != null;
  }

  Future<void> _selectImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = XFile(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to pick image: $e")),
      );
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
        border: Border.all(color: const Color(0xFF556B2F), width: 2),
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
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Update Land",
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
              _buildCustomTextField(
                labelText: "Total Area (km²)",
                icon: Icons.square_foot,
                controller: _areaController,
                onChanged: (_) {},
              ),
              if (useMapForLocation)
                _buildCustomTextField(
                  labelText: "Location (Latitude, Longitude)",
                  icon: Icons.location_pin,
                  controller: _locationController,
                  readOnly: true,
                  onChanged: (_) {},
                )
              else ...[
                _buildCustomTextField(
                  labelText: "Governorate",
                  icon: Icons.location_city,
                  controller: _governorateController,
                  onChanged: (_) {},
                ),
                _buildCustomTextField(
                  labelText: "Town/Village/Camp",
                  icon: Icons.location_on,
                  controller: _townController,
                  onChanged: (_) {},
                ),
                _buildCustomTextField(
                  labelText: "Street Name",
                  icon: Icons.streetview,
                  controller: _streetController,
                  onChanged: (_) {},
                ),
              ],
              _buildCustomTextField(
                labelText: "Type of Work",
                icon: Icons.work,
                controller: _workTypeController,
                onChanged: (_) {},
              ),
              _buildCustomTextField(
                labelText: "Guarantee Value",
                icon: Icons.attach_money,
                controller: _guaranteeController,
                keyboardType: TextInputType.number,
                onChanged: (_) {},
              ),
              _buildCustomTextField(
                labelText: "Guarantee Duration",
                icon: Icons.timer,
                controller: _guaranteeDurationController,
                keyboardType: TextInputType.number,
                onChanged: (_) {},
              ),
              _buildCustomTextField(
                labelText: "Description",
                icon: Icons.description,
                controller: _descriptionController,
                onChanged: (_) {},
              ),
              GestureDetector(
                onTap: _selectImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: const Color(0xFF556B2F), width: 2),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: _selectedImage == null
                      ? const Center(
                          child: Text("Tap to select image (Optional)"))
                      : Image.file(
                          File(_selectedImage!.path),
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFF556B2F),
                ),
                onPressed: () {
                  final updatedLand = {
                    "area": _areaController.text,
                    "location": useMapForLocation
                        ? selectedLocation
                        : {
                            "governorate": _governorateController.text,
                            "town": _townController.text,
                            "street": _streetController.text,
                          },
                    "workType": _workTypeController.text.trim(),
                    "guaranteeValue": _guaranteeController.text,
                    "guaranteeDuration": _guaranteeDurationController.text,
                    "description": _descriptionController.text,
                    "image": _selectedImage?.path,
                  };
                  widget.onLandUpdated(updatedLand);
                  Navigator.pop(context);
                },
                child: const Text("Save Changes"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
