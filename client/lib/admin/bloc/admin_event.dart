part of 'admin_bloc.dart';

@immutable
sealed class AdminEvent {}

class AdminDataLoaded extends AdminEvent {}

class AdminEventsLoaded extends AdminEvent {}

class DeleteEvent extends AdminEvent {
  final int id;

  DeleteEvent({required this.id});

  @override
  List<Object> get props => [id];
}

class DeleteUserEvent extends AdminEvent {
  final int id;

  DeleteUserEvent({required this.id});

  @override
  List<Object> get props => [id];
}