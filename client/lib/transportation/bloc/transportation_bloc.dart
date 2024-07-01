import 'package:flutter/cupertino.dart';
import 'package:flutter_flash_event/core/exceptions/api_exception.dart';
import 'package:flutter_flash_event/core/models/transportation.dart';
import 'package:flutter_flash_event/core/models/participant.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_flash_event/core/services/message_services.dart';
import 'package:flutter_flash_event/core/services/transportation_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_flash_event/core/models/user.dart'; // Import your Participant model
import 'package:flutter_flash_event/core/services/participant_services.dart';
import 'package:flutter_flash_event/core/services/user_services.dart'; // Import participant services

part 'transportation_event.dart';
part 'transportation_state.dart';

class TransportationBloc extends Bloc<TransportationEvent, TransportationState> {

  TransportationBloc() : super(TransportationState()) {
    on<TransportationDataLoaded>((event, emit) async {
      emit(state.copyWith(status: TransportationStatus.loading));
      print(state);
      try {
        print(state);
        final currentUser = await UserServices.getCurrentUserByEmail();
        print(currentUser);

        final transportations = await TransportationServices.getTransportationsByEvent(id: event.id);
        final participantsFutures = transportations.map((transportation) =>
            UserServices.getParticipantsByTransportation(id: transportation.id));

        final participants = (await Future.wait(participantsFutures)).expand((x) => x).toList();
        print(transportations);

        emit(state.copyWith(
          status: TransportationStatus.success,
          transportations: transportations,
          participants: participants,
          currentUser: currentUser,
        ));
      } catch (error) {
        emit(state.copyWith(status: TransportationStatus.error, errorMessage: 'An error occurred'));
      }
    });

    on<UpdateParticipant>((event, emit) async {
      try {
        await ParticipantServices.updateParticipant(event.participant);
        // Reload participants for the affected transportation
        print('id of event: ${event.participant.eventId}');
        final transportations = await TransportationServices.getTransportationsByEvent(id: event.participant.eventId);
        final participantsFutures = transportations.map((transportation) =>
            UserServices.getParticipantsByTransportation(id: transportation.id));

        final participants = (await Future.wait(participantsFutures)).expand((x) => x).toList();
        print(transportations);
        print('list of transportss: ${transportations}');

        emit(state.copyWith(
          status: TransportationStatus.success,
          transportations: transportations,
          participants: participants,
        ));
      } catch (error) {
        emit(state.copyWith(status: TransportationStatus.error, errorMessage: 'Error when updating participant'));
      }
    });
  }
}
