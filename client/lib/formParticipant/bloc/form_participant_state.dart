part of 'form_participant_bloc.dart';

class FormParticipantState extends Equatable {
  const FormParticipantState({
    this.email = const BlocFormItem(error: 'Enter email'),
    this.formKey,
    this.emailSuggestions = const [],
  });

  final BlocFormItem email;
  final GlobalKey<FormState>? formKey;
  final List<String> emailSuggestions;

  FormParticipantState copyWith({
    BlocFormItem? email,
    GlobalKey<FormState>? formKey,
    List<String>? emailSuggestions,
  }) {
    return FormParticipantState(
      email: email ?? this.email,
      formKey: formKey,
      emailSuggestions: emailSuggestions ?? this.emailSuggestions,
    );
  }

  @override
  List<Object> get props => [email, emailSuggestions];
}

enum FormStatus { none, inProgress, valid, invalid }