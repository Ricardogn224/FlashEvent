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
  final List<ItemEvent>? itemEvents;
  final List<Transportation>? transportations; // Ajoutez ceci

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
    this.itemEvents,
    this.transportations, // Ajoutez ceci
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
    List<ItemEvent>? itemEvents,
    List<Transportation>? transportations, // Ajoutez ceci
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
      itemEvents: itemEvents ?? this.itemEvents,
      transportations: transportations ?? this.transportations, // Ajoutez ceci
    );
  }
}
