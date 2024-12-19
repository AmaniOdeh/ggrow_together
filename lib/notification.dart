import 'package:flutter/material.dart';
import 'messageland.dart'; // Assuming MessagingHomePage is in messageland.dart

class NotificationsPage extends StatefulWidget {
  final List<Map<String, dynamic>> notifications;

  const NotificationsPage({Key? key, required this.notifications})
      : super(key: key);

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<Map<String, dynamic>> notifications = [];
  final List<Map<String, dynamic>> users = [
    // Example user data, shared with MessagingHomePage
    {
      "name": "أحمد",
      "chats": [
        {"text": "مرحبًا، كيف حالك؟", "isSent": false, "time": "10:00 ص"},
        {"text": "أنا بخير، شكرًا! وأنت؟", "isSent": true, "time": "10:01 ص"},
      ],
    },
    {
      "name": "فاطمة",
      "chats": [
        {"text": "هل يمكنك إرسال التقرير؟", "isSent": false, "time": "09:30 ص"},
        {"text": "بالتأكيد، سأرسله قريبًا.", "isSent": true, "time": "09:31 ص"},
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    notifications = widget.notifications.isNotEmpty
        ? widget.notifications
        : _generateSampleNotifications();
  }

  void _handleAction(int index, bool isAccepted) {
    final action = isAccepted ? "تم قبول" : "تم رفض";
    final notification = notifications[index];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isAccepted ? "تم قبول الطلب" : "تم رفض الطلب"),
          content: Text(
            "لقد ${action} الطلب من ${notification['sender']} بخصوص الأرض ${notification['land']}.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  notifications.removeAt(index);
                });
                Navigator.of(context).pop();
              },
              child: const Text("موافق"),
            ),
          ],
        );
      },
    );
  }

  void _openChat(String recipient) {
    // Check if a chat already exists for the recipient
    final existingUser = users.firstWhere(
      (user) => user['name'] == recipient,
      orElse: () => {"name": recipient, "chats": []},
    );

    if (!users.contains(existingUser)) {
      // If no existing chat, create a new chat entry
      setState(() {
        users.add(existingUser);
      });
    }

    // Navigate to ChatPage with the recipient's chat
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(
          userName: existingUser['name'],
          chats: existingUser['chats'],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _generateSampleNotifications() {
    return [
      {
        "sender": "أحمد",
        "land": "المحافظة أ - المدينة أ",
        "message": "أرغب في العمل على هذه الأرض لفترة محددة.",
        "type": "طلب عامل"
      },
      {
        "sender": "فاطمة",
        "land": "المحافظة ب - المدينة ب",
        "message": "أرغب في ضمان هذه الأرض للموسم القادم.",
        "type": "طلب ضمان"
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("الإشعارات"),
        backgroundColor: const Color(0xFF556B2F),
      ),
      body: notifications.isNotEmpty
          ? ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor: notification['type'] == "طلب عامل"
                                ? Colors.blue.withOpacity(0.2)
                                : Colors.green.withOpacity(0.2),
                            child: Icon(
                              notification['type'] == "طلب عامل"
                                  ? Icons.people
                                  : Icons.shield,
                              color: notification['type'] == "طلب عامل"
                                  ? Colors.blue
                                  : Colors.green,
                              size: 28,
                            ),
                          ),
                          title: Text(
                            notification['type'] == "طلب عامل"
                                ? "طلب عامل من ${notification['sender']}"
                                : "طلب ضمان من ${notification['sender']}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                            "الأرض: ${notification['land']}",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        const Divider(color: Colors.grey),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            notification['message'],
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.check,
                                  color: Color(0xFF556B2F)),
                              onPressed: () {
                                _handleAction(index, true);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () {
                                _handleAction(index, false);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.message,
                                  color: Colors.green),
                              onPressed: () {
                                _openChat(notification['sender']);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            )
          : const Center(
              child: Text(
                "لا توجد إشعارات حالياً.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
    );
  }
}
