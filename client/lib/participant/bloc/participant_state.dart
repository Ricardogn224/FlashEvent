part of 'participant_bloc.dart';


enum ParticipantStatus { initial, loading, success, error }

class ParticipantState {
  final ParticipantStatus status;
  final List<User>? participants;
  final String? errorMessage;

  ParticipantState({
    this.status = ParticipantStatus.initial,
    this.participants,
    this.errorMessage,
  });

  ParticipantState copyWith({
    ParticipantStatus? status,
    List<User>? participants,
    String? errorMessage,
  }) {
    return ParticipantState(
      status: status ?? this.status,
      participants: participants ?? this.participants,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
