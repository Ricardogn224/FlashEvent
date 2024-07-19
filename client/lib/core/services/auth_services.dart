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

    log('Received response with status code: ${response.statusCode}');
    log('Response body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // Vérification et journalisation du contenu de la réponse JSON
      Map<String, dynamic> responseJson;
      try {
        responseJson = jsonDecode(response.body);
      } catch (e) {
        log('Error decoding JSON: $e');
        throw Exception('Failed to decode JSON');
      }

      // Vérification de la présence du token
      if (responseJson.containsKey('token') &&
          responseJson['token'] is String) {
        String token = responseJson['token'];
        log('Token received: $token');

        // Stocker le token
        await prefs.setString('token', token);

        // Récupérer et loguer le token pour vérification
        String storedToken = prefs.getString('token') ?? 'null';
        log('Stored token: $storedToken');
      } else {
        log('Token is missing or is not a string');
        throw Exception('Failed to retrieve token');
      }
      return response;
    } else {
      log('Failed to login, status code: ${response.statusCode}');
      throw Exception('Failed to login');
    }
  }

  static Future<void> logoutUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }
}
