part of 'transportation_bloc.dart';

@immutable
sealed class TransportationEvent {}

class TransportationDataLoaded extends TransportationEvent {
  final int id;

  TransportationDataLoaded({required this.id});
}

class TransportationLoadParticipants extends TransportationEvent {
  final int transportationId;

  TransportationLoadParticipants({required this.transportationId});
}

class UpdateParticipant extends TransportationEvent {
  final Participant participant;

  UpdateParticipant({required this.participant});
}
