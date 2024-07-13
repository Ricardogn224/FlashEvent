part of 'form_transportation_bloc.dart';

abstract class FormTransportationEvent extends Equatable {
  const FormTransportationEvent();

  @override
  List<Object> get props => [];
}

class FormSubmitEvent extends FormTransportationEvent {
  final VoidCallback onSuccess;
  final Function(String) onError;

  const FormSubmitEvent({required this.onSuccess, required this.onError});

  @override
  List<Object> get props => [onSuccess, onError];
}

class FormResetEvent extends FormTransportationEvent {
  const FormResetEvent();
}

class InitEvent extends FormTransportationEvent {
  const InitEvent();
}

class NameChanged extends FormTransportationEvent {
  const NameChanged({required this.name});
  final BlocFormItem name;
  @override
  List<Object> get props => [name];
}

class SeatNumberChanged extends FormTransportationEvent {
  const SeatNumberChanged({required this.seatNumber});
  final BlocFormItem seatNumber;
  @override
  List<Object> get props => [seatNumber];
}