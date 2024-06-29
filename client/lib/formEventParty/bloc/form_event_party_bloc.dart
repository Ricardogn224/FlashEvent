import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_flash_event/core/models/event.dart';
import 'package:flutter_flash_event/core/services/event_services.dart';
import 'package:flutter_flash_event/formEventParty/form_item.dart';
import 'package:flutter_flash_event/utils/extensions.dart';
import 'package:flutter/material.dart';

part 'form_event_party_event.dart';
part 'form_event_party_state.dart';


class FormEventPartyBloc extends Bloc<FormEventPartyEvent, FormEventPartyState> {
  FormEventPartyBloc() : super(const FormEventPartyState()) {
    on<InitEvent>(_initState);
    on<NameChanged>(_onNameChanged);
    on<DescriptionChanged>(_onDescriptionChanged);
    on<PlaceChanged>(_onPlaceChanged);
    on<DateChanged>(_onDateChanged);
    on<FormSubmitEvent>(_onFormSubmitted);
    on<FormResetEvent>(_onFormReset);
  }

  final formKey = GlobalKey<FormState>();

  Future<void> _initState(InitEvent event, Emitter<FormEventPartyState> emit) async {
    emit(state.copyWith(formKey: formKey));
  }

  Future<void> _onNameChanged(NameChanged event, Emitter<FormEventPartyState> emit) async {
    emit(
      state.copyWith(
        name: BlocFormItem(
          value: event.name.value,
          error: event.name.value.isValidName ? null : 'Enter name',
        ),
        formKey: formKey,
      ),
    );
  }

  Future<void> _onDescriptionChanged(DescriptionChanged event, Emitter<FormEventPartyState> emit) async {
    emit(
      state.copyWith(
        description: BlocFormItem(
          value: event.description.value,
          error: event.description.value.isValidName ? null : 'Enter description',
        ),
        formKey: formKey,
      ),
    );
  }

  Future<void> _onPlaceChanged(PlaceChanged event, Emitter<FormEventPartyState> emit) async {
    emit(
      state.copyWith(
        place: BlocFormItem(
          value: event.place.value,
          error: event.place.value.isValidName ? null : 'Enter place',
        ),
        formKey: formKey,
      ),
    );
  }

  Future<void> _onDateChanged(DateChanged event, Emitter<FormEventPartyState> emit) async {
    emit(
      state.copyWith(
        date: BlocFormItem(
          value: event.date.value,
          error: event.date.value.isValidName ? null : 'Enter date',
        ),
        formKey: formKey,
      ),
    );
  }

  Future<void> _onFormReset(FormResetEvent event, Emitter<FormEventPartyState> emit) async {
    state.formKey?.currentState?.reset();
  }

  Future<void> _onFormSubmitted(FormSubmitEvent event, Emitter<FormEventPartyState> emit) async {
    if (state.formKey!.currentState!.validate()) {
      Event newEvent = Event(
        id: 0,
        name: state.name.value,
        description: state.description.value,
        place: state.place.value,
        date: state.date.value,
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
}
