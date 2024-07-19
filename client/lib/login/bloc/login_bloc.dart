import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:flutter_flash_event/api/firebase_api.dart';
import 'package:flutter_flash_event/core/services/auth_services.dart';
import 'package:flutter_flash_event/core/services/user_services.dart';
import 'package:flutter_flash_event/login/bloc/login_event.dart';
import 'package:flutter_flash_event/login/bloc/login_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'dart:developer';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginInitial()) {
    on<LoginButtonPressed>(_onLoginButtonPressed);
  }

  Future<void> _onLoginButtonPressed(
      LoginButtonPressed event, Emitter<LoginState> emit) async {
    emit(LoginLoading());

    try {
      final response =
          await AuthServices.loginUser(event.email, event.password);
      if (response.statusCode == 200) {
        // Extract token from response body
        Map<String, dynamic> data = jsonDecode(response.body);
        String token = data['token'];

        // Decode the token
        Map<String, dynamic>? decodedToken = Jwt.parseJwt(token);

        // Log the decoded token
        log('Decoded token: $decodedToken');

        // Access information from the decoded token
        String email = decodedToken['email'] ?? '';
        String userRole = decodedToken['role'] ??
            ''; // Assuming the role is stored in the token

        if (email == null || userRole == null) {
          throw Exception('Invalid token: missing email or role');
        }

        // Store token in session
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('email', email);
        await prefs.setString('role', userRole);

        // log the token
        log('Token befor geting user: $token');
        final user = await UserServices.getCurrentUser();

        // Log the user information
        log('User: ${user.firstname} ${user.lastname}');

        await prefs.setInt('userId', user.id);

        emit(LoginSuccess(userRole: userRole));

        // Initialize notifications
        // await FirebaseApi().initNotifications();
      } else {
        log('Login failed: ${response.body}');
        emit(LoginFailure(error: 'Login failed: ${response.body}'));
      }
    } catch (e) {
      log('Error during login: $e');
      emit(LoginFailure(error: 'Error: $e'));
    }
  }
}
