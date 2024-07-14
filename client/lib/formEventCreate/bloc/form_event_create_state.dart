import 'package:equatable/equatable.dart';

enum FormStatus { initial, loading, success, error }

class FormEventCreateState extends Equatable {
  final String name;
  final String description;
  final String place;
  final String dateStart;
  final String dateEnd;
  final bool transportActive;
  final FormStatus status;
  final String? errorMessage;

  FormEventCreateState({
    this.name = '',
    this.description = '',
    this.place = '',
    this.dateStart = '',
    this.dateEnd = '',
    this.transportActive = false,
    this.status = FormStatus.initial,
    this.errorMessage,
  });

  FormEventCreateState copyWith({
    String? name,
    String? description,
    String? place,
    String? dateStart,
    String? dateEnd,
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
        transportActive,
        status,
        errorMessage,
      ];
}
