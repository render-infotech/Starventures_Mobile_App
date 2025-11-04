// lib/Screens/applications/controller/application_controller.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../core/data/api_client/api_client.dart';
import '../../../core/data/api_constant/api_constant.dart';
import '../model/application_model.dart';

class ApplicationListController extends GetxController {
  final ApiClient _apiClient = ApiClient();

  // Observable variables
  var isLoading = false.obs;
  var isLoadingMore = false.obs;
  var applications = <Application>[].obs;
  var errorMessage = ''.obs;
  var hasError = false.obs;
  var isDeleting = false.obs;

  // Pagination variables
  var currentPage = 1.obs;
  var hasNextPage = false.obs;
  var totalApplications = 0.obs;
  String? nextPageUrl;

  bool _isDisposed = false;

  @override
  void onInit() {
    super.onInit();
    print('📱 ApplicationListController initialized');
  }

  List<Application> get recentApplications {
    if (applications.isEmpty) return [];
    return applications.take(3).toList();
  }

  Future<void> fetchApplications({bool isFirstPage = true}) async {
    try {
      if (isFirstPage) {
        isLoading(true);
        applications.clear();
        currentPage.value = 1;
        nextPageUrl = null;
        print('🔄 Fetching first page of applications');
      }

      hasError(false);
      errorMessage('');

      final token = await _apiClient.getAuthToken();
      if (token == null || token.isEmpty) {
        throw Exception('No authentication token found');
      }

      final url = ApiConstants.getApplciations;
      print('📤 Fetching from URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final applicationResponse = ApplicationResponse.fromJson(jsonData);

        // ✅ Use assignAll like Leads controller
        applications.assignAll(applicationResponse.data);

        // Update pagination info
        currentPage.value = applicationResponse.meta.currentPage;
        nextPageUrl = applicationResponse.links.next;
        hasNextPage.value = nextPageUrl != null;
        totalApplications.value = applicationResponse.meta.total;

        print('✅ Successfully loaded ${applicationResponse.data.length} applications');

      } else {
        print('❌ Server returned error: ${response.statusCode}');
        throw Exception('Server error: ${response.statusCode}');
      }

    } catch (e, stackTrace) {
      hasError(true);
      errorMessage('Failed to fetch applications: ${e.toString()}');
      print('❌ Error fetching applications: $e');
      print('❌ Stack trace: $stackTrace');
    } finally {
      isLoading(false);
    }
  }

  // ✅ FIXED: Delete application - EXACT SAME AS LEADS!
  Future<bool> deleteApplication(String applicationId) async {
    try {
      isDeleting(true);
      print('🗑️ Deleting application: $applicationId');

      final token = await _apiClient.getAuthToken();
      if (token == null || token.isEmpty) {
        throw Exception('No authentication token found');
      }

      final url = ApiConstants.deleteApplication(applicationId);
      print('📤 DELETE request to: $url');

      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print('📥 Delete response status: ${response.statusCode}');
      print('📥 Delete response body: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ Application deleted successfully');

        // ✅ EXACT SAME AS LEADS - Remove from list immediately
        applications.removeWhere((app) => app.id == applicationId);
        totalApplications.value = totalApplications.value - 1;

        print('✅ List updated, remaining applications: ${applications.length}');

        return true;
      } else {
        try {
          final jsonData = jsonDecode(response.body);
          final errorMsg = jsonData['message'] ?? 'Failed to delete application';
          throw Exception(errorMsg);
        } catch (e) {
          throw Exception('Server error: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('❌ Error deleting application: $e');

      Get.snackbar(
        'Delete Failed',
        'Failed to delete application: ${e.toString().replaceAll('Exception: ', '')}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        duration: const Duration(seconds: 3),
        icon: Icon(Icons.error_outline, color: Colors.red.shade900),
      );

      return false;
    } finally {
      isDeleting(false);
    }
  }

  // Load next page
  Future<void> loadNextPage() async {
    if (!hasNextPage.value || isLoadingMore.value || nextPageUrl == null) {
      return;
    }

    try {
      isLoadingMore(true);
      print('⏳ Loading next page from: $nextPageUrl');

      final token = await _apiClient.getAuthToken();
      if (token == null || token.isEmpty) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse(nextPageUrl!),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final applicationResponse = ApplicationResponse.fromJson(jsonData);

        applications.addAll(applicationResponse.data);

        currentPage.value = applicationResponse.meta.currentPage;
        nextPageUrl = applicationResponse.links.next;
        hasNextPage.value = nextPageUrl != null;

        print('✅ Successfully loaded next page');
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }

    } catch (e) {
      print('❌ Error loading next page: $e');
    } finally {
      isLoadingMore(false);
    }
  }

  // Refresh applications
  Future<void> refreshApplications() async {
    print('🔄 Refreshing applications list');
    await fetchApplications(isFirstPage: true);
  }

  // Get applications by status
  List<Application> getApplicationsByStatus(String status) {
    return applications.where((app) =>
    app.status.toLowerCase() == status.toLowerCase()).toList();
  }

  // Get approved applications count
  int get approvedCount => applications.where((app) =>
  app.statusEnum == ApplicationStatus.approved).length;

  // Get pending applications count
  int get pendingCount => applications.where((app) =>
  app.statusEnum == ApplicationStatus.pending).length;

  // Get processing applications count
  int get processingCount => applications.where((app) =>
  app.statusEnum == ApplicationStatus.processing).length;

  // Get rejected applications count
  int get rejectedCount => applications.where((app) =>
  app.statusEnum == ApplicationStatus.rejected).length;

  @override
  void onClose() {
    _isDisposed = true;
    print('🔴 ApplicationListController disposed');
    super.onClose();
  }
}

class ApplicationHelper {
  // ✅ Call this after creating/updating/deleting applications
  static Future<void> refreshApplicationsList() async {
    if (Get.isRegistered<ApplicationListController>()) {
      final controller = Get.find<ApplicationListController>();
      await controller.refreshApplications();
      print('🔄 Applications list refreshed');
    } else {
      print('⚠️ ApplicationListController not found');
    }
  }
}