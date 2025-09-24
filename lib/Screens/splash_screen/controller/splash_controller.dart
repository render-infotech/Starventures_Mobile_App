import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../app_routes.dart';

class SplashController extends GetxController {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

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
        // Token exists, navigate to home screen
        print('Navigating to home screen - user is authenticated');

        Get.offAllNamed(AppRoutes.homeScreenMain);
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

  // Optional: Method to manually trigger navigation (useful for testing)
  Future<void> checkTokenAndNavigate() async {
    await _checkAuthenticationAndNavigate();
  }

  // Optional: Method to validate token with server (if needed)
  Future<bool> _isTokenValid(String token) async {
    // You can add server validation here if needed
    // For now, we just check if token exists
    return token.isNotEmpty;
  }
}
