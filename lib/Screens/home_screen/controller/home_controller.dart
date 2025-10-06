// lib/Screens/home_screen/controller/home_controller.dart

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/data/api_client/api_client.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../core/data/api_client/api_client.dart';
import '../../../core/utils/custom_snackbar.dart';
import '../model/dashboard_model.dart';

class HomeController extends GetxController {
  final ApiClient apiClient = ApiClient();
  static const platform = MethodChannel('com.geosentry.sdk/channel');

  // Loading states
  var loading = false.obs;
  var dashboardLoading = false.obs;

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

  // Clock Out method (unchanged)

  // Debug method to manually test SDK initialization
  Future<void> testGeosentrySDK() async {
    // Test values - replace with actual values for testing
    await _initializeGeosentrySDK(
        'test_api_key',
        'test_cipher_key',
        'test_user_id'
    );
  }



// Enhanced location permission check - only called during clock in
// Enhanced location permission check - forces "Allow all the time" permission
  Future<bool> _checkLocationPermission(BuildContext context) async {
    try {
      print('=== Checking Location Permission ===');

      // Step 1: Check if we already have "Always" permission
      final locationAlwaysStatus = await Permission.locationAlways.status;
      print('Location Always permission status: $locationAlwaysStatus');

      if (locationAlwaysStatus.isGranted) {
        print('✅ Location Always permission already granted');
        return true;
      }

      // Step 2: Check basic location permissions first
      final locationStatus = await Permission.location.status;
      print('Location permission status: $locationStatus');

      // Handle permanently denied case
      if (locationStatus.isPermanentlyDenied || locationAlwaysStatus.isPermanentlyDenied) {
        print('❌ Location permission permanently denied');
        await _showPermanentlyDeniedDialog(context);
        return false;
      }

      // Step 3: Request basic location permission first (required for Android 10+)
      if (locationStatus.isDenied) {
        final shouldRequest = await _showInitialPermissionDialog(context);
        if (!shouldRequest) {
          print('❌ User declined initial permission request');
          return false;
        }

        // Request basic location permission
        final locationResult = await Permission.location.request();
        print('Basic location permission result: $locationResult');

        if (!locationResult.isGranted) {
          print('❌ Basic location permission denied');
          await _showPermissionDeniedDialog(context);
          return false;
        }
      }

      // Step 4: Now request "Always" permission with clear explanation
      final shouldRequestAlways = await _showAlwaysPermissionDialog(context);
      if (!shouldRequestAlways) {
        print('❌ User declined Always permission request');
        await _showSDKRequirementDialog(context);
        return false;
      }

      // Request "Always" location permission
      final alwaysResult = await Permission.locationAlways.request();
      print('Location Always permission result: $alwaysResult');

      if (alwaysResult.isGranted) {
        print('✅ Location Always permission granted');
        return true;
      } else {
        print('❌ Location Always permission not granted');
        await _showAlwaysPermissionFailedDialog(context);
        return false;
      }

    } catch (e) {
      print('❌ Error checking location permission: $e');
      CustomSnackbar.show(
        context,
        title: "Permission Error",
        message: "Failed to check location permission: ${e.toString()}",
      );
      return false;
    }
  }

// Updated performClockIn method - permission check only happens here
  Future<bool> performClockIn(BuildContext context) async {
    loading.value = true;

    try {
      // Check location permission ONLY when user tries to clock in
      print('=== Starting Clock In Process ===');
      final hasPermission = await _checkLocationPermission(context);

      if (!hasPermission) {
        print('❌ Clock in cancelled - no location permission');
        CustomSnackbar.show(
          context,
          title: "Permission Required",
          message: "Location permission is needed to clock in",
        );
        return false;
      }

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

        print('=== Geosentry SDK Initialization ===');
        print('User ID: $userId');
        print('API Key: $apiKey');
        print('Cipher Key: $cipherKey');

        try {
          // Initialize Geosentry SDK
          await _initializeGeosentrySDK(apiKey, cipherKey, userId);

          // Refresh dashboard data
          await fetchDashboardData();

          CustomSnackbar.show(
            context,
            title: "Clock In Successful",
            message: "You have successfully clocked in with location tracking",
          );
          return true;

        } catch (sdkError) {
          print('Geosentry SDK initialization failed: $sdkError');

          // Still refresh data but show warning
          await fetchDashboardData();

          CustomSnackbar.show(
            context,
            title: "Clock In Partially Successful",
            message: "Clocked in but location tracking unavailable",
          );
          return true;
        }
      } else {
        print('Warning: Geosentry data not found in response');
        await fetchDashboardData();

        CustomSnackbar.show(
          context,
          title: "Clock In Successful",
          message: "You have successfully clocked in",
        );
        return true;
      }

    } catch (err) {
      print('Clock In Error: $err');

      String errorMessage = "Failed to clock in. Please try again.";
      if (err.toString().contains("already clocked in")) {
        errorMessage = "You have already clocked in for the day";
      }

      CustomSnackbar.show(
        context,
        title: "Clock In Failed",
        message: errorMessage,
      );
      return false;
    } finally {
      loading.value = false;
    }
  }

  // Show explanation dialog before requesting permission
  Future<bool> _showPermissionExplanationDialog(BuildContext context) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Location Permission Required'),
        content: const Text(
          'This app needs access to your location for accurate clock in/out functionality and attendance tracking. Your location data is used only for work-related purposes.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Grant Permission'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
    return result ?? false;
  }

  // Show dialog to open app settings for permanently denied permission
  Future<void> _showPermissionSettingsDialog(BuildContext context) async {
    await Get.dialog(
      AlertDialog(
        title: const Text('Location Permission Required'),
        content: const Text(
          'Location permission is permanently denied. Please enable it in app settings to use clock in/out functionality.',
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




}
