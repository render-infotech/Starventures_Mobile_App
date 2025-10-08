// lib/controllers/application_history_controller.dart
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../core/data/api_client/api_client.dart';
import '../../../core/utils/custom_snackbar.dart';
import '../model/application_history_model.dart';

class ApplicationHistoryController extends GetxController {
  final ApiClient _apiClient = ApiClient();

  // Observable variables
  var isLoading = false.obs;
  var actionController = TextEditingController();
  var remarksController = TextEditingController();
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Set default action
    actionController.text = 'Status Changed';
  }

  @override
  void onClose() {
    actionController.dispose();
    remarksController.dispose();
    super.onClose();
  }

  // Method to update application history
  Future<bool> updateApplicationHistory(String applicationId) async {
    if (actionController.text.trim().isEmpty) {
      errorMessage('Action cannot be empty');
      return false;
    }

    if (remarksController.text.trim().isEmpty) {
      errorMessage('Remarks cannot be empty');
      return false;
    }

    try {
      isLoading(true);
      errorMessage('');

      final request = ApplicationHistoryRequest(
        action: actionController.text.trim(),
        remarks: remarksController.text.trim(),
      );

      final response = await _apiClient.postApplicationHistory(applicationId, request);

      if (response.success) {
        // Clear form after successful update
        clearForm();

        return true;
      } else {
        errorMessage(response.message);
        return false;
      }
    } catch (e) {
      errorMessage('Failed to update application history: $e');
      print('Error updating application history: $e');
      return false;
    } finally {
      isLoading(false);
    }
  }

  // Method to clear form
  void clearForm() {
    actionController.text = 'Status Changed'; // Reset to default
    remarksController.clear();
    errorMessage('');
  }

  // Method to reset form to default values
  void resetForm() {
    clearForm();
  }
}
