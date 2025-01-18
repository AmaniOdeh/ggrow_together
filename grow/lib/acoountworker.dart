import 'package:flutter/material.dart';

class WorkerAccountPage extends StatelessWidget {
  final String name;
  final String email;
  final String contactNumber;
  final String password;
  final List<String> skills;
  final List<String> tools;
  final String location;

  const WorkerAccountPage({
    Key? key,
    required this.name,
    required this.email,
    required this.contactNumber,
    required this.password,
    required this.skills,
    required this.tools,
    required this.location,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF66BB6A),
        title: const Text(
          'حساب العامل',
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
            _buildUserImage(),
            const SizedBox(height: 20),
            _buildUserInfo(name, email),
            const SizedBox(height: 30),
            _buildField(
              icon: Icons.person,
              label: 'الاسم',
              value: name,
              onEdit: () {
                _showEditDialog(context, 'تعديل الاسم', 'الاسم الحالي:', name,
                    (newValue) {
                  // Save new name
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
              value: '******',
              onEdit: () {
                _showPasswordChangeDialog(context);
              },
            ),
            const SizedBox(height: 15),
            _buildField(
              icon: Icons.build,
              label: 'المهارات',
              value: skills.join(', '),
              onEdit: () {
                _showEditDialog(
                  context,
                  'تعديل المهارات',
                  'المهارات الحالية:',
                  skills.join(', '),
                  (newSkills) {
                    // Save new skills
                  },
                );
              },
            ),
            const SizedBox(height: 15),
            _buildField(
              icon: Icons.construction,
              label: 'الأدوات',
              value: tools.join(', '),
              onEdit: () {
                _showEditDialog(
                  context,
                  'تعديل الأدوات',
                  'الأدوات الحالية:',
                  tools.join(', '),
                  (newTools) {
                    // Save new tools
                  },
                );
              },
            ),
            const SizedBox(height: 15),
            _buildField(
              icon: Icons.location_on,
              label: 'الموقع',
              value: location,
              onEdit: () {
                _showEditDialog(
                  context,
                  'تعديل الموقع',
                  'الموقع الحالي:',
                  location,
                  (newLocation) {
                    // Save new location
                  },
                );
              },
            ),
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
                  // Change profile picture
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green,
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
            color: Colors.green,
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
            backgroundColor: Colors.green.shade50,
            radius: 25,
            child: Icon(icon, color: Colors.green, size: 30),
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
            icon: const Icon(Icons.edit, color: Colors.green),
            onPressed: onEdit,
          ),
        ],
      ),
    );
  }

  void _showPasswordChangeDialog(BuildContext context) {
    final TextEditingController currentPasswordController =
        TextEditingController();
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
                controller: currentPasswordController,
                decoration: const InputDecoration(
                  labelText: 'كلمة المرور الحالية',
                ),
                obscureText: true,
              ),
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
                foregroundColor: Colors.green,
              ),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                // Implement password validation and saving logic here
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text('حفظ', style: TextStyle(color: Colors.white)),
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
                foregroundColor: Colors.green,
              ),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                onSave(controller.text);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text('حفظ', style: TextStyle(color: Colors.white)),
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
    int step = 1; // 1: Send code, 2: Verify code, 3: New email

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
                        'سيتم إرسال كود تحقق إلى البريد الإلكتروني الحالي.'),
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
                    foregroundColor: Colors.green,
                  ),
                  child: const Text('إلغاء'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (step == 1) {
                      setState(() {
                        step = 2;
                      });
                    } else if (step == 2) {
                      setState(() {
                        step = 3;
                      });
                    } else if (step == 3) {
                      // Save the new email here
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

  void _showPhoneVerificationDialog(BuildContext context) {
    final TextEditingController verificationCodeController =
        TextEditingController();
    final TextEditingController newPhoneNumberController =
        TextEditingController();
    int step = 1; // 1: Send code, 2: Verify code, 3: New phone number

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
                    const Text('سيتم إرسال كود تحقق إلى رقم الهاتف الحالي.'),
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
                    foregroundColor: Colors.green,
                  ),
                  child: const Text('إلغاء'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (step == 1) {
                      setState(() {
                        step = 2;
                      });
                    } else if (step == 2) {
                      setState(() {
                        step = 3;
                      });
                    } else if (step == 3) {
                      // Save the new phone number here
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
