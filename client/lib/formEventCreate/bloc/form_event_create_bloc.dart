import 'package:flutter_bloc/flutter_bloc.dart';
import 'form_event_create_event.dart';
import 'form_event_create_state.dart';

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
    on<EventTransportActiveChanged>((event, emit) {
      emit(state.copyWith(transportActive: event.transportActive));
    });
    on<EventFormSubmitted>((event, emit) async {
      emit(state.copyWith(status: FormStatus.loading));

      try {
        // Simulate an API call
        await Future.delayed(Duration(seconds: 2));

        emit(state.copyWith(status: FormStatus.success));
      } catch (e) {
        emit(state.copyWith(status: FormStatus.error, errorMessage: 'Erreur lors de la création de l\'événement'));
      }
    });
  }
}
