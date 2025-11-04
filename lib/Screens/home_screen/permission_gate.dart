import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:starcapitalventures/app_export/app_export.dart';
import '../home_screen_main/HomeScreenMain.dart';
import 'location_permission_screen.dart';
import '../home_screen/controller/home_controller.dart';
import '../../app_routes.dart';

class PermissionGate extends StatefulWidget {
  const PermissionGate({Key? key}) : super(key: key);

  @override
  State<PermissionGate> createState() => _PermissionGateState();
}

class _PermissionGateState extends State<PermissionGate> {
  bool _isCheckingPermission = true;
  bool _hasAlwaysPermission = false;
  bool _needsGeosentry = false;

  @override
  void initState() {
    super.initState();
    print('PermissionGate: initState called');
    _checkPermissionStatus();
  }

  Future<void> _checkPermissionStatus() async {
    try {
      print('PermissionGate: Starting permission check');

      // Get arguments passed from login
      final arguments = Get.arguments as Map<String, dynamic>? ?? {};
      final role = arguments['role'] ?? 'employee';
      print('PermissionGate: Role from arguments: $role');

      // Initialize controller if not already done
      if (!Get.isRegistered<HomeController>()) {
        Get.put(HomeController());
      }

      final controller = Get.find<HomeController>();

      // Check if geosentry is required first
      await controller.fetchDashboardData();

      final needsGeosentry = controller.shouldUseGeosentry;
      print('PermissionGate: Geosentry required: $needsGeosentry');

      if (!needsGeosentry) {
        // If geosentry not required, go directly to home with role arguments
        print('PermissionGate: Geosentry not required, navigating to home');
        setState(() {
          _needsGeosentry = false;
          _hasAlwaysPermission = true;
          _isCheckingPermission = false;
        });
        return;
      }

      // Check permission status
      final alwaysStatus = await Permission.locationAlways.status;
      print('PermissionGate: Location Always permission status: $alwaysStatus');

      setState(() {
        _needsGeosentry = needsGeosentry;
        _hasAlwaysPermission = alwaysStatus.isGranted;
        _isCheckingPermission = false;
      });

    } catch (e) {
      print('PermissionGate: Error checking permission status: $e');
      setState(() {
        _needsGeosentry = false;
        _hasAlwaysPermission = true; // Default to allowing access
        _isCheckingPermission = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print('PermissionGate: build called - checking: $_isCheckingPermission, needsGeosentry: $_needsGeosentry, hasAlways: $_hasAlwaysPermission');

    if (_isCheckingPermission) {
      return  Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: appTheme.theme,
                backgroundColor: appTheme.whiteA700,
              ),
              SizedBox(height: 16),
              Text(
                'Checking permissions...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Show location permission screen if geosentry is needed and "Allow all the time" is not granted
    if (_needsGeosentry && !_hasAlwaysPermission) {
      print('PermissionGate: Showing LocationPermissionScreen');
      return const LocationPermissionScreen();
    }

    // Navigate to home screen if permission is granted or not needed
    print('PermissionGate: Permission granted or not needed, navigating to home');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Get the role arguments passed from SignInController
      final arguments = Get.arguments as Map<String, dynamic>? ?? {};
      print('PermissionGate: Navigating to HomeScreenMain with arguments: $arguments');

      // Navigate to HomeScreenMain with the role arguments
      Get.offAllNamed(AppRoutes.homeScreenMain, arguments: arguments);
    });

    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
