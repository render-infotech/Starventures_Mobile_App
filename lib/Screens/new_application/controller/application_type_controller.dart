// lib/controllers/application_type_controller.dart
import 'package:get/get.dart';
import '../../../core/data/api_client/api_client.dart';
import '../model/application_type_model.dart';

class ApplicationTypeController extends GetxController {
  final ApiClient _apiClient = ApiClient();

  // Observable variables
  var isLoading = false.obs;
  var applicationTypes = <ApplicationTypeModel>[].obs;
  var selectedApplicationType = Rx<ApplicationTypeModel?>(null);
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchApplicationTypes();
  }

  // Fetch application types from API
  Future<void> fetchApplicationTypes() async {
    try {
      isLoading(true);
      errorMessage('');
      final response = await _apiClient.fetchApplicationTypes();
      if (response.success) {
        applicationTypes.assignAll(response.data);
        // DO NOT set first item as default - keep hint text visible
        // selectedApplicationType.value remains null
      } else {
        errorMessage(response.message);
      }
    } catch (e) {
      errorMessage('Failed to fetch application types: $e');
      print('Error fetching application types: $e');
    } finally {
      isLoading(false);
    }
  }

  // Method to select application type
  void selectApplicationType(ApplicationTypeModel? type) {
    selectedApplicationType.value = type;
  }

  // Get selected application type ID
  int? getSelectedApplicationTypeId() {
    return selectedApplicationType.value?.id;
  }

  // Get selected application type name
  String? getSelectedApplicationTypeName() {
    return selectedApplicationType.value?.name;
  }

  // Method to clear selection (reset to hint)
  void clearSelection() {
    selectedApplicationType.value = null;
  }

  // Method to refresh data
  Future<void> refreshApplicationTypes() async {
    await fetchApplicationTypes();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
