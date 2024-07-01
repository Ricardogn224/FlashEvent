part of 'form_participant_bloc.dart';

class FormParticipantState extends Equatable {
  const FormParticipantState({
    this.email = const BlocFormItem(error: 'Enter email'),
    this.formKey,
  });

  final BlocFormItem email;
  final GlobalKey<FormState>? formKey;

  FormParticipantState copyWith({
    BlocFormItem? email,
    GlobalKey<FormState>? formKey,
  }) {
    return FormParticipantState(
      email: email ?? this.email,
      formKey: formKey,
    );
  }

  @override
  List<Object> get props => [email];
}

enum FormStatus { none, inProgress, valid, invalid }