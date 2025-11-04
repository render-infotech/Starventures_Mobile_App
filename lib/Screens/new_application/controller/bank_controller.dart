// lib/Screens/new_application/controller/bank_controller.dart

import 'package:get/get.dart';
import '../../../../../core/data/api_client/api_client.dart';
import '../model/bank_model.dart';

class BankController extends GetxController {
  final ApiClient apiClient = ApiClient();

  // Observable variables
  var isLoading = false.obs;
  var banks = <BankModel>[].obs;
  var selectedBank = Rx<BankModel?>(null);

  @override
  void onInit() {
    super.onInit();
    fetchBanks();
  }

  /// Fetch banks from API
  Future<void> fetchBanks() async {
    try {
      isLoading(true);
      print('🏦 Fetching banks...');

      final response = await apiClient.fetchBanks();

      if (response.success) {
        banks.value = response.data;
        print('✅ Banks fetched successfully: ${banks.length} banks');
      } else {
        print('❌ Failed to fetch banks: ${response.message}');
      }
    } catch (e) {
      print('❌ Error fetching banks: $e');
    } finally {
      isLoading(false);
    }
  }

  /// Select a bank
  void selectBank(BankModel? bank) {
    selectedBank.value = bank;
    print('🏦 Selected bank: ${bank?.name} (ID: ${bank?.id})');
  }

  /// Get selected bank ID
  int? getSelectedBankId() {
    return selectedBank.value?.id;
  }

  /// Clear selection
  void clearSelection() {
    selectedBank.value = null;
  }
}
