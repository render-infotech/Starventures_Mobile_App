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

  Future<void> login(String email, String password, BuildContext context) async {
    // Show overlay loading
    LoadingService.to.show(message: 'Signing you in...');

    // Set button loading state
    loading.value = true;

    try {
      print('Starting login process');
      final loginResponse = await apiClient.login(email, password);
      print('Received loginResponse, status: ${loginResponse.status}');

      // in SignInController.login(...)
      if (loginResponse.status == true) {
        final type = loginResponse.data.user.type?.toString().toLowerCase() ?? '';
        await secureStorage.write(key: 'auth_token', value: loginResponse.data.token);

        final appInit = AppInitialize();
        appInit.initProfile();

        // map API type -> role argument
        // SignInController: success branch
        final rawType = loginResponse.data.user.type?.toString().toLowerCase() ?? '';
        String roleArg;
        switch (rawType) {
          case 'manager':  roleArg = 'manager'; break;
          case 'employee': roleArg = 'employee'; break;
          case 'customer': roleArg = 'customer'; break;
          case 'lead':     roleArg = 'lead';     break;
          default:         roleArg = 'employee'; // never 'lead'
        }
        Get.offAllNamed(AppRoutes.homeScreenMain, arguments: {'role': roleArg});

      } else {
        CustomSnackbar.show(context, title: "Login Failed", message: "Login failed please try again");
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
