import 'dart:convert';
import 'dart:developer';

import 'package:flutter_flash_event/core/exceptions/api_exception.dart';
import 'package:flutter_flash_event/core/models/product.dart';
import 'package:flutter_flash_event/core/models/user.dart';
import 'package:flutter_flash_event/core/models/event.dart';
import 'package:http/http.dart' as http;

class EventServices {
  static Future<http.Response> addEvent(Event event) async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8080/event'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'name': event.name,
        'description': event.description,
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
