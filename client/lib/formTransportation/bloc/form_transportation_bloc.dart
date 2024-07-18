import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_flash_event/core/models/itemEvent.dart';
import 'package:flutter_flash_event/core/models/transportation.dart';
import 'package:flutter_flash_event/core/services/event_services.dart';
import 'package:flutter_flash_event/core/services/item_services.dart';
import 'package:flutter_flash_event/core/services/transportation_services.dart';
import 'package:flutter_flash_event/formEventParty/form_item.dart';
import 'package:flutter_flash_event/utils/extensions.dart';
import 'package:flutter/material.dart';

part 'form_transportation_event.dart';
part 'form_transportation_state.dart';


class FormTransportationBloc extends Bloc<FormTransportationEvent, FormTransportationState> {
  final int eventId;

  FormTransportationBloc({required this.eventId}) : super(const FormTransportationState()) {
    on<InitEvent>(_initState);
    on<NameChanged>(_onNameChanged);
    on<SeatNumberChanged>(_onSeatNumberChanged);
    on<FormSubmitEvent>(_onFormSubmitted);
    on<FormResetEvent>(_onFormReset);
  }

  final formKey = GlobalKey<FormState>();

  Future<void> _initState(InitEvent event, Emitter<FormTransportationState> emit) async {
    emit(state.copyWith(formKey: formKey));
  }

  Future<void> _onNameChanged(
      NameChanged event, Emitter<FormTransportationState> emit) async {
    emit(
      state.copyWith(
        name: BlocFormItem(
          value: event.name.value,
        ),
        formKey: formKey,
      ),
    );
  }

  Future<void> _onSeatNumberChanged(
      SeatNumberChanged event, Emitter<FormTransportationState> emit) async {
    emit(
      state.copyWith(
        seatNumber: BlocFormItem(
          value: event.seatNumber.value,
          error: event.seatNumber.value.isValidInteger ? null : 'Entrer un nombre valide',
        ),
        formKey: formKey,
      ),
    );
  }

  Future<void> _onFormReset(
      FormResetEvent event,
      Emitter<FormTransportationState> emit,
      ) async {
    state.formKey?.currentState?.reset();
  }

  Future<void> _onFormSubmitted(FormSubmitEvent event, Emitter<FormTransportationState> emit) async {
    if (state.formKey!.currentState!.validate()) {
      Transportation newTransportation = Transportation(
        id: 0,
        vehicle: state.name.value,
        userId: 0,
        eventId: eventId,
        seatNumber: int.parse(state.seatNumber.value),
        email: '',
      );

      try {
        final response = await TransportationServices.addTransportation(newTransportation);
        if (response.statusCode == 201) {
          event.onSuccess();
        } else {
          event.onError('transportation creation failed');
        }
      } catch (e) {
        event.onError('Error: $e');
      }
    }
  }
}