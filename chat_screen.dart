import 'package:chat_app/cubit/cubit/cubit/chat_cubit.dart';
import 'package:chat_app/screens/12.1%20message_bubble.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;

  ChatScreen({required this.chatId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? userImage;
  String chatPartnerName = "Loading..."; // اسم الشخص اللي بكلمه

  @override
  void initState() {
    super.initState();
    _loadUserImage();
    _getChatPartnerName();
    context.read<ChatCubit>().fetchMessages();
  }

  Future<void> _loadUserImage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userImage = prefs.getString('userImage');
    });
  }

  Future<void> _getChatPartnerName() async {
  try {
    final currentUser = FirebaseAuth.instance.currentUser!;
    final chatDoc = await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .get();

    if (chatDoc.exists) {
      List<String> users = List<String>.from(chatDoc['users'] ?? []);

      if (users.isEmpty) {
        print("⚠️ قائمة المستخدمين فارغة!");
        return;
      }

      String? partnerEmail = users.firstWhere(
        (email) => email != currentUser.email,
        orElse: () => "",
      );

      if (partnerEmail.isEmpty) {
        print("⚠️ لم يتم العثور على شريك المحادثة!");
        return;
      }

      print("✅ شريك المحادثة: $partnerEmail");

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(partnerEmail)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        setState(() {
          chatPartnerName = userDoc['username'] ??
              partnerEmail.split('@')[0]; // ✅ جلب الاسم، وإذا لم يوجد، استخدم الإيميل بدون @
        });
      } else {
        setState(() {
          chatPartnerName = partnerEmail.split('@')[0]; // ✅ عرض الإيميل بدون @
        });
      }
    }
  } catch (e) {
    print("❌ خطأ أثناء جلب اسم الشريك: $e");
  }
}


  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      context.read<ChatCubit>().sendMessage(text);
      _messageController.clear();
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 300), () {
      _scrollController.animateTo(
        0.0,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser!;
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          chatPartnerName.split('@').first,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        // ✅ اسم الشخص اللي بتكلمه
        actions: [
          IconButton(
            icon: Icon(
              FontAwesomeIcons.video,
              size: 20,
            ),
            onPressed: () => print("📹 مكالمة فيديو مع $chatPartnerName"),
          ),
          IconButton(
            icon: Icon(
              FontAwesomeIcons.phone,
              size: 18,
            ),
            onPressed: () => print("📞 مكالمة صوتية مع $chatPartnerName"),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/desktop-wallpaper-hopped-the-original-background-if-you-want-to-use-whatsapp-dark-mode-go-to-settings-chats-background-and-use-this-r-whatsapp 2.png",
              fit: BoxFit.cover,
              color: isDarkMode ? Colors.black.withOpacity(0.6) : null,
              colorBlendMode: isDarkMode ? BlendMode.darken : null,
            ),
          ),
          Column(
            children: [
              Expanded(
                child: BlocBuilder<ChatCubit, ChatState>(
                  builder: (context, state) {
                    if (state is ChatLoading) {
                      return Center(child: CircularProgressIndicator());
                    } else if (state is ChatLoaded) {
                      final messages = state.messages;

                      return ListView.builder(
                        controller: _scrollController,
                        reverse: true,
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final msg = messages[index];
                          final bool isMe =
                              msg['senderEmail'] == currentUser.email;
                          final bool isFirstInSequence =
                              index == messages.length - 1 ||
                                  messages[index + 1]['senderEmail'] !=
                                      msg['senderEmail'];

                          return isFirstInSequence
                              ? MessageBubble.first(
                                  message: msg['text'],
                                  isMe: isMe,
                                  userImage:
                                      isMe ? userImage : msg['senderImage'],
                                  timestamp: msg['timestamp'],
                                )
                              : MessageBubble.next(
                                  message: msg['text'],
                                  isMe: isMe,
                                  timestamp: msg['timestamp'],
                                );
                        },
                      );
                    } else if (state is ChatError) {
                      return Center(child: Text(state.message));
                    }
                    return Center(child: Text("Start chatting!"));
                  },
                ),
              ),
              _buildMessageInput(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: "Type a message...",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          SizedBox(width: 8),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[300],
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.send, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
