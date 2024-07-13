part of 'admin_bloc.dart';

@immutable
sealed class AdminEvent {}

class AdminDataLoaded extends AdminEvent {}

class AdminEventsLoaded extends AdminEvent {}