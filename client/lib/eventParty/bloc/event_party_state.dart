part of 'event_party_bloc.dart';

enum EventPartyStatus { initial, loading, success, error }

class EventPartyState {
  final EventPartyStatus status;
  final Event? eventParty;
  final List<User>? participants;
  final String? errorMessage;

  EventPartyState({
    this.status = EventPartyStatus.initial,
    this.eventParty,
    this.participants,
    this.errorMessage,
  });

  EventPartyState copyWith({
    EventPartyStatus? status,
    Event? eventParty,
    List<User>? participants,
    String? errorMessage,
  }) {
    return EventPartyState(
      status: status ?? this.status,
      eventParty: eventParty ?? this.eventParty,
      participants: participants ?? this.participants,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}