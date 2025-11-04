import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:starcapitalventures/app_export/app_export.dart';
import '../../../core/data/api_client/api_client.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:starcapitalventures/app_export/app_export.dart';
import '../../../core/data/api_client/api_client.dart';
import '../../../widgets/success_dialog.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:starcapitalventures/app_export/app_export.dart';
import '../../../core/data/api_client/api_client.dart';
import '../../../widgets/success_dialog.dart';

class UpdatePasswordController extends GetxController {
  final ApiClient _apiClient = ApiClient();

  // Observable states
  final loading = false.obs;

  // Text editing controllers
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Password visibility toggles
  final showCurrentPassword = false.obs;
  final showNewPassword = false.obs;
  final showConfirmPassword = false.obs;

  @override
  void onClose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void toggleCurrentPasswordVisibility() {
    showCurrentPassword.value = !showCurrentPassword.value;
  }

  void toggleNewPasswordVisibility() {
    showNewPassword.value = !showNewPassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    showConfirmPassword.value = !showConfirmPassword.value;
  }

  // Helper method to convert technical errors to user-friendly messages
  String _getUserFriendlyMessage(String errorMessage) {
    final lowerError = errorMessage.toLowerCase();

    // Map technical/API errors to user-friendly messages
    if (lowerError.contains('confirm password') && lowerError.contains('must match')) {
      return 'Your new password and confirm password don\'t match. Please make sure they are the same.';
    } else if (lowerError.contains('current password') && (lowerError.contains('incorrect') || lowerError.contains('wrong'))) {
      return 'The current password you entered is incorrect. Please try again.';
    } else if (lowerError.contains('password') && lowerError.contains('length')) {
      return 'Your new password is too short. Please use at least 8 characters.';
    } else if (lowerError.contains('password') && lowerError.contains('weak')) {
      return 'Please choose a stronger password with letters, numbers, and special characters.';
    } else if (lowerError.contains('same') || lowerError.contains('identical')) {
      return 'Your new password cannot be the same as your current password.';
    } else if (lowerError.contains('unauthorized') || lowerError.contains('401')) {
      return 'Your session has expired. Please log in again.';
    } else if (lowerError.contains('network') || lowerError.contains('connection')) {
      return 'Unable to connect. Please check your internet connection and try again.';
    } else if (lowerError.contains('timeout')) {
      return 'The request took too long. Please try again.';
    } else if (lowerError.contains('server') || lowerError.contains('500')) {
      return 'Something went wrong on our end. Please try again in a few moments.';
    } else {
      // Return the original error message if no pattern matches
      return errorMessage.isNotEmpty
          ? errorMessage
          : 'We couldn\'t update your password. Please try again.';
    }
  }

  bool _validatePasswords() {
    final currentPwd = currentPasswordController.text.trim();
    final newPwd = newPasswordController.text.trim();
    final confirmPwd = confirmPasswordController.text.trim();

    if (currentPwd.isEmpty) {
      Get.snackbar(
        'Required Field',
        'Please enter your current password',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: appTheme.theme,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return false;
    }

    if (newPwd.isEmpty) {
      Get.snackbar(
        'Required Field',
        'Please enter your new password',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: appTheme.theme,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return false;
    }

    if (newPwd.length < 8) {
      Get.snackbar(
        'Password Too Short',
        'Your new password must be at least 8 characters long',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: appTheme.theme,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return false;
    }

    if (confirmPwd.isEmpty) {
      Get.snackbar(
        'Required Field',
        'Please confirm your new password',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: appTheme.theme,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return false;
    }

    if (newPwd != confirmPwd) {
      Get.snackbar(
        'Passwords Don\'t Match',
        'Your new password and confirm password must be the same',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: appTheme.theme,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return false;
    }

    if (currentPwd == newPwd) {
      Get.snackbar(
        'Same Password',
        'Your new password must be different from your current password',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: appTheme.theme,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return false;
    }

    return true;
  }

  Future<void> submitUpdatePassword() async {
    if (!_validatePasswords()) return;

    loading.value = true;

    try {
      final response = await _apiClient.updatePassword(
        currentPassword: currentPasswordController.text.trim(),
        newPassword: newPasswordController.text.trim(),
        confirmPassword: confirmPasswordController.text.trim(),
      );

      loading.value = false;

      print('✅ Response success: ${response.success}');
      print('✅ Response message: ${response.message}');

      // Check if status is true (success)
      if (response.success == true) {
        // Clear all fields first
        currentPasswordController.clear();
        newPasswordController.clear();
        confirmPasswordController.clear();

        // Show success dialog
        showSuccessDialog(
          title: 'Password Updated!',
          message: response.message.isNotEmpty
              ? response.message
              : 'Your password has been updated successfully.',
          onClose: () {
            // Navigate back to profile screen after dialog closes
            Get.back(); // This closes the update password screen
          },
        );
      } else {
        // Handle unsuccessful response (status: false)
        final friendlyMessage = _getUserFriendlyMessage(
          response.message.isNotEmpty ? response.message : 'Failed to update password',
        );

        Get.snackbar(
          'Unable to Update',
          friendlyMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: appTheme.theme,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      loading.value = false;
      print('❌ Error updating password: $e');

      // Convert exception message to user-friendly format
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      final friendlyMessage = _getUserFriendlyMessage(errorMessage);

      Get.snackbar(
        'Update Failed',
        friendlyMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: appTheme.theme,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      );
    }
  }
}
