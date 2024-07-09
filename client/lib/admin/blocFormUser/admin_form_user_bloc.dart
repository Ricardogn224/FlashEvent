import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_flash_event/core/exceptions/api_exception.dart';
import 'package:flutter_flash_event/core/services/user_services.dart';
import 'package:flutter_flash_event/formEventParty/form_item.dart';
import 'package:flutter_flash_event/utils/extensions.dart';
import 'package:flutter/material.dart';

part 'admin_form_user_event.dart';
part 'admin_form_user_state.dart';


class AdminFormUserBloc extends Bloc<AdminFormUserEvent, AdminFormUserState> {
  AdminFormUserBloc() : super(const AdminFormUserState()) {
    on<InitEvent>(_initState);
    on<FirstnameChanged>(_onFirstnameChanged);
    on<LastnameChanged>(_onLastnameChanged);
    on<EmailChanged>(_onEmailChanged);
    on<UsernameChanged>(_onUsernameChanged);
    on<FormSubmitEvent>(_onFormSubmitted);
    on<FormResetEvent>(_onFormReset);
    on<ToggleAdminRoleEvent>(_onToggleAdminRole);
  }

  final formKey = GlobalKey<FormState>();

  Future<void> _initState(InitEvent event, Emitter<AdminFormUserState> emit) async {
    emit(state.copyWith(status: FormStatus.inProgress));
    try {
      final user = await UserServices.getUser(id: event.id);

      emit(state.copyWith(
        formKey: formKey,
        firstname: BlocFormItem(value: user.firstname ?? '', error: 'Enter name'),
        lastname: BlocFormItem(value: user.lastname ?? '', error: 'Enter name'),
        email: BlocFormItem(value: user.email ?? '', error: 'Enter email'),
        username: BlocFormItem(value: user.username ?? '', error: 'Enter username'),
        status: FormStatus.valid,
      ));
    } on ApiException catch (error) {
      emit(state.copyWith(
        formKey: formKey,
        firstname: BlocFormItem(value: '', error: 'Enter name'),
        lastname: BlocFormItem(value: '', error: 'Enter name'),
        email: BlocFormItem(value: '', error: 'Enter email'),
        username: BlocFormItem(value: '', error: 'Enter username'),
        status: FormStatus.error,
      ));
    }
  }


  Future<void> _onFirstnameChanged(
      FirstnameChanged event, Emitter<AdminFormUserState> emit) async {
    emit(
      state.copyWith(
        firstname: BlocFormItem(
          value: event.firstname.value,
          error: event.firstname.value.isValidName ? null : 'Enter a valid name',
        ),
        formKey: formKey,
      ),
    );
  }

  Future<void> _onLastnameChanged(
      LastnameChanged event, Emitter<AdminFormUserState> emit) async {
    emit(
      state.copyWith(
        lastname: BlocFormItem(
          value: event.lastname.value,
          error: event.lastname.value.isValidName ? null : 'Enter a valid name',
        ),
        formKey: formKey,
      ),
    );
  }

  Future<void> _onEmailChanged(
      EmailChanged event, Emitter<AdminFormUserState> emit) async {
    emit(
      state.copyWith(
        email: BlocFormItem(
          value: event.email.value,
          error: event.email.value.isValidEmail ? null : 'Enter a valid mail',
        ),
        formKey: formKey,
      ),
    );
  }

  Future<void> _onUsernameChanged(
      UsernameChanged event, Emitter<AdminFormUserState> emit) async {
    emit(
      state.copyWith(
        username: BlocFormItem(
          value: event.username.value,
          error: event.username.value.isValidName ? null : 'Enter a valid name',
        ),
        formKey: formKey,
      ),
    );
  }

  Future<void> _onFormReset(
      FormResetEvent event,
      Emitter<AdminFormUserState> emit,
      ) async {
    state.formKey?.currentState?.reset();
  }

  Future<void> _onFormSubmitted(FormSubmitEvent event, Emitter<AdminFormUserState> emit) async {
    if (state.formKey!.currentState!.validate()) {

      // Handle the submission logic here
      // For example, call an API to save the event

      // If successful, call event.onSuccess()
      event.onSuccess();
    } else {
      // If validation fails, you can call event.onError() with a message
      event.onError('Validation failed');
    }
  }

  Future<void> _onToggleAdminRole(ToggleAdminRoleEvent event, Emitter<AdminFormUserState> emit) async {
    try {
      //await UserServices.toggleAdminRole(userId: event.userId, isAdmin: event.isAdmin);
      emit(state.copyWith(isAdmin: event.isAdmin));
    } on ApiException catch (error) {
      // Handle error if needed
    }
  }
}