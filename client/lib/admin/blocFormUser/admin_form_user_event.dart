part of 'admin_form_user_bloc.dart';

abstract class AdminFormUserEvent extends Equatable {
  const AdminFormUserEvent();

  @override
  List<Object> get props => [];
}

class FormSubmitEvent extends AdminFormUserEvent {
  final VoidCallback onSuccess;
  final Function(String) onError;

  const FormSubmitEvent({required this.onSuccess, required this.onError});

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

class ToggleAdminRoleEvent extends AdminFormUserEvent {
  final int id;
  final bool isAdmin;

  const ToggleAdminRoleEvent({required this.id, required this.isAdmin});

  @override
  List<Object> get props => [id, isAdmin];
}