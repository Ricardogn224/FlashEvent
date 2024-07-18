part of 'chat_room_bloc.dart';


enum ChatRoomStatus { initial, loading, success, error }

class ChatRoomState {
  final ChatRoomStatus status;
  final List<ChatRoom>? chatRooms;
  final List<String> emails;
  final String? errorMessage;

  ChatRoomState({
    this.status = ChatRoomStatus.initial,
    this.chatRooms,
    this.emails = const [],
    this.errorMessage,
  });

  ChatRoomState copyWith({
    ChatRoomStatus? status,
    List<ChatRoom>? chatRooms,
    List<String>? emails,
    String? errorMessage,
  }) {
    return ChatRoomState(
      status: status ?? this.status,
      chatRooms: chatRooms ?? this.chatRooms,
      emails: emails ?? this.emails,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
