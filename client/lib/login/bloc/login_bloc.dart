import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:flutter_flash_event/api/firebase_api.dart';
import 'package:flutter_flash_event/core/services/auth_services.dart';
import 'package:flutter_flash_event/login/bloc/login_event.dart';
import 'package:flutter_flash_event/login/bloc/login_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decode/jwt_decode.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {

  LoginBloc() : super(LoginInitial()) {
    on<LoginButtonPressed>(_onLoginButtonPressed);
  }

  Future<void> _onLoginButtonPressed(LoginButtonPressed event, Emitter<LoginState> emit) async {
    emit(LoginLoading());

    try {
      final response = await AuthServices.loginUser(event.email, event.password);
      if (response.statusCode == 200) {
        // Extract token from response body
        Map<String, dynamic> data = jsonDecode(response.body);
        String token = data['token'];

        // Decode the token
        Map<String, dynamic>? decodedToken = Jwt.parseJwt(token);

        // Access information from the decoded token
        String email = decodedToken['email'];

        // Store token in session
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('email', email);

        emit(LoginSuccess());

        await FirebaseApi().initNotifications();
      } else {
        emit(LoginFailure(error: 'Login failed: ${response.body}'));
      }
    } catch (e) {
      emit(LoginFailure(error: 'Error: $e'));
    }
  }
}
