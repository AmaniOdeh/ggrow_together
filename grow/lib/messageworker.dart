import 'package:flutter/material.dart';

class WorkerMessagingPage extends StatefulWidget {
  @override
  _WorkerMessagingPageState createState() => _WorkerMessagingPageState();
}

class _WorkerMessagingPageState extends State<WorkerMessagingPage> {
  // قائمة المستخدمين مع سجل المحادثات لكل منهم
  final List<Map<String, dynamic>> users = [
    {
      "name": "مالك الأرض أحمد",
      "chats": [
        {
          "text": "مرحبًا، هل يمكنك العمل غدًا؟",
          "isSent": false,
          "time": "10:00 ص"
        },
        {"text": "بالتأكيد، سأكون متاحًا.", "isSent": true, "time": "10:01 ص"},
      ],
    },
    {
      "name": "مالك الأرض فاطمة",
      "chats": [
        {
          "text": "هل يمكنني ضمان الأرض للموسم القادم؟",
          "isSent": false,
          "time": "09:30 ص"
        },
        {
          "text": "سأراجع التفاصيل وأرد عليك.",
          "isSent": true,
          "time": "09:31 ص"
        },
      ],
    },
    {
      "name": "مالك الأرض عمر",
      "chats": [
        {
          "text": "لدينا عمل حراثة الأسبوع المقبل.",
          "isSent": false,
          "time": "08:15 ص"
        },
        {
          "text": "ممتاز. سأجهز الأدوات المطلوبة.",
          "isSent": true,
          "time": "08:16 ص"
        },
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "المحادثات",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF4CAF50),
        centerTitle: true,
        elevation: 5,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, const Color(0xFFD7ECD9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            final lastMessage = user["chats"].isNotEmpty
                ? user["chats"].last["text"]
                : "لا توجد رسائل بعد.";
            final lastTime =
                user["chats"].isNotEmpty ? user["chats"].last["time"] : "";
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WorkerChatPage(
                      userName: user["name"],
                      chats: user["chats"],
                    ),
                  ),
                );
              },
              onLongPress: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return Container(
                      padding: const EdgeInsets.all(10),
                      child: ListTile(
                        leading: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        title: const Text(
                          "حذف المحادثة",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text("تأكيد الحذف"),
                                content: Text(
                                    "هل أنت متأكد أنك تريد حذف المحادثة مع ${user["name"]}؟"),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text("إلغاء"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        users.removeAt(index);
                                      });
                                      Navigator.pop(context);
                                    },
                                    child: const Text("حذف",
                                        style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    );
                  },
                );
              },
              child: Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 3,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF81C784),
                    child: Text(
                      user["name"][0],
                      style: const TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        user["name"],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      Text(
                        lastTime,
                        style: const TextStyle(
                          color: Color(0xFF2E7D32),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Text(
                    lastMessage,
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class WorkerChatPage extends StatefulWidget {
  final String userName;
  final List<Map<String, dynamic>> chats;

  const WorkerChatPage({Key? key, required this.userName, required this.chats})
      : super(key: key);

  @override
  _WorkerChatPageState createState() => _WorkerChatPageState();
}

class _WorkerChatPageState extends State<WorkerChatPage> {
  late List<Map<String, dynamic>> messages;
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    messages = widget.chats;
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      setState(() {
        messages.add({
          "text": _messageController.text.trim(),
          "isSent": true,
          "time": TimeOfDay.now().format(context),
        });
      });
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.userName,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF4CAF50),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, const Color(0xFFD7ECD9)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: messages.isEmpty
                  ? Center(
                      child: Text(
                        "لا توجد رسائل حتى الآن.",
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      reverse: true,
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[messages.length - 1 - index];
                        return Align(
                          alignment: message["isSent"]
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 14),
                            decoration: BoxDecoration(
                              color: message["isSent"]
                                  ? const Color(0xFF66BB6A)
                                  : const Color(0xFFEEEEEE),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              message["text"],
                              style: TextStyle(
                                color: message["isSent"]
                                    ? Colors.white
                                    : Colors.black87,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: "اكتب رسالة...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send, color: Color(0xFF4CAF50)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
