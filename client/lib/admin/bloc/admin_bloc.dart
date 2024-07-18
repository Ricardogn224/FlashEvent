import 'package:flutter/cupertino.dart';
import 'package:flutter_flash_event/core/exceptions/api_exception.dart';
import 'package:flutter_flash_event/core/models/user.dart';
import 'package:flutter_flash_event/core/models/event.dart';
import 'package:flutter_flash_event/core/services/event_services.dart';
import 'package:flutter_flash_event/core/services/user_services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'admin_event.dart';
part 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  AdminBloc() : super(AdminState()) {
    on<AdminDataLoaded>((event, emit) async {
      emit(state.copyWith(status: AdminStatus.loading));

      try {
        final users = await UserServices.getUsers();
        emit(state.copyWith(status: AdminStatus.success, users: users));
      } on ApiException catch (error) {
        emit(state.copyWith(status: AdminStatus.error, errorMessage: 'An error occurred'));
      }
    });

    on<AdminEventsLoaded>((event, emit) async {
      emit(state.copyWith(status: AdminStatus.loading));

      try {
        final events = await EventServices.getEvents();
        emit(state.copyWith(status: AdminStatus.success, events: events));
      } on ApiException catch (error) {
        emit(state.copyWith(status: AdminStatus.error, errorMessage: 'An error occurred'));
      }
    });

    on<DeleteEvent>((event, emit) async {
      emit(state.copyWith(status: AdminStatus.loading));

      try {
        await EventServices.deleteEventById(event.id);
        final events = await EventServices.getEvents();
        emit(state.copyWith(status: AdminStatus.success, events: events));
      } on ApiException catch (error) {
        emit(state.copyWith(status: AdminStatus.error, errorMessage: 'An error occurred'));
      }
    });

    on<DeleteUserEvent>((event, emit) async {
      emit(state.copyWith(status: AdminStatus.loading));

      try {
        await UserServices.deleteUserById(event.id);
        final users = await UserServices.getUsers();
        emit(state.copyWith(status: AdminStatus.success, users: users));
      } on ApiException catch (error) {
        emit(state.copyWith(status: AdminStatus.error, errorMessage: 'An error occurred'));
      }
    });
  }


}