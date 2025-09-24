import 'package:get/get.dart';

class HomeOneContainer1Controller extends GetxController {
  // Current tab index for HomeScreenMain + CustomBottomBar
  final RxInt selectedIndex = 0.obs;

  // Call this from UI (e.g., onChanged in CustomBottomBar)
  void changeTab(int index) {
    selectedIndex.value = index;
  }

  @override
  void onInit() {
    super.onInit();

    // Optional: listen to tab changes to run side-effects
    ever<int>(selectedIndex, (idx) {
      // e.g., analytics, scroll-to-top, refresh logic per tab
      // log('Tab changed to $idx');
    });
  }
}
