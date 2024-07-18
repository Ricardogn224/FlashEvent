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
    final response = await http.post(
      Uri.https(ApiEndpoints.baseUrl, '/register'),
      headers: <String, String>{
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': '*/*'
      },
      body: jsonEncode(<String, String>{
        'firstname': user.firstname,
        'lastname': user.lastname,
        'username': user.username,
        'email': user.email,
        'password': user.password, // Add password to the User model
      }),
    );

    if (response.statusCode == 201) {
      return response;
    } else {
      throw Exception('Failed to register user');
    }
  }

  static Future<http.Response> loginUser(String email, String password) async {
    final response = await http.post(
      Uri.https(ApiEndpoints.baseUrl, '/login'),
      headers: <String, String>{
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': '*/*'
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
    );

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
