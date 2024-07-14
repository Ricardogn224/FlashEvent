import 'dart:convert';
import 'dart:developer';

import 'package:flutter_flash_event/core/models/chatRoom.dart';
import 'package:flutter_flash_event/core/models/message.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_flash_event/core/exceptions/api_exception.dart';

class MessageServices {
  static Future<List<Message>> getMessagesByChat({required int id}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/chat-rooms/$id/messages'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token', // Include token in headers
        },
      );
      print(response.body);
      if (response.statusCode < 200 || response.statusCode >= 400) {
        throw ApiException(
            message: 'Error while requesting event with id $id',
            statusCode: response.statusCode);
      }
      final data = json.decode(response.body);
      return (data as List<dynamic>?)?.map((e) {
            return Message.fromJson(e);
          }).toList() ??
          [];
    } catch (error) {
      throw ApiException(
          message: 'Unknown error while requesting product with id $id');
    }
  }

  static Future<http.Response> sendMessage(Message message) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? email = prefs.getString('email');

    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/chat-rooms/${message.chatRoomId}/messages'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token', // Include token in headers
      },
      body: jsonEncode(
          <String, dynamic>{"content": message.content, "email": email}),
    );

    if (response.statusCode == 201) {
      return response;
    } else {
      print('Error: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to send message');
    }
  }
}
