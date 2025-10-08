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
      // Get token and role from secure storage
      final token = await secureStorage.read(key: 'auth_token');
      final role = await secureStorage.read(key: 'user_role');

      print(
        'Splash Controller - Token check: ${token != null ? 'Token exists' : 'No token found'}',
      );
      print('Splash Controller - Role check: ${role ?? 'No role found'}');

      if (token != null && token.isNotEmpty) {
        // Token exists, navigate to home screen with saved role
        final userRole =
            role ?? 'employee'; // Default to employee if no role saved
        print(
          'Navigating to home screen - user is authenticated as: $userRole',
        );

        Get.offAllNamed(
          AppRoutes.homeScreenMain,
          arguments: {'role': userRole},
        );
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
