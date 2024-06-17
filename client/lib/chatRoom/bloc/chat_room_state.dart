part of 'chat_room_bloc.dart';


enum ChatRoomStatus { initial, loading, success, error }

class ChatRoomState {
  final ChatRoomStatus status;
  final List<ChatRoom>? chatRooms;
  final String? errorMessage;

  ChatRoomState({
    this.status = ChatRoomStatus.initial,
    this.chatRooms,
    this.errorMessage,
  });

  ChatRoomState copyWith({
    ChatRoomStatus? status,
    List<ChatRoom>? chatRooms,
    String? errorMessage,
  }) {
    return ChatRoomState(
      status: status ?? this.status,
      chatRooms: chatRooms ?? this.chatRooms,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
