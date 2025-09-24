import 'package:get/get.dart';
import '../utils/loading_service.dart'; // Adjust path as needed
// Import other services you want to initialize

class AppBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize global services that should live throughout the app
    Get.put(LoadingService(), permanent: true);

  }
}
