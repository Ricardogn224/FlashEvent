part of 'form_chat_room_bloc.dart';

class FormChatRoomState extends Equatable {
  const FormChatRoomState({
    this.name = const BlocFormItem(error: 'Nom du vehicule'),
    this.emailSuggestions = const [],
    this.email = const BlocFormItem(error: 'Enter email'),
    this.formKey,
  });

  final BlocFormItem name;
  final GlobalKey<FormState>? formKey;
  final BlocFormItem email;
  final List<String> emailSuggestions;

  FormChatRoomState copyWith({
    BlocFormItem? name,
    BlocFormItem? email,
    GlobalKey<FormState>? formKey,
    List<String>? emailSuggestions,
  }) {
    return FormChatRoomState(
      name: name ?? this.name,
      email: email ?? this.email,
      formKey: formKey,
      emailSuggestions: emailSuggestions ?? this.emailSuggestions,
    );
  }

  @override
  List<Object> get props => [name, email, emailSuggestions];
}

enum FormStatus { none, inProgress, valid, invalid }