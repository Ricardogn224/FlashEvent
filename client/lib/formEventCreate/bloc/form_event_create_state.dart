import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum FormStatus { initial, loading, success, error }

class FormEventCreateState extends Equatable {
  final String name;
  final String description;
  final String place;
  final DateTime dateStart;
  final DateTime dateEnd;
  final TimeOfDay timeStart;
  final TimeOfDay timeEnd;
  final bool transportActive;
  final FormStatus status;
  final String? errorMessage;

  FormEventCreateState({
    this.name = '',
    this.description = '',
    this.place = '',
    DateTime? dateStart,
    DateTime? dateEnd,
    TimeOfDay? timeStart,
    TimeOfDay? timeEnd,
    this.transportActive = false,
    this.status = FormStatus.initial,
    this.errorMessage,
  })  : dateStart = dateStart ?? DateTime.now(),
        dateEnd = dateEnd ?? DateTime.now(),
        timeStart = timeStart ?? TimeOfDay.now(),
        timeEnd = timeEnd ?? TimeOfDay.now();

  FormEventCreateState copyWith({
    String? name,
    String? description,
    String? place,
    DateTime? dateStart,
    DateTime? dateEnd,
    TimeOfDay? timeStart,
    TimeOfDay? timeEnd,
    bool? transportActive,
    FormStatus? status,
    String? errorMessage,
  }) {
    return FormEventCreateState(
      name: name ?? this.name,
      description: description ?? this.description,
      place: place ?? this.place,
      dateStart: dateStart ?? this.dateStart,
      dateEnd: dateEnd ?? this.dateEnd,
      timeStart: timeStart ?? this.timeStart,
      timeEnd: timeEnd ?? this.timeEnd,
      transportActive: transportActive ?? this.transportActive,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        name,
        description,
        place,
        dateStart,
        dateEnd,
        timeStart,
        timeEnd,
        transportActive,
        status,
        errorMessage,
      ];
}
