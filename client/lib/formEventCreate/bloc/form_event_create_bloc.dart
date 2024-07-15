import 'package:flutter/material.dart'; 
import 'package:flutter_bloc/flutter_bloc.dart';
import 'form_event_create_event.dart';
import 'form_event_create_state.dart';
import 'package:flutter_flash_event/core/services/event_services.dart';
import 'package:flutter_flash_event/core/models/event.dart';
import 'package:intl/intl.dart';


class FormEventCreateBloc extends Bloc<FormEventCreateEvent, FormEventCreateState> {
  FormEventCreateBloc() : super(FormEventCreateState()) {
    on<EventNameChanged>((event, emit) {
      emit(state.copyWith(name: event.name));
    });
    on<EventDescriptionChanged>((event, emit) {
      emit(state.copyWith(description: event.description));
    });
    on<EventPlaceChanged>((event, emit) {
      emit(state.copyWith(place: event.place));
    });
    on<EventDateStartChanged>((event, emit) {
      emit(state.copyWith(dateStart: event.dateStart));
    });
    on<EventDateEndChanged>((event, emit) {
      emit(state.copyWith(dateEnd: event.dateEnd));
    });
    on<EventTimeStartChanged>((event, emit) {
      emit(state.copyWith(timeStart: event.timeStart));
    });
    on<EventTimeEndChanged>((event, emit) {
      emit(state.copyWith(timeEnd: event.timeEnd));
    });
    on<EventTransportActiveChanged>((event, emit) {
      emit(state.copyWith(transportActive: event.transportActive));
    });
    on<EventFormSubmitted>((event, emit) async {
      emit(state.copyWith(status: FormStatus.loading));

      try {
        // Combine date and time
        final dateTimeStart = combineDateAndTime(state.dateStart, state.timeStart);
        final dateTimeEnd = combineDateAndTime(state.dateEnd, state.timeEnd);

        // Create Event object
        final newEvent = Event(
          id: 0, // id will be assigned by the backend
          name: state.name,
          description: state.description,
          place: state.place,
          dateStart: dateTimeStart,
          dateEnd: dateTimeEnd,
          transportActive: state.transportActive,
          transportStart: '', // Assuming transportStart will be assigned later
        );

        // Call the API to add the event
        final response = await EventServices.addEvent(newEvent);

        if (response.statusCode == 201) {
          emit(state.copyWith(status: FormStatus.success));
        } else {
          emit(state.copyWith(status: FormStatus.error, errorMessage: 'Erreur lors de la création de l\'événement'));
        }
      } catch (e) {
        emit(state.copyWith(status: FormStatus.error, errorMessage: 'Erreur lors de la création de l\'événement'));
      }
    });
  }

  String combineDateAndTime(DateTime date, TimeOfDay time) {
    final dateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
  }
}
