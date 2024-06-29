part of 'chat_room_bloc.dart';

@immutable
sealed class ChatRoomEvent {}

class ChatRoomDataLoaded extends ChatRoomEvent {
  final int id;

  ChatRoomDataLoaded({required this.id});
}
