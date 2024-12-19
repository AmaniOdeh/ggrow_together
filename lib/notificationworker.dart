import 'package:flutter/material.dart';

class WorkerNotificationsPage extends StatefulWidget {
  final List<Map<String, dynamic>> notifications;

  const WorkerNotificationsPage({Key? key, required this.notifications})
      : super(key: key);

  @override
  _WorkerNotificationsPageState createState() =>
      _WorkerNotificationsPageState();
}

class _WorkerNotificationsPageState extends State<WorkerNotificationsPage> {
  List<Map<String, dynamic>> notifications = [];
  final List<Map<String, dynamic>> employers = [
    {
      "name": "مالك الأرض أحمد",
      "chats": [
        {"text": "هل يمكنك العمل غدًا؟", "isSent": false, "time": "09:00 ص"},
        {"text": "نعم، متى أبدأ؟", "isSent": true, "time": "09:01 ص"},
      ],
    },
    {
      "name": "مالك الأرض فاطمة",
      "chats": [
        {
          "text": "نحتاج إلى عامل لحراثة الأرض.",
          "isSent": false,
          "time": "10:00 ص"
        },
        {"text": "متى يمكنني البدء؟", "isSent": true, "time": "10:01 ص"},
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
            "لقد ${action} الطلب من ${notification['sender']} للعمل على الأرض ${notification['land']}.",
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

  void _openChat(String employerName) {
    final existingEmployer = employers.firstWhere(
      (employer) => employer['name'] == employerName,
      orElse: () => {"name": employerName, "chats": []},
    );

    if (!employers.contains(existingEmployer)) {
      setState(() {
        employers.add(existingEmployer);
      });
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(
          userName: existingEmployer['name'],
          chats: existingEmployer['chats'],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _generateSampleNotifications() {
    return [
      {
        "sender": "مالك الأرض أحمد",
        "land": "رام الله - بيتونيا",
        "message": "نحتاج إلى عامل لحراثة الأرض لمدة يومين.",
        "type": "طلب عمل"
      },
      {
        "sender": "مالك الأرض فاطمة",
        "land": "نابلس - عسكر",
        "message": "يرجى التواصل لتحديد موعد العمل.",
        "type": "طلب تواصل"
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("إشعارات العامل"),
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
                            backgroundColor: notification['type'] == "طلب عمل"
                                ? Colors.blue.withOpacity(0.2)
                                : Colors.green.withOpacity(0.2),
                            child: Icon(
                              notification['type'] == "طلب عمل"
                                  ? Icons.work
                                  : Icons.phone,
                              color: notification['type'] == "طلب عمل"
                                  ? Colors.blue
                                  : Colors.green,
                              size: 28,
                            ),
                          ),
                          title: Text(
                            "${notification['type']} من ${notification['sender']}",
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

class ChatPage extends StatelessWidget {
  final String userName;
  final List<Map<String, String>> chats;

  const ChatPage({Key? key, required this.userName, required this.chats})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("المحادثة مع $userName"),
        backgroundColor: const Color(0xFF556B2F),
      ),
      body: ListView.builder(
        itemCount: chats.length,
        itemBuilder: (context, index) {
          final chat = chats[index];
          return ListTile(
            title: Text(
              chat['text']!,
              textAlign:
                  chat['isSent'] == "true" ? TextAlign.right : TextAlign.left,
            ),
            subtitle: Text(chat['time']!),
          );
        },
      ),
    );
  }
}
