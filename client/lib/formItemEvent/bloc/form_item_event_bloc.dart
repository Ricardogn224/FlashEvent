import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_flash_event/core/models/itemEvent.dart';
import 'package:flutter_flash_event/core/services/event_services.dart';
import 'package:flutter_flash_event/core/services/item_services.dart';
import 'package:flutter_flash_event/formEventParty/form_item.dart';
import 'package:flutter_flash_event/utils/extensions.dart';
import 'package:flutter/material.dart';

part 'form_event_item_event.dart';
part 'form_item_event_state.dart';


class FormItemEventBloc extends Bloc<FormEventItemEvent, FormItemEventState> {
  final int eventId;

  FormItemEventBloc({required this.eventId}) : super(const FormItemEventState()) {
    on<InitEvent>(_initState);
    on<NameChanged>(_onNameChanged);
    on<FormSubmitEvent>(_onFormSubmitted);
    on<FormResetEvent>(_onFormReset);
  }

  final formKey = GlobalKey<FormState>();

  Future<void> _initState(InitEvent event, Emitter<FormItemEventState> emit) async {
    emit(state.copyWith(formKey: formKey));
  }

  Future<void> _onNameChanged(
      NameChanged event, Emitter<FormItemEventState> emit) async {
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

  Future<void> _onFormReset(
      FormResetEvent event,
      Emitter<FormItemEventState> emit,
      ) async {
    state.formKey?.currentState?.reset();
  }

  Future<void> _onFormSubmitted(FormSubmitEvent event, Emitter<FormItemEventState> emit) async {
    if (state.formKey!.currentState!.validate()) {
      ItemEvent newItem = ItemEvent(
        id: 0,
        name: state.name.value,
        userId: 0,
        eventId: eventId,
        firstname: '',
        lastname: '',
      );

      try {
        final response = await ItemServices.addItem(newItem);
        if (response.statusCode == 201) {
          event.onSuccess();
        } else {
          event.onError('Item creation failed');
        }
      } catch (e) {
        event.onError('Error: $e');
      }
    }
  }
}