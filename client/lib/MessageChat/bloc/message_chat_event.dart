part of 'message_chat_bloc.dart';

@immutable
sealed class MessageChatEvent {}

class MessageChatDataLoaded extends MessageChatEvent {
  final int id;

  MessageChatDataLoaded({required this.id});
}
