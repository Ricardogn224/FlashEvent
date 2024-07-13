part of 'form_transportation_bloc.dart';

class FormTransportationState extends Equatable {
  const FormTransportationState({
    this.name = const BlocFormItem(error: 'Nom du vehicule'),
    this.seatNumber = const BlocFormItem(error: 'Enter seat number'),
    this.formKey,
  });

  final BlocFormItem name;
  final BlocFormItem seatNumber;
  final GlobalKey<FormState>? formKey;

  FormTransportationState copyWith({
    BlocFormItem? name,
    BlocFormItem? seatNumber,
    GlobalKey<FormState>? formKey,
  }) {
    return FormTransportationState(
      name: name ?? this.name,
      seatNumber: seatNumber ?? this.seatNumber,
      formKey: formKey,
    );
  }

  @override
  List<Object> get props => [name, seatNumber];
}

enum FormStatus { none, inProgress, valid, invalid }