import 'dart:convert';
import 'dart:developer';
import 'package:flutter_flash_event/core/models/feature.dart';
import 'package:flutter_flash_event/core/services/api_endpoints.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_flash_event/core/exceptions/api_exception.dart';

class FeatureServices {
  static Future<List<Feature>> getFeatures() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    try {
      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}/features'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token', // Include token in headers
        },
      );

      print(response.statusCode);
      if (response.statusCode < 200 || response.statusCode >= 400) {
        throw Error();
      }

      final data = json.decode(response.body);
      return (data as List<dynamic>?)?.map((e) {
        return Feature.fromJson(e);
      }).toList() ??
          [];
    } catch (error) {
      log('Error occurred while retrieving features.', error: error);
      rethrow;
    }
  }

  static Future<http.Response> addFeature(Feature feature) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.post(
      Uri.parse('${ApiEndpoints.baseUrl}/features'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token', // Include token in headers
      },
      body: json.encode(feature.toJson()),
    );

    if (response.statusCode == 201) {
      return response;
    } else {
      print('Error: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to create feature');
    }
  }

  static Future<Feature> getFeature({required int id}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    try {
      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}/features/$id'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token', // Include token in headers
        },
      );
      if (response.statusCode < 200 || response.statusCode >= 400) {
        throw ApiException(
            message: 'Error while requesting feature with id $id',
            statusCode: response.statusCode);
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      return Feature.fromJson(data);
    } catch (error) {
      throw ApiException(
          message: 'Unknown error while requesting feature with id $id');
    }
  }

  static Future<http.Response> updateFeatureById(Feature feature) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    try {
      final response = await http.patch(
        Uri.parse('${ApiEndpoints.baseUrl}/features/${feature.id}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token', // Include token in headers
        },
        body: json.encode(feature.toJson()),
      );

      if (response.statusCode < 200 || response.statusCode >= 400) {
        throw ApiException(
            message: 'Error while updating feature with id ${feature.id}',
            statusCode: response.statusCode);
      }

      return response;
    } catch (error) {
      throw ApiException(
          message: 'Unknown error while updating feature with id ${feature.id}');
    }
  }

  static Future<void> deleteFeatureById(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    try {
      final response = await http.delete(
        Uri.parse('${ApiEndpoints.baseUrl}/features/$id'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token', // Include token in headers
        },
      );

      if (response.statusCode < 200 || response.statusCode >= 400) {
        throw ApiException(
            message: 'Error while deleting feature with id $id',
            statusCode: response.statusCode);
      }
    } catch (error) {
      throw ApiException(
          message: 'Unknown error while deleting feature with id $id');
    }
  }

  static Future<Feature> findTransportFeature() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    try {
      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}/features/transport'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token', // Include token in headers
        },
      );

      if (response.statusCode < 200 || response.statusCode >= 400) {
        throw ApiException(
            message: 'Error while retrieving transport feature',
            statusCode: response.statusCode);
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      return Feature.fromJson(data);
    } catch (error) {
      log('Error occurred while retrieving transport feature.', error: error);
      throw ApiException(message: 'Unknown error while retrieving transport feature');
    }
  }
}
