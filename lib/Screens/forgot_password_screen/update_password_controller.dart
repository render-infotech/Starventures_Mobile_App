import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/data/api_client/api_client.dart';

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

  bool _validatePasswords() {
    final currentPwd = currentPasswordController.text.trim();
    final newPwd = newPasswordController.text.trim();
    final confirmPwd = confirmPasswordController.text.trim();

    if (currentPwd.isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please enter your current password',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      return false;
    }

    if (newPwd.isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please enter your new password',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      return false;
    }

    if (newPwd.length < 8) {
      Get.snackbar(
        'Validation Error',
        'New password must be at least 8 characters long',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      return false;
    }

    if (confirmPwd.isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please confirm your new password',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      return false;
    }

    if (newPwd != confirmPwd) {
      Get.snackbar(
        'Validation Error',
        'New password and confirm password do not match',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      return false;
    }

    if (currentPwd == newPwd) {
      Get.snackbar(
        'Validation Error',
        'New password must be different from current password',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withOpacity(0.8),
        colorText: Colors.white,
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

      if (response.success) {
        Get.snackbar(
          'Success',
          response.message.isNotEmpty
              ? response.message
              : 'Password updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );

        // Clear all fields
        currentPasswordController.clear();
        newPasswordController.clear();
        confirmPasswordController.clear();

        // Navigate back after a short delay
        await Future.delayed(const Duration(seconds: 2));
        Get.back();
      } else {
        Get.snackbar(
          'Error',
          response.message.isNotEmpty
              ? response.message
              : 'Failed to update password',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('❌ Error updating password: $e');
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } finally {
      loading.value = false;
    }
  }
}
