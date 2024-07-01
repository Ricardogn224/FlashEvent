part of 'invitation_bloc.dart';

@immutable
sealed class InvitationEvent {}

class InvitationDataLoaded extends InvitationEvent {

  InvitationDataLoaded();
}

class InvitationAnsw extends InvitationEvent {
  final int participantId;
  final bool active;

  InvitationAnsw({required this.participantId, required this.active});
}