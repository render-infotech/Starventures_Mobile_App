// lib/core/network/api_client.dart

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../Screens/sign_in_screen/login_model/login_responce_model.dart';
import '../../../core/data/api_constant/api_constant.dart';

import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ApiClient {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  Future<String?> getAuthToken() async {
    return await secureStorage.read(key: 'auth_token');
  }

  Future<bool> hasValidToken() async {
    try {
      final token = await getAuthToken();
      return token != null && token.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> clearToken() async {
    await secureStorage.delete(key: 'auth_token');
  }

  Future<bool> logout() async {
    try {
      final token = await getAuthToken();
      if (token != null && token.isNotEmpty) {
        final response = await http.post(
          Uri.parse(ApiConstants.logout),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
        await clearToken();
        return response.statusCode == 200 || response.statusCode == 201;
      } else {
        await clearToken();
        return true;
      }
    } catch (_) {
      await clearToken();
      return false;
    }
  }

  Future<LoginResponse> login(String email, String password) async {
    final response = await http.post(
      Uri.parse(ApiConstants.login),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return LoginResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to login. Server responded: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> clockIn() async {
    final token = await getAuthToken();
    final response = await http.post(
      Uri.parse(ApiConstants.clockIn),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'timestamp': DateTime.now().toIso8601String()}),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to clock in. Server responded: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> clockOut() async {
    final token = await getAuthToken();
    final response = await http.post(
      Uri.parse(ApiConstants.clockout),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'timestamp': DateTime.now().toIso8601String()}),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to clock out. Server responded: ${response.statusCode}');
    }
  }

  // NEW: fetch profile
  Future<Map<String, dynamic>> fetchProfile() async {
    final token = await getAuthToken();
    if (token == null || token.isEmpty) {
      throw Exception('No auth token found');
    }

    final response = await http.get(
      Uri.parse(ApiConstants.profile),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to fetch profile: ${response.statusCode}');
  }

  Future<Map<String, dynamic>> updateProfileMultipart({
    required String name,
    required String email,
    File? profileImage, // nullable
  }) async {
    final token = await getAuthToken();
    if (token == null || token.isEmpty) {
      throw Exception('No auth token found');
    }

    final uri = Uri.parse(ApiConstants.profileUpdate);
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['name'] = name
      ..fields['email'] = email;

    if (profileImage != null) {
      final mimeType = 'image/jpeg'; // or detect from extension if desired
      request.files.add(
        await http.MultipartFile.fromPath(
          'profile', // server expects "profile" as in Postman screenshot
          profileImage.path,
          contentType: MediaType.parse(mimeType),
        ),
      );
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to update profile: ${response.statusCode}: ${response.body}');
    }
  }
}
