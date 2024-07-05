part of 'my_account_bloc.dart';

@immutable
sealed class MyAccountEvent {}

class MyAccountDataLoaded extends MyAccountEvent {}
