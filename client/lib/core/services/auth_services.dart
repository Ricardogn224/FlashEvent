import 'dart:convert';
import 'dart:developer';
import 'package:flutter_flash_event/core/exceptions/api_exception.dart';
import 'package:flutter_flash_event/core/models/product.dart';
import 'package:flutter_flash_event/core/models/user.dart';
import 'package:flutter_flash_event/core/models/event.dart';
import 'package:flutter_flash_event/core/services/api_endpoints.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthServices {
  static Future<http.Response> registerUser(User user) async {
    final uri = Uri.https(ApiEndpoints.baseUrl, '/register');
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': '*/*'
    };
    final body = jsonEncode(<String, String>{
      'firstname': user.firstname,
      'lastname': user.lastname,
      'username': user.username,
      'email': user.email,
      'password': user.password,
    });

    log('Registering user at $uri with body: $body');

    final response = await http.post(uri, headers: headers, body: body);

    if (response.statusCode == 201) {
      return response;
    } else {
      throw Exception('Failed to register user');
    }
  }

  static Future<http.Response> loginUser(String email, String password) async {
    final uri = Uri.https(ApiEndpoints.baseUrl, '/login');
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': '*/*'
    };
    final body = jsonEncode(<String, String>{
      'email': email,
      'password': password,
    });

    log('Logging in user at $uri with body: $body');

    final response = await http.post(uri, headers: headers, body: body);

    if (response.statusCode == 200) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', jsonDecode(response.body)['token']);
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
