part of 'message_chat_bloc.dart';

@immutable
sealed class MessageChatEvent {}

class MessageChatDataLoaded extends MessageChatEvent {
  final int id;

  MessageChatDataLoaded({required this.id});
}

class MessageChatAdded extends MessageChatEvent {
  final String content;
  final int chatRoomId;
  final String email;

  MessageChatAdded({required this.content, required this.chatRoomId, required this.email});
}

class MessageChatReceived extends MessageChatEvent {
  final Message message;

  MessageChatReceived({required this.message});
}
