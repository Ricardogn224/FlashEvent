part of 'transportation_bloc.dart';

enum TransportationStatus { initial, loading, success, error }

class TransportationState {
  final TransportationStatus status;
  final List<Transportation>? transportations;
  final List<UserTransport>? participants; // Add participants
  final Event? eventParty;
  final User? currentUser;
  final String? errorMessage;

  TransportationState({
    this.status = TransportationStatus.initial,
    this.transportations,
    this.participants,
    this.eventParty,
    this.currentUser,
    this.errorMessage,
  });

  TransportationState copyWith({
    TransportationStatus? status,
    List<Transportation>? transportations,
    List<UserTransport>? participants, // Add participants
    Event? eventParty,
    User? currentUser,
    String? errorMessage,
  }) {
    return TransportationState(
      status: status ?? this.status,
      transportations: transportations ?? this.transportations,
      participants: participants ?? this.participants, // Add participants
      eventParty: eventParty ?? this.eventParty,
      currentUser: currentUser ?? this.currentUser,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
