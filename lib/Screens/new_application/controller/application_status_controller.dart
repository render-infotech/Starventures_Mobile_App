// lib/controllers/application_status_controller.dart
import 'package:get/get.dart';
import '../../../core/data/api_client/api_client.dart';
import '../model/application_status_model.dart';

class ApplicationStatusController extends GetxController {
  final ApiClient _apiClient = ApiClient();

  // Observable variables
  var isLoading = false.obs;
  var applicationStatuses = <ApplicationStatusModel>[].obs;
  var selectedApplicationStatus = Rx<ApplicationStatusModel?>(null);
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchApplicationStatuses();
  }

  // Fetch application statuses from API
  Future<void> fetchApplicationStatuses() async {
    try {
      isLoading(true);
      errorMessage('');
      final response = await _apiClient.fetchApplicationStatuses();
      if (response.success) {
        applicationStatuses.assignAll(response.data);
        // DO NOT set first item as default - keep hint text visible
        // selectedApplicationStatus.value remains null
      } else {
        errorMessage(response.message);
      }
    } catch (e) {
      errorMessage('Failed to fetch application statuses: $e');
      print('Error fetching application statuses: $e');
    } finally {
      isLoading(false);
    }
  }

  // Method to select application status
  void selectApplicationStatus(ApplicationStatusModel? status) {
    selectedApplicationStatus.value = status;
  }

  // Get selected application status ID
  int? getSelectedApplicationStatusId() {
    return selectedApplicationStatus.value?.id;
  }

  // Get selected application status name
  String? getSelectedApplicationStatusName() {
    return selectedApplicationStatus.value?.name;
  }

  // Method to clear selection (reset to hint)
  void clearSelection() {
    selectedApplicationStatus.value = null;
  }

  // Method to refresh data
  Future<void> refreshApplicationStatuses() async {
    await fetchApplicationStatuses();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
