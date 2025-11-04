// lib/Screens/create_account/create_account_controller.dart

import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../../core/data/api_client/api_client.dart';
import '../../core/utils/custom_snackbar.dart';
import '../../core/utils/loading_service.dart';
import '../../app_routes.dart';

class CreateAccountController extends GetxController {
  var loading = false.obs;
  final ApiClient apiClient = ApiClient();

  Future<void> registerCustomer({
    required String name,
    required String phone,
    required String email,
    required String dob,
    required BuildContext context,
  }) async {
    // Show overlay loading
    LoadingService.to.show(message: 'Creating your account...');
    loading.value = true;

    try {
      print('📤 Registering customer with:');
      print('Name: $name');
      print('Phone: $phone');
      print('Email: $email');
      print('DOB: $dob');

      final response = await apiClient.registerCustomer(
        name: name,
        phone: phone,
        email: email,
        dob: dob,
      );

      print('✅ Registration Response: $response');

      if (response['status'] == true) {
        // ✅ Success - Navigate directly to OTP screen
        final message = response['message'] ?? 'OTP sent to your mobile number';

        // Show brief success message
        CustomSnackbar.show(
          context,
          title: "Account Created! 🎉",
          message: message,
          backgroundColor: Colors.green.shade600,
        );

        // ✅ Navigate to OTP verification screen immediately
        Get.offNamed(
          AppRoutes.otpVerification2,
          arguments: {
            'phone': phone,
            'name': name,
            'email': email,
            'isRegistration': true, // Flag to show success dialog after OTP
          },
        );
      } else {
        CustomSnackbar.show(
          context,
          title: "Registration Failed",
          message: response['message'] ?? 'Unable to create account',
        );
      }
    } catch (err, stacktrace) {
      print('❌ Registration error: $err');
      print(stacktrace);

      String errorMessage = err.toString().replaceAll('Exception: ', '');

      CustomSnackbar.show(
        context,
        title: "Registration Error",
        message: errorMessage,
      );
    } finally {
      LoadingService.to.hide();
      loading.value = false;
    }
  }
}
