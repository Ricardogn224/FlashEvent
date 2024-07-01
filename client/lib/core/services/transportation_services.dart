import 'dart:convert';
import 'dart:developer';
import 'package:flutter_flash_event/core/models/transportation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TransportationServices {
  static Future<List<Transportation>> getTransportationsByEvent({required int id}) async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:8080/event/$id/transportations'));
      // Simulate call length for loader display
      await Future.delayed(const Duration(seconds: 1));

      if (response.statusCode < 200 || response.statusCode >= 400) {
        throw Error();
      }

      print(json.decode(response.body));

      final data = json.decode(response.body);
      return (data as List<dynamic>?)?.map((e) {
        return Transportation.fromJson(e);
      }).toList() ?? [];
    } catch (error) {
      log('Error occurred while retrieving transportations.', error: error);
      rethrow;
    }
  }

  static Future<http.Response> addTransportation(Transportation transportation) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? email = prefs.getString('email');

    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.post(
      Uri.parse('http://10.0.2.2:8080/event/${transportation.eventId}/transportations'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token', // Include token in headers
      },
      body: jsonEncode(<String, dynamic>{
        'vehicle': transportation.vehicle,
        'seat_number': transportation.seatNumber,
        'email': email ?? '',
      }),
    );

    if (response.statusCode == 201) {
      return response;
    } else {
      print('Error: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to create transportation');
    }
  }
}
