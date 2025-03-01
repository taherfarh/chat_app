import 'package:chat_app/cubit/cubit/chats_cubit.dart';

import 'package:chat_app/cubit/cubit/cubit/chat_cubit.dart';
import 'package:chat_app/screens/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'chat_screen.dart';

class ChatsScreen extends StatefulWidget {
  @override
  _ChatsScreenState createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  @override
  void initState() {
    super.initState();
    // 📌 استدعاء الدردشات عند تحميل الشاشة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatsCubit>().getChats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 220, 218, 218),
        title: Text("Chats"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showCreateChatDialog(context),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
          image: AssetImage(
              "assets/images/desktop-wallpaper-hopped-the-original-background-if-you-want-to-use-whatsapp-dark-mode-go-to-settings-chats-background-and-use-this-r-whatsapp 2.png"), // ✅ ضع مسار الصورة هنا
          fit: BoxFit.cover, // ✅ تجعل الصورة تغطي الشاشة بالكامل
        )),
        padding: EdgeInsets.only(top: 20),
        child: BlocBuilder<ChatsCubit, ChatsState>(
          builder: (context, state) {
            if (state is ChatsLoading) {
              return Center(child: CircularProgressIndicator());
            }
            if (state is ChatsLoaded) {
              return Column(
                children: [
                  Expanded(
                    // 📌 الحل هنا: ضمان أن `ListView` داخل مساحة محددة
                    child: ListView.builder(
                      itemCount: state.chats.length,
                      itemBuilder: (context, index) {
                        final chat = state.chats[index];
                        return Card(
                          child: ListTile(
                            title: Text(
                              (chat['users'] as List<String>)
                                  .where((user) =>
                                      user !=
                                      FirebaseAuth.instance.currentUser!.email)
                                  .join(", "), // ✅ عرض اسم الشخص الآخر فقط
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text("اضغط للدردشة 📩"),
                            trailing:
                                Icon(Icons.chat, color: Colors.blueAccent),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BlocProvider(
                                    create: (context) =>
                                        ChatCubit(chat['chatId']),
                                    child: ChatScreen(chatId: chat['chatId']),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            }
            return Center(child: Text("No chats found"));
          },
        ),
      ),
    );
  }

  // 🔹 دالة تسجيل الخروج
  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut(); // تسجيل الخروج من Firebase
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (_) => AuthScreen()), // الانتقال إلى شاشة تسجيل الدخول
    );
  }

  // 🔹 نافذة إدخال البريد الإلكتروني لإنشاء محادثة جديدة
  void _showCreateChatDialog(BuildContext context) {
    final TextEditingController emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Start New Chat"),
          content: TextField(
            controller: emailController,
            decoration: InputDecoration(hintText: "Enter email"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
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
}
