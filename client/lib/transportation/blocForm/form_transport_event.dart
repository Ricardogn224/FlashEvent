part of 'form_transport_bloc.dart';

abstract class FormTransportEvent extends Equatable {
  const FormTransportEvent();

  @override
  List<Object> get props => [];
}

class FormSubmitEvent extends FormTransportEvent {
  final VoidCallback onSuccess;
  final Function(String) onError;

  const FormSubmitEvent({required this.onSuccess, required this.onError});

  @override
  List<Object> get props => [onSuccess, onError];
}

class FormUpdateSubmitEvent extends FormTransportEvent {
  final VoidCallback onSuccess;
  final Function(String) onError;
  final Event event;

  const FormUpdateSubmitEvent({required this.event, required this.onSuccess, required this.onError});

  @override
  List<Object> get props => [onSuccess, onError];
}

class FormResetEvent extends FormTransportEvent {
  const FormResetEvent();
}

class InitEvent extends FormTransportEvent {
  final Event event;

  InitEvent({required this.event});
}

class NameChanged extends FormTransportEvent {
  const NameChanged({required this.name});
  final BlocFormItem name;
  @override
  List<Object> get props => [name];
}

class DescriptionChanged extends FormTransportEvent {
  const DescriptionChanged({required this.description});
  final BlocFormItem description;
  @override
  List<Object> get props => [description];
}

class TransportStartChanged extends FormTransportEvent {
  const TransportStartChanged({required this.transportStart});
  final BlocFormItem transportStart;
  @override
  List<Object> get props => [transportStart];
}
