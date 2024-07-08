part of 'admin_form_bloc.dart';

class AdminFormState extends Equatable {
  const AdminFormState({
    this.name = const BlocFormItem(error: 'Enter name'),
    this.description = const BlocFormItem(error: 'Enter description'),
    this.participants,
    this.email = const BlocFormItem(error: 'Enter email'),
    this.emailSuggestions = const [],
    this.formKey,
    this.status = FormStatus.none,
  });

  final BlocFormItem name;
  final BlocFormItem description;
  final BlocFormItem email;
  final List<String> emailSuggestions;
  final GlobalKey<FormState>? formKey;
  final FormStatus status;
  final List<User>? participants;

  AdminFormState copyWith({
    BlocFormItem? name,
    BlocFormItem? description,
    BlocFormItem? email,
    List<String>? emailSuggestions,
    List<User>? participants,

    GlobalKey<FormState>? formKey,
    FormStatus? status,
  }) {
    return AdminFormState(
      name: name ?? this.name,
      description: description ?? this.description,
      participants: participants ?? this.participants,
      email: email ?? this.email,
      emailSuggestions: emailSuggestions ?? this.emailSuggestions,
      formKey: formKey ?? this.formKey,
      status: status ?? this.status,
    );
  }

  @override
  List<Object> get props => [name, description, status, email, emailSuggestions];
}

enum FormStatus { none, inProgress, valid, error }