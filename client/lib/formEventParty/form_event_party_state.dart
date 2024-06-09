part of 'form_event_party_bloc.dart';

class FormEventPartyState extends Equatable {
  const FormEventPartyState({
    this.name = const BlocFormItem(error: 'Enter name'),
    this.description = const BlocFormItem(error: 'Enter description'),
    this.formKey,
  });

  final BlocFormItem description;
  final BlocFormItem name;
  final GlobalKey<FormState>? formKey;

  FormEventPartyState copyWith({
    BlocFormItem? name,
    BlocFormItem? description,
    GlobalKey<FormState>? formKey,
  }) {
    return FormEventPartyState(
      description: description ?? this.description,
      name: name ?? this.name,
      formKey: formKey,
    );
  }

  @override
  List<Object> get props => [name, description];
}

enum FormStatus { none, inProgress, valid, invalid }