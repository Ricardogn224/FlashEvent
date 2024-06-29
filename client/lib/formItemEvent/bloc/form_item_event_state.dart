part of 'form_item_event_bloc.dart';

class FormItemEventState extends Equatable {
  const FormItemEventState({
    this.name = const BlocFormItem(error: 'Enter name'),
    this.formKey,
  });

  final BlocFormItem name;
  final GlobalKey<FormState>? formKey;

  FormItemEventState copyWith({
    BlocFormItem? name,
    GlobalKey<FormState>? formKey,
  }) {
    return FormItemEventState(
      name: name ?? this.name,
      formKey: formKey,
    );
  }

  @override
  List<Object> get props => [name];
}

enum FormStatus { none, inProgress, valid, invalid }