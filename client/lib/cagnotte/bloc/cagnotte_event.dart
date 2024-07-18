part of 'cagnotte_bloc.dart';

@immutable
sealed class CagnotteEvent {}

class CagnotteDataLoaded extends CagnotteEvent {
  final int id;

  CagnotteDataLoaded({required this.id});
}
