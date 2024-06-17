part of 'form_participant_bloc.dart';

abstract class FormParticipantEvent extends Equatable {
  const FormParticipantEvent();

  @override
  List<Object> get props => [];
}

class FormSubmitEvent extends FormParticipantEvent {
  final VoidCallback onSuccess;
  final Function(String) onError;

  const FormSubmitEvent({required this.onSuccess, required this.onError});

  @override
  List<Object> get props => [onSuccess, onError];
}

class FormResetEvent extends FormParticipantEvent {
  const FormResetEvent();
}

class InitEvent extends FormParticipantEvent {
  const InitEvent();
}

class EmailChanged extends FormParticipantEvent {
  const EmailChanged({required this.email});
  final BlocFormItem email;
  @override
  List<Object> get props => [email];
}