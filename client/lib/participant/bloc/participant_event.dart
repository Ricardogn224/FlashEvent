part of 'participant_bloc.dart';

@immutable
sealed class ParticipantEvent {}

class ParticipantDataLoaded extends ParticipantEvent {
  final int id;

  ParticipantDataLoaded({required this.id});
}
