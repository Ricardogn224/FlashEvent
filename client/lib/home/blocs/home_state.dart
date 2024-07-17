part of 'home_bloc.dart';

@immutable
sealed class HomeState {}

final class HomeInitial extends HomeState {}

final class HomeLoading extends HomeState {}

final class HomeDataLoadSuccess extends HomeState {
  final List<Event> myEvents;
  final List<Event> createdEvents;

  HomeDataLoadSuccess({required this.myEvents, required this.createdEvents});
}


final class HomeDataLoadError extends HomeState {
  final String errorMessage;

  HomeDataLoadError({required this.errorMessage});
}
