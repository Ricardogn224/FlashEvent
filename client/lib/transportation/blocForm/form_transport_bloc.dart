import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_flash_event/core/models/event.dart';
import 'package:flutter_flash_event/core/services/event_services.dart';
import 'package:flutter_flash_event/formEventParty/form_item.dart';
import 'package:flutter_flash_event/utils/extensions.dart';
import 'package:flutter/material.dart';

part 'form_transport_event.dart';
part 'form_transport_state.dart';

class FormTransportBloc extends Bloc<FormTransportEvent, FormTransportState> {
  FormTransportBloc() : super(const FormTransportState()) {
    on<InitEvent>(_initState);
    on<NameChanged>(_onNameChanged);
    on<DescriptionChanged>(_onDescriptionChanged);
    on<TransportStartChanged>(_onTransportStartChanged);
    on<FormSubmitEvent>(_onFormSubmitted);
    on<FormUpdateSubmitEvent>(_onFormUpdateSubmitted);
    on<FormResetEvent>(_onFormReset);
  }

  final formKey = GlobalKey<FormState>();

  Future<void> _initState(InitEvent event, Emitter<FormTransportState> emit) async {
    emit(state.copyWith(
      formKey: formKey,
      transportStart: BlocFormItem(value: event.event.transportStart ?? '', error: 'Enter transport start'),
    ));
  }

  Future<void> _onNameChanged(NameChanged event, Emitter<FormTransportState> emit) async {
    emit(
      state.copyWith(
        name: BlocFormItem(
          value: event.name.value,
          error: event.name.value.isValidName ? null : 'Entrer un nom valide',
        ),
        formKey: formKey,
      ),
    );
  }

  Future<void> _onDescriptionChanged(DescriptionChanged event, Emitter<FormTransportState> emit) async {
    emit(
      state.copyWith(
        description: BlocFormItem(
          value: event.description.value,
        ),
        formKey: formKey,
      ),
    );
  }

  Future<void> _onTransportStartChanged(TransportStartChanged event, Emitter<FormTransportState> emit) async {
    emit(
      state.copyWith(
        transportStart: BlocFormItem(
          value: event.transportStart.value,
        ),
        formKey: formKey,
      ),
    );
  }

  Future<void> _onFormReset(FormResetEvent event, Emitter<FormTransportState> emit) async {
    state.formKey?.currentState?.reset();
  }

  Future<void> _onFormSubmitted(FormSubmitEvent event, Emitter<FormTransportState> emit) async {
    if (state.formKey!.currentState!.validate()) {
      Event newEvent = Event(
        id: 0,
        name: state.name.value,
        description: state.description.value,
        place: "Sample Place", // Fournir une valeur par défaut ou récupérer de l'état
        dateStart: "2024-02-01 00:00:00", // Fournir une valeur par défaut ou récupérer de l'état
        dateEnd: "2024-02-02 00:00:00", // Fournir une valeur par défaut ou récupérer de l'état
        transportActive: false,
        transportStart: state.transportStart.value,
        cagnotte: 0,
      );

      try {
        final response = await EventServices.addEvent(newEvent);
        if (response.statusCode == 201) {
          event.onSuccess();
        } else {
          event.onError('Event creation failed');
        }
      } catch (e) {
        event.onError('Error: $e');
      }
    }
  }

  Future<void> _onFormUpdateSubmitted(FormUpdateSubmitEvent event, Emitter<FormTransportState> emit) async {
    print(event.event);
    if (state.formKey!.currentState!.validate()) {
      print(event.event);
      final currentEvent = event.event; // You need to pass the current event in the event or have it in the state

      Event updatedEvent = Event(
        id: currentEvent.id,
        name: currentEvent.name,
        description: currentEvent.description,
        place: currentEvent.place,
        dateStart: currentEvent.dateStart,
        dateEnd: currentEvent.dateEnd,
        transportActive: currentEvent.transportActive,
        transportStart: state.transportStart.value,
        cagnotte: currentEvent.cagnotte, // Update only transportStart
      );

      try {
        final response = await EventServices.updateEventById(updatedEvent);
        if (response.statusCode == 200) {
          event.onSuccess();
        } else {
          event.onError('Event creation failed');
        }
      } catch (e) {
        event.onError('Error: $e');
      }
    }
  }
}
