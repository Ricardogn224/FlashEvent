import 'package:flutter/cupertino.dart';
import 'package:flutter_flash_event/core/exceptions/api_exception.dart';
import 'package:flutter_flash_event/core/models/event.dart';
import 'package:flutter_flash_event/core/services/event_services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'event_party_event.dart';
part 'event_party_state.dart';

class EventPartyBloc extends Bloc<EventPartyEvent, EventPartyState> {
  EventPartyBloc() : super(EventPartyState()) {
    on<EventPartyDataLoaded>((event, emit) async {
      emit(state.copyWith(status: EventPartyStatus.loading));

      try {
        final eventParty = await EventServices.getEvent(id: event.id);
        print(eventParty);
        emit(state.copyWith(status: EventPartyStatus.success, eventParty: eventParty));
      } on ApiException catch (error) {
        emit(state.copyWith(status: EventPartyStatus.error, errorMessage: 'An error occurred'));
      }
    });
  }
}