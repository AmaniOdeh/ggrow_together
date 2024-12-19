import 'package:flutter/material.dart';

class MessagingHomePage extends StatefulWidget {
  @override
  _MessagingHomePageState createState() => _MessagingHomePageState();
}

class _MessagingHomePageState extends State<MessagingHomePage> {
  // قائمة المستخدمين مع سجل المحادثات لكل منهم
  final List<Map<String, dynamic>> users = [
    {
      "name": "أحمد",
      "chats": [
        {"text": "مرحبًا، كيف حالك؟", "isSent": false, "time": "10:00 ص"},
        {"text": "أنا بخير، شكرًا! وأنت؟", "isSent": true, "time": "10:01 ص"},
      ],
    },
    {
      "name": "سارة",
      "chats": [
        {"text": "هل يمكنك إرسال التقرير؟", "isSent": false, "time": "09:30 ص"},
        {"text": "بالتأكيد، سأرسله قريبًا.", "isSent": true, "time": "09:31 ص"},
      ],
    },
    {
      "name": "عمر",
      "chats": [
        {"text": "لنلتقي غدًا.", "isSent": false, "time": "08:15 ص"},
        {
          "text": "فكرة رائعة. أراك عند الظهر!",
          "isSent": true,
          "time": "08:16 ص"
        },
      ],
    },
    {
      "name": "Huda",
      "chats": [
        {"text": "حسنًا، فهمت!", "isSent": false, "time": "07:45 ص"},
        {"text": "رائع. شكرًا!", "isSent": true, "time": "07:46 ص"},
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
        backgroundColor: const Color(0xFF4CAF50), // لون أخضر ناعم
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
                    builder: (context) => ChatPage(
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

class ChatPage extends StatefulWidget {
  final String userName;
  final List<Map<String, dynamic>> chats;

  const ChatPage({Key? key, required this.userName, required this.chats})
      : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
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
          "time": TimeOfDay.now().format(context), // التأكد من استخدام نص
        } as Map<String, Object>); // تحويل إلى النوع المطلوب
      });
      _messageController.clear();
    }
  }

  void _showMessageOptions(int index) {
    final message = messages[index];
    final isSent = message["isSent"];
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF4CAF50)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Wrap(
            children: [
              if (isSent)
                ListTile(
                  leading: const Icon(Icons.edit, color: Color(0xFF4CAF50)),
                  title: const Text(
                    "تعديل الرسالة",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _editMessage(index);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  "حذف الرسالة لي فقط",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  setState(() {
                    messages.removeAt(index);
                  });
                  Navigator.pop(context);
                },
              ),
              if (isSent)
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title: const Text(
                    "حذف الرسالة للجميع",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    setState(() {
                      messages.removeAt(index);
                    });
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _editMessage(int index) {
    _messageController.text = messages[index]["text"];
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("تعديل الرسالة"),
          content: TextField(
            controller: _messageController,
            maxLines: null,
            decoration: InputDecoration(
              hintText: "قم بتعديل الرسالة هنا",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF4CAF50)),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  messages[index]["text"] = _messageController.text;
                });
                _messageController.clear();
                Navigator.pop(context);
              },
              child: const Text(
                "حفظ",
                style: TextStyle(color: Color(0xFF4CAF50)),
              ),
            ),
          ],
        );
      },
    );
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
                        return GestureDetector(
                          onLongPress: () =>
                              _showMessageOptions(messages.length - 1 - index),
                          child: Align(
                            alignment: message["isSent"]
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Column(
                              crossAxisAlignment: message["isSent"]
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 5.0, horizontal: 10.0),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12.0, horizontal: 14.0),
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
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15.0),
                                  child: Text(
                                    message["time"],
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
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
                        borderSide: const BorderSide(color: Color(0xFF4CAF50)),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
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
