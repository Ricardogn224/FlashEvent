
import 'package:flutter/foundation.dart';
import 'package:flutter_flash_event/core/exceptions/api_exception.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_flash_event/core/services/api_services.dart';
import 'package:flutter_flash_event/core/models/event.dart';
import 'package:flutter_flash_event/core/services/event_services.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
    on<HomeDataLoaded>((event, emit) async {
      await _loadEvents(emit);
    });

    on<ReloadEvents>((event, emit) async {
      await _loadEvents(emit);
    });
  }

  Future<void> _loadEvents(Emitter<HomeState> emit) async {
    emit(HomeLoading());
    try {
      final myEvents = await EventServices.getMyEvents();
      final createdEvents = await EventServices.getCreatedEvents();
      emit(HomeDataLoadSuccess(myEvents: myEvents, createdEvents: createdEvents));
    } on ApiException catch (error) {
      emit(HomeDataLoadError(errorMessage: 'An error occurred.'));
    }
  }
}


