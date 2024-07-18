part of 'admin_form_user_bloc.dart';

abstract class AdminFormUserEvent extends Equatable {
  const AdminFormUserEvent();

  @override
  List<Object> get props => [];
}

class FormSubmitEvent extends AdminFormUserEvent {
  final int id;
  final void Function() onSuccess;
  final void Function(String errorMessage) onError;

  const FormSubmitEvent({
    required this.id,
    required this.onSuccess,
    required this.onError,
  });

  @override
  List<Object> get props => [onSuccess, onError, id];
}

class FormNewSubmitEvent extends AdminFormUserEvent {
  final VoidCallback onSuccess;
  final Function(String) onError;

  const FormNewSubmitEvent({required this.onSuccess, required this.onError});

  @override
  List<Object> get props => [onSuccess, onError];
}

class FormResetEvent extends AdminFormUserEvent {
  const FormResetEvent();
}

class InitEvent extends AdminFormUserEvent {
  final int id;

  InitEvent({required this.id});
}

class InitNewEvent extends AdminFormUserEvent {
  const InitNewEvent();
}

class FirstnameChanged extends AdminFormUserEvent {
  const FirstnameChanged({required this.firstname});
  final BlocFormItem firstname;
  @override
  List<Object> get props => [firstname];
}

class LastnameChanged extends AdminFormUserEvent {
  const LastnameChanged({required this.lastname});
  final BlocFormItem lastname;
  @override
  List<Object> get props => [lastname];
}

class EmailChanged extends AdminFormUserEvent {
  const EmailChanged({required this.email});
  final BlocFormItem email;
  @override
  List<Object> get props => [email];
}

class UsernameChanged extends AdminFormUserEvent {
  const UsernameChanged({required this.username});
  final BlocFormItem username;
  @override
  List<Object> get props => [username];
}

class PasswordChanged extends AdminFormUserEvent {
  const PasswordChanged({required this.password});
  final BlocFormItem password;
  @override
  List<Object> get props => [password];
}

class RoleChanged extends AdminFormUserEvent {
  final bool role;

  const RoleChanged({required this.role});

  @override
  List<Object> get props => [role];
}

class ToggleAdminRoleEvent extends AdminFormUserEvent {
  final int id;
  final bool isAdmin;

  const ToggleAdminRoleEvent({required this.id, required this.isAdmin});

  @override
  List<Object> get props => [id, isAdmin];
}

class DeleteEvent extends AdminFormUserEvent {
  final int id;
  final VoidCallback onSuccess;
  final Function(String) onError;

  DeleteEvent({required this.id, required this.onSuccess, required this.onError});

  @override
  List<Object> get props => [id, onSuccess, onError];
}