import 'package:flutter/cupertino.dart';
import 'package:flutter_flash_event/core/exceptions/api_exception.dart';
import 'package:flutter_flash_event/core/models/event.dart';
import 'package:flutter_flash_event/core/models/feature.dart';
import 'package:flutter_flash_event/core/models/participant.dart';
import 'package:flutter_flash_event/core/models/user.dart';
import 'package:flutter_flash_event/core/services/event_services.dart';
import 'package:flutter_flash_event/core/services/feature_services.dart';
import 'package:flutter_flash_event/core/services/participant_services.dart';
import 'package:flutter_flash_event/core/services/user_services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_flash_event/formEventParty/form_item.dart';
import 'package:flutter_flash_event/utils/extensions.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'event_party_event.dart';
part 'event_party_state.dart';

class EventPartyBloc extends Bloc<EventPartyEvent, EventPartyState> {
  EventPartyBloc() : super(EventPartyState()) {
    final formKey = GlobalKey<FormState>();

    on<EventPartyDataLoaded>((event, emit) async {
      emit(state.copyWith(status: EventPartyStatus.loading));

      try {
        final eventParty = await EventServices.getEvent(id: event.id);
        final participants = await UserServices.getUsersParticipants(
            id: event.id);
        final participantsPresence = await ParticipantServices
            .getUsersParticipantsPresence(id: event.id);

        final userParticipant = await ParticipantServices
            .getParticipantByEventId(event.id);

        // Check for the transport feature
        Feature transportFeature;
        try {
          transportFeature = await FeatureServices.findTransportFeature();
        } catch (e) {
          transportFeature = Feature(id: 0, name: '', active: false);
        }

        emit(state.copyWith(
            status: EventPartyStatus.success,
            eventParty: eventParty,
            participants: participants,
            participantsPresence: participantsPresence,
            userParticipant: userParticipant,
            feature: transportFeature
        ));
      } on ApiException catch (error) {
        emit(state.copyWith(status: EventPartyStatus.error,
            errorMessage: 'An error occurred: ${error.message}'));
      }
    });

    on<UpdateParticipant>((event, emit) async {
      Participant updatedParticipant = Participant(
        id: event.participant.id,
        eventId: event.participant.eventId,
        userId: event.participant.userId,
        transportationId: event.participant.transportationId,
        present: event.newVal,
        contribution: event.participant.contribution,
      );

      try {
        final response = await ParticipantServices.updateParticipantPresentById(
            updatedParticipant);
        print(response.statusCode);
        if (response.statusCode == 200) {
          // Reload participants
          add(EventPartyDataLoaded(id: event.participant.eventId));
        }
      } on ApiException catch (error) {
        emit(state.copyWith(
          status: EventPartyStatus.error,
          errorMessage: 'An error occurred while updating the feature: ${error
              .message}',
        ));
      }
    });

    on<EmailChanged >((event, emit) async{
      emit(
        state.copyWith(
          email: BlocFormItem(
            value: event.email.value,
            error: event.email.value.isValidEmail ? null : 'Enter email',
          ),
          formKey: formKey,
        ),
      );
    });


    on<FetchEmailSuggestions>((event, emit) async {
      print(event.eventId);
      try {
        // Assuming you have a service method to fetch email suggestions
        final suggestions = await UserServices.getAllUserEmails(
            id: event.eventId);

        // Filter the suggestions based on the query
        final filteredSuggestions = suggestions.where((email) =>
            email.contains(event.query)).toList();

        // Emit the new state with filtered suggestions
        print(suggestions);
        emit(state.copyWith(emailSuggestions: filteredSuggestions));
      } catch (e) {
        emit(state.copyWith(emailSuggestions: []));
      }
    });

    on<FormSubmitEvent>((event, emit) async{
      if (state.formKey!.currentState!.validate()) {
        ParticipantAdd newParticipant = ParticipantAdd(
            id: 0,
            email: state.email.value,
            eventId: event.participant.eventId
        );

        try {
          final response = await ParticipantServices.addParticipant(newParticipant);
          if (response.statusCode == 201) {
            event.onSuccess();
          } else {
            event.onError('Event creation failed');
          }
        } catch (e) {
          event.onError('Error: $e');
        }
      }
    });
  }
}