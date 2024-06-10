part of 'event_party_bloc.dart';


enum EventPartyStatus { initial, loading, success, error }

class EventPartyState {
  final EventPartyStatus status;
  final Event? eventParty;
  final String? errorMessage;

  EventPartyState({
    this.status = EventPartyStatus.initial,
    this.eventParty,
    this.errorMessage,
  });

  EventPartyState copyWith({
    EventPartyStatus? status,
    Event? eventParty,
    String? errorMessage,
  }) {
    return EventPartyState(
      status: status ?? this.status,
      eventParty: eventParty ?? this.eventParty,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
