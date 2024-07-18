import 'dart:convert';
import 'dart:developer';

import 'package:flutter_flash_event/core/models/chatRoom.dart';
import 'package:flutter_flash_event/core/services/api_endpoints.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_flash_event/core/exceptions/api_exception.dart';

class ChatRoomServices {
  static Future<List<ChatRoom>> getChatRooms(int eventId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    try {
      final response = await http.get(
        Uri.parse('http://${ApiEndpoints.baseUrl}/events/$eventId/chat-rooms'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );
      await Future.delayed(const Duration(seconds: 1));

      if (response.statusCode < 200 || response.statusCode >= 400) {
        throw Error();
      }

      final data = json.decode(response.body);
      return (data as List<dynamic>?)?.map((e) {
        return ChatRoom.fromJson(e);
      }).toList() ??
          [];
    } catch (error) {
      log('Error occurred while retrieving chat rooms.', error: error);
      rethrow;
    }
  }

  static Future<http.Response> addChatRoom(ChatRoom chatRoom) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.post(
      Uri.parse('http://${ApiEndpoints.baseUrl}/events/${chatRoom.eventId}/chat-rooms'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(chatRoom.toJson()),
    );

    if (response.statusCode == 201) {
      return response;
    } else {
      throw Exception('Failed to create chat room');
    }
  }

  static Future<ChatRoom> getChatRoomById(int chatRoomId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    try {
      final response = await http.get(
        Uri.parse('http://${ApiEndpoints.baseUrl}/chat-rooms/$chatRoomId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode < 200 || response.statusCode >= 400) {
        throw ApiException(
            message: 'Error while requesting chat room with id $chatRoomId',
            statusCode: response.statusCode);
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      return ChatRoom.fromJson(data);
    } catch (error) {
      throw ApiException(
          message: 'Unknown error while requesting chat room with id $chatRoomId');
    }
  }

  static Future<http.Response> updateChatRoomById(ChatRoom chatRoom) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    try {
      final response = await http.patch(
        Uri.parse('http://${ApiEndpoints.baseUrl}/chat-rooms/${chatRoom.id}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(chatRoom.toJson()),
      );

      if (response.statusCode < 200 || response.statusCode >= 400) {
        throw ApiException(
            message: 'Error while updating chat room with id ${chatRoom.id}',
            statusCode: response.statusCode);
      }

      return response;
    } catch (error) {
      throw ApiException(
          message: 'Unknown error while updating chat room with id ${chatRoom.id}');
    }
  }

  static Future<void> deleteChatRoomById(int chatRoomId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    try {
      final response = await http.delete(
        Uri.parse('http://${ApiEndpoints.baseUrl}/chat-rooms/$chatRoomId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode < 200 || response.statusCode >= 400) {
        throw ApiException(
            message: 'Error while deleting chat room with id $chatRoomId',
            statusCode: response.statusCode);
      }
    } catch (error) {
      throw ApiException(
          message: 'Unknown error while deleting chat room with id $chatRoomId');
    }
  }

  static Future<List<ChatRoom>> getUserChatRooms(int eventId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    try {
      final response = await http.get(
        Uri.parse('http://${ApiEndpoints.baseUrl}/events/$eventId/user-chat-rooms'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );
      print(response.statusCode);
      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        List<ChatRoom> chatRooms = responseData.map((data) => ChatRoom.fromJson(data)).toList();
        return chatRooms;
      } else {
        throw ApiException(message: 'Failed to fetch user chat rooms', statusCode: response.statusCode);
      }
    } catch (error) {
      log('Error occurred while retrieving user chat rooms.', error: error);
      rethrow;
    }
  }

  static Future<List<String>> getUnassociatedEmails(int chatRoomId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    try {
      final response = await http.get(
        Uri.parse('http://${ApiEndpoints.baseUrl}/chat-rooms/$chatRoomId/unassociated-emails'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          return [];
        }
        final responseData = json.decode(response.body);
        if (responseData is List<dynamic>) {
          return List<String>.from(responseData);
        } else {
          throw ApiException(message: 'Unexpected response format', statusCode: response.statusCode);
        }
      } else {
        throw ApiException(message: 'Failed to fetch unassociated emails', statusCode: response.statusCode);
      }
    } catch (error) {
      log('Error occurred while retrieving unassociated emails.', error: error);
      rethrow;
    }
  }

  static Future<http.Response> addChatRoomParticipant(int chatRoomId, String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.post(
      Uri.parse('http://${ApiEndpoints.baseUrl}/chat-rooms/$chatRoomId/participants'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({"email": email}),
    );

    if (response.statusCode == 201) {
      return response;
    } else {
      throw Exception('Failed to add participant to chat room');
    }
  }
}
