part of 'form_event_party_bloc.dart';

class FormEventPartyState extends Equatable {
  final BlocFormItem name;
  final BlocFormItem description;
  final BlocFormItem place;
  final BlocFormItem date;
  final GlobalKey<FormState>? formKey;

  const FormEventPartyState({
    this.name = const BlocFormItem(),
    this.description = const BlocFormItem(),
    this.place = const BlocFormItem(),
    this.date = const BlocFormItem(),
    this.formKey,
  });

  FormEventPartyState copyWith({
    BlocFormItem? name,
    BlocFormItem? description,
    BlocFormItem? place,
    BlocFormItem? date,
    GlobalKey<FormState>? formKey,
  }) {
    return FormEventPartyState(
      name: name ?? this.name,
      description: description ?? this.description,
      place: place ?? this.place,
      date: date ?? this.date,
      formKey: formKey ?? this.formKey,
    );
  }

  @override
  List<Object?> get props => [name, description, place, date, formKey];
}
