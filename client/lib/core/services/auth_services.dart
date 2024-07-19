import 'dart:convert';
import 'dart:developer';
import 'package:flutter_flash_event/core/exceptions/api_exception.dart';
import 'package:flutter_flash_event/core/models/product.dart';
import 'package:flutter_flash_event/core/models/user.dart';
import 'package:flutter_flash_event/core/models/event.dart';
import 'package:flutter_flash_event/core/services/api_endpoints.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

class AuthServices {
  static final Dio _dio = Dio();


  static Future<Response<dynamic>> registerUser(User user) async {
    final uri = '${ApiEndpoints.baseUrl}/register';


    final body = jsonEncode(<String, String>{
      'firstname': user.firstname,
      'lastname': user.lastname,
      'username': user.username,
      'email': user.email,
      'password': user.password,
    });

    log('Registering user at $uri with body: $body');

    final response = await _dio.post(
      uri,
      data: body,
      options: Options(
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      ),
    );

    if (response.statusCode == 201) {
      return response;
    } else {
      throw Exception('Failed to register user');
    }
  }

  static Future<Response<dynamic>> loginUser(String email, String password) async {
    final uri = '${ApiEndpoints.baseUrl}/login';

    final body = jsonEncode(<String, String>{
      'email': email,
      'password': password,
    });

    log('Logging in user at $uri with body: $body');

    final response = await _dio.post(
      uri,
      data: body,
      options: Options(
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      ),
    );

    log('Received response with status code: ${response.statusCode}');
    log('Response body: ${response.data}');

    if (response.statusCode == 200) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', response.data['token']);
      return response;
    } else {
      throw Exception('Failed to login');
    }
  }

  static Future<void> logoutUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }
}