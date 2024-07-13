import 'dart:convert';
import 'dart:developer';

import 'package:flutter_flash_event/core/exceptions/api_exception.dart';
import 'package:flutter_flash_event/core/models/product.dart';
import 'package:flutter_flash_event/core/models/user.dart';
import 'package:flutter_flash_event/core/models/event.dart';
import 'package:http/http.dart' as http;

class AuthServices {
  static Future<http.Response> registerUser(User user) async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/register'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
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
      Uri.parse('http://10.0.2.2:8000/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return response;
    } else {
      throw Exception('Failed to login');
    }
  }
}
