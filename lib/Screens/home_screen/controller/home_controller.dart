// lib/Screens/home_screen/controller/home_controller.dart

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/data/api_client/api_client.dart';
import '../../../core/utils/custom_snackbar.dart';
import '../model/dashboard_model.dart';

// lib/Screens/home_screen/controller/home_controller.dart

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/data/api_client/api_client.dart';
import '../../../core/utils/custom_snackbar.dart';
import '../model/dashboard_model.dart';

class HomeController extends GetxController {
  final ApiClient apiClient = ApiClient();
  static const platform = MethodChannel('com.geosentry.sdk/channel');

  // Loading states
  var loading = false.obs;
  var dashboardLoading = false.obs;

  // Permission state
  var hasLocationAlwaysPermission = false.obs;
  var permissionRequested = false.obs;
  var currentPermissionStatus = PermissionStatus.denied.obs;

  // Dashboard data
  var dashboardData = Rx<DashboardData?>(null);
  var attendanceData = Rx<AttendanceData?>(null);
  var holidays = <Holiday>[].obs;

  // Clock in/out state
  var isCheckedIn = false.obs;
  var clockInTime = ''.obs;
  var clockOutTime = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
  }

  @override
  void onReady() {
    super.onReady();
    // Request permission after the UI is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestLocationPermissionOnAppStart();
    });
  }

  /// Request location permission immediately when app starts with proper error handling
  Future<void> _requestLocationPermissionOnAppStart() async {
    if (permissionRequested.value) {
      return; // Already requested in this session
    }

    try {
      print('=== App Start - Requesting Location Permission ===');

      // Check current permission status safely
      await _updatePermissionStatus();

      if (hasLocationAlwaysPermission.value) {
        print('✅ Already have "Allow all time" permission');
        return;
      }

      // Mark as requested to avoid multiple requests
      permissionRequested.value = true;

      // Show permission dialog immediately
      final shouldRequest = await _showAppStartPermissionDialog();
      if (!shouldRequest) {
        print('❌ User declined permission request on app start');
        return;
      }

      await _handlePermissionRequest();

    } catch (e) {
      print('❌ Error requesting permission on app start: $e');
      // Don't crash the app, just log the error
      hasLocationAlwaysPermission.value = false;
    }
  }

  /// Safely update permission status without crashing
  Future<void> _updatePermissionStatus() async {
    try {
      final locationAlwaysStatus = await Permission.locationAlways.status;
      currentPermissionStatus.value = locationAlwaysStatus;
      hasLocationAlwaysPermission.value = locationAlwaysStatus.isGranted;

      print('Current permission status: $locationAlwaysStatus');
    } catch (e) {
      print('Error checking permission status: $e');
      hasLocationAlwaysPermission.value = false;
      currentPermissionStatus.value = PermissionStatus.denied;
    }
  }

  /// Handle permission request with proper error handling
  Future<void> _handlePermissionRequest() async {
    try {
      // Request basic location permission first
      final locationStatus = await Permission.location.status;
      if (!locationStatus.isGranted) {
        final locationResult = await Permission.location.request();
        if (!locationResult.isGranted) {
          print('❌ Basic location permission denied');
          await _showPermissionDeniedDialog();
          return;
        }
      }

      // Request "Always" permission with error handling
      try {
        final alwaysResult = await Permission.locationAlways.request();
        await _updatePermissionStatus();

        if (alwaysResult.isGranted) {
          print('✅ Location Always permission granted on app start');
          CustomSnackbar.show(
            Get.context!,
            title: "Permission Granted",
            message: "Location tracking enabled for attendance",
          );
        } else {
          print('❌ Location Always permission not granted: $alwaysResult');
          await _handlePermissionDenied(alwaysResult);
        }
      } catch (permissionError) {
        print('❌ Error requesting Always permission: $permissionError');
        await _showPermissionErrorDialog();
      }

    } catch (e) {
      print('❌ Error in permission request flow: $e');
      await _showPermissionErrorDialog();
    }
  }

  /// Handle different permission denied scenarios
  Future<void> _handlePermissionDenied(PermissionStatus status) async {
    switch (status) {
      case PermissionStatus.denied:
        await _showWhileUsingAppSelectedDialog();
        break;
      case PermissionStatus.permanentlyDenied:
        await _showPermanentlyDeniedDialog();
        break;
      case PermissionStatus.restricted:
        await _showRestrictedPermissionDialog();
        break;
      default:
        await _showAlwaysPermissionFailedDialog();
    }
  }

  /// Show dialog when user selects "While using app" instead of "Allow all time"
  Future<void> _showWhileUsingAppSelectedDialog() async {
    await Get.dialog(
      AlertDialog(
        title: const Text('Insufficient Permission'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You selected "While using the app" but attendance tracking requires "Allow all the time" permission.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text('Without "Allow all the time" permission:'),
            Text('• Clock in/out may not work properly'),
            Text('• Location tracking will be limited'),
            Text('• Attendance accuracy may be reduced'),
            SizedBox(height: 12),
            Text(
              'You can change this in Settings > Permissions > Location',
              style: TextStyle(color: Colors.blue, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Continue Anyway'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  /// Show permission error dialog
  Future<void> _showPermissionErrorDialog() async {
    await Get.dialog(
      AlertDialog(
        title: const Text('Permission Error'),
        content: const Text(
          'There was an error requesting location permission. Some features may not work properly.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  /// Show restricted permission dialog
  Future<void> _showRestrictedPermissionDialog() async {
    await Get.dialog(
      AlertDialog(
        title: const Text('Permission Restricted'),
        content: const Text(
          'Location permission is restricted by your device settings (possibly parental controls). Please check your device settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Simplified and crash-safe clock in method
  Future<bool> performClockIn(BuildContext context) async {
    loading.value = true;

    try {
      print('=== Starting Clock In Process ===');

      // Refresh permission status before proceeding
      await _updatePermissionStatus();

      // Check if we have the required permission
      if (!hasLocationAlwaysPermission.value) {
        print('❌ No "Allow all time" permission available');

        CustomSnackbar.show(
          context,
          title: "Permission Required",
          message: "Clock-in requires 'Allow all time' location permission",
        );

        final shouldOpenSettings = await _showClockInPermissionDialog(context);
        if (shouldOpenSettings) {
          await openAppSettings();
        }
        return false;
      }

      print('✅ "Allow all time" permission confirmed');

      // Proceed with clock in API call
      final response = await apiClient.clockIn();
      print('Clock In API Response: $response');

      if (response is Map<String, dynamic> &&
          response['status'] == true &&
          response.containsKey('geosentry')) {

        final geosentry = response['geosentry'];
        final String userId = geosentry['user_id'] ?? '';
        final String apiKey = geosentry['api_key'] ?? '';
        final String cipherKey = geosentry['ciper_key'] ?? '';

        print('=== Geosentry SDK Initialization (Safe) ===');

        try {
          // Initialize SDK with error handling
          await _initializeGeosentrySDKSafe(apiKey, cipherKey, userId);

          await fetchDashboardData();

          CustomSnackbar.show(
            context,
            title: "Clock In Successful",
            message: "You have successfully clocked in with location tracking",
          );
          return true;

        } catch (sdkError) {
          print('Geosentry SDK initialization failed: $sdkError');

          // Don't crash, show error and allow basic clock in
          CustomSnackbar.show(
            context,
            title: "Clock In Completed",
            message: "Clocked in successfully but location tracking may be limited",
          );

          // Still refresh dashboard
          await fetchDashboardData();
          return true; // Return true for basic clock in success
        }
      }

      CustomSnackbar.show(
        context,
        title: "Clock In Failed",
        message: "Server error occurred. Please try again.",
      );
      return false;

    } catch (err) {
      print('Clock In Error: $err');
      CustomSnackbar.show(
        context,
        title: "Clock In Failed",
        message: "Failed to clock in. Please try again.",
      );
      return false;
    } finally {
      loading.value = false;
    }
  }

  /// Safe SDK initialization with comprehensive error handling
  Future<void> _initializeGeosentrySDKSafe(String apiKey, String cipherKey, String userID) async {
    try {
      print('=== Initializing Geosentry SDK (Safe Mode) ===');

      // Double-check permission before SDK initialization
      final currentStatus = await Permission.locationAlways.status;
      if (!currentStatus.isGranted) {
        throw PlatformException(
          code: 'PERMISSION_NOT_GRANTED',
          message: 'Allow all time permission not granted',
        );
      }

      print('Calling platform method: initializeSDK');

      // Call SDK initialization with timeout
      final result = await platform.invokeMethod('initializeSDK', {
        'apiKey': apiKey,
        'cipherKey': cipherKey,
        'userID': userID,
      }).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw PlatformException(
            code: 'TIMEOUT',
            message: 'SDK initialization timed out',
          );
        },
      );

      print('Platform method result: $result');

      // Handle result safely
      if (result is Map) {
        final success = result['success'] ?? false;
        final errorMessage = result['errormessage'] ?? '';

        if (!success) {
          throw PlatformException(
            code: 'SDK_INIT_FAILED',
            message: 'Geosentry SDK initialization failed',
            details: errorMessage,
          );
        }
      }

      print('✅ Geosentry SDK initialization SUCCESS');

    } catch (e) {
      print('❌ Geosentry SDK initialization FAILED: $e');

      // Log the error but don't crash the app
      if (e is PlatformException) {
        print('Platform Exception Code: ${e.code}');
        print('Platform Exception Message: ${e.message}');
        print('Platform Exception Details: ${e.details}');
      }

      // Re-throw to be handled by calling method
      rethrow;
    }
  }

  /// Show dialog for clock-in permission issue
  Future<bool> _showClockInPermissionDialog(BuildContext context) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Location Permission Required'),
        content: const Text(
          'To clock in, please enable "Allow all the time" location permission in app settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Open Settings'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
    return result ?? false;
  }

  /// Show permission dialog on app start
  Future<bool> _showAppStartPermissionDialog() async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Location Permission Required'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This app requires location access for accurate attendance tracking.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text('⚠️ Important: Please select "Allow all the time" for:'),
            Text('• Accurate attendance tracking'),
            Text('• Location-based clock in/out'),
            Text('• Compliance monitoring'),
            SizedBox(height: 12),
            Text(
              'Selecting "While using the app" will cause limited functionality.',
              style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Not Now'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Grant Permission'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
    return result ?? false;
  }

  // Rest of your existing methods remain the same...
  // (fetchDashboardData, _updateClockState, clockButtonText, etc.)

  // Get assigned leads count
  int get assignedLeads => dashboardData.value?.assignedLeads ?? 0;

  // Get assigned applications count
  int get assignedApplications => dashboardData.value?.assignedApplications ?? 0;

  // Get converted leads count
  int get convertedLeads => dashboardData.value?.convertedLeads ?? 0;

  // Refresh dashboard data
  Future<void> refreshDashboard() async {
    await fetchDashboardData();
  }


  // Fetch dashboard data
  Future<void> fetchDashboardData() async {
    dashboardLoading.value = true;
    try {
      final response = await apiClient.fetchDashboard();

      if (response.status && response.data != null) {
        dashboardData.value = response.data;
        attendanceData.value = response.data!.attendance;
        holidays.value = response.data!.holidays;

        // Update clock in/out state based on attendance data
        _updateClockState();

        print('Dashboard data fetched successfully');
      } else {
        print('Dashboard fetch failed: Invalid response');
      }
    } catch (err) {
      print('Dashboard fetch error: $err');
    } finally {
      dashboardLoading.value = false;
    }
  }

  // Update clock in/out state based on attendance data
  void _updateClockState() {
    if (attendanceData.value != null) {
      final attendance = attendanceData.value!;

      // Check if already clocked in
      isCheckedIn.value = attendance.isClockedIn;
      clockInTime.value = attendance.clockIn;
      clockOutTime.value = attendance.clockOut;

      print('Clock state updated - Checked in: ${isCheckedIn.value}, Clock in time: ${clockInTime.value}');
    } else {
      // No attendance data means ready to clock in
      isCheckedIn.value = false;
      clockInTime.value = '';
      clockOutTime.value = '';

      print('No attendance data - Ready to clock in');
    }
  }

  // Get display text for clock in/out button
  String get clockButtonText {
    if (attendanceData.value == null) {
      return 'Ready to Clock In';
    }

    final attendance = attendanceData.value!;
    if (attendance.isReadyToClockIn) {
      return 'Ready to Clock In';
    } else if (attendance.isReadyToClockOut) {
      return 'Ready to Clock Out';
    } else if (attendance.isClockedOut) {
      return 'Clocked Out';
    }
    return 'Clock In';
  }

  // Get switch state
  bool get switchValue {
    if (attendanceData.value == null) return false;
    return attendanceData.value!.isClockedIn && !attendanceData.value!.isClockedOut;
  }

  // Get formatted time for display
  String get displayTime {
    if (attendanceData.value == null) {
      return _getCurrentFormattedTime();
    }

    final attendance = attendanceData.value!;
    if (attendance.isClockedIn && attendance.clockIn != "00:00:00") {
      return _formatApiTime(attendance.clockIn);
    }

    return _getCurrentFormattedTime();
  }

  // Format API time (HH:mm:ss) to display format
  String _formatApiTime(String apiTime) {
    try {
      if (apiTime == "00:00:00" || apiTime.isEmpty) {
        return _getCurrentFormattedTime();
      }

      final parts = apiTime.split(':');
      if (parts.length >= 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);

        final now = DateTime.now();
        final time = DateTime(now.year, now.month, now.day, hour, minute);

        return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} • ${_formatDate(now)}";
      }
    } catch (e) {
      print('Error formatting API time: $e');
    }
    return _getCurrentFormattedTime();
  }

  // Get current formatted time
  String _getCurrentFormattedTime() {
    final now = DateTime.now();
    return "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} • ${_formatDate(now)}";
  }

  // Format date
  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return "${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}";
  }

  // Clock Out method
  Future<bool> performClockOut(BuildContext context) async {
    loading.value = true;
    try {
      final response = await apiClient.clockOut();
      print('Clock Out Success: $response');

      // Refresh dashboard data to get updated attendance
      await fetchDashboardData();

      CustomSnackbar.show(
        context,
        title: "Clock Out Successful",
        message: "You have successfully clocked out",
      );
      return true;
    } catch (err) {
      print('Clock Out Error: $err');
      CustomSnackbar.show(
        context,
        title: "Clock Out Failed",
        message: "Failed to clock out. Please try again",
      );
      return false;
    } finally {
      loading.value = false;
    }
  }

  // Initialize Geosentry SDK using MethodChannel with proper result checking
  Future<void> _initializeGeosentrySDK(String apiKey, String cipherKey, String userID) async {
    try {
      print('=== Initializing Geosentry SDK ===');
      print('Calling platform method: initializeSDK');

      // Get the actual result from the platform method
      final result = await platform.invokeMethod('initializeSDK', {
        'apiKey': apiKey,
        'cipherKey': cipherKey,
        'userID': userID,
      });

      print('Platform method result: $result');

      // Check if result contains success information
      if (result is Map) {
        final success = result['success'] ?? false;
        final errorMessage = result['errormessage'] ?? '';

        if (success) {
          print('✅ Geosentry SDK initialization SUCCESS');
        } else {
          print('❌ Geosentry SDK initialization FAILED: $errorMessage');

          // Handle specific error cases
          if (errorMessage.toLowerCase().contains('permission')) {
            print('🔐 Location permission issue detected');
            throw PlatformException(
              code: 'PERMISSION_DENIED',
              message: 'Location permission is required for Geosentry SDK',
              details: errorMessage,
            );
          }

          throw PlatformException(
            code: 'SDK_INIT_FAILED',
            message: 'Geosentry SDK initialization failed',
            details: errorMessage,
          );
        }
      } else {
        print('✅ Geosentry SDK initialization SUCCESS (legacy result)');
      }

    } catch (e) {
      print('❌ Geosentry SDK initialization FAILED: $e');

      // Handle different types of platform exceptions
      if (e is PlatformException) {
        print('Platform Exception Code: ${e.code}');
        print('Platform Exception Message: ${e.message}');
        print('Platform Exception Details: ${e.details}');

        // Re-throw to be handled by calling method
        rethrow;
      } else {
        print('Unknown error type: ${e.runtimeType}');
        throw PlatformException(
          code: 'UNKNOWN_ERROR',
          message: 'Unknown error during SDK initialization',
          details: e.toString(),
        );
      }
    }
  }

  // Dialog when Always permission fails
  Future<void> _showAlwaysPermissionFailedDialog() async {
    await Get.dialog(
      AlertDialog(
        title: const Text('Permission Required'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'The app requires "Allow all the time" location permission.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text('To enable attendance tracking:'),
            Text('1. Go to App Settings'),
            Text('2. Select Permissions > Location'),
            Text('3. Choose "Allow all the time"'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  // Permission denied dialog
  Future<void> _showPermissionDeniedDialog() async {
    await Get.dialog(
      AlertDialog(
        title: const Text('Location Permission Denied'),
        content: const Text(
          'Location access is required for attendance tracking. Please grant location permission to continue.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('OK'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  // Show dialog to open app settings for permanently denied permission
  Future<void> _showPermissionSettingsDialog(BuildContext context) async {
    await Get.dialog(
      AlertDialog(
        title: const Text('Location Permission Required'),
        content: const Text(
          'Please enable "Allow all the time" location permission in app settings to use attendance tracking.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }


  // Debug method to manually test SDK initialization
  Future<void> testGeosentrySDK() async {
    // Test values - replace with actual values for testing
    await _initializeGeosentrySDK(
        'test_api_key',
        'test_cipher_key',
        'test_user_id'
    );
  }
}
