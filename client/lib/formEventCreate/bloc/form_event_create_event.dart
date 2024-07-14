import 'package:equatable/equatable.dart';

abstract class FormEventCreateEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class EventNameChanged extends FormEventCreateEvent {
  final String name;

  EventNameChanged({required this.name});

  @override
  List<Object> get props => [name];
}

class EventDescriptionChanged extends FormEventCreateEvent {
  final String description;

  EventDescriptionChanged({required this.description});

  @override
  List<Object> get props => [description];
}

class EventPlaceChanged extends FormEventCreateEvent {
  final String place;

  EventPlaceChanged({required this.place});

  @override
  List<Object> get props => [place];
}

class EventDateStartChanged extends FormEventCreateEvent {
  final String dateStart;

  EventDateStartChanged({required this.dateStart});

  @override
  List<Object> get props => [dateStart];
}

class EventDateEndChanged extends FormEventCreateEvent {
  final String dateEnd;

  EventDateEndChanged({required this.dateEnd});

  @override
  List<Object> get props => [dateEnd];
}

class EventTransportActiveChanged extends FormEventCreateEvent {
  final bool transportActive;

  EventTransportActiveChanged({required this.transportActive});

  @override
  List<Object> get props => [transportActive];
}

class EventFormSubmitted extends FormEventCreateEvent {}
