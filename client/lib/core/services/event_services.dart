import 'dart:convert';
import 'dart:developer';

import 'package:flutter_flash_event/core/models/event.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_flash_event/core/exceptions/api_exception.dart';

class EventServices {
  static Future<List<Event>> getEvents() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:8000/events'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token', // Include token in headers
        },);
      // Simulate call length for loader display
      await Future.delayed(const Duration(seconds: 1));

      if (response.statusCode < 200 || response.statusCode >= 400) {
        throw Error();
      }

      final data = json.decode(response.body);
      return (data as List<dynamic>?)?.map((e) {
            return Event.fromJson(e);
          }).toList() ??
          [];
    } catch (error) {
      log('Error occurred while retrieving users.', error: error);
      rethrow;
    }
  }

  static Future<http.Response> addEvent(Event event) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? email = prefs.getString('email');

    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/events'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token', // Include token in headers
      },
      body: json.encode(event.toJson()),
    );

        print('Token : ${token}');


    if (response.statusCode == 201) {
      print('Succes: ${response.statusCode}');
      print('Response body: ${response.body}');
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
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/events/$id'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token', // Include token in headers
        },
      );
      if (response.statusCode < 200 || response.statusCode >= 400) {
        throw ApiException(
            message: 'Error while requesting event with id $id',
            statusCode: response.statusCode);
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      return Event.fromJson(data);
    } catch (error) {
      throw ApiException(
          message: 'Unknown error while requesting product with id $id');
    }
  }

  static Future<http.Response> updateEventById(Event event) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    try {
      final response = await http.patch(
        Uri.parse('http://10.0.2.2:8000/events/${event.id}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token', // Include token in headers
        },
        body: json.encode(event.toJson()),
      );

      if (response.statusCode < 200 || response.statusCode >= 400) {
        throw ApiException(
            message: 'Error while updating event with id ${event.id}',
            statusCode: response.statusCode);
      }

      return response;
    } catch (error) {
      throw ApiException(
          message: 'Unknown error while updating event with id ${event.id}');
    }
  }

  static Future<void> deleteEventById(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    try {
      final response = await http.delete(
        Uri.parse('http://10.0.2.2:8000/events/$id'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token', // Include token in headers
        },
      );

      if (response.statusCode < 200 || response.statusCode >= 400) {
        throw ApiException(
            message: 'Error while deleting event with id $id',
            statusCode: response.statusCode);
      }
    } catch (error) {
      throw ApiException(
          message: 'Unknown error while deleting event with id $id');
    }
  }
}
