// app_initialize.dart
import 'package:get/get.dart';
import '../../Screens/profile/controller/profile_controller.dart';
// lib/core/app_initialize.dart
import 'package:get/get.dart';
import '../../Screens/profile/controller/profile_controller.dart';
import '../../Screens/new_application/controller/application_type_controller.dart';
import '../../Screens/home_screen/controller/home_controller.dart';

class AppInitialize {
  late ProfileController profileController;
  late ApplicationTypeController applicationTypeController;
  late HomeController homeController;

  void initializeControllers() {
    // Initialize Profile Controller
    initProfile();

    // Initialize Application Type Controller
    initApplicationTypes();

    // Initialize Home Controller (if needed globally)
    initHomeController();
  }

  void initProfile() {
    // Ensure a single instance is available across the app
    profileController = Get.put(ProfileController(), permanent: true);

    // Load the profile asynchronously
    profileController.loadProfile();
    profileController.loadRelationshipManager();
  }

  void initApplicationTypes() {
    // Ensure a single instance is available across the app
    applicationTypeController = Get.put(ApplicationTypeController(), permanent: true);

    // Fetch application types asynchronously
    applicationTypeController.fetchApplicationTypes();
  }

  void initHomeController() {
    // Only initialize if needed globally
    // Otherwise, let screens initialize it when needed
    if (!Get.isRegistered<HomeController>()) {
      homeController = Get.put(HomeController(), permanent: true);
    }
  }

}
