// lib/Screens/new_application/controller/employee_controller.dart

import 'package:get/get.dart';
import '../../../core/data/api_client/api_client.dart';
import '../model/employee_model.dart';

class EmployeeController extends GetxController {
  final ApiClient _apiClient = ApiClient();

  var isLoading = false.obs;
  var employees = <EmployeeModel>[].obs;
  var selectedEmployee = Rx<EmployeeModel?>(null);
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchEmployees();
  }

  Future<void> fetchEmployees() async {
    try {
      isLoading(true);
      errorMessage('');

      final response = await _apiClient.fetchEmployeesByBranch();

      if (response.success) {
        employees.assignAll(response.data);
        print('✅ Fetched ${employees.length} employees');
      } else {
        errorMessage(response.message);
        print('❌ Failed to fetch employees: ${response.message}');
      }
    } catch (e) {
      errorMessage('Failed to load employees: $e');
      print('❌ Error fetching employees: $e');
    } finally {
      isLoading(false);
    }
  }

  void selectEmployee(EmployeeModel? employee) {
    selectedEmployee.value = employee;
    print('✅ Selected employee: ${employee?.name}');
  }

  int? getSelectedEmployeeId() {
    return selectedEmployee.value?.id;
  }

  Future<void> refreshEmployees() async {
    await fetchEmployees();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
