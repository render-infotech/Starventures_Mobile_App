// app_initialize.dart
import 'package:get/get.dart';
import '../../Screens/profile/controller/profile_controller.dart';

class AppInitialize {
  late ProfileController profileController;

  void initProfile() {
    // Ensure a single instance is available across the app
    profileController = Get.put(ProfileController(), permanent: true);
    // Load the profile asynchronously
    profileController.loadProfile();
  }
}
