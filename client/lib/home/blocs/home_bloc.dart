
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
      emit(HomeLoading());

      try {
        final events = await EventServices.getEvents();
        emit(HomeDataLoadSuccess(events: events));
      } on ApiException catch (error) {
        emit(HomeDataLoadError(errorMessage: 'An error occurred.'));
      }
    });
  }
}
