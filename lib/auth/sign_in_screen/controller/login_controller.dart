import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../../../core/data/api_client/api_client.dart';
import '../../../core/data/app_initialize.dart';
import '../../../core/utils/appTheme/app_theme.dart';
import '../../../core/utils/custom_snackbar.dart';
import '../../../core/utils/loading_service.dart';
import '../login_model/login_responce_model.dart';
import '../../../app_routes.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SignInController extends GetxController {
  var loading = false.obs;
  final ApiClient apiClient = ApiClient();
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  Future<void> login(
    String email,
    String password,
    BuildContext context,
  ) async {
    // Show overlay loading
    LoadingService.to.show(message: 'Signing you in...');

    // Set button loading state
    loading.value = true;

    try {
      print('Starting login process');
      final loginResponse = await apiClient.login(email, password);
      print('Received loginResponse, status: ${loginResponse.status}');

      if (loginResponse.status == true) {
        final type = loginResponse.data.user.type;
        print('User type received from API: "$type"');
        print(
          'Type comparison - employee: ${type == 'employee'}, customer: ${type == 'customer'}, lead: ${type == 'lead'}',
        );

        await secureStorage.write(
          key: 'auth_token',
          value: loginResponse.data.token,
        );
        final appInit = AppInitialize();
        appInit.initProfile();

        try {
          // Force customer navigation for testing
          if (type == 'customer') {
            print('🎯 CUSTOMER TYPE DETECTED - Forcing customer navigation');
            print('🚀 About to navigate to customer home...');
            print('📍 Route: ${AppRoutes.homeScreenMain}');
            print('📦 Arguments: {"role": "customer"}');

            // Try navigation
            final result = Get.offAllNamed(
              AppRoutes.homeScreenMain,
              arguments: {'role': 'customer'},
            );
            print('✅ Customer navigation command sent, result: $result');
            return; // Exit early to avoid other conditions
          }

          if (type == 'employee') {
            print('✅ Navigating to employee home');
            Get.offAllNamed(
              AppRoutes.homeScreenMain,
              arguments: {'role': 'employee'},
            );
          } else {
            print('✅ Navigating to lead home (default for type: "$type")');
            Get.offAllNamed(
              AppRoutes.homeScreenMain,
              arguments: {'role': 'lead'},
            );
          }
        } catch (navError, navStack) {
          print('❌ Navigation error: $navError');
          print(navStack);
          CustomSnackbar.show(
            context,
            title: 'Navigation Error',
            message: navError.toString(),
          );
        }
      } else {
        CustomSnackbar.show(
          context,
          title: "Login Failed",
          message: "Login failed please try again",
        );
      }
    } catch (err, stacktrace) {
      print('Login method error: $err');
      print(stacktrace);
      CustomSnackbar.show(
        context,
        title: "Login Error",
        message: "Login failed please try again",
      );
    } finally {
      // Hide overlay loading and button loading
      LoadingService.to.hide();
      loading.value = false;
    }
  }
}
