part of 'event_party_bloc.dart';

enum EventPartyStatus { initial, loading, success, error }

class EventPartyState {
  final EventPartyStatus status;
  final Event? eventParty;
  final List<User>? participants;
  final List<User>? participantsPresence;
  final Participant? userParticipant;
  final List<String> emailSuggestions;
  final BlocFormItem email;
  final GlobalKey<FormState>? formKey;
  final String? errorMessage;

  EventPartyState({
    this.status = EventPartyStatus.initial,
    this.eventParty,
    this.participants,
    this.participantsPresence,
    this.userParticipant,
    this.emailSuggestions = const [],
    this.email = const BlocFormItem(error: 'Enter email'),
    this.formKey,
    this.errorMessage,
  });

  EventPartyState copyWith({
    EventPartyStatus? status,
    Event? eventParty,
    List<User>? participants,
    List<User>? participantsPresence,
    Participant? userParticipant,
    List<String>? emailSuggestions,
    BlocFormItem? email,
    GlobalKey<FormState>? formKey,
    String? errorMessage,
  }) {
    return EventPartyState(
      status: status ?? this.status,
      eventParty: eventParty ?? this.eventParty,
      participants: participants ?? this.participants,
      participantsPresence: participantsPresence ?? this.participantsPresence,
      userParticipant: userParticipant ?? this.userParticipant,
      emailSuggestions: emailSuggestions ?? this.emailSuggestions,
      email: email ?? this.email,
      formKey: formKey,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}