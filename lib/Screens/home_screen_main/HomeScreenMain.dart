



// ignore_for_file: must_be_immutable
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:starcapitalventures/Screens/Leads/leads_screen.dart';
import 'package:starcapitalventures/Screens/applications/application.dart';
import 'package:starcapitalventures/Screens/documents/documents_screen.dart';
import '../../apply_loan/apply_loan_screen.dart';
import '../emi_calculator/emi_calculator_screen.dart';
import '../home_screen_customer/home_screen_customer.dart';
import '../profile/controller/profile_controller.dart';
import '../profile/profile_screen.dart';
import 'controller/home_screen_controller.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../home_screen/home_screen.dart';
import '../home_screen_Lead/home_screen.dart'; // lead home

///   UN COMMENT AND USE THIS WHILE IN API INTEGRATION  IT IS  MANUAL PROFILE TYPE HANDLING UNWANTED

// lib/Screens/home_screen_main/home_screen_main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:starcapitalventures/Screens/Leads/leads_screen.dart';
import 'package:starcapitalventures/Screens/applications/application.dart';
import 'package:starcapitalventures/Screens/documents/documents_screen.dart';
import '../../apply_loan/apply_loan_screen.dart';
import '../emi_calculator/emi_calculator_screen.dart';
import '../home_screen_customer/home_screen_customer.dart';
import '../profile/controller/profile_controller.dart';
import '../profile/profile_screen.dart';
import 'controller/home_screen_controller.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../home_screen/home_screen.dart';
import '../home_screen_Lead/home_screen.dart'; // lead home

class HomeScreenMain extends StatelessWidget {
  HomeScreenMain({Key? key}) : super(key: key);

  final HomeOneContainer1Controller controller = Get.put(HomeOneContainer1Controller());
  final ProfileController profile = Get.put(ProfileController());

  List<Widget> _buildScreens(String? role) {
    final normalized = role?.toLowerCase();

    late final Widget firstTab;
    if (normalized == 'manager' || normalized == 'employee' || normalized == null) {
      firstTab = const HomeScreen();
    } else if (normalized == 'customer') {
      firstTab = const HomeScreenCustomer();
    } else if (normalized == 'agent') {
      firstTab = const HomeScreenLead();
    } else {
      firstTab = const HomeScreen();
    }

    if (normalized == 'customer') {
      return [
        firstTab,
        const ApplyLoanScreen(),
        Application(key: ValueKey('app_${controller.selectedIndex.value}')), // ✅ Add key that changes
        const ProfileScreen(),
      ];
    } else if(normalized == 'agent'){
      return [
        firstTab,
        const EmiCalculatorScreen(),
        Application(key: ValueKey('app_${controller.selectedIndex.value}')), // ✅ Add key that changes
        const ProfileScreen(),
      ];
    } else {
      return [
        firstTab,
        const LeadsScreen(),
        Application(key: ValueKey('app_${controller.selectedIndex.value}')), // ✅ Add key that changes
        const ProfileScreen(),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final screens = _buildScreens(profile.role.value);
      return Scaffold(
        extendBody: true,
        body: IndexedStack(
          index: controller.selectedIndex.value.clamp(0, screens.length - 1),
          children: screens,
        ),
        bottomNavigationBar: CustomBottomBar(
          onChanged: (index) => controller.selectedIndex.value = index,
        ),
      );
    });
  }
}

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

/*// ignore_for_file: must_be_immutable
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
import '../home_screen_customer/home_screen_customer.dart'; // customer home
import '../new_application/new_application_screen.dart'; // for customer apply loan
import '../../apply_loan/apply_loan_screen.dart'; // for customer apply loan list
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

  final HomeOneContainer1Controller controller = Get.put(
    HomeOneContainer1Controller(),
  );

  // Get role once and store it
  String get userRole {
    final role = (Get.arguments as Map<String, dynamic>?)?['role'] as String?;
    print('🏠 HomeScreenMain received role: "$role"');
    return role ?? 'employee';
  }

  List<Widget> _buildScreens(String role) {
    print('🔧 Building screens for role: "$role"');

    // Determine the first tab based on role
    Widget firstTab;
    switch (role) {
      case 'employee':
        print('📋 Setting up employee interface');
        firstTab = const HomeScreen();
        break;
      case 'lead':
        print('👥 Setting up lead interface');
        firstTab = const HomeScreenLead();
        break;
      case 'customer':
        print('🛒 Setting up customer interface');
        firstTab = const HomeScreenCustomer();
        break;
      default:
        print('⚠️ Unknown role "$role", defaulting to employee');
        firstTab = const HomeScreen(); // default to employee
    }

    // Return screens based on role
    if (role == 'customer') {
      print('✅ Building customer screens (4 tabs)');
      // Customer-specific navigation tabs (4 tabs matching screenshot)
      return [
        firstTab, // Dashboard
        const ApplyLoanScreen(), // Apply Loan
        const Application(), // Applications
        const ProfileScreen(), // Profile
      ];
    } else {
      print('✅ Building employee/lead screens (5 tabs)');
      // Employee and Lead navigation tabs
      return [
        firstTab,
        const LeadsScreen(),
        const Application(),
        const DocumentsScreen(),
        const ProfileScreen(),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = userRole; // Get role once
    final screens = _buildScreens(role); // Pass role to build screens

    print('🎯 Final role for navigation: "$role"');
    print('📱 Number of screens built: ${screens.length}');

    return Obx(
      () => Scaffold(
        extendBody: true,
        body: IndexedStack(
          index: controller.selectedIndex.value.clamp(0, screens.length - 1),
          children: screens,
        ),
        bottomNavigationBar: CustomBottomBar(
          role: role, // Pass consistent role to bottom bar
          onChanged: (index) => controller.selectedIndex.value = index,
        ),
      ),
    );
  }
}
*/