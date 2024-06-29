import 'dart:convert';
import 'dart:developer';
import 'package:flutter_flash_event/core/models/user.dart';
import 'package:http/http.dart' as http;

class UserServices {
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
        final userResponse = await http.get(Uri.parse('http://10.0.2.2:8080/user/$userId'));
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
}
