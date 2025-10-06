import 'package:flutter/foundation.dart';
import '../../applications/model/application_model.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../core/data/api_client/api_client.dart';
import '../../../core/data/api_constant/api_constant.dart';
import '../model/application_detail_model.dart';

class ApplicationDetailController extends GetxController {
  final ApiClient _apiClient = ApiClient();

  // Observable variables
  var isLoading = false.obs;
  var applicationDetail = Rxn<ApplicationDetailData>();
  var errorMessage = ''.obs;
  var hasError = false.obs;

  // Fetch application detail from API
  Future<void> fetchApplicationDetail(String applicationId) async {
    try {
      isLoading(true);
      hasError(false);
      errorMessage('');

      final token = await _apiClient.getAuthToken();
      if (token == null || token.isEmpty) {
        throw Exception('No authentication token found');
      }

      final url = ApiConstants.getApplicationDetails(applicationId);
      print('Fetching application detail from: $url'); // Debug log

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
        final detailResponse = ApplicationDetailResponse.fromJson(jsonData);
        applicationDetail.value = detailResponse.data;

        print('Successfully loaded application detail for ID: $applicationId');

      } else {
        throw Exception('Server error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      hasError(true);
      errorMessage('Failed to fetch application detail: ${e.toString()}');
      print('Error fetching application detail: $e');
    } finally {
      isLoading(false);
    }
  }

  // Refresh application detail
  Future<void> refreshApplicationDetail(String applicationId) async {
    await fetchApplicationDetail(applicationId);
  }
}
