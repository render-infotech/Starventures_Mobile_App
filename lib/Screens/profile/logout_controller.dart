// lib/Screens/auth/logout_controller.dart (adjust path)
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../core/data/api_client/api_client.dart';
import '../../../core/utils/custom_snackbar.dart';
import '../../../app_routes.dart';
// import 'package:starcapitalventures/Screens/sign_in/sign_in_screen.dart'; // optional fallback

class LogoutController extends GetxController {
  final ApiClient apiClient = ApiClient();
  var loading = false.obs;

  Future<void> performLogout(BuildContext context) async {
    loading.value = true;
    print('[Logout] performLogout -> start');
    try {
      final success = await apiClient.logout();
      print('[Logout] API result: $success');

      CustomSnackbar.show(
        context,
        title: success ? 'Logout Successful' : 'Logout Completed',
        message: success
            ? 'You have been logged out successfully'
            : 'Logged out locally. Please check your connection.',
      );

      try {
        print('[Logout] Navigating to ${AppRoutes.signinscreen}');
        Get.offAllNamed(AppRoutes.signinscreen);
      } catch (e, st) {
        print('[Logout] offAllNamed failed: $e\n$st');
        // Fallback to a safe route or a screen
        // Get.offAll(() => const SignInScreen());
        Get.offAllNamed('/'); // last resort
      }
    } catch (err, st) {
      print('[Logout] ERROR: $err\n$st');
      await apiClient.clearToken();
      CustomSnackbar.show(
        context,
        title: 'Logout Error',
        message: 'Logged out locally due to an error',
      );
      try {
        Get.offAllNamed(AppRoutes.signinscreen);
      } catch (_) {
        Get.offAllNamed('/');
      }
    } finally {
      loading.value = false;
      print('[Logout] performLogout -> end');
    }
  }
}
