import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';

part 'chats_state.dart';

class ChatsCubit extends Cubit<ChatsState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  ChatsCubit() : super(ChatsInitial());

  Future<void> fetchChats() async {
    emit(ChatsLoading());
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception("User not logged in");

      final querySnapshot = await _firestore
          .collection('chats')
          .where('users', arrayContains: user.email)
          .get();

      final chats = querySnapshot.docs.map((doc) {
        return {'chatId': doc.id, 'users': doc['users']};
      }).toList();

      emit(ChatsLoaded(chats));
    } catch (e) {
      emit(ChatsError('Failed to load chats: $e'));
    }
  }

  Future<void> createChat(String email) async {
  try {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");
    if (email == user.email) throw Exception("Can't chat with yourself");

    // 🔹 **التحقق من وجود المستخدم في قاعدة البيانات**
    final userQuery = await _firestore
        .collection('users') // تأكد أن لديك Collection يحتوي على المستخدمين
        .where('email', isEqualTo: email)
        .get();

    if (userQuery.docs.isEmpty) {
      emit(ChatsError("User not found!")); // ❌ المستخدم غير موجود
      return;
    }

    final chatRef = _firestore.collection('chats');

    // 🔹 **البحث عن محادثة موجودة بين المستخدمين**
    final existingChat = await chatRef
        .where('users', arrayContains: user.email)
        .get();

    for (var doc in existingChat.docs) {
      if (doc['users'].contains(email)) {
        emit(ChatExists(doc.id)); // ✅ المحادثة موجودة بالفعل
        return;
      }
    }

    // 🔹 **إنشاء محادثة جديدة إذا لم تكن موجودة**
    final newChat = await chatRef.add({
      'users': [user.email, email],
      'createdAt': FieldValue.serverTimestamp(),
    });

    emit(ChatCreated(newChat.id)); // ✅ المحادثة تم إنشاؤها بنجاح
    fetchChats(); // تحديث قائمة المحادثات
  } catch (e) {
    emit(ChatsError('Failed to create chat: $e')); // ❌ خطأ أثناء الإنشاء
  }
}

void getChats() async {
  try {
    print("🔄 Fetching chats..."); // ✅ طباعة قبل بدء الجلب
    emit(ChatsLoading());

    String? currentUser = _auth.currentUser?.email;
    if (currentUser == null) {
      print("❌ No logged-in user found.");
      emit(ChatsError("No user logged in"));
      return;
    }

    print("👤 Logged-in user: $currentUser");

    QuerySnapshot chatsSnapshot = await _firestore
        .collection("chats")
        .where("users", arrayContains: currentUser)
        .get();

    print("✅ Chats fetched: ${chatsSnapshot.docs.length}");

    List<Map<String, dynamic>> chats = chatsSnapshot.docs.map((doc) {
      return {
        "chatId": doc.id,
        "users": List<String>.from(doc["users"]),
      };
    }).toList();

    emit(ChatsLoaded(chats));
  } catch (e) {
    print("❌ Error fetching chats: $e");
    emit(ChatsError("Failed to load chats: $e"));
  }
}


  
}
