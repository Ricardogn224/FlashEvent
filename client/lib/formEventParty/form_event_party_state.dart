part of 'form_event_party_bloc.dart';

class FormEventPartyState extends Equatable {
  const FormEventPartyState({
    this.name = const BlocFormItem(error: 'Enter name'),
    this.description = const BlocFormItem(error: 'Enter description'),
    this.place = const BlocFormItem(error: 'Enter place'),
    this.date = const BlocFormItem(error: 'Enter date'),
    this.formKey,
  });

  final BlocFormItem name;
  final BlocFormItem description;
  final BlocFormItem place;
  final BlocFormItem date;
  final GlobalKey<FormState>? formKey;

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
      formKey: formKey,
    );
  }

  @override
  List<Object> get props => [name, description, place, date];
}
