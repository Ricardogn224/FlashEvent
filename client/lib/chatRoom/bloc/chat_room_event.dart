part of 'chat_room_bloc.dart';

@immutable
sealed class ChatRoomEvent {}

class ChatRoomDataLoaded extends ChatRoomEvent {
  final int id;

  ChatRoomDataLoaded({required this.id});
}

class ChatRoomParticipantDataLoaded extends ChatRoomEvent {
  final int id;

  ChatRoomParticipantDataLoaded({required this.id});
}

class ParticipantSubmitEvent extends ChatRoomEvent {
  final int chatRoomId;
  final String email;
  final VoidCallback onSuccess;
  final Function(String) onError;

  ParticipantSubmitEvent({required this.chatRoomId, required this.email, required this.onSuccess, required this.onError});
}
