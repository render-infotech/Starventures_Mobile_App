import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../app_routes.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../app_routes.dart';
import '../../../core/data/api_client/api_client.dart';
import '../../../core/data/app_initialize.dart';

class SplashController extends GetxController {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  final ApiClient apiClient = ApiClient();

  @override
  void onInit() {
    super.onInit();
    _initializeApp();
  }

  // Initialize app and check authentication
  Future<void> _initializeApp() async {
    // Show splash for minimum 3 seconds
    await Future.delayed(const Duration(seconds: 3));

    // Check if user has valid token
    await _checkAuthenticationAndNavigate();
  }

  // Check for existing token and navigate accordingly
  Future<void> _checkAuthenticationAndNavigate() async {
    try {
      // Get token from secure storage
      final token = await secureStorage.read(key: 'auth_token');

      print('Splash Controller - Token check: ${token != null ? 'Token exists' : 'No token found'}');

      if (token != null && token.isNotEmpty) {
        // Token exists, validate and get user profile to determine role
        print('Token found - validating and getting user profile');

        final isValid = await _validateTokenAndGetUserRole();

        if (isValid) {
          // Valid token with user role, navigate to permission gate
          print('Navigating to permission gate - user is authenticated');
          Get.offAllNamed(AppRoutes.permissionGate);
        } else {
          // Invalid token, clear it and go to sign-in
          print('Invalid token - clearing and navigating to sign-in');
          await secureStorage.delete(key: 'auth_token');
          Get.offAllNamed(AppRoutes.signinscreen);
        }
      } else {
        // No token found, navigate to sign-in screen
        print('Navigating to sign-in screen - user not authenticated');
        Get.offAllNamed(AppRoutes.signinscreen);
      }
    } catch (e) {
      print('Error checking authentication: $e');
      // In case of error, navigate to sign-in screen
      Get.offAllNamed(AppRoutes.signinscreen);
    }
  }

  // Validate token and get user role
  Future<bool> _validateTokenAndGetUserRole() async {
    try {
      // Initialize app profile to get user data
      final appInit = AppInitialize();
     // await appInit.initProfile();

      // You can also make an API call to validate token if needed
      // For example: await apiClient.getUserProfile();

      return true; // Token is valid if profile initialization succeeds
    } catch (e) {
      print('Error validating token or getting user profile: $e');
      return false;
    }
  }

  // Optional: Method to manually trigger navigation (useful for testing)
  Future<void> checkTokenAndNavigate() async {
    await _checkAuthenticationAndNavigate();
  }

  // Optional: Method to validate token with server (enhanced version)
  Future<bool> _isTokenValid(String token) async {
    try {
      // You can add server validation here if needed
      // For now, we just check if token exists and is not empty
      if (token.isEmpty) return false;

      // Optional: Make API call to validate token
      // final response = await apiClient.validateToken();
      // return response.isValid;

      return true;
    } catch (e) {
      print('Error validating token: $e');
      return false;
    }
  }
}
