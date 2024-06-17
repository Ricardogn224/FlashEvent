import 'package:flutter/cupertino.dart';
import 'package:flutter_flash_event/core/exceptions/api_exception.dart';
import 'package:flutter_flash_event/core/models/user.dart';
import 'package:flutter_flash_event/core/services/user_services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'participant_event.dart';
part 'participant_state.dart';

class ParticipantBloc extends Bloc<ParticipantEvent, ParticipantState> {
  ParticipantBloc() : super(ParticipantState()) {
    on<ParticipantDataLoaded>((event, emit) async {
      emit(state.copyWith(status: ParticipantStatus.loading));

      try {
        final participants = await UserServices.getUsersParticipants(id: event.id);
        emit(state.copyWith(status: ParticipantStatus.success, participants: participants));
      } on ApiException catch (error) {
        emit(state.copyWith(status: ParticipantStatus.error, errorMessage: 'An error occurred'));
      }
    });
  }
}