import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_flash_event/core/models/contribution.dart';
import 'package:flutter_flash_event/core/models/event.dart';
import 'package:flutter_flash_event/core/models/participant.dart';
import 'package:flutter_flash_event/core/services/cagnotte_services.dart';
import 'package:flutter_flash_event/core/services/event_services.dart';
import 'package:flutter_flash_event/core/services/participant_services.dart';
import 'package:flutter_flash_event/core/services/user_services.dart';
import 'package:flutter_flash_event/formEventParty/form_item.dart';
import 'package:flutter_flash_event/home/home_screen.dart';
import 'package:flutter_flash_event/utils/extensions.dart';
import 'package:flutter/material.dart';

part 'form_cagnotte_event.dart';
part 'form_cagnotte_state.dart';


class FormCagnotteBloc extends Bloc<FormCagnotteEvent, FormCagnotteState> {
  final int eventId;

  FormCagnotteBloc({required this.eventId}) : super(const FormCagnotteState()) {
    on<InitEvent>(_initState);
    on<ContributionChanged>(_onContributionChanged);
    on<FormSubmitEvent>(_onFormSubmitted);
    on<FormResetEvent>(_onFormReset);
  }

  final formKey = GlobalKey<FormState>();

  Future<void> _initState(InitEvent event, Emitter<FormCagnotteState> emit) async {
    emit(state.copyWith(formKey: formKey));
  }

  Future<void> _onContributionChanged(
      ContributionChanged event, Emitter<FormCagnotteState> emit) async {
    emit(
      state.copyWith(
        contribution: BlocFormItem(
          value: event.contribution.value,
          error: event.contribution.value.isValidInteger ? null : 'Enter contribution',
        ),
        formKey: formKey,
      ),
    );
  }

  Future<void> _onFormReset(
      FormResetEvent event,
      Emitter<FormCagnotteState> emit,
      ) async {
    state.formKey?.currentState?.reset();
  }

  double parseContribution(String value) {
    try {
      return double.parse(value);
    } catch (e) {
      print('Error parsing contribution value: $e');
      return 0.0; // Provide a default value in case of error
    }
  }

  Future<void> _onFormSubmitted(FormSubmitEvent event, Emitter<FormCagnotteState> emit) async {
    if (state.formKey!.currentState!.validate()) {
      final userParticipant = await ParticipantServices
          .getParticipantByEventId(eventId);

      Participant updatedParticipant = Participant(
          id: userParticipant.id,
          eventId: 0,
          userId: 0,
          transportationId: 0,
          present: false,
          contribution: double.parse(state.contribution.value),
      );


      try {
        final response = await ParticipantServices.updateParticipantContributionById(
            updatedParticipant);
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