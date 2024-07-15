import 'dart:convert';
import 'dart:developer';

import 'package:flutter_flash_event/core/models/chatRoom.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_flash_event/core/exceptions/api_exception.dart';

class ChatRoomServices {
  static Future<List<ChatRoom>> getChatRooms({required int id}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/events/$id/chat-rooms'),
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

      final data = json.decode(response.body);
      return (data as List<dynamic>?)?.map((e) {
            return ChatRoom.fromJson(e);
          }).toList() ??
          [];
    } catch (error) {
      throw ApiException(
          message: 'Unknown error while requesting product with id $id');
    }
  }
}
