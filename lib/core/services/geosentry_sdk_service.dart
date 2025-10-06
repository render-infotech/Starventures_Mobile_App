// lib/services/geosentry_sdk_service.dart
import 'package:flutter/services.dart';

import '../../Screens/home_screen/model/geosentry_model.dart';

class GeosentrySdkService {
  static const platform = MethodChannel('com.geosentry.sdk/channel');

  /// Initialize the Geosentry SDK with the provided credentials
  static Future<bool> initializeSDK({
    required String apiKey,
    required String cipherKey,
    required String userID,
  }) async {
    try {
      print('🔧 GeosentrySDK: Starting SDK initialization...');
      print('🔧 GeosentrySDK: API Key: ${apiKey.substring(0, 10)}...'); // Show first 10 chars for security
      print('🔧 GeosentrySDK: Cipher Key: ${cipherKey.substring(0, 10)}...');
      print('🔧 GeosentrySDK: User ID: $userID');

      await platform.invokeMethod('initializeSDK', {
        'apiKey': apiKey,
        'cipherKey': cipherKey,
        'userID': userID,
      });

      print('✅ GeosentrySDK: SDK initialized successfully!');
      return true;
    } catch (e) {
      print('❌ GeosentrySDK: Failed to initialize SDK: $e');
      return false;
    }
  }

  /// Initialize SDK from GeosentryModel
  static Future<bool> initializeFromModel(GeosentryModel geosentry) async {
    return await initializeSDK(
      apiKey: geosentry.apiKey,
      cipherKey: geosentry.cipherKey,
      userID: geosentry.userId,
    );
  }

  /// Check if SDK is available
  static Future<bool> isSDKAvailable() async {
    try {
      await platform.invokeMethod('checkSDKAvailability');
      return true;
    } catch (e) {
      print('⚠️ GeosentrySDK: SDK not available: $e');
      return false;
    }
  }
}
