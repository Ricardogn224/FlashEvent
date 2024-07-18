import 'dart:convert';
import 'dart:developer';
import 'package:flutter_flash_event/core/models/invitation.dart';
import 'package:flutter_flash_event/core/models/participant.dart';
import 'package:flutter_flash_event/core/models/user.dart';
import 'package:flutter_flash_event/core/services/api_endpoints.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_flash_event/core/exceptions/api_exception.dart';

class ParticipantServices {
  static Future<http.Response> addParticipant(
      ParticipantAdd participant) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.post(
      Uri.https(ApiEndpoints.baseUrl, '/participants'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token', // Include token in headers
      },
      body: jsonEncode(<String, dynamic>{
        'email': participant.email,
        'event_id': participant.eventId,
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

  static Future<List<Invitation>> getInvitations() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? email = prefs.getString('email');

    if (token == null) {
      throw Exception('Token not found');
    }

    try {
      final response = await http.get(
        Uri.https(ApiEndpoints.baseUrl, '/invitations/${email}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token', // Include token in headers
        },
      );
      print('Response body: ${response.body}');
      if (response.statusCode < 200 || response.statusCode >= 400) {
        throw ApiException(
            message: 'Error while requesting event with email',
            statusCode: response.statusCode);
      }
      final data = json.decode(response.body);
      return (data as List<dynamic>?)?.map((e) {
        return Invitation.fromJson(e);
      }).toList() ??
          [];
    } catch (error) {
      throw ApiException(
          message: 'Unknown error while requesting product with email');
    }
  }

  static Future<void> answerInvitation(InvitationAnswer answer) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.post(
      Uri.https(ApiEndpoints.baseUrl, '/answer-invitation'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token', // Include token in headers
      },
      body: jsonEncode(<String, dynamic>{
        'active': answer.active,
        'participant_id': answer.participantId
      }),
    );

    if (response.statusCode != 200) {
      throw ApiException(
          message: 'Failed to answer invitation',
          statusCode: response.statusCode);
    }
  }

  static Future<Participant> getParticipantByEventId(int eventId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token not found');
    }

    try {
      final responseParticipant = await http.get(
        Uri.https(ApiEndpoints.baseUrl, '/get-participant/$eventId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token', // Include token in headers
        },
      );

      if (responseParticipant.statusCode < 200 ||
          responseParticipant.statusCode >= 400) {
        throw ApiException(
            message: 'Error while requesting participant for event ID $eventId',
            statusCode: responseParticipant.statusCode);
      }

      final data = json.decode(responseParticipant.body) as Map<String, dynamic>;
      return Participant.fromJson(data);
    } catch (error) {
      throw ApiException(
          message: 'Unknown error while requesting participant with event ID $eventId');
    }
  }

  static Future<List<User>> getUsersParticipantsPresence({required int id}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    try {
      // Fetch participants for the given event ID
      final response = await http.get(
        Uri.https(ApiEndpoints.baseUrl, '/participants-presence/$id'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token', // Include token in headers
        },
      );

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
        final userResponse = await http.get(
          Uri.https(ApiEndpoints.baseUrl, '/users/$userId'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token', // Include token in headers
          },
        );
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

  static Future<http.Response> updateParticipantById(Participant participant) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token not found');
    }

    final participantId = participant.id;

    print(json.encode(participant.toJson()));

    final response = await http.patch(
      Uri.https(ApiEndpoints.baseUrl, '/participants/$participantId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token', // Include token in headers
      },
      body: json.encode(participant.toJson()),
    );

    print(response.statusCode);
    if (response.statusCode == 200) {
      return response;
    } else {
      print('Error: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to update participant');
    }
  }

  static Future<http.Response> updateParticipantContributionById(Participant participant) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token not found');
    }

    final participantId = participant.id;

    // Create a JSON object for the contribution field
    final body = jsonEncode({'contribution': participant.contribution});

    print(body);

    final response = await http.patch(
      Uri.https(ApiEndpoints.baseUrl, '/participant-contribution/$participantId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: body, // Send the JSON-encoded string
    );

    print(response.statusCode);
    if (response.statusCode == 200) {
      return response;
    } else {
      print('Error: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to update participant');
    }
  }

  static Future<http.Response> updateParticipantPresentById(Participant participant) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token not found');
    }

    final participantId = participant.id;

    print(json.encode(participant.toJson()));

    final response = await http.patch(
      Uri.https(ApiEndpoints.baseUrl, '/participant-present/$participantId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token', // Include token in headers
      },
      body: json.encode(participant.toJson()),
    );

    print(response.statusCode);
    if (response.statusCode == 200) {
      return response;
    } else {
      print('Error: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to update participant');
    }
  }

  static Future<http.Response> updateParticipant(
      Participant participant) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token not found');
    }

    int newIdParticipant = 0;

    if (participant.id == 0) {
      try {
        final responseParticipant = await http.get(
          Uri.https(ApiEndpoints.baseUrl, '/get-participant/${participant.eventId}'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token', // Include token in headers
          },
        );
        print(responseParticipant.statusCode);
        if (responseParticipant.statusCode < 200 ||
            responseParticipant.statusCode >= 400) {
          throw ApiException(
              message: 'Error while requesting ',
              statusCode: responseParticipant.statusCode);
        }

        final data =
        json.decode(responseParticipant.body) as Map<String, dynamic>;
        final participantReq = Participant.fromJson(data);
        newIdParticipant = participantReq.id;
      } catch (error) {
        throw ApiException(
            message: 'Unknown error while requesting product with user id');
      }
    }

    String url = '';

    if (newIdParticipant != 0) {
      url = '/participants/$newIdParticipant';
    } else {
      url = '/participants/${participant.id}';
    }

    final response = await http.patch(
      Uri.https(ApiEndpoints.baseUrl, url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token', // Include token in headers
      },
      body: jsonEncode(<String, dynamic>{
        'transportation_id': participant.transportationId,
      }),
    );

    if (response.statusCode == 200) {
      return response;
    } else {
      print('Error: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to create event');
    }
  }
}
