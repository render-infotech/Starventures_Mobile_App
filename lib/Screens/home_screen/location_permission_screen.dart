import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../app_export/app_export.dart';
import '../home_screen/controller/home_controller.dart';
import '../../app_routes.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../home_screen/controller/home_controller.dart';
import '../../app_routes.dart';

class LocationPermissionScreen extends StatefulWidget {
  const LocationPermissionScreen({Key? key}) : super(key: key);

  @override
  State<LocationPermissionScreen> createState() => _LocationPermissionScreenState();
}

class _LocationPermissionScreenState extends State<LocationPermissionScreen> with WidgetsBindingObserver {
  bool _isPermissionGranted = false;
  bool _isCheckingPermission = false;
  String _permissionStatus = '';
  bool _showDeniedWarning = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkInitialPermissionStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _checkPermissionStatus();
    }
  }

  Future<void> _checkInitialPermissionStatus() async {
    try {
      final alwaysStatus = await Permission.locationAlways.status;
      final basicStatus = await Permission.location.status;

      setState(() {
        _isPermissionGranted = alwaysStatus.isGranted;
        _permissionStatus = _getPermissionStatusText(alwaysStatus, basicStatus);
        _showDeniedWarning = !alwaysStatus.isGranted;
      });

      print('Initial permission check - Always: $alwaysStatus, Basic: $basicStatus');
    } catch (e) {
      print('Error checking initial permission: $e');
      setState(() {
        _isPermissionGranted = false;
        _permissionStatus = 'Permission check failed';
        _showDeniedWarning = true;
      });
    }
  }

  String _getPermissionStatusText(PermissionStatus alwaysStatus, PermissionStatus basicStatus) {
    if (alwaysStatus.isGranted) {
      return 'Location access: Allow all the time ✅';
    } else if (basicStatus.isGranted) {
      return 'Location access: While using app only ⚠️';
    } else if (alwaysStatus.isDenied || basicStatus.isDenied) {
      return 'Location access: Denied ❌';
    } else if (alwaysStatus.isPermanentlyDenied || basicStatus.isPermanentlyDenied) {
      return 'Location access: Permanently denied ❌';
    } else {
      return 'Location access: Not determined';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.whiteA700,
      body: SafeArea(
        child: Padding(
          padding: getPadding(all: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Location Icon with success state
              Container(
                width: getSize(120),
                height: getSize(120),
                decoration: BoxDecoration(
                  color: _isPermissionGranted
                      ? appTheme.greenA700.withOpacity(0.1)
                      : appTheme.red600.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isPermissionGranted ? Icons.check_circle : Icons.location_off,
                  size: getSize(60),
                  color: _isPermissionGranted ? appTheme.greenA700 : appTheme.red600,
                ),
              ),

              SizedBox(height: getVerticalSize(32)),

              // Dynamic Title
              Text(
                _isPermissionGranted
                    ? 'Perfect! You\'re All Set!'
                    : 'Location Permission Required',
                style: TextStyle(
                  fontSize: getFontSize(24),
                  fontWeight: FontWeight.bold,
                  color: appTheme.black900,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: getVerticalSize(16)),

              // Show current permission status
              if (_permissionStatus.isNotEmpty) ...[
                Container(
                  padding: getPadding(left: 16, right: 16, top: 8, bottom: 8),
                  decoration: BoxDecoration(
                    color: _isPermissionGranted
                        ? appTheme.lightGreen50
                        : appTheme.red50,
                    borderRadius: BorderRadius.circular(getHorizontalSize(20)),
                    border: Border.all(
                      color: _isPermissionGranted
                          ? appTheme.greenA700.withOpacity(0.3)
                          : appTheme.red600.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    _permissionStatus,
                    style: TextStyle(
                      fontSize: getFontSize(12),
                      fontWeight: FontWeight.w500,
                      color: _isPermissionGranted
                          ? appTheme.greenA700
                          : appTheme.red600,
                    ),
                  ),
                ),
                SizedBox(height: getVerticalSize(16)),
              ],

              // Dynamic Description
              Text(
                _isPermissionGranted
                    ? 'You have successfully enabled location tracking! Ready to start your amazing workday? Let\'s make today productive and successful!'
                    : 'This app requires "Allow all the time" location permission to function properly. This is mandatory for accurate attendance tracking and location-based features.',
                style: TextStyle(
                  fontSize: getFontSize(16),
                  color: appTheme.gray700,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: getVerticalSize(32)),

              // Features List or Success Message or Warning
              Container(
                padding: getPadding(all: 16),
                decoration: BoxDecoration(
                  color: _isPermissionGranted
                      ? appTheme.lightGreen50
                      : _showDeniedWarning
                      ? appTheme.theme2.withOpacity(0.1)
                      : appTheme.gray100,
                  borderRadius: BorderRadius.circular(getHorizontalSize(12)),
                  border: Border.all(
                    color: _isPermissionGranted
                        ? appTheme.greenA700.withOpacity(0.2)
                        : _showDeniedWarning
                        ? appTheme.red600.withOpacity(0.2)
                        : appTheme.gray300,
                  ),
                ),
                child: _isPermissionGranted
                    ? _buildSuccessMessage()
                    : _showDeniedWarning
                    ? _buildWarningMessage()
                    : _buildFeaturesList(),
              ),

              SizedBox(height: getVerticalSize(32)),

              // Dynamic Button
              if (_isPermissionGranted) ...[
                SizedBox(
                  width: double.infinity,
                  height: getVerticalSize(50),
                  child: ElevatedButton(
                    onPressed: _navigateToHome,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appTheme.greenA700,
                      foregroundColor: appTheme.whiteA700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(getHorizontalSize(12)),
                      ),
                    ),
                    child: Text(
                      'Let\'s Go!',
                      style: TextStyle(
                        fontSize: getFontSize(16),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  height: getVerticalSize(50),
                  child: ElevatedButton(
                    onPressed: _isCheckingPermission ? null : _openAppLocationPermissionSettings,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appTheme.theme,
                      foregroundColor: appTheme.whiteA700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(getHorizontalSize(12)),
                      ),
                    ),
                    child: _isCheckingPermission
                        ? SizedBox(
                      width: getSize(20),
                      height: getSize(20),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(appTheme.whiteA700),
                      ),
                    )
                        : Text(
                      'Grant Required Permission',
                      style: TextStyle(
                        fontSize: getFontSize(16),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],

              // Critical requirement notice
              if (!_isPermissionGranted) ...[
                SizedBox(height: getVerticalSize(16)),
                Container(
                  padding: getPadding(all: 12),
                  decoration: BoxDecoration(
                    color: appTheme.orange50,
                    borderRadius: BorderRadius.circular(getHorizontalSize(8)),
                    border: Border.all(color: appTheme.orange600.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: appTheme.orange600,
                        size: getSize(20),
                      ),
                      SizedBox(width: getHorizontalSize(8)),
                      Expanded(
                        child: Text(
                          'MANDATORY: You must select "Allow all the time" to use this app',
                          style: TextStyle(
                            fontSize: getFontSize(12),
                            color: appTheme.orange600,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturesList() {
    return Column(
      children: [
        _buildFeatureItem(
          Icons.access_time,
          'Accurate Clock In/Out',
          'Track your work hours precisely',
        ),
        SizedBox(height: getVerticalSize(12)),
        _buildFeatureItem(
          Icons.location_searching,
          'Location Tracking',
          'Verify attendance location',
        ),
        SizedBox(height: getVerticalSize(12)),
        _buildFeatureItem(
          Icons.security,
          'Compliance Monitoring',
          'Ensure workplace compliance',
        ),
      ],
    );
  }

  Widget _buildSuccessMessage() {
    return Column(
      children: [
        Icon(
          Icons.celebration,
          size: getSize(40),
          color: appTheme.greenA700,
        ),
        SizedBox(height: getVerticalSize(12)),
        Text(
          'Location Tracking Enabled!',
          style: TextStyle(
            fontSize: getFontSize(18),
            fontWeight: FontWeight.bold,
            color: appTheme.greenA700,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: getVerticalSize(8)),
        Text(
          'Your attendance will now be tracked accurately. Time to make today count!',
          style: TextStyle(
            fontSize: getFontSize(14),
            color: appTheme.gray700,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildWarningMessage() {
    return Column(
      children: [
        Icon(
          Icons.error_outline,
          size: getSize(40),
          color: appTheme.red600,
        ),
        SizedBox(height: getVerticalSize(12)),
        Text(
          'Permission Required',
          style: TextStyle(
            fontSize: getFontSize(18),
            fontWeight: FontWeight.bold,
            color: appTheme.red600,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: getVerticalSize(8)),
        Text(
          'This app cannot function without "Allow all the time" location permission. Please grant the required permission to continue.',
          style: TextStyle(
            fontSize: getFontSize(14),
            color: appTheme.gray700,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: getSize(40),
          height: getSize(40),
          decoration: BoxDecoration(
            color: appTheme.theme.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: getSize(20),
            color: appTheme.theme,
          ),
        ),
        SizedBox(width: getHorizontalSize(12)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: getFontSize(14),
                  fontWeight: FontWeight.w600,
                  color: appTheme.black900,
                ),
              ),
              SizedBox(height: getVerticalSize(2)),
              Text(
                description,
                style: TextStyle(
                  fontSize: getFontSize(12),
                  color: appTheme.gray700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _openAppLocationPermissionSettings() async {
    try {
      setState(() {
        _isCheckingPermission = true;
      });

      print('Opening app-specific location permission settings');

      await openAppSettings();

      Get.snackbar(
        'Important',
        'Please select "Allow all the time" - this is required for the app to work',
        backgroundColor: appTheme.theme,
        colorText: appTheme.whiteA700,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
        isDismissible: false,
      );

    } catch (e) {
      print('Error opening app permission settings: $e');
      Get.snackbar(
        'Manual Setup Required',
        'Go to: Settings > Apps > starcapitalventures > Permissions > Location > "Allow all the time"',
        backgroundColor: appTheme.red600,
        colorText: appTheme.whiteA700,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
        isDismissible: false,
      );
    } finally {
      setState(() {
        _isCheckingPermission = false;
      });
    }
  }

  Future<void> _checkPermissionStatus() async {
    try {
      print('Checking permission status after returning from settings...');

      final alwaysStatus = await Permission.locationAlways.status;
      final basicStatus = await Permission.location.status;

      print('Permission status - Always: $alwaysStatus, Basic: $basicStatus');

      setState(() {
        _isPermissionGranted = alwaysStatus.isGranted;
        _permissionStatus = _getPermissionStatusText(alwaysStatus, basicStatus);
        _showDeniedWarning = !alwaysStatus.isGranted;
      });

      if (_isPermissionGranted) {
        Get.snackbar(
          '🎉 Perfect!',
          'Location permission enabled! Ready to start your productive day?',
          backgroundColor: appTheme.greenA700,
          colorText: appTheme.whiteA700,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );

        if (Get.isRegistered<HomeController>()) {
          final controller = Get.find<HomeController>();
          await controller.updatePermissionStatus();
        }
      } else {
        if (basicStatus.isGranted) {
          Get.snackbar(
            'Permission Insufficient',
            '"While using app" is not enough. Please select "Allow all the time"',
            backgroundColor: appTheme.orange600,
            colorText: appTheme.whiteA700,
            snackPosition: SnackPosition.TOP,
            duration: const Duration(seconds: 2),
            isDismissible: false,
          );
        } else {
          Get.snackbar(
            'Permission Required',
            'Location permission is required. Please grant "Allow all the time" permission.',
            backgroundColor: appTheme.red600,
            colorText: appTheme.whiteA700,
            snackPosition: SnackPosition.TOP,
            duration: const Duration(seconds: 2),
            isDismissible: false,
          );
        }
      }
    } catch (e) {
      print('Error checking permission: $e');
    }
  }

  void _navigateToHome() {
    try {
      Get.snackbar(
        '🚀 Let\'s Go!',
        'Have an amazing and productive workday ahead!',
        backgroundColor: appTheme.greenA700,
        colorText: appTheme.whiteA700,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 1),
      );

      final arguments = Get.arguments as Map<String, dynamic>? ?? {};

      print('Navigating to home with arguments: $arguments');
      Get.offAllNamed(AppRoutes.homeScreenMain, arguments: arguments);
    } catch (e) {
      print('Error navigating to home: $e');
      Get.offAllNamed(AppRoutes.homeScreenMain);
    }
  }
}
