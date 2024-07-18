import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_flash_event/core/exceptions/api_exception.dart';
import 'package:flutter_flash_event/core/models/cagnotte.dart';
import 'package:flutter_flash_event/core/models/contribution.dart';

class CagnotteServices {
  static Future<http.Response> addCagnotte(int eventId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/events/$eventId/cagnottes'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode < 200 || response.statusCode >= 400) {
        throw ApiException(
            message: 'Error while adding cagnotte',
            statusCode: response.statusCode);
      }

      if (response.statusCode == 201) {
        return response;
      } else {
        throw Exception('Failed to create cagnotte');
      }
    } catch (error) {
      log('Error occurred while adding cagnotte.', error: error);
      throw ApiException(message: 'Unknown error while adding cagnotte');
    }
  }


  static Future<http.Response> contributeToCagnotte(Contribution contribution) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/cagnottes/${contribution.cagnotteId}/contribution'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(<String, dynamic>{
          'participant_id': contribution.participantId,
          'amount': contribution.amount,
        }),
      );

      if (response.statusCode < 200 || response.statusCode >= 400) {
        throw ApiException(
            message: 'Error while contributing to cagnotte',
            statusCode: response.statusCode);
      }

      if (response.statusCode == 201) {
        return response;
      } else {
        throw Exception('Failed to contribute');
      }
    } catch (error) {
      log('Error occurred while contributing to cagnotte.', error: error);
      throw ApiException(
          message: 'Unknown error while contributing to cagnotte');
    }
  }

  static Future<Cagnotte> getCagnotteByEventId(int eventId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/events/$eventId/cagnotte'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode < 200 || response.statusCode >= 400) {
        throw ApiException(
            message: 'Error while retrieving cagnotte for event ID $eventId',
            statusCode: response.statusCode);
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      return Cagnotte.fromJson(data);
    } catch (error) {
      log('Error occurred while retrieving cagnotte for event ID $eventId.', error: error);
      throw ApiException(message: 'Unknown error while retrieving cagnotte for event ID $eventId');
    }
  }

  static Future<List<Contribution>> getContributorsByCagnotteID(int cagnotteId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/cagnottes/$cagnotteId/contributors'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode < 200 || response.statusCode >= 400) {
        throw ApiException(
            message: 'Error while retrieving contributors',
            statusCode: response.statusCode);
      }

      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Contribution.fromJson(json)).toList();
    } catch (error) {
      log('Error occurred while retrieving contributors.', error: error);
      throw ApiException(message: 'Unknown error while retrieving contributors');
    }
  }
}