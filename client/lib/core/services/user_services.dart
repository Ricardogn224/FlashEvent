import 'dart:convert';
import 'dart:developer';
import 'package:flutter_flash_event/core/models/transportation.dart';
import 'package:flutter_flash_event/core/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_flash_event/core/exceptions/api_exception.dart';

class UserServices {

  static Future<List<User>> getUsers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:8080/users'));
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

  static Future<User> getCurrentUserByEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? email = prefs.getString('email');

    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:8080/users-email/$email'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token', // Include token in headers
        },);
      if (response.statusCode < 200 || response.statusCode >= 400) {
        throw ApiException(message: 'Error while requesting event with email $email', statusCode: response.statusCode);
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      return User.fromJson(data);
    } catch (error) {
      throw ApiException(message: 'Unknown error while requesting product with email $email');
    }
  }

  static Future<List<User>> getUsersParticipants({required int id}) async {
    try {
      // Fetch participants for the given event ID
      final response = await http.get(Uri.parse('http://10.0.2.2:8080/participants-event/$id'));

      if (response.statusCode < 200 || response.statusCode >= 400) {
        throw Exception('Failed to load participants');
      }

      // Decode the participants data
      final List<dynamic> participantsData = json.decode(response.body);

      // Initialize a list to hold User objects
      List<User> users = [];

      // Fetch user data for each participant
      for (var participantData in participantsData) {
        final int userId = participantData['user_id'];
        final userResponse = await http.get(Uri.parse('http://10.0.2.2:8080/users/$userId'));
        if (userResponse.statusCode < 200 || userResponse.statusCode >= 400) {
          throw Exception('Failed to load user with ID $userId');
        }

        // Decode the user data and add to the users list
        final userData = json.decode(userResponse.body);
        users.add(User.fromJson(userData));
      }
      // Simulate call length for loader display
      await Future.delayed(const Duration(seconds: 1));
      return users;
    } catch (error) {
      log('Error occurred while retrieving users.', error: error);
      rethrow;
    }
  }

  static Future<List<UserTransport>> getParticipantsByTransportation({required int id}) async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:8080/transportation/$id/participants'));

      if (response.statusCode < 200 || response.statusCode >= 400) {
        throw Exception('Failed to load participants');
      }

      final List<dynamic> participantsData = json.decode(response.body);
      return participantsData.map((data) => UserTransport.fromJson(data)).toList();
    } catch (error) {
      log('Error occurred while retrieving participants.', error: error);
      rethrow;
    }
  }

  static Future<List<String>> getAllUserEmails({required int id}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8080/users-emails/$id'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token', // Include token in headers
        },
      );

      if (response.statusCode < 200 || response.statusCode >= 400) {
        throw ApiException(message: 'Error while requesting user emails', statusCode: response.statusCode);
      }

      final List<dynamic> emailsData = json.decode(response.body);
      return List<String>.from(emailsData);
    } catch (error) {
      log('Error occurred while retrieving user emails.', error: error);
      throw ApiException(message: 'Unknown error while requesting user emails');
    }
  }

}
