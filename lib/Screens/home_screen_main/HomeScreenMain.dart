// ignore_for_file: must_be_immutable
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:starcapitalventures/Screens/Leads/leads_screen.dart';
import 'package:starcapitalventures/Screens/applications/application.dart';
import 'package:starcapitalventures/Screens/documents/documents_screen.dart';
import '../profile/profile_screen.dart';
import 'controller/home_screen_controller.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../home_screen/home_screen.dart';
import '../home_screen_Lead/home_screen.dart'; // lead home
/*
class HomeScreenMain extends StatelessWidget {
  HomeScreenMain({Key? key}) : super(key: key);
  final HomeOneContainer1Controller controller = Get.put(HomeOneContainer1Controller());

  // expose role to children via Get.arguments or an inherited/state object
  Map<String, dynamic> get _args => (Get.arguments as Map<String, dynamic>?) ?? const {};
  String get _role => (_args['role'] as String?) ?? 'employee'; // default [web:7]
  bool get isEmployee => _role == 'employee'; // flag [web:9]

  List<Widget> _buildScreens() {
    final firstTab = isEmployee ? const HomeScreen() : const HomeScreenLead(); // role-based home [web:9]
    final tabs = <Widget>[
      firstTab,
      const LeadsScreen(),
      const Application(),
      if (isEmployee) const DocumentsScreen(), // hide for agent [web:9]
      const ProfileScreen(),
    ];
    return tabs;
  }

  @override
  Widget build(BuildContext context) {
    final screens = _buildScreens();
    return Obx(() => Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: controller.selectedIndex.value.clamp(0, screens.length - 1), // safe index [web:12]
        children: screens,
      ),
      bottomNavigationBar: CustomBottomBar(
        role: _role, // pass role down to build items [web:9]
        onChanged: (index) => controller.selectedIndex.value = index,
      ),
    ));
  }
}
*/
///   UN COMMENT AND USE THIS WHILE IN API INTEGRATION  IT IS  MANUAL PROFILE TYPE HANDLING UNWANTED


class HomeScreenMain extends StatelessWidget {
  HomeScreenMain({Key? key}) : super(key: key);

  final HomeOneContainer1Controller controller = Get.put(HomeOneContainer1Controller());

  List<Widget> _buildScreens() {
    final role = (Get.arguments as Map<String, dynamic>?)?['role'] as String?;
    final isEmployee = role == null || role == 'employee'; // default to employee

    final firstTab = isEmployee ? const HomeScreen() : const HomeScreenLead();

    return [
      firstTab,
      const LeadsScreen(),
      const Application(),
      const DocumentsScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final screens = _buildScreens();

    return Obx(() => Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: controller.selectedIndex.value.clamp(0, screens.length - 1),
        children: screens,
      ),
      bottomNavigationBar: CustomBottomBar(
        onChanged: (index) => controller.selectedIndex.value = index,
      ),
    ));
  }
}
