part of 'chats_cubit.dart';

@immutable
abstract class ChatsState {}




class ChatsInitial extends ChatsState {}

class ChatsLoading extends ChatsState {}

class ChatsLoaded extends ChatsState {
  final List<Map<String, dynamic>> chats;
  ChatsLoaded(this.chats);
}

abstract class ChatStateWithId extends ChatsState { // واجهة مشتركة
  final String chatId;
  ChatStateWithId(this.chatId);
}

class ChatCreated extends ChatStateWithId {
  ChatCreated(String chatId) : super(chatId);
}

class ChatExists extends ChatStateWithId {
  ChatExists(String chatId) : super(chatId);
}

class ChatsError extends ChatsState {
  final String message;
  ChatsError(this.message);
}
