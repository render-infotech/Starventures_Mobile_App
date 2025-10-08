// lib/controllers/action_history_controller.dart
import 'package:get/get.dart';
import '../../../core/data/api_client/api_client.dart';
import '../model/action_history_model.dart';

class ActionHistoryController extends GetxController {
  final ApiClient _apiClient = ApiClient();

  // Observable variables
  var isLoading = false.obs;
  var actionHistory = <ActionHistoryItem>[].obs;
  var errorMessage = ''.obs;
  var hasError = false.obs;

  // Fetch action history for an application
  Future<void> fetchActionHistory(String applicationId) async {
    try {
      isLoading(true);
      hasError(false);
      errorMessage('');

      final response = await _apiClient.fetchApplicationHistory(applicationId);

      if (response.success || response.data.isNotEmpty) {
        // Sort by created_at in descending order (most recent first)
        final sortedData = response.data..sort((a, b) =>
            DateTime.parse(b.createdAt).compareTo(DateTime.parse(a.createdAt)));

        actionHistory.assignAll(sortedData);
      } else {
        hasError(true);
        errorMessage(response.message.isEmpty ? 'Failed to load action history' : response.message);
      }
    } catch (e) {
      hasError(true);
      errorMessage('Failed to fetch action history: $e');
      print('Error fetching action history: $e');
    } finally {
      isLoading(false);
    }
  }

  // Refresh action history
  Future<void> refreshActionHistory(String applicationId) async {
    await fetchActionHistory(applicationId);
  }

  @override
  void onClose() {
    super.onClose();
  }
}
