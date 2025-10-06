import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../core/data/api_client/api_client.dart';
import '../../../core/data/api_constant/api_constant.dart';

import '../model/application_model.dart' show Application, ApplicationResponse, ApplicationStatus;

import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../core/data/api_client/api_client.dart';
import '../../../core/data/api_constant/api_constant.dart';
import '../model/application_model.dart';

class ApplicationListController extends GetxController {
  final ApiClient _apiClient = ApiClient();

  // Observable variables
  var isLoading = false.obs;
  var applications = <Application>[].obs;
  var errorMessage = ''.obs;
  var hasError = false.obs;

  // Pagination variables
  var currentPage = 1.obs;
  var hasNextPage = false.obs;
  var totalApplications = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchApplications();
  }

  // Fetch applications from API
  Future<void> fetchApplications({int page = 1}) async {
    try {
      if (page == 1) {
        isLoading(true);
        applications.clear();
      }

      hasError(false);
      errorMessage('');

      final token = await _apiClient.getAuthToken();
      if (token == null || token.isEmpty) {
        throw Exception('No authentication token found');
      }

      // Add page parameter to the URL
      final url = page == 1
          ? ApiConstants.getApplciations
          : '${ApiConstants.getApplciations}?page=$page';

      print('Fetching from URL: $url'); // Debug log

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Response status: ${response.statusCode}'); // Debug log
      print('Response body: ${response.body}'); // Debug log

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final applicationResponse = ApplicationResponse.fromJson(jsonData);

        if (page == 1) {
          applications.value = applicationResponse.data;
        } else {
          applications.addAll(applicationResponse.data);
        }

        // Update pagination info
        currentPage.value = applicationResponse.meta.currentPage;
        hasNextPage.value = applicationResponse.meta.currentPage < applicationResponse.meta.lastPage;
        totalApplications.value = applicationResponse.meta.total;

        print('Successfully loaded ${applicationResponse.data.length} applications');

      } else {
        throw Exception('Server error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      hasError(true);
      errorMessage('Failed to fetch applications: ${e.toString()}');
      print('Error fetching applications: $e');
    } finally {
      if (page == 1) {
        isLoading(false);
      }
    }
  }

  // Load next page
  Future<void> loadNextPage() async {
    if (hasNextPage.value && !isLoading.value) {
      await fetchApplications(page: currentPage.value + 1);
    }
  }

  // Refresh applications
  Future<void> refreshApplications() async {
    currentPage.value = 1;
    await fetchApplications(page: 1);
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
}
