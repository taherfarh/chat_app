import 'package:chat_app/cubit/cubit/chats_cubit.dart';
import 'package:chat_app/cubit/cubit/cubit/chat_cubit.dart';
import 'package:chat_app/screens/ProfileScreen.dart';
import 'package:chat_app/screens/SettingsScreen.dart';
import 'package:chat_app/screens/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'chat_screen.dart';
import 'package:intl/intl.dart';

class ChatsScreen extends StatefulWidget {
  @override
  _ChatsScreenState createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    ChatsList(),
    SettingsScreen(),
    Profilescreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatsCubit>().getChats();
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        leading: Image.asset(
            "assets/images/undraw_real_time_collaboration_c62i 1.png"),
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[300],
        title: Text(
          ["Chats", "Settings", "Profile"][_selectedIndex],
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        ),
        actions: _selectedIndex == 0
            ? [
                IconButton(
                  icon: Icon(FontAwesomeIcons.signOutAlt,
                      color: isDarkMode ? Colors.white : Colors.black),
                  onPressed: () => _logout(context),
                ),
              ]
            : null,
      ),
      body:Stack(
        children: [
          /// ✅ **إضافة الخلفية هنا**
          Positioned.fill(
            child: Image.asset(
              "assets/images/desktop-wallpaper-hopped-the-original-background-if-you-want-to-use-whatsapp-dark-mode-go-to-settings-chats-background-and-use-this-r-whatsapp 2.png",
              fit: BoxFit.cover,
              color: isDarkMode ? Colors.black.withOpacity(0.6) : null,
              colorBlendMode: isDarkMode ? BlendMode.darken : null,
            ),
          ),

          /// ✅ **عرض الشاشة المختارة فوق الخلفية**
          _screens[_selectedIndex],
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: isDarkMode ? Colors.black : Colors.grey[850],
        selectedItemColor: isDarkMode ? Colors.cyanAccent : Colors.cyan,
        unselectedItemColor: isDarkMode ? Colors.grey[500] : Colors.grey[300],
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chats"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () => _showCreateChatDialog(context),
              backgroundColor: isDarkMode ? Colors.cyanAccent : Colors.cyan,
              child: Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}

class ChatsList extends StatefulWidget {
  @override
  _ChatsListState createState() => _ChatsListState();
}

class _ChatsListState extends State<ChatsList> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatsCubit>().getChats();
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<ChatsCubit, ChatsState>(
      builder: (context, state) {
        if (state is ChatsLoading) {
          return Center(child: CircularProgressIndicator());
        }
        if (state is ChatsLoaded) {
          return ListView.builder(
            itemCount: state.chats.length,
            itemBuilder: (context, index) {
              final chat = state.chats[index];
              final chatId = chat['chatId'];

              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('chats')
                    .doc(chatId)
                    .collection('messages')
                    .orderBy('timestamp', descending: true)
                    .limit(1)
                    .snapshots(),
                builder: (context, snapshot) {
                  String lastMessage = "No messages yet 📨";
                  String time = "";

                  if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                    var lastMessageData = snapshot.data!.docs.first;
                    lastMessage = lastMessageData['text'] ?? "📩 صورة أو ملف";
                    Timestamp timestamp =
                        lastMessageData['timestamp'] ?? Timestamp.now();
                    time = DateFormat('hh:mm a').format(timestamp.toDate());
                  }

                  return Dismissible(
                    key: Key(chatId),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      color: Colors.red,
                      child: Icon(Icons.delete, color: Colors.white, size: 30),
                    ),
                    confirmDismiss: (direction) async {
                      return await _confirmDeleteChat(context, chatId);
                    },
                    onDismissed: (direction) async {
                      await FirebaseFirestore.instance
                          .collection('chats')
                          .doc(chatId)
                          .delete();
                      context.read<ChatsCubit>().getChats();
                    },
                    child: _buildChatTile(
                        chat, lastMessage, time, context, isDarkMode),
                  );
                },
              );
            },
          );
        }
        return Center(child: Text("No chats found"));
      },
    );
  }

  Widget _buildChatTile(Map<String, dynamic> chat, String lastMessage,
      String time, BuildContext context, bool isDarkMode) {
    return Card(
      color: isDarkMode ? Colors.grey[900] : Colors.white.withOpacity(0.8),
      child: ListTile(
        title:Text(
  (chat['users'] != null && chat['users'] is List)
      ? (chat['users'] as List).cast<String>()
          .where((user) => user != FirebaseAuth.instance.currentUser!.email)
          .join(", ")
      : "Unknown User",
  style: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: isDarkMode ? Colors.white : Colors.black,
  ),
),
        subtitle: Text(
          lastMessage,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.black),
        ),
        trailing: Text(
          time,
          style: TextStyle(
              color: isDarkMode ? Colors.grey[500] : Colors.grey, fontSize: 12),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlocProvider(
                create: (context) => ChatCubit(chat['chatId'])..fetchMessages(),
                child: ChatScreen(chatId: chat['chatId']),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<bool?> _confirmDeleteChat(BuildContext context, String chatId) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Chat"),
        content: Text("Are you sure you want to delete this chat?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

void _logout(BuildContext context) async {
  await FirebaseAuth.instance.signOut();
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (_) => AuthScreen()),
  );
}

void _showCreateChatDialog(BuildContext context) {
  final TextEditingController emailController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("Start New Chat"),
        content: TextField(
            controller: emailController,
            decoration: InputDecoration(hintText: "Enter email")),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          TextButton(
            onPressed: () {
              final email = emailController.text.trim();
              if (email.isNotEmpty) {
                context.read<ChatsCubit>().createChat(email);
                Navigator.pop(context);
              }
            },
            child: Text("Create"),
          ),
        ],
      );
    },
  );
}
