part of 'admin_bloc.dart';


enum AdminStatus { initial, loading, success, error }

class AdminState {
  final AdminStatus status;
  final List<User>? users;
  final List<Event>? events;
  final String? errorMessage;

  AdminState({
    this.status = AdminStatus.initial,
    this.users,
    this.events,
    this.errorMessage,
  });

  AdminState copyWith({
    AdminStatus? status,
    List<User>? users,
    List<Event>? events,
    String? errorMessage,
  }) {
    return AdminState(
      status: status ?? this.status,
      users: users ?? this.users,
      events: events ?? this.events,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}