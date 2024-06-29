part of 'form_event_party_bloc.dart';

abstract class FormEventPartyEvent extends Equatable {
  const FormEventPartyEvent();

  @override
  List<Object> get props => [];
}

class FormSubmitEvent extends FormEventPartyEvent {
  final VoidCallback onSuccess;
  final Function(String) onError;

  const FormSubmitEvent({required this.onSuccess, required this.onError});

  @override
  List<Object> get props => [onSuccess, onError];
}

class FormResetEvent extends FormEventPartyEvent {
  const FormResetEvent();
}

class InitEvent extends FormEventPartyEvent {
  const InitEvent();
}

class NameChanged extends FormEventPartyEvent {
  const NameChanged({required this.name});
  final BlocFormItem name;
  @override
  List<Object> get props => [name];
}

class DescriptionChanged extends FormEventPartyEvent {
  const DescriptionChanged({required this.description});
  final BlocFormItem description;
  @override
  List<Object> get props => [description];
}

class PlaceChanged extends FormEventPartyEvent {
  const PlaceChanged({required this.place});
  final BlocFormItem place;
  @override
  List<Object> get props => [place];
}

class DateChanged extends FormEventPartyEvent {
  const DateChanged({required this.date});
  final BlocFormItem date;
  @override
  List<Object> get props => [date];
}
