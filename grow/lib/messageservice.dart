import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:jwt_decode/jwt_decode.dart';

class MessagesPage extends StatefulWidget {
  @override
  _MessagesPageState createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  List<dynamic> chats = [];
  List<dynamic> messages = [];
  String? selectedChatId;
  String? selectedChatName;
  String? token;
  String? currentUserId;
  bool _isLoadingMessages = false;
  bool _isEditingMessage = false;
  String? _editingMessageId;
  final TextEditingController _messageController = TextEditingController();
  // To track the selected chat index
  int? _selectedChatIndex;
  int _messageListKey = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadTokenAndUserId();
  }

  @override
  void initState() {
    super.initState();
    _loadTokenAndUserId();
  }

  Future<void> _loadTokenAndUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString("token");

    if (token == null) {
      print("Token is missing. Please log in again.");
      return;
    }

    try {
      Map<String, dynamic> decodedToken = Jwt.parseJwt(token!);
      currentUserId = decodedToken['id'];
      print("Decoded Token: $decodedToken");
      print("Extracted UserId: $currentUserId");
      fetchChats();
    } catch (e) {
      print("Error decoding token: $e");
    }
  }

  Future<void> fetchChats() async {
    if (token == null) {
      print("Token is not loaded yet.");
      return;
    }

    try {
      final response = await http.get(
        Uri.parse("http://192.168.1.10:2000/chats"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final List<dynamic> fetchedChats = jsonDecode(response.body);

        if (fetchedChats.isNotEmpty) {
          setState(() {
            chats = fetchedChats.map((chat) {
              String? otherParticipantId;
              try {
                otherParticipantId = chat["participants"]
                    .firstWhere((participant) => participant != currentUserId);
              } catch (e) {
                otherParticipantId = null;
              }

              return {
                ...chat,
                "otherParticipantName": "Loading...",
                "lastMessage": chat["messages"]?.isNotEmpty == true
                    ? chat["messages"].last["text"]
                    : "No messages yet",
                "lastMessageTime": chat["messages"]?.isNotEmpty == true
                    ? chat["messages"].last["timestamp"]
                    : null,
                "otherParticipantId": otherParticipantId,
              };
            }).toList();
          });
          _updateParticipantNames();
        } else {
          setState(() {
            chats = [];
          });
          print("No chats found for this user.");
        }
      } else if (response.statusCode == 401) {
        print("Unauthorized: Please log in again.");
      } else {
        print("Failed to fetch chats: ${response.body}");
      }
    } catch (e) {
      print("Error fetching chats: $e");
    }
  }

  Future<void> _fetchUserName(String? otherParticipantId, int index) async {
    if (otherParticipantId != null) {
      try {
        final userResponse = await http.get(
          Uri.parse("http://192.168.1.10:2000/users/$otherParticipantId"),
          headers: {"Authorization": "Bearer $token"},
        );
        if (userResponse.statusCode == 200) {
          final userData = jsonDecode(userResponse.body);
          final name =
              userData["name"] ?? userData["userName"] ?? "Unknown User";
          setState(() {
            chats[index]["otherParticipantName"] = name;
          });
        } else {
          print(
              "Failed to fetch user data for $otherParticipantId: ${userResponse.body}");
        }
      } catch (e) {
        print("Error fetching user data for $otherParticipantId: $e");
      }
    }
  }

  Future<void> _updateParticipantNames() async {
    if (chats.isEmpty) return;
    for (var i = 0; i < chats.length; i++) {
      final otherParticipantId = chats[i]["otherParticipantId"];
      await _fetchUserName(otherParticipantId, i);
    }
  }

  Future<void> fetchMessages(String chatId, String chatName) async {
    if (token == null) return;
    setState(() {
      _isLoadingMessages = true;
    });

    try {
      final response = await http.get(
        Uri.parse("http://192.168.1.10:2000/chats/$chatId/messages"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final fetchedMessages = jsonDecode(response.body);
        // فرز الرسائل حسب الوقت من الأقدم إلى الأحدث
        fetchedMessages.sort((a, b) {
          final dateA = DateTime.parse(a["timestamp"]);
          final dateB = DateTime.parse(b["timestamp"]);
          return dateA.compareTo(dateB);
        });

        setState(() {
          messages = fetchedMessages;
          selectedChatId = chatId;
          selectedChatName = chatName;
          _isLoadingMessages = false;
        });
      } else if (response.statusCode == 401) {
        print("Unauthorized: Please log in again.");
      } else {
        print("Failed to fetch messages: ${response.body}");
      }
    } catch (e) {
      print("Error fetching messages: $e");
    } finally {
      setState(() {
        _isLoadingMessages = false;
      });
    }
  }

  Future<void> sendMessage(String text) async {
    if (token == null || selectedChatId == null || text.trim().isEmpty) return;

    final chat =
        chats.firstWhereOrNull((chat) => chat["_id"] == selectedChatId);

    if (chat == null) {
      print("Error: Chat with id $selectedChatId not found");
      return;
    }

    final newMessage = {
      "text": text,
      "sender": currentUserId,
      "timestamp": DateTime.now().toIso8601String(),
    };

    setState(() {
      messages.insert(0, newMessage);
      _messageController.clear();
      _messageListKey++;
    });

    try {
      final response = await http.post(
        Uri.parse("http://192.168.1.10:2000/chats/$selectedChatId/messages"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(newMessage),
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        print("Failed to send message: ${response.body}");
        setState(() {
          messages.removeWhere((msg) =>
              msg["text"] == newMessage["text"] &&
              msg["sender"] == newMessage["sender"] &&
              msg["timestamp"] == newMessage["timestamp"]);
          _messageListKey++;
        });
      }
    } catch (e) {
      print("Error sending message: $e");
      setState(() {
        messages.removeWhere((msg) =>
            msg["text"] == newMessage["text"] &&
            msg["sender"] == newMessage["sender"] &&
            msg["timestamp"] == newMessage["timestamp"]);
        _messageListKey++;
      });
    }
  }

  Future<void> editMessage(String messageId, String newText) async {
    if (token == null || selectedChatId == null || newText.trim().isEmpty) {
      return;
    }
    final newMessage = {
      "text": newText,
    };
    setState(() {
      final messageIndex =
          messages.indexWhere((msg) => msg["_id"] == messageId);
      if (messageIndex != -1) {
        messages[messageIndex]["text"] = newText;
      }
      _messageListKey++;
    });
    try {
      final response = await http.put(
        Uri.parse(
            "http://192.168.1.10:2000/chats/$selectedChatId/messages/$messageId"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(newMessage),
      );

      if (response.statusCode != 200) {
        print("Failed to edit message: ${response.body}");
        setState(() {
          final messageIndex =
              messages.indexWhere((msg) => msg["_id"] == messageId);
          if (messageIndex != -1) {
            messages[messageIndex]["text"] = newText;
          }
          _messageListKey++;
        });
      } else {
        setState(() {
          _isEditingMessage = false;
          _editingMessageId = null;
        });
      }
    } catch (e) {
      print("Error editing message: $e");
      setState(() {
        final messageIndex =
            messages.indexWhere((msg) => msg["_id"] == messageId);
        if (messageIndex != -1) {
          messages[messageIndex]["text"] = newText;
        }
        _messageListKey++;
      });
    }
    fetchMessages(selectedChatId!, selectedChatName!);
  }

  Future<void> deleteMessage(String messageId) async {
    if (token == null || selectedChatId == null) return;

    try {
      final response = await http.delete(
        Uri.parse(
            "http://192.168.1.10:2000/chats/$selectedChatId/messages/$messageId"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        setState(() {
          messages.removeWhere((msg) => msg["_id"] == messageId);
        });
      } else {
        print("Failed to delete message: ${response.body}");
      }
    } catch (e) {
      print("Error deleting message: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFF556B2F),
        hintColor: Color(0xFF556B2F),
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF556B2F),
          titleTextStyle: TextStyle(color: Colors.white),
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: selectedChatId == null
              ? Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    Text("  Messages", style: TextStyle(color: Colors.white)),
                  ],
                )
              : Text(selectedChatName!, style: TextStyle(color: Colors.white)),
          leading: selectedChatId == null
              ? null
              : IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      selectedChatId = null;
                      messages = [];
                      _selectedChatIndex = null;
                    });
                  },
                ),
        ),
        floatingActionButton: selectedChatId == null
            ? FloatingActionButton(
                onPressed: () {},
                backgroundColor: Color(0xFF556B2F),
                child: Icon(Icons.add, color: Colors.white),
              )
            : null,
        body: selectedChatId == null
            ? _buildChatList()
            : Stack(
                children: [
                  _buildChatMessages(),
                  if (_isLoadingMessages)
                    Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).primaryColor),
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  Widget _buildChatList() {
    return chats.isEmpty
        ? Center(
            child: Text("No chats available",
                style: TextStyle(color: Colors.grey[700])))
        : ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final otherParticipantName =
                  chat["otherParticipantName"] ?? "Unknown User";
              final otherParticipantId = chat["otherParticipantId"];
              if (otherParticipantName == "Loading...")
                _fetchUserName(otherParticipantId, index);
              return Card(
                elevation: 2,
                margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(
                      otherParticipantName[0].toUpperCase(),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    otherParticipantName,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  subtitle: Text(chat["lastMessage"] ?? "No messages yet",
                      style: TextStyle(color: Colors.grey[600])),
                  trailing: Text(
                    chat["lastMessageTime"] != null
                        ? _formatTime(chat["lastMessageTime"])
                        : "",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  onTap: () {
                    setState(() {
                      _selectedChatIndex = index;
                    });
                    fetchMessages(chat["_id"], otherParticipantName);
                  },
                  selected: _selectedChatIndex == index,
                  selectedTileColor: Colors.green[100],
                  splashColor: Colors.grey[200],
                  focusColor: Colors.grey[200],
                  hoverColor: Colors.grey[200],
                ),
              );
            },
          );
  }

  Widget _buildChatMessages() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            key: ValueKey(_messageListKey),
            reverse: true,
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];
              return _buildMessageItem(message);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: "Type your message...",
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          BorderSide(color: Theme.of(context).primaryColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                          color: Theme.of(context).primaryColor, width: 2),
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.send),
                color: Color(0xFF556B2F),
                onPressed: () {
                  if (_isEditingMessage && _editingMessageId != null) {
                    editMessage(_editingMessageId!, _messageController.text);
                  } else {
                    sendMessage(_messageController.text);
                  }
                  _messageController.clear();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessageItem(dynamic message) {
    return Align(
      alignment: message["sender"] == currentUserId
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: () {
          if (message["sender"] == currentUserId) {
            _showEditDeleteModal(message);
          }
        },
        child: Container(
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: message["sender"] == currentUserId
                  ? Color(0xFF556B2F)
                  : Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message["text"],
                    style: TextStyle(
                        color: message["sender"] == currentUserId
                            ? Colors.white
                            : Colors.white)),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    message["timestamp"] != null
                        ? DateFormat('hh:mm a')
                            .format(DateTime.parse(message["timestamp"]))
                        : "",
                    style: TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                ),
              ],
            )),
      ),
    );
  }

  void _showEditDeleteModal(dynamic message) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Container(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.edit),
                title: Text('Edit'),
                onTap: () {
                  Navigator.pop(context);
                  _startEditingMessage(message);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete),
                title: Text('Delete'),
                onTap: () {
                  Navigator.pop(context);
                  _deleteMessageAlert(message["_id"]);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _startEditingMessage(dynamic message) {
    setState(() {
      _isEditingMessage = true;
      _editingMessageId = message["_id"];
      _messageController.text = message["text"];
    });
  }

  void _deleteMessageAlert(String messageId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Delete"),
          content: Text("Are you sure you want to delete this message?"),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel",
                  style: TextStyle(color: Theme.of(context).primaryColor)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Delete", style: TextStyle(color: Colors.red)),
              onPressed: () {
                deleteMessage(messageId);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  String _formatTime(String? timestamp) {
    if (timestamp == null) return "";
    final dateTime = DateTime.parse(timestamp);
    if (dateTime.day == DateTime.now().day) {
      return DateFormat('hh:mm a').format(dateTime);
    } else {
      return DateFormat('MM/dd').format(dateTime);
    }
  }
}
