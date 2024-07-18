import 'dart:convert';
import 'dart:developer';

import 'package:flutter_flash_event/core/exceptions/api_exception.dart';
import 'package:flutter_flash_event/core/models/itemEvent.dart';
import 'package:flutter_flash_event/core/services/api_endpoints.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ItemServices {
  static Future<List<ItemEvent>> getItemsByEvent({required int id}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    print(id);
    try {
      final response =
          await http.get(Uri.parse('${ApiEndpoints.baseUrl}/items-event/$id'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': 'Bearer $token', // Include token in headers
            },);
      // Simulate call length for loader display
      await Future.delayed(const Duration(seconds: 1));
      print(response.statusCode);

      if (response.statusCode < 200 || response.statusCode >= 400) {
        throw Error();
      }

      final data = json.decode(response.body);
      return (data as List<dynamic>?)?.map((e) {
            return ItemEvent.fromJson(e);
          }).toList() ??
          [];
    } catch (error) {
      log('Error occurred while retrieving items.', error: error);
      rethrow;
    }
  }

  static Future<http.Response> addItem(ItemEvent itemEvent) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? email = prefs.getString('email');

    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.post(
      Uri.parse('${ApiEndpoints.baseUrl}/events/${itemEvent.eventId}/items'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token', // Include token in headers
      },
      body: jsonEncode(<String, dynamic>{
        'name': itemEvent.name,
        'email': email ?? '',
      }),
    );

    if (response.statusCode == 201) {
      return response;
    } else {
      print('Error: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to create item');
    }
  }
}
