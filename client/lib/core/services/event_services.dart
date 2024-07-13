import 'dart:convert';
import 'dart:developer';

import 'package:flutter_flash_event/core/models/event.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_flash_event/core/exceptions/api_exception.dart';

class EventServices {
  static Future<http.Response> addEvent(Event event) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? email = prefs.getString('email');

    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.post(
      Uri.parse('http://localhost:8080/event'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token', // Inclure le token dans les en-têtes
      },
      body: jsonEncode(<String, String>{
        'name': event.name,
        'description': event.description,
        'place': event.place,
        'date': event.date,
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

  static Future<Event> getEvent({required int id}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    try {
      final response = await http.get(Uri.parse('http://localhost:8080/event/$id'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token', // Inclure le token dans les en-têtes
        },);
      if (response.statusCode < 200 || response.statusCode >= 400) {
        throw ApiException(message: 'Error while requesting event with id $id', statusCode: response.statusCode);
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      return Event.fromJson(data);
    } catch (error) {
      throw ApiException(message: 'Unknown error while requesting product with id $id');
    }
  }
}
