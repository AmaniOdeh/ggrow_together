import 'package:flutter/material.dart';

class ServiceProviderMessagingPage extends StatefulWidget {
  @override
  _ServiceProviderMessagingPageState createState() =>
      _ServiceProviderMessagingPageState();
}

class _ServiceProviderMessagingPageState
    extends State<ServiceProviderMessagingPage> {
  // قائمة مقدمي الخدمات وسجل المحادثات لكل منهم
  final List<Map<String, dynamic>> serviceProviders = [
    {
      "name": "محمد أحمد",
      "chats": [
        {
          "text": "مرحبًا، نحتاج لنقل 5 أطنان من الحبوب.",
          "isSent": false,
          "time": "12:00 م"
        },
        {"text": "Ali", "isSent": true, "time": "12:05 م"},
      ],
    },
    {
      "name": "جعفر",
      "chats": [
        {
          "text": "هل يمكن عصر 10 أطنان من الزيتون؟",
          "isSent": false,
          "time": "03:30 م"
        },
        {
          "text": "نعم، الموعد متاح غدًا الساعة 9 صباحًا.",
          "isSent": true,
          "time": "03:35 م"
        },
      ],
    },
    {
      "name": "حسن أنيس",
      "chats": [
        {
          "text": "نحتاج لطحن 2 طن من القمح هذا الأسبوع.",
          "isSent": false,
          "time": "11:15 ص"
        },
        {
          "text": "تم حجز الموعد ليوم الخميس الساعة 10 صباحًا.",
          "isSent": true,
          "time": "11:20 ص"
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
          itemCount: serviceProviders.length,
          itemBuilder: (context, index) {
            final provider = serviceProviders[index];
            final lastMessage = provider["chats"].isNotEmpty
                ? provider["chats"].last["text"]
                : "لا توجد رسائل بعد.";
            final lastTime = provider["chats"].isNotEmpty
                ? provider["chats"].last["time"]
                : "";
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ServiceProviderChatPage(
                      providerName: provider["name"],
                      chats: provider["chats"],
                    ),
                  ),
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
                      provider["name"][0],
                      style: const TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        provider["name"],
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

class ServiceProviderChatPage extends StatefulWidget {
  final String providerName;
  final List<Map<String, dynamic>> chats;

  const ServiceProviderChatPage(
      {Key? key, required this.providerName, required this.chats})
      : super(key: key);

  @override
  _ServiceProviderChatPageState createState() =>
      _ServiceProviderChatPageState();
}

class _ServiceProviderChatPageState extends State<ServiceProviderChatPage> {
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
          widget.providerName,
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
