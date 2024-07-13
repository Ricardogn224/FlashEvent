part of 'admin_form_user_bloc.dart';

class AdminFormUserState extends Equatable {
  const AdminFormUserState({
    this.firstname = const BlocFormItem(error: 'Enter firstname'),
    this.lastname = const BlocFormItem(error: 'Enter lastname'),
    this.username = const BlocFormItem(error: 'Enter lastname'),
    this.email = const BlocFormItem(error: 'Enter email'),
    this.password = const BlocFormItem(error: 'Enter password'),
    this.isAdmin = false,
    this.formKey,
    this.status = FormStatus.none,
  });

  final BlocFormItem firstname;
  final BlocFormItem lastname;
  final BlocFormItem username;
  final BlocFormItem email;
  final BlocFormItem password;
  final bool isAdmin;
  final GlobalKey<FormState>? formKey;
  final FormStatus status;

  AdminFormUserState copyWith({
    BlocFormItem? firstname,
    BlocFormItem? lastname,
    BlocFormItem? email,
    BlocFormItem? username,
    BlocFormItem? password,
    bool? isAdmin,
    GlobalKey<FormState>? formKey,
    FormStatus? status,
  }) {
    return AdminFormUserState(
      firstname: firstname ?? this.firstname,
      lastname: lastname ?? this.lastname,
      email: email ?? this.email,
      username: username ?? this.username,
      password: password ?? this.password,
      isAdmin: isAdmin ?? this.isAdmin,
      formKey: formKey ?? this.formKey,
      status: status ?? this.status,
    );
  }

  @override
  List<Object> get props => [firstname, lastname, email, username, isAdmin];
}

enum FormStatus { none, inProgress, valid, error }