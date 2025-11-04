import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../app_routes.dart';
import '../data/api_client/api_client.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'dart:convert';

class SessionService extends GetxService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // ✅ Callback for session expiration
  Function()? onSessionExpired;

  /// Check if the API response indicates token expiration
  bool isTokenExpired(int statusCode, dynamic responseBody) {
    // Check for 401 Unauthorized
    if (statusCode == 401) {
      return true;
    }

    // Check for specific error messages in response body
    if (responseBody is String) {
      try {
        final json = jsonDecode(responseBody);
        if (json is Map) {
          final error = json['error']?.toString().toLowerCase() ?? '';
          final message = json['message']?.toString().toLowerCase() ?? '';

          return error.contains('unauthenticated') ||
              message.contains('unauthenticated') ||
              error.contains('token') ||
              message.contains('token expired');
        }
      } catch (_) {
        // If response body is not JSON, check string directly
        return responseBody.toLowerCase().contains('unauthenticated');
      }
    }

    return false;
  }

  /// Handle token expiration globally
  Future<void> handleTokenExpiration() async {
    print('🚫 Handling token expiration...');

    // Clear stored auth token
    await _secureStorage.delete(key: 'auth_token');

    // Clear any other user session data
    await clearAllSessionData();

    // Trigger callback to main.dart
    if (onSessionExpired != null) {
      onSessionExpired!();
    }
  }

  /// Clear all session-related data
  Future<void> clearAllSessionData() async {
    try {
      // Clear all secure storage keys related to session
      await _secureStorage.delete(key: 'auth_token');
      await _secureStorage.delete(key: 'user_id');
      await _secureStorage.delete(key: 'user_email');
      await _secureStorage.delete(key: 'user_name');
      // Add any other session keys you're storing

      print('✅ All session data cleared');
    } catch (e) {
      print('❌ Error clearing session data: $e');
    }
  }

  /// Check if user has valid token
  Future<bool> hasValidToken() async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      return token != null && token.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
