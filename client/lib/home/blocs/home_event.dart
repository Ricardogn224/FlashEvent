part of 'home_bloc.dart';

@immutable
sealed class HomeEvent {}

class HomeDataLoaded extends HomeEvent {}

class ReloadEvents extends HomeEvent {} 
