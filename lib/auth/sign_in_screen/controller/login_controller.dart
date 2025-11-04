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
import '../otp_verification_screen.dart';
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
import '../otp_verification_screen.dart';
import '../../../widgets/success_dialog.dart';

class SignInController extends GetxController {
  var loading = false.obs;
  final ApiClient apiClient = ApiClient();
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  // Send OTP to phone number
  Future<void> sendOtp(String phone, BuildContext context) async {
    LoadingService.to.show(message: 'Sending OTP...');
    loading.value = true;

    try {
      print('📤 Sending OTP to: $phone');
      final response = await apiClient.sendOtp(phone);
      print('✅ OTP Response: $response');

      if (response['status'] == true) {
        CustomSnackbar.show(
          context,
          title: "OTP Sent",
          message: response['message'] ?? 'OTP sent successfully',
        );

        // Navigate to OTP verification screen
        Get.to(() => OtpVerificationScreen(phoneNumber: phone));
      } else {
        CustomSnackbar.show(
          context,
          title: "Error",
          message: response['message'] ?? 'Failed to send OTP',
        );
      }
    } catch (err, stacktrace) {
      print('❌ Send OTP error: $err');
      print(stacktrace);
      CustomSnackbar.show(
        context,
        title: "Error",
        message: err.toString().replaceAll('Exception: ', ''),
      );
    } finally {
      LoadingService.to.hide();
      loading.value = false;
    }
  }

  // ✅ Resend OTP for OTP Verification 2 screen
  Future<void> resendOtpforotpverification2(String phone, BuildContext context) async {
    LoadingService.to.show(message: 'Sending OTP...');
    loading.value = true;

    try {
      print('📤 Resending OTP to: $phone');
      final response = await apiClient.sendOtp(phone);
      print('✅ OTP Response: $response');

      if (response['status'] == true) {
        CustomSnackbar.show(
          context,
          title: "OTP Sent",
          message: response['message'] ?? 'OTP sent successfully',
          backgroundColor: Colors.green.shade600,
        );
      } else {
        CustomSnackbar.show(
          context,
          title: "Error",
          message: response['message'] ?? 'Failed to send OTP',
        );
      }
    } catch (err, stacktrace) {
      print('❌ Resend OTP error: $err');
      print(stacktrace);
      CustomSnackbar.show(
        context,
        title: "Error",
        message: err.toString().replaceAll('Exception: ', ''),
      );
    } finally {
      LoadingService.to.hide();
      loading.value = false;
    }
  }

  // ✅ FIXED: Verify OTP and login (with registration flow support)
// In login_controller.dart - verifyOtp method

// ✅ FIXED: Verify OTP and login (with registration flow support)
  Future<void> verifyOtp(
      String phone,
      String otp,
      BuildContext context,
      ) async {
    LoadingService.to.show(message: 'Verifying OTP...');
    loading.value = true;

    try {
      print('✅ Verifying OTP for: $phone with OTP: $otp');
      final loginResponse = await apiClient.verifyOtp(phone, otp);
      print('✅ Login Response: ${loginResponse.status}');

      if (loginResponse.status == true) {
        // ✅ Get user type FIRST (needed for both flows)
        final type = loginResponse.data.user.type;
        print('👤 User type: "$type"');

        // Save token
        await secureStorage.write(
          key: 'auth_token',
          value: loginResponse.data.token,
        );

        final appInit = AppInitialize();
        appInit.initializeControllers();

        // ✅ Determine role
        String roleArg;
        if (type == 'customer') {
          roleArg = 'customer';
          print('🎯 CUSTOMER TYPE DETECTED - Setting role to customer');
        } else if (type == 'employee') {
          roleArg = 'employee';
          print('✅ EMPLOYEE TYPE DETECTED - Setting role to employee');
        } else if (type == 'manager') {
          roleArg = 'manager';
          print('✅ MANAGER TYPE DETECTED - Setting role to manager');
        } else if (type == 'lead') {
          roleArg = 'lead';
          print('✅ LEAD TYPE DETECTED - Setting role to lead');
        } else {
          roleArg = 'employee';
          print('⚠️ UNKNOWN TYPE - Defaulting to employee role');
        }

        // ✅ Check if this is from registration
        final args = Get.arguments as Map<String, dynamic>?;
        final isRegistration = args?['isRegistration'] ?? false;

        print('🔍 isRegistration flag: $isRegistration');

        if (isRegistration) {
          // ✅ Show success dialog for registration WITH navigation to home
          print('🎉 Registration flow - showing success dialog');

          showSuccessDialog(
            title: 'Welcome! 🎉',
            message: 'Your account has been verified successfully. Let\'s get started!',
            onClose: () {
              // ✅ Navigate to home screen based on role
              print('🚀 Navigating to PERMISSION GATE with role: $roleArg');
              Get.offAllNamed(
                AppRoutes.permissionGate,
                arguments: {'role': roleArg},
              );
            },
          );
        } else {
          // ✅ Regular login flow - navigate to home directly
          print('🔐 Regular login flow - navigating to app');

          try {
            print('🚀 Navigating to PERMISSION GATE with role: $roleArg');

            final result = Get.offAllNamed(
              AppRoutes.permissionGate,
              arguments: {'role': roleArg},
            );

            print('✅ Navigation command sent, result: $result');
          } catch (navError, navStack) {
            print('❌ Navigation error: $navError');
            print(navStack);
            CustomSnackbar.show(
              context,
              title: 'Navigation Error',
              message: navError.toString(),
            );
          }
        }
      } else {
        CustomSnackbar.show(
          context,
          title: "Login Failed",
          message: "Invalid OTP. Please try again.",
        );
      }
    } catch (err, stacktrace) {
      print('❌ Verify OTP error: $err');
      print(stacktrace);
      CustomSnackbar.show(
        context,
        title: "Verification Error",
        message: err.toString().replaceAll('Exception: ', ''),
      );
    } finally {
      LoadingService.to.hide();
      loading.value = false;
    }
  }

  // Keep the old login method for backward compatibility if needed
  Future<void> login(
      String email,
      String password,
      BuildContext context,
      ) async {
    LoadingService.to.show(message: 'Signing you in...');
    loading.value = true;

    try {
      print('Starting login process');
      final loginResponse = await apiClient.login(email, password);
      print('Received loginResponse, status: ${loginResponse.status}');

      if (loginResponse.status == true) {
        final type = loginResponse.data.user.type;
        print('User type received from API: "$type"');

        await secureStorage.write(
          key: 'auth_token',
          value: loginResponse.data.token,
        );

        final appInit = AppInitialize();
        appInit.initializeControllers();

        try {
          String roleArg;

          if (type == 'customer') {
            roleArg = 'customer';
            print('🎯 CUSTOMER TYPE DETECTED - Setting role to customer');
          } else if (type == 'employee') {
            roleArg = 'employee';
            print('✅ EMPLOYEE TYPE DETECTED - Setting role to employee');
          } else if (type == 'manager') {
            roleArg = 'manager';
            print('✅ MANAGER TYPE DETECTED - Setting role to manager');
          } else if (type == 'lead') {
            roleArg = 'lead';
            print('✅ LEAD TYPE DETECTED - Setting role to lead');
          } else {
            roleArg = 'employee';
            print('⚠️ UNKNOWN TYPE - Defaulting to employee role');
          }

          print('🚀 About to navigate to PERMISSION GATE...');

          final result = Get.offAllNamed(
            AppRoutes.permissionGate,
            arguments: {'role': roleArg},
          );

          print('✅ Permission gate navigation command sent, result: $result');
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
      LoadingService.to.hide();
      loading.value = false;
    }
  }
}


/*





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
        appInit.initializeControllers();

        try {
          // Map API type to role argument
          String roleArg;

          if (type == 'customer') {
            roleArg = 'customer';
            print('🎯 CUSTOMER TYPE DETECTED - Setting role to customer');
          } else if (type == 'employee') {
            roleArg = 'employee';
            print('✅ EMPLOYEE TYPE DETECTED - Setting role to employee');
          } else if (type == 'manager') {
            roleArg = 'manager';
            print('✅ MANAGER TYPE DETECTED - Setting role to manager');
          } else if (type == 'lead') {
            roleArg = 'lead';
            print('✅ LEAD TYPE DETECTED - Setting role to lead');
          } else {
            roleArg = 'employee'; // Default fallback
            print('⚠️ UNKNOWN TYPE - Defaulting to employee role');
          }

          print('🚀 About to navigate to PERMISSION GATE...');
          print('📍 Route: ${AppRoutes.permissionGate}');
          print('📦 Arguments: {"role": "$roleArg"}');

          // Navigate to permission gate (NOT directly to home)
          final result = Get.offAllNamed(
            AppRoutes.permissionGate,
            arguments: {'role': roleArg},
          );

          print('✅ Permission gate navigation command sent, result: $result');

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

*/
