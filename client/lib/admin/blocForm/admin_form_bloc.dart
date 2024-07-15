import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_flash_event/core/exceptions/api_exception.dart';
import 'package:flutter_flash_event/core/models/event.dart';
import 'package:flutter_flash_event/core/models/invitation.dart';
import 'package:flutter_flash_event/core/models/participant.dart';
import 'package:flutter_flash_event/core/models/user.dart';
import 'package:flutter_flash_event/core/services/event_services.dart';
import 'package:flutter_flash_event/core/services/participant_services.dart';
import 'package:flutter_flash_event/core/services/user_services.dart';
import 'package:flutter_flash_event/formEventParty/form_item.dart';
import 'package:flutter_flash_event/utils/extensions.dart';
import 'package:flutter/material.dart';

part 'admin_form_event.dart';
part 'admin_form_state.dart';

class AdminFormBloc extends Bloc<AdminFormEvent, AdminFormState> {
  AdminFormBloc() : super(const AdminFormState()) {
    on<InitEvent>(_initState);
    on<InitNewEvent>(_initStateNew);
    on<NameChanged>(_onNameChanged);
    on<DescriptionChanged>(_onDescriptionChanged);
    on<InitAddEmail>(_addEmail);
    on<EmailChanged>(_onEmailChanged);
    on<TransportActiveChanged>(_onTransportActiveChanged);
    on<FetchEmailSuggestions>(_onFetchEmailSuggestions);
    on<RemoveParticipant>(_onRemoveParticipant);
    on<FormParticipantSubmitEvent>(_onFormParticipantSubmitted);
    on<FormSubmitEvent>(_onFormSubmitted);
    on<FormNewSubmitEvent>(_onFormNewSubmitted);
    on<FormResetEvent>(_onFormReset);
  }

  final formKey = GlobalKey<FormState>();

  Future<void> _initState(InitEvent event, Emitter<AdminFormState> emit) async {
    emit(state.copyWith(status: FormStatus.inProgress));
    try {
      final eventParty = await EventServices.getEvent(id: event.id);
      final participants = await UserServices.getUsersParticipants(id: event.id);

      emit(state.copyWith(
        formKey: formKey,
        name: BlocFormItem(value: eventParty.name ?? '', error: 'Enter name'),
        description: BlocFormItem(value: eventParty.description ?? '', error: 'Enter description'),
        transportActive: BlocFormItemBool(value: eventParty.transportActive),
        participants: participants,
        status: FormStatus.valid,
      ));
    } on ApiException catch (error) {
      emit(state.copyWith(
        formKey: formKey,
        name: BlocFormItem(value: '', error: 'Enter name'),
        description: BlocFormItem(value: '', error: 'Enter description'),
        status: FormStatus.error,
      ));
    }
  }

  Future<void> _initStateNew(InitNewEvent event, Emitter<AdminFormState> emit) async {
    emit(state.copyWith(formKey: formKey));
  }

  Future<void> _onNameChanged(NameChanged event, Emitter<AdminFormState> emit) async {
    emit(
      state.copyWith(
        name: BlocFormItem(
          value: event.name.value,
          error: event.name.value.isValidName ? null : 'Enter a valid name',
        ),
        formKey: formKey,
      ),
    );
  }

  Future<void> _onDescriptionChanged(DescriptionChanged event, Emitter<AdminFormState> emit) async {
    emit(
      state.copyWith(
        description: BlocFormItem(
          value: event.description.value,
        ),
        formKey: formKey,
      ),
    );
  }


  Future<void> _onTransportActiveChanged(
      TransportActiveChanged event, Emitter<AdminFormState> emit) async {

    emit(state.copyWith(

      transportActive: BlocFormItemBool(value: event.transportActive),

    ));

  }


  Future<void> _onFormReset(FormResetEvent event, Emitter<AdminFormState> emit) async {
    state.formKey?.currentState?.reset();
  }

  Future<void> _onFormSubmitted(FormSubmitEvent event, Emitter<AdminFormState> emit) async {
    if (state.formKey!.currentState!.validate()) {
      Event newEvent = Event(
        id: event.id, // Replace with actual id
        name: state.name.value,
        description: state.description.value,
        transportActive: state.transportActive.value,
        place: "Sample Place", // Fournir une valeur par défaut ou récupérer de l'état
        dateStart: "2024-02-01 00:00:00", // Fournir une valeur par défaut ou récupérer de l'état
        dateEnd: "2024-02-02 00:00:00", // Fournir une valeur par défaut ou récupérer de l'état
        transportStart: '',
      );

      try {
        final response = await EventServices.updateEventById(newEvent);
        if (response.statusCode == 201 || response.statusCode == 200) {
          event.onSuccess();
        } else {
          event.onError('Event update failed');
        }
      } catch (e) {
        event.onError('Error: $e');
      }
    } else {
      event.onError('Validation failed');
    }
  }

  Future<void> _onFormNewSubmitted(FormNewSubmitEvent event, Emitter<AdminFormState> emit) async {
    if (state.formKey!.currentState!.validate()) {
      Event newEvent = Event(
        id: 0,
        name: state.name.value,
        description: state.description.value,
        place: "Sample Place", // Fournir une valeur par défaut ou récupérer de l'état
        dateStart: "2024-02-01 00:00:00", // Fournir une valeur par défaut ou récupérer de l'état
        dateEnd: "2024-02-02 00:00:00", // Fournir une valeur par défaut ou récupérer de l'état
        transportActive: state.transportActive.value,
        transportStart: '',
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
    } else {
      // If validation fails, you can call event.onError() with a message
      event.onError('Validation failed');
    }
  }

  Future<void> _addEmail(InitAddEmail event, Emitter<AdminFormState> emit) async {
    emit(state.copyWith(formKey: formKey));
  }

  Future<void> _onEmailChanged(EmailChanged event, Emitter<AdminFormState> emit) async {
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

  Future<void> _onFetchEmailSuggestions(FetchEmailSuggestions event, Emitter<AdminFormState> emit) async {
    try {
      // Assuming you have a service method to fetch email suggestions
      final suggestions = await UserServices.getAllUserEmails(id: event.eventId);

      // Filter the suggestions based on the query
      final filteredSuggestions = suggestions.where((email) => email.contains(event.query)).toList();

      // Emit the new state with filtered suggestions
      emit(state.copyWith(emailSuggestions: filteredSuggestions));
    } catch (e) {
      emit(state.copyWith(emailSuggestions: []));
    }
  }

  Future<void> _onFormParticipantSubmitted(FormParticipantSubmitEvent event, Emitter<AdminFormState> emit) async {
    if (state.formKey!.currentState!.validate()) {
      ParticipantAdd newParticipant = ParticipantAdd(
          id: 0,
          email: state.email.value,
          eventId: event.eventId
      );

      try {
        final response = await ParticipantServices.addParticipant(
            newParticipant);
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

  Future<void> _onRemoveParticipant(RemoveParticipant event, Emitter<AdminFormState> emit) async {
    InvitationAnswer invitationAnswer = InvitationAnswer(
      participantId: event.participantId,
      active: false,
    );

    try {
      await ParticipantServices.answerInvitation(invitationAnswer);
      add(InitEvent(id: event.eventId));
    } on ApiException catch (error) {
      emit(state.copyWith(status: FormStatus.error));
    }
  }
}
