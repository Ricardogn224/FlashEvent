import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class FormEventCreateEvent extends Equatable {
  const FormEventCreateEvent();

  @override
  List<Object> get props => [];
}

class EventNameChanged extends FormEventCreateEvent {
  final String name;

  const EventNameChanged({required this.name});

  @override
  List<Object> get props => [name];
}

class EventDescriptionChanged extends FormEventCreateEvent {
  final String description;

  const EventDescriptionChanged({required this.description});

  @override
  List<Object> get props => [description];
}

class EventPlaceChanged extends FormEventCreateEvent {
  final String place;

  const EventPlaceChanged({required this.place});

  @override
  List<Object> get props => [place];
}

class EventDateStartChanged extends FormEventCreateEvent {
  final DateTime dateStart;

  const EventDateStartChanged({required this.dateStart});

  @override
  List<Object> get props => [dateStart];
}

class EventDateEndChanged extends FormEventCreateEvent {
  final DateTime dateEnd;

  const EventDateEndChanged({required this.dateEnd});

  @override
  List<Object> get props => [dateEnd];
}

class EventTimeStartChanged extends FormEventCreateEvent {
  final TimeOfDay timeStart;

  const EventTimeStartChanged({required this.timeStart});

  @override
  List<Object> get props => [timeStart];
}

class EventTimeEndChanged extends FormEventCreateEvent {
  final TimeOfDay timeEnd;

  const EventTimeEndChanged({required this.timeEnd});

  @override
  List<Object> get props => [timeEnd];
}

class EventTransportActiveChanged extends FormEventCreateEvent {
  final bool transportActive;

  const EventTransportActiveChanged({required this.transportActive});

  @override
  List<Object> get props => [transportActive];
}

class EventFormSubmitted extends FormEventCreateEvent {
  final String dateTimeStart;
  final String dateTimeEnd;

  const EventFormSubmitted({
    required this.dateTimeStart,
    required this.dateTimeEnd,
  });

  @override
  List<Object> get props => [dateTimeStart, dateTimeEnd];
}
