// lib/Screens/lead_detail/lead_detail_controller.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../core/data/api_client/api_client.dart';
import '../../core/data/api_constant/api_constant.dart';
import '../../core/utils/appTheme/app_theme.dart';
import 'lead_detail_model.dart';

class LeadDetailController extends GetxController {
  final ApiClient _apiClient = ApiClient();

  // Observable variables
  var isLoading = false.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;
  var leadDetail = Rxn<LeadDetail>();
  var isUpdating = false.obs; // ✅ Add this for update loading state

  // Fetch lead detail by ID
  Future<void> fetchLeadDetail(String leadId) async {
    try {
      isLoading(true);
      hasError(false);
      errorMessage('');

      final response = await _apiClient.fetchLeadDetail(leadId);

      // Directly assign the lead from response
      leadDetail.value = response.lead;

      print('Lead loaded successfully: ${leadDetail.value?.name}');

    } catch (e) {
      hasError(true);
      errorMessage('Error loading lead: $e');
      print('Error fetching lead detail: $e');
    } finally {
      isLoading(false);
    }
  }

  // ✅ NEW: Update lead method
  Future<bool> updateLead({
    required String name,
    required String phone,
    required String notes,
  }) async {
    try {
      isUpdating(true);
      hasError(false);
      errorMessage('');

      final leadId = leadDetail.value?.id.toString();
      if (leadId == null) {
        throw Exception('Lead ID not found');
      }

      final token = await _apiClient.getAuthToken();
      if (token == null || token.isEmpty) {
        throw Exception('No authentication token found');
      }

      final url = ApiConstants.updateLead(leadId);
      print('📤 Updating lead at: $url');

      final payload = {
        'name': name,
        'phone': phone,
        'notes': notes,
      };

      print('📤 Payload: $payload');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: jsonEncode(payload),
      );

      print('📥 Update response status: ${response.statusCode}');
      print('📥 Update response body: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ Lead updated successfully');

        // Refresh lead detail to get updated data
        await fetchLeadDetail(leadId);

        return true;
      } else {
        // Try to parse error message from response
        try {
          final jsonData = jsonDecode(response.body);
          final errorMsg = jsonData['message'] ?? 'Failed to update lead';
          throw Exception(errorMsg);
        } catch (e) {
          throw Exception('Failed to update lead. Status: ${response.statusCode}');
        }
      }
    } catch (e) {
      hasError(true);
      errorMessage('Failed to update lead: ${e.toString()}');
      print('❌ Error updating lead: $e');

      // Show error snackbar
      Get.snackbar(
        'Update Failed',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: appTheme.theme,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        icon: Icon(Icons.error_outline, color: Colors.white),
      );

      return false;
    } finally {
      isUpdating(false);
    }
  }

  // Refresh lead detail
  Future<void> refreshLeadDetail(String leadId) async {
    await fetchLeadDetail(leadId);
  }
}
