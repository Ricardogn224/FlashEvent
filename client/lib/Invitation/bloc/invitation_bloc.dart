import 'package:flutter/cupertino.dart';
import 'package:flutter_flash_event/core/exceptions/api_exception.dart';
import 'package:flutter_flash_event/core/models/invitation.dart';
import 'package:flutter_flash_event/core/models/participant.dart';
import 'package:flutter_flash_event/core/models/user.dart';
import 'package:flutter_flash_event/core/services/participant_services.dart';
import 'package:flutter_flash_event/core/services/user_services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'invitation_event.dart';
part 'invitation_state.dart';

class InvitationBloc extends Bloc<InvitationEvent, InvitationState> {
  InvitationBloc() : super(InvitationState()) {
    on<InvitationDataLoaded>((event, emit) async {
      emit(state.copyWith(status: InvitationStatus.loading));

      try {
        final invitations = await ParticipantServices.getInvitations();
        emit(state.copyWith(status: InvitationStatus.success, invitations: invitations));
      } on ApiException catch (error) {
        emit(state.copyWith(status: InvitationStatus.error, errorMessage: 'An error occurred'));
      }
    });

    on<InvitationAnsw>((event, emit) async {

      InvitationAnswer invitationAnswer = InvitationAnswer(
          participantId: event.participantId,
          active: event.active
      );

      try {
        await ParticipantServices.answerInvitation(invitationAnswer);
        add(InvitationDataLoaded());
      } on ApiException catch (error) {
        emit(state.copyWith(status: InvitationStatus.error, errorMessage: 'Failed to accept invitation'));
      }
    });
  }
}