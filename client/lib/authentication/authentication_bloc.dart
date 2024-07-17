import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'authentication_event.dart';
import 'authentication_state.dart';

class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
  AuthenticationBloc() : super(AuthenticationUninitialized()) {
    on<AppStarted>(_onAppStarted);
    on<LoggedIn>(_onLoggedIn);
    on<LoggedOut>(_onLoggedOut);
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthenticationState> emit) async {
    emit(AuthenticationLoading());

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userRole = prefs.getString('role');

    if (token != null && userRole != null) {
      bool isTokenExpired = JwtDecoder.isExpired(token);
      if (isTokenExpired) {
        await prefs.remove('token');
        await prefs.remove('email');
        await prefs.remove('userId');
        await prefs.remove('role');
        emit(AuthenticationUnauthenticated());
      } else {
        emit(AuthenticationAuthenticated(userRole));
      }
    } else {
      emit(AuthenticationUnauthenticated());
    }
  }

  Future<void> _onLoggedIn(LoggedIn event, Emitter<AuthenticationState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final userRole = prefs.getString('role');

    emit(AuthenticationAuthenticated(userRole ?? ''));
  }

  Future<void> _onLoggedOut(LoggedOut event, Emitter<AuthenticationState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('email');
    await prefs.remove('userId');
    await prefs.remove('role');

    emit(AuthenticationUnauthenticated());
  }
}
