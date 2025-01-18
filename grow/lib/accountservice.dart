// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';

class MyAccountPageService extends StatelessWidget {
  final String name;
  final String email;
  final String contactNumber;
  final String password;
  final String serviceType;

  const MyAccountPageService({
    Key? key,
    required this.name,
    required this.email,
    required this.contactNumber,
    required this.password,
    required this.serviceType,
    required String username,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // خلفية ناعمة بلون أخضر فاتح
      appBar: AppBar(
        backgroundColor: const Color(0xFF556B2F), // لون أخضر حديث
        title: const Text(
          'حسابي',
          style: TextStyle(color: Colors.white, fontSize: 22),
        ),
        centerTitle: true,
        elevation: 5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // صورة المستخدم
            _buildUserImage(),
            const SizedBox(height: 20),
            // اسم المستخدم والبريد الإلكتروني
            _buildUserInfo(name, email),
            const SizedBox(height: 30),
            // الحقول الأساسية
            _buildField(
              icon: Icons.person,
              label: 'الاسم',
              value: name,
              onEdit: () {
                _showEditDialog(context, 'تعديل الاسم', 'الاسم الحالي:', name,
                    (newValue) {
                  // حفظ الاسم الجديد
                });
              },
            ),
            const SizedBox(height: 15),
            _buildField(
              icon: Icons.email,
              label: 'البريد الإلكتروني',
              value: email,
              onEdit: () {
                _showEmailVerificationDialog(context);
              },
            ),
            const SizedBox(height: 15),
            _buildField(
              icon: Icons.phone,
              label: 'رقم الهاتف',
              value: contactNumber,
              onEdit: () {
                _showPhoneVerificationDialog(context);
              },
            ),
            const SizedBox(height: 15),
            _buildField(
              icon: Icons.lock,
              label: 'كلمة المرور',
              value: '**',
              onEdit: () {
                _showPasswordChangeDialog(context);
              },
            ),
            const SizedBox(height: 30),
            // الحقول الديناميكية بناءً على نوع الخدمة
            ..._getFieldsForService(serviceType).map((field) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: _buildField(
                    icon: _getIconForField(field),
                    label: field,
                    value: _getValueForField(field),
                    onEdit: () {
                      _showEditDialog(
                        context,
                        'تعديل $field',
                        field,
                        _getValueForField(field),
                        (newValue) {
                          // حفظ القيمة الجديدة
                        },
                      );
                    },
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildUserImage() {
    return Container(
      height: 120,
      width: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.green.shade50,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Center(
        child: Stack(
          children: [
            const CircleAvatar(
              radius: 55,
              backgroundImage:
                  AssetImage('profilephoto/default-profile-photo.jpg'),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: () {
                  // وظيفة تغيير الصورة
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF556B2F),
                  ),
                  padding: const EdgeInsets.all(6),
                  child: const Icon(
                    Icons.camera_alt,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo(String name, String email) {
    return Column(
      children: [
        Text(
          name,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF556B2F),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          email,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildField({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onEdit,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF556B2F).withOpacity(0.1),
            radius: 25,
            child: Icon(icon, color: const Color(0xFF556B2F), size: 30),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: const Color(0xFF556B2F)),
            onPressed: onEdit,
          ),
        ],
      ),
    );
  }

  List<String> _getFieldsForService(String serviceType) {
    switch (serviceType) {
      case 'معاصر':
        return [
          'اسم المعصرة',
          'اسم المالك',
          'رقم الهاتف',
          'عنوان المعصرة',
          'رابط الفيسبوك'
        ];
      case 'مطاحن':
        return [
          'اسم المطحنة',
          'اسم المالك',
          'رقم الهاتف',
          'عنوان المطحنة',
          'رابط الفيسبوك'
        ];
      case 'الحسبة':
        return [
          'اسم الحسبة',
          'اسم المالك',
          'رقم الهاتف',
          'عنوان الحسبة',
          'رابط الفيسبوك'
        ];
      case 'نقليات':
        return ['اسم شركة النقليات', 'اسم المالك', 'رقم الهاتف'];
      case 'منتجات زراعية':
        return [
          'اسم المتجر',
          'اسم المالك',
          'رقم الهاتف',
          'عنوان المتجر',
          'رابط الفيسبوك'
        ];
      default:
        return [];
    }
  }

  IconData _getIconForField(String field) {
    switch (field) {
      case 'رابط الفيسبوك':
        return Icons.link;
      case 'رقم الهاتف':
        return Icons.phone;
      case 'عنوان المعصرة':
      case 'عنوان المطحنة':
      case 'عنوان الحسبة':
      case 'عنوان المتجر':
        return Icons.location_on;
      case 'اسم المالك':
        return Icons.person;
      default:
        return Icons.text_fields;
    }
  }

  String _getValueForField(String field) {
    switch (field) {
      case 'اسم المعصرة':
      case 'اسم المطحنة':
      case 'اسم الحسبة':
      case 'اسم شركة النقليات':
      case 'اسم المتجر':
        return name;
      case 'رابط الفيسبوك':
        return 'www.facebook.com';
      case 'رقم الهاتف':
        return contactNumber;
      case 'عنوان المعصرة':
      case 'عنوان المطحنة':
      case 'عنوان الحسبة':
      case 'عنوان المتجر':
        return 'عنوان افتراضي';
      default:
        return '';
    }
  }

  void _showPasswordChangeDialog(BuildContext context) {
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تغيير كلمة المرور'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: newPasswordController,
                decoration: const InputDecoration(
                  labelText: 'كلمة المرور الجديدة',
                ),
                obscureText: true,
              ),
              TextField(
                controller: confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'تأكيد كلمة المرور الجديدة',
                ),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF556B2F), // لون النص الأخضر
              ),
              child: const Text(
                'إلغاء',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // قم بالتحقق من كلمة المرور الجديدة وتأكيدها
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF556B2F), // لون الزر الأخضر
              ),
              child: const Text(
                'حفظ',
                style: TextStyle(color: Colors.white), // لون النص الأبيض
              ),
            ),
          ],
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, String title, String label,
      String initialValue, Function(String) onSave) {
    final TextEditingController controller =
        TextEditingController(text: initialValue);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: label),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF556B2F),
              ),
              child: const Text(
                'إلغاء',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                onSave(controller.text);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF556B2F),
              ),
              child: const Text(
                'حفظ',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showEmailVerificationDialog(BuildContext context) {
    final TextEditingController verificationCodeController =
        TextEditingController();
    final TextEditingController newEmailController = TextEditingController();
    int step = 1; // للتحكم في المرحلة (1: إرسال، 2: تحقق، 3: بريد جديد)

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('تعديل البريد الإلكتروني'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (step == 1)
                    const Text(
                        'سوف يتم إرسال كود تحقق إلى البريد الإلكتروني الحالي.'),
                  if (step == 2)
                    TextField(
                      controller: verificationCodeController,
                      decoration: const InputDecoration(
                        labelText: 'أدخل كود التحقق',
                      ),
                    ),
                  if (step == 3)
                    TextField(
                      controller: newEmailController,
                      decoration: const InputDecoration(
                        labelText: 'أدخل البريد الإلكتروني الجديد',
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF556B2F),
                  ),
                  child: const Text(
                    'إلغاء',
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (step == 1) {
                      // الانتقال إلى المرحلة الثانية (إدخال كود التحقق)
                      setState(() {
                        step = 2;
                      });
                    } else if (step == 2) {
                      // الانتقال إلى المرحلة الثالثة (إدخال البريد الإلكتروني الجديد)
                      setState(() {
                        step = 3;
                      });
                    } else if (step == 3) {
                      // حفظ البريد الإلكتروني الجديد وإنهاء الحوار
                      String newEmail = newEmailController.text;

                      // تحقق من البيانات واحفظها هنا
                      Navigator.of(context).pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF556B2F),
                  ),
                  child: Text(
                    step == 1
                        ? 'إرسال'
                        : step == 2
                            ? 'تحقق'
                            : 'حفظ',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showPhoneVerificationDialog(BuildContext context) {
    final TextEditingController verificationCodeController =
        TextEditingController();
    final TextEditingController newPhoneNumberController =
        TextEditingController();
    int step = 1; // للتحكم في المرحلة (1: إرسال، 2: تحقق، 3: رقم جديد)

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('تعديل رقم الهاتف'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (step == 1)
                    const Text('سوف يتم إرسال كود تحقق إلى رقم الهاتف الحالي.'),
                  if (step == 2)
                    TextField(
                      controller: verificationCodeController,
                      decoration: const InputDecoration(
                        labelText: 'أدخل كود التحقق',
                      ),
                    ),
                  if (step == 3)
                    TextField(
                      controller: newPhoneNumberController,
                      decoration: const InputDecoration(
                        labelText: 'أدخل رقم الهاتف الجديد',
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF556B2F),
                  ),
                  child: const Text(
                    'إلغاء',
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (step == 1) {
                      // الانتقال إلى المرحلة الثانية (إدخال كود التحقق)
                      setState(() {
                        step = 2;
                      });
                    } else if (step == 2) {
                      // الانتقال إلى المرحلة الثالثة (إدخال الرقم الجديد)
                      setState(() {
                        step = 3;
                      });
                    } else if (step == 3) {
                      // حفظ الرقم الجديد وإنهاء الحوار
                      String verificationCode = verificationCodeController.text;
                      String newPhoneNumber = newPhoneNumberController.text;

                      // تحقق من البيانات واحفظها هنا
                      Navigator.of(context).pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: Text(
                    step == 1
                        ? 'إرسال'
                        : step == 2
                            ? 'تحقق'
                            : 'حفظ',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
