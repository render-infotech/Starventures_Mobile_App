// lib/Screens/Leads/controller/leads_controller.dart

import 'package:get/get.dart';
import '../../../core/data/api_client/api_client.dart';
import 'lead_model.dart';


// lib/Screens/Leads/controller/leads_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/data/api_client/api_client.dart';
import '../../../app_export/app_export.dart';
import 'lead_model.dart';
// lib/Screens/Leads/controller/leads_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/data/api_client/api_client.dart';
import '../../../app_export/app_export.dart';
import 'lead_model.dart';

class LeadsController extends GetxController {
  final ApiClient _apiClient = ApiClient();

  // Observable variables
  var isLoading = false.obs;
  var leads = <LeadModel>[].obs;
  var meta = Rx<LeadMeta?>(null);
  var errorMessage = ''.obs;
  var hasError = false.obs;

  // Track which lead is being deleted by ID
  var deletingLeadId = Rx<String?>(null);

  @override
  void onInit() {
    super.onInit();
    fetchLeads();
  }

  // Check if a specific lead is being deleted
  bool isDeletingLead(String leadId) {
    return deletingLeadId.value == leadId;
  }

  // Fetch leads from API
  Future<void> fetchLeads() async {
    try {
      isLoading(true);
      hasError(false);
      errorMessage('');

      final response = await _apiClient.fetchLeads();
      leads.assignAll(response.data);
      meta.value = response.meta;

      print('✅ Fetched ${leads.length} leads');
      print('📊 Meta - Total: ${meta.value?.total}, Converted: ${meta.value?.converted}');
    } catch (e) {
      hasError(true);
      errorMessage('Unable to load leads');
      print('❌ Error fetching leads: $e');
    } finally {
      isLoading(false);
    }
  }

  // Refresh leads
  Future<void> refreshLeads() async {
    await fetchLeads();
  }

  // Delete lead with confirmation dialog
  Future<void> deleteLead(BuildContext context, String leadId, String leadName) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: appTheme.red600, size: 28),
              const SizedBox(width: 12),
              const Text('Delete Lead?'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to delete this lead?',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.person_outline, color: Colors.grey.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        leadName,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'This action cannot be undone.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: appTheme.red600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    // If user confirmed, proceed with deletion
    if (confirmed == true) {
      await _performDelete(leadId);
    }
  }

  // Perform the actual delete operation
  Future<void> _performDelete(String leadId) async {
    try {
      // Set this specific lead as being deleted
      deletingLeadId.value = leadId;

      final response = await _apiClient.deleteLead(leadId);

      if (response.success) {
        // Remove lead from list immediately (optimistic update)
        leads.removeWhere((lead) => lead.id.toString() == leadId);

        // Show success message
        Get.snackbar(
          'Success',
          response.message.isNotEmpty
              ? response.message
              : 'Lead deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: appTheme.theme,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        );

        // Refresh leads list from server to sync
        await fetchLeads();
      } else {
        Get.snackbar(
          'Error',
          response.message.isNotEmpty
              ? response.message
              : 'Failed to delete lead',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: appTheme.red600,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      print('❌ Error deleting lead: $e');

      final errorMessage = e.toString().replaceAll('Exception: ', '');

      Get.snackbar(
        'Delete Failed',
        errorMessage.isNotEmpty
            ? errorMessage
            : 'Unable to delete lead. Please try again',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: appTheme.theme,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      );
    } finally {
      // Clear the deleting state
      deletingLeadId.value = null;
    }
  }

  // Filter leads by status
  List<LeadModel> getLeadsByStatus(String statusName) {
    return leads
        .where((lead) =>
    lead.status.name.toLowerCase() == statusName.toLowerCase())
        .toList();
  }

  // Get stats
  int get totalCount => meta.value?.total ?? 0;
  int get convertedCount => meta.value?.converted ?? 0;
  int get inProgressCount => meta.value?.inProgress ?? 0;
  int get lostCount => meta.value?.lost ?? 0;

  @override
  void onClose() {
    super.onClose();
  }
}
