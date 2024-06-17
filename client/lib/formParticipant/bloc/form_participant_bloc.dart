import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_flash_event/core/models/event.dart';
import 'package:flutter_flash_event/core/models/participant.dart';
import 'package:flutter_flash_event/core/services/event_services.dart';
import 'package:flutter_flash_event/core/services/participant_services.dart';
import 'package:flutter_flash_event/formEventParty/form_item.dart';
import 'package:flutter_flash_event/home/home_screen.dart';
import 'package:flutter_flash_event/utils/extensions.dart';
import 'package:flutter/material.dart';

part 'form_participant_event.dart';
part 'form_participant_state.dart';


class FormParticipantBloc extends Bloc<FormParticipantEvent, FormParticipantState> {
  final int eventId;

  FormParticipantBloc({required this.eventId}) : super(const FormParticipantState()) {
    on<InitEvent>(_initState);
    on<EmailChanged>(_onEmailChanged);
    on<FormSubmitEvent>(_onFormSubmitted);
    on<FormResetEvent>(_onFormReset);
  }

  final formKey = GlobalKey<FormState>();

  Future<void> _initState(InitEvent event, Emitter<FormParticipantState> emit) async {
    emit(state.copyWith(formKey: formKey));
  }

  Future<void> _onEmailChanged(
      EmailChanged event, Emitter<FormParticipantState> emit) async {
    emit(
      state.copyWith(
        email: BlocFormItem(
          value: event.email.value,
          error: event.email.value.isValidEmail ? null : 'Enter email',
        ),
        formKey: formKey,
      ),
    );
  }

  Future<void> _onFormReset(
      FormResetEvent event,
      Emitter<FormParticipantState> emit,
      ) async {
    state.formKey?.currentState?.reset();
  }

  Future<void> _onFormSubmitted(FormSubmitEvent event, Emitter<FormParticipantState> emit) async {
    if (state.formKey!.currentState!.validate()) {
      ParticipantAdd newParticipant = ParticipantAdd(
        id: 0,
        email: state.email.value,
        eventId: eventId
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
  }
}