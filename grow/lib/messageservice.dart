import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:file_picker/file_picker.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

class MessagesPage extends StatefulWidget {
  final String userId;

  const MessagesPage({Key? key, required this.userId}) : super(key: key);

  @override
  _MessagesPageState createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  static const String _apiBaseUrl = "http://192.168.1.10:2000/messages";
  static const Color _primaryColor = Color(0xFF556B2F);
  List<dynamic> chats = [];
  List<dynamic> messages = [];
  String? selectedChatId;
  String? selectedChatName;
  String? selectedReceiverId;
  bool _isLoadingMessages = false;
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isSearching = false;
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  late AudioRecorder audioRecorder;
  bool isRecording = false;
  String? audioPath;
  final audioPlayer = AudioPlayer();
  late String localPath;
  String? _editingMessageId;
  FocusNode _messageFocusNode = FocusNode();
  bool _isLoading = false;
  bool _isEditing = false;
  late StreamSubscription<RemoteMessage> _messageSubscription;
  late ScrollController _scrollController; // Add ScrollController

  @override
  void initState() {
    super.initState();
    audioRecorder = AudioRecorder();
    _scrollController = ScrollController(); // Initialize ScrollController
    fetchChats();
    requestPermission();
    getToken();
    _getLocalPath();

    _messageSubscription =
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (mounted) {
        if (message.data['chatId'] == selectedChatId) {
          fetchMessages(selectedChatId!);
        }
        fetchChats();
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {});
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  @override
  void dispose() {
    _messageSubscription.cancel();
    _messageFocusNode.dispose();
    _messageController.dispose();
    _searchController.dispose();
    _scrollController.dispose(); // Dispose ScrollController
    super.dispose();
  }

  Future<void> _getLocalPath() async {
    final directory = await getApplicationDocumentsDirectory();
    localPath = directory.path;
  }

  Future<void> getToken() async {
    try {
      String? token = await messaging.getToken();
      if (token != null) {
        await http.post(
          Uri.parse("$_apiBaseUrl/users/updateToken"),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({"token": token, "userId": widget.userId}),
        );
      }
    } catch (e) {
      print("Error getting token $e");
    }
  }

  Future<void> requestPermission() async {
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> fetchChats() async {
    try {
      final response = await http
          .get(Uri.parse("$_apiBaseUrl/chats?userId=${widget.userId}"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        if (mounted) {
          setState(() => chats = data);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to load chats: $e')));
      }
      print('Error fetching chats: $e');
    }
  }

  Future<void> fetchMessages(String chatId) async {
    if (!mounted) return;
    setState(() {
      _isLoadingMessages = true;
      _editingMessageId = null;
    });
    try {
      final response =
          await http.get(Uri.parse("$_apiBaseUrl/messages/$chatId"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            messages = data;
            selectedChatId = chatId;
            _isLoadingMessages = false;
            final currentChat = chats.firstWhere((chat) => chat['id'] == chatId,
                orElse: () => null);
            if (currentChat != null) {
              final otherParticipant =
                  currentChat['participantsInfo']?.firstWhere(
                (p) => p['id'] != widget.userId,
                orElse: () => null,
              );
              selectedReceiverId = otherParticipant?['id'];
              selectedChatName = otherParticipant?['name'];
            }
          });
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              _scrollController
                  .jumpTo(_scrollController.position.maxScrollExtent);
            }
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingMessages = false);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load messages: $e')));
      }

      print("Error fetching messages: $e");
    }
  }

  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) {
      if (mounted) {
        setState(() {
          _isSearching = false;
          _searchResults = [];
        });
      }
      return;
    }

    if (mounted) {
      setState(() => _isSearching = true);
    }

    try {
      final response = await http.get(Uri.parse(
          "$_apiBaseUrl/users/search?query=$query&userId=${widget.userId}"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _searchResults = data.toSet().toList();
            _isSearching = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSearching = false);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to search users: $e')));
      }

      print('Error searching users: $e');
    }
  }

  Future<void> createChat(String chatName, String userId) async {
    try {
      final response = await http.post(
        Uri.parse("$_apiBaseUrl/chats"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "participants": [widget.userId, userId]
        }),
      );
      if (response.statusCode == 200) {
        final chatData = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            selectedChatName = chatData['participantsInfo']
                .firstWhere((p) => p['id'] != widget.userId)['name'];
            selectedChatId = chatData['id'];
            selectedReceiverId = userId;
          });
        }

        fetchMessages(chatData['id']);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to create chat: $e')));
      }

      print("Error creating chat: $e");
    }
  }

  Future<void> _editMessage(String messageId, String newText) async {
    try {
      final response = await http.put(
        Uri.parse("$_apiBaseUrl/messages/edit"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "messageId": messageId,
          "newText": newText,
          "senderId": widget.userId,
          "timestamp": DateTime.now().toIso8601String()
        }),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _editingMessageId = null;
            _messageController.clear();
            _messageFocusNode.unfocus();
          });
        }
        await fetchMessages(selectedChatId!); // إعادة تحميل الرسائل
      }
    } catch (e) {
      print("Error editing message: $e");
    }
  }

  Future<void> _deleteMessage(String messageId) async {
    try {
      await http.delete(Uri.parse("$_apiBaseUrl/messages/$messageId"));
      if (mounted) {
        setState(() {
          messages.removeWhere((message) => message['id'] == messageId);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete message: $e')));
      }

      print("Error deleting message: $e");
    }
  }

  Future<void> sendMessage(String text, String? type) async {
    if (selectedChatId == null || selectedReceiverId == null) return;
    try {
      if (type == 'image' || type == 'audio') {
        File? file;
        if (type == 'image') {
          final compressedFile = await _compressImage(File(text));
          file = compressedFile;
        } else {
          file = File(text);
        }
        if (file == null) return;

        var request =
            http.MultipartRequest('POST', Uri.parse("$_apiBaseUrl/send"));
        request.files.add(await http.MultipartFile.fromPath('file', file.path,
            contentType: type == 'audio'
                ? MediaType('audio', 'm4a') // Use audio/m4a for audio
                : MediaType('image', 'jpeg')));

        request.fields.addAll({
          'chatId': selectedChatId!,
          'senderId': widget.userId,
          'receiverId': selectedReceiverId!,
          'type': type!,
        });
        final response = await request.send();

        if (response.statusCode != 200) {
          throw Exception('Failed with status: ${response.statusCode}');
        }
      } else {
        final response = await http.post(
          Uri.parse("$_apiBaseUrl/send"),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            "text": text,
            "chatId": selectedChatId!,
            "senderId": widget.userId,
            "receiverId": selectedReceiverId,
            "type": type,
          }),
        );
        if (response.statusCode != 200) {
          throw Exception('Failed with status: ${response.statusCode}');
        }
      }

      _messageController.clear();
      fetchMessages(selectedChatId!);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to send message: ${e.toString()}')));
      }
      print("Error sending message: $e");
    }
  }

  Future<File?> _compressImage(File file) async {
    final tempDir = await getTemporaryDirectory();
    final compressedFile = await FlutterImageCompress.compressAndGetFile(
      file.path,
      '${tempDir.path}/${path.basename(file.path)}.compressed.jpg',
      quality: 50,
    );
    if (compressedFile != null) {
      return File(compressedFile.path);
    }
    return null;
  }

  Future<void> _requestStoragePermission() async {
    if (kIsWeb) {
      await _pickImage();
      return;
    }
    final status = await Permission.storage.status;
    if (status.isGranted) {
      await _pickImage();
    } else {
      final requestStatus = await Permission.storage.request();
      if (requestStatus.isGranted) {
        await _pickImage();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Storage permission denied.')));
        }
        print("Storage permission denied.");
      }
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    final compressedFile = await _compressImage(File(image.path));
    if (compressedFile != null) {
      sendMessage(compressedFile.path, "image");
    }
  }

  Future<void> _showCreateChatDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إنشاء محادثة جديدة'),
        content: _buildUserSearchList(),
        actions: [
          TextButton(
            child: const Text('إلغاء'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildUserSearchList() {
    if (_isSearching) return const Center(child: CircularProgressIndicator());
    if (_searchResults.isEmpty)
      return const Center(child: Text("لم يتم العثور على مستخدمين"));

    return SizedBox(
      height: 200,
      width: 300,
      child: ListView.separated(
        itemCount: _searchResults.length,
        separatorBuilder: (_, __) =>
            Divider(height: 1, color: Colors.grey[300]),
        itemBuilder: (context, index) {
          final user = _searchResults[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: _primaryColor.withOpacity(0.2),
              child: Text(
                (user['displayName']?[0] ?? 'U').toUpperCase(),
                style: TextStyle(color: _primaryColor),
              ),
            ),
            title: Text(user['displayName'] ?? "مستخدم غير معروف"),
            onTap: () {
              createChat(user['displayName'], user['id']);
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }

  Future<void> _recordAudio() async {
    if (isRecording) {
      try {
        final path = await audioRecorder.stop();
        if (mounted) {
          setState(() => isRecording = false);
        }
        if (path != null) sendMessage(path, "audio");
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error stopping recording: $e')));
        }
        print("Error stopping recording: $e");
      }
    } else {
      try {
        if (await audioRecorder.hasPermission()) {
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final newPath = '$localPath/audio_$timestamp.m4a';
          await audioRecorder.start(const RecordConfig(), path: newPath);
          if (mounted) {
            setState(() => isRecording = true);
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error starting recording: $e')));
        }
        print("Error starting recording: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Scaffold(
        appBar: AppBar(
          backgroundColor: _primaryColor,
          iconTheme: const IconThemeData(color: Colors.white),
          titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
          title: Text(selectedChatName ?? "المحادثات"),
          leading: selectedChatId != null
              ? IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                  onPressed: () => setState(() {
                    selectedChatId = null;
                    messages = [];
                    selectedReceiverId = null;
                    selectedChatName = null;
                    _editingMessageId = null;
                  }),
                )
              : null,
        ),
        body: selectedChatId == null ? _buildChatList() : _buildChatMessages(),
        floatingActionButton: selectedChatId == null
            ? FloatingActionButton(
                backgroundColor: _primaryColor,
                onPressed: _showCreateChatDialog,
                child: const Icon(Icons.add, color: Colors.white),
              )
            : null,
      ),
      if (_isLoading)
        Center(child: CircularProgressIndicator(color: _primaryColor)),
    ]);
  }

  Widget _buildChatList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "ابحث عن مستخدمين...",
                prefixIcon: const Icon(
                  Icons.search,
                  color: _primaryColor,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear,
                          color: _primaryColor,
                        ),
                        onPressed: () => setState(() {
                          _searchController.clear();
                          _searchResults = [];
                        }),
                      )
                    : null,
                border: InputBorder.none,
              ),
              onChanged: _searchUsers,
            ),
          ),
        ),
        Expanded(
          child: _isSearching
              ? const Center(child: CircularProgressIndicator())
              : _searchResults.isNotEmpty
                  ? ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final user = _searchResults[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _primaryColor.withOpacity(0.2),
                            child: Icon(Icons.person, color: _primaryColor),
                          ),
                          title:
                              Text(user['displayName'] ?? "مستخدم غير معروف"),
                          onTap: () =>
                              createChat(user['displayName'], user['id']),
                        );
                      },
                    )
                  : (chats.isEmpty
                      ? const Center(child: Text("لا توجد محادثات متاحة"))
                      : ListView.builder(
                          itemCount: chats.length,
                          itemBuilder: (context, index) {
                            final chat = chats[index];
                            final otherParticipant =
                                chat['participantsInfo']?.firstWhere(
                              (p) => p['id'] != widget.userId,
                              orElse: () => null,
                            );
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _primaryColor.withOpacity(0.2),
                                child: Icon(Icons.chat, color: _primaryColor),
                              ),
                              title: Text(otherParticipant?['name'] ??
                                  "مستخدم غير معروف"),
                              subtitle: Text(
                                  chat['lastMessage'] ?? "لا توجد رسائل بعد"),
                              onTap: () => fetchMessages(chat['id']),
                            );
                          },
                        )),
        ),
      ],
    );
  }

  Widget _buildChatMessages() {
    DateTime _parseTimestamp(dynamic timestamp) {
      if (timestamp is Timestamp) return timestamp.toDate();
      if (timestamp is String) return DateTime.parse(timestamp);
      return DateTime.now();
    }

    return Column(children: [
      Expanded(
          child: ListView.builder(
              controller: _scrollController,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isCurrentUser = message['senderId'] == widget.userId;
                String textContent = '';
                if (message['type'] == 'text') {
                  textContent = message['text']?.toString() ?? "";
                } else {
                  textContent = message['text']?.toString() ?? '';
                }
                Widget messageContent;
                if (message['type'] == 'text' &&
                    _editingMessageId == message['id']) {
                  messageContent = TextField(
                    key: ValueKey(message['id']),
                    controller: _messageController,
                    autofocus: true,
                    focusNode: _messageFocusNode,
                    onSubmitted: (newText) {
                      if (newText.isNotEmpty) {
                        _editMessage(message['id'], newText);
                      } else {
                        if (mounted) {
                          setState(() {
                            _editingMessageId = null;
                            _messageFocusNode.unfocus();
                            _messageController.clear();
                          });
                        }
                      }
                    },
                    decoration: const InputDecoration(
                      hintText: "تعديل الرسالة...",
                      border: InputBorder.none,
                    ),
                  );
                } else if (message['type'] == 'text') {
                  messageContent = Text(
                    textContent,
                    style: TextStyle(
                      color: isCurrentUser ? Colors.white : Colors.black,
                    ),
                  );
                } else if (message['type'] == 'image') {
                  messageContent =
                      Image.file(File(textContent), width: 200, height: 200);
                } else if (message['type'] == 'audio') {
                  messageContent = IconButton(
                    icon: const Icon(Icons.play_arrow),
                    onPressed: () => audioPlayer.play(UrlSource(textContent)),
                  );
                } else {
                  messageContent = SizedBox();
                }

                return Align(
                    alignment: isCurrentUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: GestureDetector(
                        onLongPress: () {
                          if (message['type'] == 'text') {
                            _showContextMenu(context, message);
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.all(8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isCurrentUser
                                ? _primaryColor.withOpacity(0.8)
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (_isLoadingMessages)
                                  const Center(
                                      child: CircularProgressIndicator())
                                else ...[
                                  messageContent,
                                  Text(
                                    DateFormat('hh:mm a').format(
                                        _parseTimestamp(message['timestamp'])),
                                    style: TextStyle(
                                      color: isCurrentUser
                                          ? Colors.white70
                                          : Colors.grey[600],
                                      fontSize: 10,
                                    ),
                                  ),
                                  if (message['editHistory'] != null &&
                                      _editingMessageId != message['id'])
                                    for (var oldMessage
                                        in message['editHistory'])
                                      Text(
                                        oldMessage,
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 10,
                                        ),
                                      ),
                                ]
                              ]),
                        )));
              })),
      Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(children: [
            IconButton(
              icon: const Icon(Icons.camera_alt, color: _primaryColor),
              onPressed: _requestStoragePermission,
            ),
            GestureDetector(
              onLongPressStart: (_) => _recordAudio(),
              onLongPressEnd: (_) => _recordAudio(),
              child: Icon(
                isRecording ? Icons.mic_off : Icons.mic,
                color: _primaryColor,
                size: 30,
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    hintText: "اكتب رسالة...",
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 15),
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.send,
                color: _primaryColor,
              ),
              onPressed: () {
                if (_editingMessageId != null) {
                  if (_messageController.text.isNotEmpty) {
                    _editMessage(_editingMessageId!, _messageController.text);
                  } else {
                    if (mounted) {
                      setState(() {
                        _editingMessageId = null;
                        _messageFocusNode.unfocus();
                        _messageController.clear();
                      });
                    }
                  }
                } else {
                  if (_messageController.text.isNotEmpty) {
                    sendMessage(_messageController.text, 'text');
                  }
                }
              },
            ),
          ]))
    ]);
  }

  void _showContextMenu(BuildContext context, dynamic message) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(
                Icons.edit,
                color: _primaryColor,
              ),
              title: const Text(
                'تعديل',
                style: TextStyle(color: _primaryColor),
              ),
              onTap: () {
                if (mounted) {
                  setState(() {
                    _editingMessageId = message['id'];
                    _messageController.text = message['text']?.toString() ?? "";
                    _messageFocusNode.requestFocus();
                  });
                }

                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.delete,
                color: _primaryColor,
              ),
              title: const Text(
                'حذف',
                style: TextStyle(color: _primaryColor),
              ),
              onTap: () {
                _deleteMessage(message['id']);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}
