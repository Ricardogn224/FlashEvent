import 'dart:convert';
import 'dart:developer';
import 'package:flutter_flash_event/core/models/invitation.dart';
import 'package:flutter_flash_event/core/models/participant.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_flash_event/core/exceptions/api_exception.dart';

class ParticipantServices {
  static Future<http.Response> addParticipant(ParticipantAdd participant) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.post(
      Uri.parse('http://10.0.2.2:8080/participant'),
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
        Uri.parse('http://10.0.2.2:8080/invitations/${email}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token', // Include token in headers
        },
      );
      print('Response body: ${response.body}');
      if (response.statusCode < 200 || response.statusCode >= 400) {
        throw ApiException(message: 'Error while requesting event with email', statusCode: response.statusCode);
      }
      final data = json.decode(response.body);
      return (data as List<dynamic>?)?.map((e) {
        return Invitation.fromJson(e);
      }).toList() ?? [];
    } catch (error) {
    throw ApiException(message: 'Unknown error while requesting product with email');
    }
  }

  static Future<void> answerInvitation(InvitationAnswer answer) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.post(
      Uri.parse('http://10.0.2.2:8080/answer-invitation'),
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
      throw ApiException(message: 'Failed to answer invitation', statusCode: response.statusCode);
    }
  }

  static Future<http.Response> updateParticipant(Participant participant) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token not found');
    }

    int newIdParticipant = 0;

    if (participant.id == 0) {
      try {
        final responseParticipant= await http.get(Uri.parse('http://10.0.2.2:8080//${participant.eventId}'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token', // Include token in headers
          },);
        if (responseParticipant.statusCode < 200 || responseParticipant.statusCode >= 400) {
          throw ApiException(message: 'Error while requesting event with user id', statusCode: responseParticipant.statusCode);
        }

        final data = json.decode(responseParticipant.body) as Map<String, dynamic>;
        final participantReq = Participant.fromJson(data);
        newIdParticipant = participantReq.id;
      } catch (error) {
        throw ApiException(message: 'Unknown error while requesting product with user id');
      }
    }

    String url = '';

    if (newIdParticipant != 0) {
      url = 'http://10.0.2.2:8080/participants/${newIdParticipant}';
    } else {
      url = 'http://10.0.2.2:8080/participants/${participant.id}';
    }

    final response = await http.patch(
      Uri.parse(url),
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