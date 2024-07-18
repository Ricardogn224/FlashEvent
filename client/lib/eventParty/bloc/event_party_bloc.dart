import 'package:flutter/cupertino.dart';
import 'package:flutter_flash_event/core/exceptions/api_exception.dart';
import 'package:flutter_flash_event/core/models/event.dart';
import 'package:flutter_flash_event/core/models/participant.dart';
import 'package:flutter_flash_event/core/models/user.dart';
import 'package:flutter_flash_event/core/services/event_services.dart';
import 'package:flutter_flash_event/core/services/participant_services.dart';
import 'package:flutter_flash_event/core/services/user_services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_flash_event/formEventParty/form_item.dart';
import 'package:flutter_flash_event/utils/extensions.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_flash_event/core/models/itemEvent.dart';
import 'package:flutter_flash_event/core/services/item_services.dart';
import 'package:flutter_flash_event/core/services/transportation_services.dart';
import 'package:flutter_flash_event/core/models/transportation.dart';

part 'event_party_event.dart';
part 'event_party_state.dart';

class EventPartyBloc extends Bloc<EventPartyEvent, EventPartyState> {
  EventPartyBloc() : super(EventPartyState()) {
    final formKey = GlobalKey<FormState>();

    on<EventPartyDataLoaded>((event, emit) async {
      emit(state.copyWith(status: EventPartyStatus.loading));
      print('Loading event data for event ID: ${event.id}');

      try {
        final eventParty = await EventServices.getEvent(id: event.id);
        print('Event data loaded: ${eventParty.name}');

        final participants = await UserServices.getUsersParticipants(id: event.id);
        final participantsPresence = await ParticipantServices.getUsersParticipantsPresence(id: event.id);
        final userParticipant = await ParticipantServices.getParticipantByEventId(event.id);
        final items = await ItemServices.getItemsByEvent(id: event.id);

        // Load transportations only if transport is active
        List<Transportation>? transportations;
        if (eventParty.transportActive) {
          transportations = await TransportationServices.getTransportationsByEvent(id: event.id);
        }

        emit(state.copyWith(
          status: EventPartyStatus.success,
          eventParty: eventParty,
          participants: participants,
          participantsPresence: participantsPresence,
          userParticipant: userParticipant,
          itemEvents: items,
          transportations: transportations, // Ajoutez ceci
        ));
        print('State updated successfully with event data');
      } on ApiException catch (error) {
        print('Error loading event data: ${error.message}');
        emit(state.copyWith(
          status: EventPartyStatus.error,
          errorMessage: 'An error occurred: ${error.message}',
        ));
      }
    });

    on<UpdateParticipant>((event, emit) async {
      print('Updating participant presence for participant ID: ${event.participant.id}');
      Participant updatedParticipant = Participant(
        id: event.participant.id,
        eventId: event.participant.eventId,
        userId: event.participant.userId,
        transportationId: event.participant.transportationId,
        present: event.newVal,
      );

      try {
        final response = await ParticipantServices.updateParticipantPresentById(updatedParticipant);
        print('Participant updated, response status: ${response.statusCode}');
        if (response.statusCode == 200) {
          // Reload participants
          add(EventPartyDataLoaded(id: event.participant.eventId));
        }
      } on ApiException catch (error) {
        print('Error updating participant: ${error.message}');
        emit(state.copyWith(
          status: EventPartyStatus.error,
          errorMessage: 'An error occurred while updating the feature: ${error.message}',
        ));
      }
    });

    on<EmailChanged>((event, emit) async {
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
      print('Fetching email suggestions for query: ${event.query}');
      try {
        // Assuming you have a service method to fetch email suggestions
        final suggestions = await UserServices.getAllUserEmails(id: event.eventId);

        // Filter the suggestions based on the query
        final filteredSuggestions = suggestions.where((email) => email.contains(event.query)).toList();

        // Emit the new state with filtered suggestions
        print('Email suggestions fetched: ${filteredSuggestions.length} suggestions found');
        emit(state.copyWith(emailSuggestions: filteredSuggestions));
      } catch (e) {
        print('Error fetching email suggestions: $e');
        emit(state.copyWith(emailSuggestions: []));
      }
    });

    on<FormSubmitEvent>((event, emit) async {
      if (state.formKey!.currentState!.validate()) {
        ParticipantAdd newParticipant = ParticipantAdd(
          id: 0,
          email: state.email.value,
          eventId: event.participant.eventId,
        );

        try {
          final response = await ParticipantServices.addParticipant(newParticipant);
          if (response.statusCode == 201) {
            print('Participant added successfully');
            event.onSuccess();
          } else {
            print('Error adding participant: ${response.statusCode}');
            event.onError('Event creation failed');
          }
        } catch (e) {
          print('Error adding participant: $e');
          event.onError('Error: $e');
        }
      }
    });

    // Ajoutez ces gestionnaires d'événements
    on<LoadItems>((event, emit) async {
      emit(state.copyWith(status: EventPartyStatus.loading));
      print('Loading items for event ID: ${event.eventId}');

      try {
        final items = await ItemServices.getItemsByEvent(id: event.eventId);
        emit(state.copyWith(status: EventPartyStatus.success, itemEvents: items));
        print('Items loaded successfully');
      } catch (error) {
        print('Error loading items: $error');
        emit(state.copyWith(status: EventPartyStatus.error, errorMessage: 'An error occurred while loading items'));
      }
    });

    on<AddItem>((event, emit) async {
      print('Adding new item: ${event.itemEvent.name}');
      try {
        await ItemServices.addItem(event.itemEvent);
        add(LoadItems(eventId: event.itemEvent.eventId));
      } catch (error) {
        print('Error adding item: $error');
        emit(state.copyWith(status: EventPartyStatus.error, errorMessage: 'An error occurred while adding item'));
      }
    });

    on<AddTransportation>((event, emit) async {
      print('Adding new transportation: ${event.transportation.vehicle}');
      try {
        await TransportationServices.addTransportation(event.transportation);
        if (state.eventParty != null) {
          add(EventPartyDataLoaded(id: state.eventParty!.id));
        }
      } catch (error) {
        print('Error adding transportation: $error');
        emit(state.copyWith(status: EventPartyStatus.error, errorMessage: 'An error occurred while adding transportation'));
      }
    });
  }
}
