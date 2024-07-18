import 'package:flutter/cupertino.dart';
import 'package:flutter_flash_event/core/exceptions/api_exception.dart';
import 'package:flutter_flash_event/core/models/cagnotte.dart';
import 'package:flutter_flash_event/core/models/event.dart';
import 'package:flutter_flash_event/core/models/user.dart';
import 'package:flutter_flash_event/core/services/cagnotte_services.dart';
import 'package:flutter_flash_event/core/services/event_services.dart';
import 'package:flutter_flash_event/core/services/user_services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'cagnotte_event.dart';
part 'cagnotte_state.dart';

class CagnotteBloc extends Bloc<CagnotteEvent, CagnotteState> {
  CagnotteBloc() : super(CagnotteState()) {
    on<CagnotteDataLoaded>((event, emit) async {
      emit(state.copyWith(status: CagnotteStatus.loading));

      try {
        final eventParty = await EventServices.getEvent(id: event.id);
        final participants = await UserServices.getUsersParticipantsContribution(
            id: event.id);
        emit(state.copyWith(
            status: CagnotteStatus.success,
            cagnotte: eventParty.cagnotte,
            participants: participants
        ));
      } on ApiException catch (error) {
        emit(state.copyWith(status: CagnotteStatus.error, errorMessage: 'An error occurred'));
      }
    });
  }
}