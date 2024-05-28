import 'dart:convert';
import 'dart:developer';

import 'package:flutter_flash_event/core/models/event.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EventServices {
  static Future<http.Response> addEvent(Event event) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? email = prefs.getString('email');

    print('email body: ${email}');
    print('email body: ${event.name}');
    print('email body: ${event.description}');

    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.post(
      Uri.parse('http://10.0.2.2:8080/event'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token', // Include token in headers
      },
      body: jsonEncode(<String, String>{
        'name': event.name,
        'description': event.description,
        'email': email ?? '',
      }),
    );

    if (response.statusCode == 201) {
      return response;
    } else {
      print('Error: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to create event');
    }
  }

}
