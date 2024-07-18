part of 'form_chat_room_bloc.dart';

abstract class FormChatRoomEvent extends Equatable {
  const FormChatRoomEvent();

  @override
  List<Object> get props => [];
}

class FormSubmitEvent extends FormChatRoomEvent {
  final VoidCallback onSuccess;
  final Function(String) onError;
  final int eventId;

  const FormSubmitEvent({required this.eventId, required this.onSuccess, required this.onError});

  @override
  List<Object> get props => [onSuccess, onError];
}

class FormParticipantSubmitEvent extends FormChatRoomEvent {
  final VoidCallback onSuccess;
  final Function(String) onError;
  final int chatRoomId;

  const FormParticipantSubmitEvent({required this.chatRoomId, required this.onSuccess, required this.onError});

  @override
  List<Object> get props => [onSuccess, onError];
}

class FormResetEvent extends FormChatRoomEvent {
  const FormResetEvent();
}

class InitEvent extends FormChatRoomEvent {
  const InitEvent();
}

class NameChanged extends FormChatRoomEvent {
  const NameChanged({required this.name});
  final BlocFormItem name;
  @override
  List<Object> get props => [name];
}

class EmailChanged extends FormChatRoomEvent {
  const EmailChanged({required this.email});
  final BlocFormItem email;
  @override
  List<Object> get props => [email];
}

class FetchEmailSuggestions extends FormChatRoomEvent {
  final String query;
  final int chatRoomId;

  const FetchEmailSuggestions({required this.query, required this.chatRoomId});

  @override
  List<Object> get props => [query];
}