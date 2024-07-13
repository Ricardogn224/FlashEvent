import 'dart:convert';
import 'dart:developer';

import 'package:flutter_flash_event/core/exceptions/api_exception.dart';
import 'package:flutter_flash_event/core/models/product.dart';
import 'package:flutter_flash_event/core/models/user.dart';
import 'package:flutter_flash_event/core/models/event.dart';
import 'package:http/http.dart' as http;

class ApiServices {
  static Future<List<User>> getUsers() async {
    try {
      final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/users'));
      // Simulate call length for loader display
      await Future.delayed(const Duration(seconds: 1));

      if (response.statusCode < 200 || response.statusCode >= 400) {
        throw Error();
      }

      final data = json.decode(response.body);
      return (data as List<dynamic>?)?.map((e) {
        return User.fromJson(e);
      }).toList() ?? [];
    } catch (error) {
      log('Error occurred while retrieving users.', error: error);
      rethrow;
    }
  }

  static Future<List<Event>> getEvents() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:8080/events'));
      // Simulate call length for loader display
      await Future.delayed(const Duration(seconds: 1));

      if (response.statusCode < 200 || response.statusCode >= 400) {
        throw ApiException(message: 'Error while requesting events', statusCode: response.statusCode);
      }

      final data = json.decode(response.body);
      return (data as List<dynamic>?)?.map((e) {
        return Event.fromJson(e);
      }).toList() ?? [];
    } catch (error) {
      log('Error occurred while retrieving events.', error: error);
      rethrow;
    }
  }

}
