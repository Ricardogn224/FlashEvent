import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_flash_event/core/models/chatRoom.dart';
import 'package:flutter_flash_event/core/models/transportation.dart';
import 'package:flutter_flash_event/core/services/chat_room_services.dart';

import 'package:flutter_flash_event/core/services/transportation_services.dart';
import 'package:flutter_flash_event/formEventParty/form_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flash_event/utils/extensions.dart';

part 'form_chat_room_event.dart';
part 'form_chat_room_state.dart';


class FormChatRoomBloc extends Bloc<FormChatRoomEvent, FormChatRoomState> {

  FormChatRoomBloc() : super(const FormChatRoomState()) {
    on<InitEvent>(_initState);
    on<NameChanged>(_onNameChanged);
    on<EmailChanged>(_onEmailChanged);
    on<FormSubmitEvent>(_onFormSubmitted);
    on<FormParticipantSubmitEvent>(_onFormParticipantSubmitted);
    on<FormResetEvent>(_onFormReset);
    on<FetchEmailSuggestions>(_onFetchEmailSuggestions);
  }

  final formKey = GlobalKey<FormState>();

  Future<void> _initState(InitEvent event, Emitter<FormChatRoomState> emit) async {
    emit(state.copyWith(formKey: formKey));
  }

  Future<void> _onNameChanged(
      NameChanged event, Emitter<FormChatRoomState> emit) async {
    emit(
      state.copyWith(
        name: BlocFormItem(
          value: event.name.value,
        ),
        formKey: formKey,
      ),
    );
  }

  Future<void> _onEmailChanged(
      EmailChanged event, Emitter<FormChatRoomState> emit) async {
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

  Future<void> _onFetchEmailSuggestions(FetchEmailSuggestions event, Emitter<FormChatRoomState> emit) async {
    try {
      // Assuming you have a service method to fetch email suggestions
      final suggestions = await ChatRoomServices.getUnassociatedEmails(event.chatRoomId);

      // Filter the suggestions based on the query
      final filteredSuggestions = suggestions.where((email) => email.contains(event.query)).toList();

      // Emit the new state with filtered suggestions
      emit(state.copyWith(emailSuggestions: filteredSuggestions));
    } catch (e) {
      emit(state.copyWith(emailSuggestions: []));
    }
  }

  Future<void> _onFormReset(
      FormResetEvent event,
      Emitter<FormChatRoomState> emit,
      ) async {
    state.formKey?.currentState?.reset();
  }

  Future<void> _onFormSubmitted(FormSubmitEvent event, Emitter<FormChatRoomState> emit) async {
    if (state.formKey!.currentState!.validate()) {
      ChatRoom chatRoom = ChatRoom(
          id: 0,
          name: state.name.value,
          eventId: event.eventId
      );

      try {
        final response = await ChatRoomServices.addChatRoom(chatRoom);
        if (response.statusCode == 201) {
          event.onSuccess();
        } else {
          event.onError('Chat room creation failed');
        }
      } catch (e) {
        event.onError('Error: $e');
      }
    }
  }

  Future<void> _onFormParticipantSubmitted(FormParticipantSubmitEvent event, Emitter<FormChatRoomState> emit) async {
    if (state.formKey!.currentState!.validate()) {

      try {
        final response = await ChatRoomServices.addChatRoomParticipant(event.chatRoomId, state.email.value);
        if (response.statusCode == 201) {
          event.onSuccess();
        } else {
          event.onError('Chat room participant creation failed');
        }
      } catch (e) {
        event.onError('Error: $e');
      }
    }
  }
}