import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WorkerRequestPage extends StatefulWidget {
  final List<Map<String, dynamic>> lands;
  final int currentIndex; // الفهرس الحالي للأرض المختارة

  const WorkerRequestPage({
    Key? key,
    required this.lands,
    required this.currentIndex,
  }) : super(key: key);

  @override
  _WorkerRequestPageState createState() => _WorkerRequestPageState();
}

class _WorkerRequestPageState extends State<WorkerRequestPage> {
  int _workerCount = 1;
  double _dailyWage = 50.0;
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  // اختيار نطاق التواريخ
  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? pickedDateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );

    if (pickedDateRange != null) {
      setState(() {
        _selectedStartDate = pickedDateRange.start;
        _selectedEndDate = pickedDateRange.end;
      });
    }
  }

  // اختيار الوقت
  Future<void> _selectTime(BuildContext context,
      {required bool isStartTime}) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime
          ? (_startTime ?? TimeOfDay.now())
          : (_endTime ?? TimeOfDay.now()),
    );

    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  // تصميم حقول الإدخال
  InputDecoration _getInputDecoration() {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFF556B2F)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFF556B2F)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: Color(0xFF556B2F),
          width: 2,
        ),
      ),
      filled: true,
      fillColor: const Color(0xFF556B2F).withOpacity(0.2),
    );
  }

  // إنشاء الإعلان
  void _makeAdvertisement() {
    if (_selectedStartDate == null ||
        _selectedEndDate == null ||
        _startTime == null ||
        _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("يرجى إكمال جميع الحقول المطلوبة.")),
      );
      return;
    }

    final selectedLand = widget.lands[widget.currentIndex];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("تم إنشاء الإعلان"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  "تفاصيل الأرض: المحافظة ${selectedLand['governorate']} - المدينة ${selectedLand['town'] ?? "غير متوفرة"}"),
              Text("عدد العمال المطلوبين: $_workerCount"),
              Text("الأجر اليومي: $_dailyWage شيكل"),
              Text(
                "التواريخ: ${DateFormat('dd/MM/yyyy').format(_selectedStartDate!)} - ${DateFormat('dd/MM/yyyy').format(_selectedEndDate!)}",
              ),
              Text(
                "الأوقات: ${_startTime?.format(context)} - ${_endTime?.format(context)}",
              ),
              const SizedBox(height: 10),
              const Text("سيصبح هذا الإعلان مرئيًا الآن للعمال."),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text("تم"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedLand = widget.lands[widget.currentIndex];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF556B2F),
        title: const Text(
          "طلب عمال",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("image/dis.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "الأرض المختارة",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "الأرض: المحافظة ${selectedLand['governorate']} - المدينة ${selectedLand['town'] ?? "غير متوفرة"}",
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "اختر نطاق التواريخ",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      readOnly: true,
                      decoration: _getInputDecoration().copyWith(
                        hintText: _selectedStartDate != null &&
                                _selectedEndDate != null
                            ? "${DateFormat('dd/MM/yyyy').format(_selectedStartDate!)} - ${DateFormat('dd/MM/yyyy').format(_selectedEndDate!)}"
                            : "اختر نطاق التواريخ",
                      ),
                      onTap: () => _selectDateRange(context),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "اختر وقت البداية والنهاية",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      readOnly: true,
                      decoration: _getInputDecoration().copyWith(
                        hintText: _startTime != null
                            ? "وقت البداية: ${_startTime!.format(context)}"
                            : "اختر وقت البداية",
                      ),
                      onTap: () => _selectTime(context, isStartTime: true),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      readOnly: true,
                      decoration: _getInputDecoration().copyWith(
                        hintText: _endTime != null
                            ? "وقت النهاية: ${_endTime!.format(context)}"
                            : "اختر وقت النهاية",
                      ),
                      onTap: () => _selectTime(context, isStartTime: false),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "عدد العمال",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      initialValue: _workerCount.toString(),
                      keyboardType: TextInputType.number,
                      decoration: _getInputDecoration(),
                      onChanged: (value) {
                        setState(() {
                          _workerCount = int.tryParse(value) ?? _workerCount;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "الأجر اليومي (بالشيكل)",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      initialValue: _dailyWage.toStringAsFixed(2),
                      keyboardType: TextInputType.number,
                      decoration: _getInputDecoration(),
                      onChanged: (value) {
                        setState(() {
                          _dailyWage = double.tryParse(value) ?? _dailyWage;
                        });
                      },
                    ),
                    const SizedBox(height: 30),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF556B2F),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: _makeAdvertisement,
                        child: const Text(
                          "إنشاء إعلان",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
