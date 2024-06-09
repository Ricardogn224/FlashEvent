part of 'event_party_bloc.dart';

@immutable
sealed class EventPartyEvent {}

class EventPartyDataLoaded extends EventPartyEvent {
  final int id;

  EventPartyDataLoaded({required this.id});
}
