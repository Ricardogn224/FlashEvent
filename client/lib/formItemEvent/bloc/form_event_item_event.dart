part of 'form_item_event_bloc.dart';

abstract class FormEventItemEvent extends Equatable {
  const FormEventItemEvent();

  @override
  List<Object> get props => [];
}

class FormSubmitEvent extends FormEventItemEvent {
  final VoidCallback onSuccess;
  final Function(String) onError;

  const FormSubmitEvent({required this.onSuccess, required this.onError});

  @override
  List<Object> get props => [onSuccess, onError];
}

class FormResetEvent extends FormEventItemEvent {
  const FormResetEvent();
}

class InitEvent extends FormEventItemEvent {
  const InitEvent();
}

class NameChanged extends FormEventItemEvent {
  const NameChanged({required this.name});
  final BlocFormItem name;
  @override
  List<Object> get props => [name];
}