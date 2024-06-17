part of 'message_chat_bloc.dart';


enum MessageChatStatus { initial, loading, success, error }

class MessageChatState {
  final MessageChatStatus status;
  final List<Message>? messagesChats;
  final String? errorMessage;

  MessageChatState({
    this.status = MessageChatStatus.initial,
    this.messagesChats,
    this.errorMessage,
  });

  MessageChatState copyWith({
    MessageChatStatus? status,
    List<Message>? messagesChats,
    String? errorMessage,
  }) {
    return MessageChatState(
      status: status ?? this.status,
      messagesChats: messagesChats ?? this.messagesChats,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
