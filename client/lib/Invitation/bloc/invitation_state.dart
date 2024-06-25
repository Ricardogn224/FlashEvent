part of 'invitation_bloc.dart';


enum InvitationStatus { initial, loading, success, error }

class InvitationState {
  final InvitationStatus status;
  final List<Invitation>? invitations;
  final String? errorMessage;

  InvitationState({
    this.status = InvitationStatus.initial,
    this.invitations,
    this.errorMessage,
  });

  InvitationState copyWith({
    InvitationStatus? status,
    List<Invitation>? invitations,
    String? errorMessage,
  }) {
    return InvitationState(
      status: status ?? this.status,
      invitations: invitations ?? this.invitations,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
