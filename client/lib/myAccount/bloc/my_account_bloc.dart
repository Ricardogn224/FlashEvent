import 'package:flutter/cupertino.dart';
import 'package:flutter_flash_event/core/exceptions/api_exception.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_flash_event/core/models/user.dart';
import 'package:flutter_flash_event/core/services/user_services.dart';

part 'my_account_event.dart';
part 'my_account_state.dart';

class MyAccountBloc extends Bloc<MyAccountEvent, MyAccountState> {
  MyAccountBloc() : super(MyAccountState()) {
    on<MyAccountDataLoaded>((event, emit) async {
      emit(state.copyWith(status: MyAccountStatus.loading));

      try {
        final user = await UserServices.getCurrentUserByEmail();
        emit(state.copyWith(status: MyAccountStatus.success, user: user));
      } on ApiException catch (error) {
        emit(state.copyWith(status: MyAccountStatus.error, errorMessage: 'An error occurred'));
      }
    });
  }
}