import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String chatId;

  ChatCubit(this.chatId) : super(ChatInitial());

  // جلب الرسائل
  Future<void> fetchMessages() async {
    emit(ChatLoading());
    try {
      final messages = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .get();

      final messageList = messages.docs.map((doc) => doc.data()).toList();
      emit(ChatLoaded(messageList));
    } catch (e) {
      emit(ChatError('Failed to fetch messages: $e'));
    }
  }

  // إرسال رسالة
  Future<void> sendMessage(String text) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .add({
          'text': text,
          'senderId': user.uid,
          'senderEmail': user.email,
          'timestamp': FieldValue.serverTimestamp(),
        });

        fetchMessages();
      }
    } catch (e) {
      emit(ChatError('Failed to send message: $e'));
    }
  }
}
