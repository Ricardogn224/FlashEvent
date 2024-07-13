part of 'form_event_party_bloc.dart';

class FormEventPartyState extends Equatable {
  const FormEventPartyState({
    this.name = const BlocFormItem(error: 'Enter name'),
    this.description = const BlocFormItem(error: 'Enter description'),
    this.transportStart = const BlocFormItem(error: 'Enter transport start'),
    this.formKey,
  });

  final BlocFormItem description;
  final BlocFormItem name;
  final BlocFormItem transportStart;
  final GlobalKey<FormState>? formKey;

  FormEventPartyState copyWith({
    BlocFormItem? name,
    BlocFormItem? description,
    BlocFormItem? transportStart,
    GlobalKey<FormState>? formKey,
  }) {
    return FormEventPartyState(
      description: description ?? this.description,
      name: name ?? this.name,
      transportStart: transportStart ?? this.transportStart,
      formKey: formKey,
    );
  }

  @override
  List<Object> get props => [name, description, transportStart];
}

enum FormStatus { none, inProgress, valid, invalid }