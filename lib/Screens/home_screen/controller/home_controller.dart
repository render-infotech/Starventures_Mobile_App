// lib/Screens/home_screen/controller/home_controller.dart

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:starcapitalventures/app_export/app_export.dart';
import '../../../core/data/api_client/api_client.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../core/data/api_client/api_client.dart';
import '../../../core/utils/custom_snackbar.dart';
// lib/Screens/home_screen/controller/home_controller.dart

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/data/api_client/api_client.dart';
import '../../../core/utils/custom_snackbar.dart';
import '../../../core/utils/loading_service.dart';
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

  // Permission state - track both types of permissions
  var hasLocationPermission = false.obs;
  var hasLocationAlwaysPermission = false.obs;
  var permissionRequested = false.obs;

  // Dashboard data
  var dashboardData = Rx<DashboardData?>(null);
  var attendanceData = Rx<AttendanceData?>(null);
  var holidays = <Holiday>[].obs;

  // Clock in/out state
  var isCheckedIn = false.obs;
  var clockInTime = ''.obs;
  var clockOutTime = ''.obs;
  final ImagePicker _imagePicker = ImagePicker();

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
  /// Public method to update permission status
  Future<void> updatePermissionStatus() async {
    await _updatePermissionStatus();
  }

  /// Check geosentry status from dashboard data
  bool get shouldUseGeosentry {
    final geosentryData = dashboardData.value?.geosentryData;
    return geosentryData != null &&
        geosentryData.hasGeosentryId &&
        geosentryData.isGeosentryActive;
  }
// In HomeController.dart

  bool _isEmpty(String? s) => s == null || s.trim().isEmpty;
  bool _isZero(String? s) => _isEmpty(s) || s == '00:00:00' || s == '000000';

  // bool get isReadyToClockIn {
  //   final a = attendanceData.value;
  //   if (a == null) return true;
  //   final ciZero = _isZero(a.clockIn);
  //   final coZero = _isZero(a.clockOut);
  //   if (ciZero && coZero) return true;
  //   if (!ciZero && !coZero) return true;
  //   return false;
  // }

  bool get isReadyToClockOut {
    final a = attendanceData.value;
    if (a == null) return false;
    final ciZero = _isZero(a.clockIn);
    final coZero = _isZero(a.clockOut);
    return !ciZero && coZero;
  }

  // String get clockButtonText =>
  //     isReadyToClockOut ? 'Ready to Clock Out' : 'Ready to Clock In';

  bool get switchValue {
    final a = attendanceData.value;
    if (a == null) return false;
    final ciZero = _isZero(a.clockIn);
    final coZero = _isZero(a.clockOut);
    return !ciZero && coZero;
  }

  String get displayTime {
    final a = attendanceData.value;
    if (a == null) return getCurrentFormattedTime();
    if (!_isZero(a.clockIn)) return formatApiTime(a.clockIn);
    return getCurrentFormattedTime();
  }
// In HomeController.dart

  String formatApiTime(String apiTime) {
    try {
      if (apiTime == '000000' || apiTime.isEmpty) return getCurrentFormattedTime();
      // Supports either "HH:mm:ss" or "HH:mm"
      if (apiTime.contains(':')) {
        final parts = apiTime.split(':');
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        final now = DateTime.now();
        final time = DateTime(now.year, now.month, now.day, hour, minute);
        return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      }
      // Fallback for "HHmmss"
      final hour = int.parse(apiTime.substring(0, 2));
      final minute = int.parse(apiTime.substring(2, 4));
      final now = DateTime.now();
      final time = DateTime(now.year, now.month, now.day, hour, minute);
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      // On any parse error, show current time
      return getCurrentFormattedTime();
    }
  }

  String getCurrentFormattedTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

// Helper method to check if attendance date matches today
  bool _isAttendanceFromToday(AttendanceData? attendance) {
    if (attendance == null) return false;

    try {
      // Parse the attendance date from API response
      final attendanceDate = DateTime.parse(attendance.date);
      final today = DateTime.now();

      // Compare year, month, and day
      return attendanceDate.year == today.year &&
          attendanceDate.month == today.month &&
          attendanceDate.day == today.day;
    } catch (e) {
      print('Error parsing attendance date: $e');
      return false; // If parsing fails, treat as not today
    }
  }

// Updated isReadyToClockIn getter
  bool get isReadyToClockIn {
    final a = attendanceData.value;

    // No attendance data = can clock in
    if (a == null) return true;

    // ✅ NEW: Check if attendance is from a previous day
    if (!_isAttendanceFromToday(a)) {
      print('Attendance is from previous day (${a.date}) - allowing new clock in');
      return true; // Allow clock in for new day
    }

    // Same day logic - check clock in/out status
    final ciZero = _isZero(a.clockIn);
    final coZero = _isZero(a.clockOut);

    if (ciZero && coZero) return true;  // Both empty = can clock in
    if (!ciZero && !coZero) return true; // Both filled = already completed (shouldn't happen on same day)

    return false; // Currently clocked in on same day, cannot clock in again
  }

// Updated clockButtonText to show appropriate message
  String get clockButtonText {
    final a = attendanceData.value;

    // Check if attendance is from previous day
    if (a != null && !_isAttendanceFromToday(a)) {
      final ciZero = _isZero(a.clockIn);
      final coZero = _isZero(a.clockOut);

      if (!ciZero && coZero) {
        // Previous day incomplete - show warning in button text
        return 'Clock In (Previous day incomplete)';
      }
    }

    // Original same-day logic
    if (isReadyToClockOut) return 'Ready to Clock Out';
    if (isReadyToClockIn) return 'Ready to Clock In';
    return 'Already Clocked Out';
  }

  /// Capture selfie using front camera
  Future<File?> _captureSelfie(BuildContext context) async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front, // Front camera for selfie
        imageQuality: 70, // Compress image
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (photo != null) {
        return File(photo.path);
      }
      return null;
    } catch (e) {
      print('Error capturing selfie: $e');
      CustomSnackbar.show(
        context,
        title: "Camera Error",
        message: "Failed to capture selfie. Please try again.",
      );
      return null;
    }
  }

  /// Show dialog to capture selfie
  Future<File?> _showSelfieDialog(BuildContext context, String action) async {
    final result = await Get.dialog<File>(
      AlertDialog(
        backgroundColor: appTheme.whiteA700,
        title: Text('Take Selfie for $action'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.camera_alt, size: 64, color: appTheme.theme),
            SizedBox(height: 16),
            Text(
              'Please take a selfie to verify your $action',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: null),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: appTheme.theme,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final file = await _captureSelfie(context);
              Get.back(result: file);
            },
            child: const Text('Open Camera'),
          ),
        ],
      ),
      barrierDismissible: false,
    );

    return result;
  }


  Future<bool> performClockIn(BuildContext context) async {
    loading.value = true;
    try {
      print('=== Starting Clock In Process ===');

      // Step 1: Show selfie dialog immediately when switch is pressed
      final selfieFile = await _showSelfieDialog(context, 'Clock In');

      if (selfieFile == null) {
        print('❌ Selfie capture cancelled');
        CustomSnackbar.show(
          context,
          title: "Clock In Cancelled",
          message: "Selfie is required for clock in",
        );
        return false;
      }

      print('✅ Selfie captured: ${selfieFile.path}');

      // Step 2: Check location permission
      await _updatePermissionStatus();

      if (!hasLocationPermission.value && !hasLocationAlwaysPermission.value) {
        print('❌ No location permission available');
        final hasPermission = await _checkLocationPermissionFlexible(context);
        if (!hasPermission) {
          CustomSnackbar.show(
            context,
            title: "Permission Required",
            message: "Location permission is needed for attendance tracking",
          );
          return false;
        }
      }

      // Step 3: Get location coordinates
      Position? currentPosition;
      print('🌍 Starting location collection process...');

      if (await _canGetLocation()) {
        print('✅ Location services available, attempting to get coordinates...');
        try {
          currentPosition = await _getCurrentLocation();

          if (currentPosition == null) {
            print('⚠️ Current position is null, checking location services...');
            bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

            if (!serviceEnabled) {
              print('❌ Location services disabled');
              final shouldEnable = await _showLocationServiceDialog(context);
              if (shouldEnable) {
                await Future.delayed(const Duration(seconds: 2));
                currentPosition = await _getCurrentLocation();
              }
            }
          }
        } catch (e) {
          print('⚠️ Exception while getting location: $e');
        }
      }

      // Step 4: STRICT validation - BLOCK if no coordinates
      if (currentPosition == null) {
        print('❌ CRITICAL: No location coordinates available');

        CustomSnackbar.show(
          context,
          title: "Location Required",
          message: "Unable to get your location. Please enable location services and try again.",
        );
        return false;
      }

      // Step 5: Log location status
      print('✅ SUCCESS: Will clock in with coordinates');
      print('📍 Latitude: ${currentPosition.latitude}');
      print('📍 Longitude: ${currentPosition.longitude}');

      // Step 6: Make API call with guaranteed non-null coordinates
      final response = await apiClient.clockIn(
        latitude: currentPosition.latitude,
        longitude: currentPosition.longitude,
        clockInImage: selfieFile,
      );

      print('📡 Clock In API Response: $response');

      if (response is Map && response['status'] == true) {
        // Check if geosentry initialization is required
        if (shouldUseGeosentry && response.containsKey('geosentry')) {
          final geosentry = response['geosentry'];
          final String userId = geosentry['user_id'] ?? '';
          final String apiKey = geosentry['api_key'] ?? '';
          final String cipherKey = geosentry['ciper_key'] ?? '';

          print('=== Initializing Geosentry SDK (Required) ===');

          if (!hasLocationAlwaysPermission.value) {
            final shouldUpgrade = await _showAlwaysPermissionDialog();
            if (shouldUpgrade) {
              await Permission.locationAlways.request();
              await _updatePermissionStatus();
            }
          }

          try {
            LoadingService.to.show(
              message: 'Initializing Location Tracking...',
              color: appTheme.theme,
              backgroundColor: Colors.black.withOpacity(0.7),
            );

            await _initializeGeosentrySDKSafe(apiKey, cipherKey, userId);
            LoadingService.to.hide();

            await fetchDashboardData();

            final trackingMessage = hasLocationAlwaysPermission.value
                ? "You have successfully clocked in with full location tracking"
                : "You have successfully clocked in with basic location tracking";

            CustomSnackbar.show(
              context,
              title: "Clock In Successful",
              message: trackingMessage,
            );
            return true;
          } catch (sdkError) {
            print('Geosentry SDK initialization failed: $sdkError');
            LoadingService.to.hide();

            await fetchDashboardData();
            CustomSnackbar.show(
              context,
              title: "Clock In Successful",
              message: "Clocked in successfully (limited location features)",
            );
            return true;
          }
        } else {
          // Simple clock in without geosentry
          print('✅ Simple clock in successful');
          await fetchDashboardData();

          CustomSnackbar.show(
            context,
            title: "Clock In Successful",
            message: "You have successfully clocked in with location data",
          );
          return true;
        }
      } else {
        throw Exception('Clock in API failed');
      }
    } catch (err) {
      print('❌ Clock In Error: $err');

      if (LoadingService.to.isLoading) {
        LoadingService.to.hide();
      }

      // ✅ Dynamic error message (same as clock out)
      String errorMessage = "Failed to clock in. Please try again";
      if (err.toString().contains('400')) {
        errorMessage = "You have already clocked in for the day or need to check your location";
      } else if (err.toString().toLowerCase().contains('already clocked,')) {
        errorMessage = "You might have already clocked out or need to check your location";
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

  /// uncomment
  /*
  Future<bool> performClockIn(BuildContext context) async {

    loading.value = true;
    try {
      print('=== Starting Clock In Process ===');

      // Step 1: Show selfie dialog immediately when switch is pressed
      final selfieFile = await _showSelfieDialog(context, 'Clock In');

      if (selfieFile == null) {
        print('❌ Selfie capture cancelled');
        CustomSnackbar.show(
          context,
          title: "Clock In Cancelled",
          message: "Selfie is required for clock in",
        );
        return false;
      }

      print('✅ Selfie captured: ${selfieFile.path}');

      // Step 2: Check location permission
      await _updatePermissionStatus();

      if (!hasLocationPermission.value && !hasLocationAlwaysPermission.value) {
        print('❌ No location permission available');
        final hasPermission = await _checkLocationPermissionFlexible(context);
        if (!hasPermission) {
          CustomSnackbar.show(
            context,
            title: "Permission Required",
            message: "Location permission is needed for attendance tracking",
          );
          return false;
        }
      }

      // Step 3: Get location coordinates
      Position? currentPosition;
      print('🌍 Starting location collection process...');

      if (await _canGetLocation()) {
        print('✅ Location services available, attempting to get coordinates...');
        try {
          currentPosition = await _getCurrentLocation();

          if (currentPosition == null) {
            print('⚠️ Current position is null, checking location services...');
            bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

            if (!serviceEnabled) {
              print('❌ Location services disabled');
              final shouldEnable = await _showLocationServiceDialog(context);
              if (shouldEnable) {
                await Future.delayed(const Duration(seconds: 2));
                currentPosition = await _getCurrentLocation();
              }
            }
          }
        } catch (e) {
          print('⚠️ Exception while getting location: $e');
        }
      }

      // Step 4: Enhanced logging for location status
      if (currentPosition != null) {
        print('✅ SUCCESS: Will clock in with coordinates:');
        print(' 📍 Latitude: ${currentPosition.latitude}');
        print(' 📍 Longitude: ${currentPosition.longitude}');
      } else {
        print('⚠️ WARNING: Will clock in WITHOUT coordinates');
      }

      print('🌐 Making API call with selfie...');

      // Step 5: Make API call with latitude, longitude, and selfie image
      final response = await apiClient.clockIn(
        latitude: currentPosition?.latitude,
        longitude: currentPosition?.longitude,
        clockInImage: selfieFile, // Add selfie file
      );

      print('📡 Clock In API Response: $response');

      if (response is Map && response['status'] == true) {
        // Check if geosentry initialization is required
        if (shouldUseGeosentry && response.containsKey('geosentry')) {
          final geosentry = response['geosentry'];
          final String userId = geosentry['user_id'] ?? '';
          final String apiKey = geosentry['api_key'] ?? '';
          final String cipherKey = geosentry['ciper_key'] ?? '';

          print('=== Initializing Geosentry SDK (Required) ===');

          if (!hasLocationAlwaysPermission.value) {
            final shouldUpgrade = await _showAlwaysPermissionDialog();
            if (shouldUpgrade) {
              await Permission.locationAlways.request();
              await _updatePermissionStatus();
            }
          }

          try {
            LoadingService.to.show(
              message: 'Initializing Location Tracking...',
              color: appTheme.theme,
              backgroundColor: Colors.black.withOpacity(0.7),
            );

            await _initializeGeosentrySDKSafe(apiKey, cipherKey, userId);
            LoadingService.to.hide();

            await fetchDashboardData();

            final trackingMessage = hasLocationAlwaysPermission.value
                ? "You have successfully clocked in with full location tracking"
                : "You have successfully clocked in with basic location tracking";

            CustomSnackbar.show(
              context,
              title: "Clock In Successful",
              message: trackingMessage,
            );
            return true;
          } catch (sdkError) {
            print('Geosentry SDK initialization failed: $sdkError');
            LoadingService.to.hide();

            await fetchDashboardData();
            CustomSnackbar.show(
              context,
              title: "Clock In Successful",
              message: "Clocked in successfully (limited location features)",
            );
            return true;
          }
        } else {
          // Simple clock in without geosentry
          print('✅ Simple clock in successful');
          await fetchDashboardData();

          final locationMessage = currentPosition != null
              ? "You have successfully clocked in with location data"
              : "You have successfully clocked in (location unavailable)";

          CustomSnackbar.show(
            context,
            title: "Clock In Successful",
            message: locationMessage,
          );
          return true;
        }
      } else {
        throw Exception('Clock in API failed');
      }
    } catch (err) {
      print('❌ Clock In Error: $err');

      if (LoadingService.to.isLoading) {
        LoadingService.to.hide();
      }

      CustomSnackbar.show(
        context,
        title: "Clock In Failed",
        message: "You have already clocked out for the day",
      );
      return false;
    } finally {
      loading.value = false;
    }
  }
  */
  /// Modified Clock Out with location permission enforcement
  Future<bool> performClockOut(BuildContext context) async {
    loading.value = true;
    try {
      print('📍 Starting Clock Out Process');

      // Step 1: Show selfie dialog immediately
      final selfieFile = await _showSelfieDialog(context, 'Clock Out');

      if (selfieFile == null) {
        print('❌ Selfie capture cancelled');
        CustomSnackbar.show(
          context,
          title: "Clock Out Cancelled",
          message: "Selfie is required for clock out",
        );
        return false;
      }

      print('✅ Selfie captured: ${selfieFile.path}');

      // ✅ Step 2: ENFORCE location permission check (NEW - same as clock in)
      await _updatePermissionStatus();

      if (!hasLocationPermission.value && !hasLocationAlwaysPermission.value) {
        print('❌ No location permission available on clock out');
        final hasPermission = await _checkLocationPermissionFlexible(context);
        if (!hasPermission) {
          CustomSnackbar.show(
            context,
            title: "Permission Required",
            message: "Location permission is needed for clock out",
          );
          return false;
        }
      }

      // Step 3: Collect location for clock out
      Position? currentPosition;
      print('🗺️ Starting location collection for clock out...');

      if (await _canGetLocation()) {
        print('📍 Location services available');
        try {
          currentPosition = await _getCurrentLocation();

          if (currentPosition == null) {
            print('⚠️ Position null, checking location services...');
            bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
            print('Service enabled: $serviceEnabled');

            if (!serviceEnabled) {
              final shouldEnable = await _showLocationServiceDialog(context);
              if (shouldEnable) {
                await Future.delayed(const Duration(seconds: 2));
                currentPosition = await _getCurrentLocation();
              }
            }
          }
        } catch (e) {
          print('❌ Exception while getting location: $e');
        }
      } else {
        print('⚠️ Cannot get location - requesting permission again...');
        // ✅ Last attempt - show location access screen if needed
        final granted = await _checkLocationPermissionFlexible(context);
        if (granted) {
          currentPosition = await _getCurrentLocation();
        }
      }

      // Step 4: Validate we have coordinates (STRICT CHECK)
      if (currentPosition == null) {
        print('❌ CRITICAL: No location coordinates available');

        // ✅ Show error and prevent clock out without location
        CustomSnackbar.show(
          context,
          title: "Location Required",
          message: "Unable to get your location. Please enable location services and try again.",
        );
        return false; // ← BLOCK clock out if no location
      }

      // Step 5: Log location status
      print('✅ SUCCESS - Will clock out with coordinates');
      print('📍 Latitude: ${currentPosition.latitude}');
      print('📍 Longitude: ${currentPosition.longitude}');

      // Step 6: Make API call with location and selfie
      print('📤 Making Clock Out API call...');
      final response = await apiClient.clockOut(
        latitude: currentPosition.latitude, // ← Guaranteed non-null now
        longitude: currentPosition.longitude,
        clockOutImage: selfieFile,
      );

      print('✅ Clock Out API Response: $response');

      // Stop SDK tracking only if geosentry was being used
      if (shouldUseGeosentry) {
        try {
          await stopTracking();
          print('✅ SDK tracking stopped successfully');
        } catch (sdkError) {
          print('❌ Error stopping SDK tracking: $sdkError');
        }
      }

      // Refresh dashboard data
      await fetchDashboardData();

      // Build success message
      final message = shouldUseGeosentry
          ? "You have successfully clocked out with location tracking stopped"
          : "You have successfully clocked out with location data";

      CustomSnackbar.show(
        context,
        title: "Clock Out Successful",
        message: message,
      );
      return true;

    } catch (err) {
      print('❌ Clock Out Error: $err');

      // Parse specific error messages
      String errorMessage = "Failed to clock out. Please try again";
      if (err.toString().contains('400')) {
        errorMessage = "Location permission is required. Please enable location and try again.";
      }

      CustomSnackbar.show(
        context,
        title: "Clock Out Failed",
        message: errorMessage,
      );
      return false;
    } finally {
      loading.value = false;
    }
  }


  /// uncomment if face issuein clock out
  /*
  Future<bool> performClockOut(BuildContext context) async {
    loading.value = true;
    try {
      print('📍 Starting Clock Out Process');

      // Step 1: Show selfie dialog immediately
      final selfieFile = await _showSelfieDialog(context, 'Clock Out');

      if (selfieFile == null) {
        print('❌ Selfie capture cancelled');
        CustomSnackbar.show(
          context,
          title: "Clock Out Cancelled",
          message: "Selfie is required for clock out",
        );
        return false;
      }

      print('✅ Selfie captured: ${selfieFile.path}');

      // Step 2: Collect location for clock out
      Position? currentPosition;
      print('🗺️ Starting location collection for clock out...');

      if (await _canGetLocation()) {
        print('📍 Location services available');
        try {
          currentPosition = await _getCurrentLocation();

          if (currentPosition == null) {
            bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
            print('Service enabled: $serviceEnabled');
          }
        } catch (e) {
          print('❌ Exception while getting location: $e');
        }
      }

      // Step 3: Log location status
      if (currentPosition != null) {
        print('✅ SUCCESS - Will clock out with coordinates');
        print('📍 Latitude: ${currentPosition.latitude}');
        print('📍 Longitude: ${currentPosition.longitude}');
      } else {
        print('⚠️ WARNING - Will clock out WITHOUT coordinates');
      }

      // Step 4: Make API call with location and selfie
      print('📤 Making Clock Out API call...');
      final response = await apiClient.clockOut(
        latitude: currentPosition?.latitude,
        longitude: currentPosition?.longitude,
        clockOutImage: selfieFile, // Add selfie file
      );

      print('✅ Clock Out API Response: $response');

      // Stop SDK tracking only if geosentry was being used
      if (shouldUseGeosentry) {
        try {
          await stopTracking();
          print('✅ SDK tracking stopped successfully');
        } catch (sdkError) {
          print('❌ Error stopping SDK tracking: $sdkError');
        }
      }

      // Refresh dashboard data
      await fetchDashboardData();

      // Build success message
      final locationMessage = currentPosition != null
          ? 'with location data'
          : '(location unavailable)';

      final message = shouldUseGeosentry
          ? "You have successfully clocked out $locationMessage and location tracking has been stopped"
          : "You have successfully clocked out $locationMessage";

      CustomSnackbar.show(
        context,
        title: "Clock Out Successful",
        message: message,
      );
      return true;

    } catch (err) {
      print('❌ Clock Out Error: $err');
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
  */

  /// Check if user has basic permission and prompt for Always permission
  Future<void> checkAndPromptForAlwaysPermission() async {
    try {
      await _updatePermissionStatus();

      // Only show if user has basic location but not Always permission
      if (hasLocationPermission.value && !hasLocationAlwaysPermission.value) {
        print('✅ User has "While Using App" - prompting for Always permission');

        final shouldUpgrade = await _showAlwaysPermissionDialog();
        if (shouldUpgrade) {
          final alwaysResult = await Permission.locationAlways.request();
          await _updatePermissionStatus();

          if (alwaysResult.isGranted) {
            CustomSnackbar.show(
              Get.context!,
              title: "Perfect!",
              message: "Full location tracking enabled for better attendance accuracy",
            );
          } else {
            CustomSnackbar.show(
              Get.context!,
              title: "Permission Status",
              message: "Continuing with 'While Using App' permission",
            );
          }
        }
      }
    } catch (e) {
      print('Error checking for Always permission: $e');
    }
  }

  /// Request location permission based on geosentry requirement
  Future<void> _requestLocationPermissionOnAppStart() async {
    if (permissionRequested.value) {
      return; // Already requested in this session
    }

    try {
      print('=== App Start - Checking Geosentry Requirement ===');

      // First check if geosentry is needed
      await fetchDashboardData();

      if (!shouldUseGeosentry) {
        print('ℹ️ Geosentry not required - skipping location permission request');
        return;
      }

      print('=== Geosentry Required - Requesting Location Permission ===');

      // Check current permission status for both types
      await _updatePermissionStatus();

      if (hasLocationAlwaysPermission.value) {
        print('✅ Already have "Allow all time" permission');
        return;
      }

      if (hasLocationPermission.value) {
        print('✅ Already have basic location permission');
        // NEW: Prompt for Always permission if user only has basic
        await checkAndPromptForAlwaysPermission();
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

      await _handleFlexiblePermissionRequest();

    } catch (e) {
      print('❌ Error requesting permission on app start: $e');
      // Don't crash - just continue without permission
    }
  }

  /// Update permission status for both permission types
  Future<void> _updatePermissionStatus() async {
    try {
      final locationStatus = await Permission.location.status;
      final locationAlwaysStatus = await Permission.locationAlways.status;

      hasLocationPermission.value = locationStatus.isGranted;
      hasLocationAlwaysPermission.value = locationAlwaysStatus.isGranted;

      print('Location permission: $locationStatus');
      print('Location Always permission: $locationAlwaysStatus');
    } catch (e) {
      print('Error updating permission status: $e');
      hasLocationPermission.value = false;
      hasLocationAlwaysPermission.value = false;
    }
  }

  /// Handle permission request with flexibility - accept both types
  Future<void> _handleFlexiblePermissionRequest() async {
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

      // Update status after basic permission
      await _updatePermissionStatus();

      // If basic permission granted, try for "Always" but don't force it
      if (hasLocationPermission.value && !hasLocationAlwaysPermission.value) {
        final shouldRequestAlways = await _showAlwaysPermissionDialog();
        if (shouldRequestAlways) {
          try {
            final alwaysResult = await Permission.locationAlways.request();
            await _updatePermissionStatus();

            if (alwaysResult.isGranted) {
              print('✅ Location Always permission granted');
              CustomSnackbar.show(
                Get.context!,
                title: "Perfect!",
                message: "Full location tracking enabled for best attendance accuracy",
              );
            } else {
              print('ℹ️ Location Always permission not granted, using basic permission');
              CustomSnackbar.show(
                Get.context!,
                title: "Permission Granted",
                message: "Basic location access granted. Consider enabling 'Always' for better accuracy",
              );
            }
          } catch (e) {
            print('Error requesting Always permission: $e');
            // Don't crash - basic permission is enough
          }
        }
      }

    } catch (e) {
      print('❌ Error in permission request flow: $e');
      // Update status to reflect current permissions
      await _updatePermissionStatus();
    }
  }

  /// Show dialog asking for "Always" permission (optional)
  Future<bool> _showAlwaysPermissionDialog() async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: appTheme.whiteA700,
        title: const Text('Enhanced Location Tracking'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enable "Allow all the time" for better accuracy?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: appTheme.theme,
              foregroundColor: appTheme.theme,
              textStyle: TextStyle(color: appTheme.whiteA700),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () => Get.back(result: true),
            child: const Text('Enable',style: TextStyle(color: Colors.white),),
          ),
        ],
      ),
      barrierDismissible: true,
    );
    return result ?? false;
  }

  /// Show permission dialog on app start
  Future<bool> _showAppStartPermissionDialog() async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: appTheme.whiteA700,
        title: const Text('Location Permission Required'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This app requires location access for attendance tracking.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text('Location is used for:'),
            Text('• Accurate attendance tracking'),
            Text('• Location-based clock in/out'),
            Text('• Compliance monitoring'),
            SizedBox(height: 12),
            Text(
              'We recommend "Allow all the time" but "While using the app" also works.',
              style: TextStyle(color: Colors.blue, fontSize: 12),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: appTheme.theme,
              foregroundColor: appTheme.theme,
              textStyle: TextStyle(color: appTheme.whiteA700),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () => Get.back(result: true),
            child: const Text('Grant Permission', style: TextStyle(color: Colors.white),),
          ),
        ],
      ),
      barrierDismissible: false,
    );
    return result ?? false;
  }
/*
  /// Modified clock in method with enhanced location handling
  Future<bool> performClockIn(BuildContext context) async {
    loading.value = true;

    try {
      print('=== Starting Clock In Process ===');

      // Always request location permission for coordinate collection
      await _updatePermissionStatus();

      // Check if we can get basic location (for coordinates)
      if (!hasLocationPermission.value && !hasLocationAlwaysPermission.value) {
        print('❌ No location permission available');

        final hasPermission = await _checkLocationPermissionFlexible(context);
        if (!hasPermission) {
          CustomSnackbar.show(
            context,
            title: "Permission Required",
            message: "Location permission is needed for attendance tracking",
          );
          return false;
        }
      }

      // ENHANCED LOCATION COLLECTION
      Position? currentPosition;
      print('🌍 Starting location collection process...');

      // Test location capability first
      await _testLocationNow();

      if (await _canGetLocation()) {
        print('✅ Location services available, attempting to get coordinates...');

        try {
          // Show loading indicator for location
          print('📍 Getting current position...');
          currentPosition = await _getCurrentLocation();

          if (currentPosition == null) {
            print('⚠️ Current position is null, checking location services...');

            // Check if location services are disabled
            bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
            print('📍 Service enabled after null result: $serviceEnabled');

            if (!serviceEnabled) {
              print('❌ Location services disabled, prompting user...');
              final shouldEnable = await _showLocationServiceDialog(context);
              if (!shouldEnable) {
                print('❌ User declined to enable location services');
                // Continue without location
              } else {
                print('📍 User agreed to enable location, trying again...');
                // Give user time to enable location services
                await Future.delayed(const Duration(seconds: 2));
                currentPosition = await _getCurrentLocation();
              }
            }
          }

        } catch (e) {
          print('⚠️ Exception while getting location: $e');
          print('⚠️ Exception type: ${e.runtimeType}');

          // Try one more time with lower accuracy
          try {
            print('📍 Trying one more time with low accuracy...');
            currentPosition = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.low,
              timeLimit: const Duration(seconds: 5),
            );
          } catch (finalError) {
            print('❌ Final location attempt failed: $finalError');
          }
        }
      } else {
        print('❌ Cannot get location - services not available or no permission');
      }

      // Enhanced logging for location status
      if (currentPosition != null) {
        print('✅ SUCCESS: Will clock in with coordinates:');
        print('   📍 Latitude: ${currentPosition.latitude}');
        print('   📍 Longitude: ${currentPosition.longitude}');
        print('   📍 Accuracy: ${currentPosition.accuracy}m');
      } else {
        print('⚠️ WARNING: Will clock in WITHOUT coordinates');
        print('⚠️ This might cause empty location in API response');
      }

      print('🌐 Making API call...');

      // Proceed with clock in API call (with or without coordinates)
      final response = await apiClient.clockIn(
        latitude: currentPosition?.latitude,
        longitude: currentPosition?.longitude,
      );

      print('📡 Clock In API Response: $response');

      // Check the response for location data
      if (response is Map<String, dynamic> && response.containsKey('data')) {
        final data = response['data'];
        if (data is Map<String, dynamic> && data.containsKey('clock_in_location')) {
          print('📍 API returned clock_in_location: "${data['clock_in_location']}"');

          if (data['clock_in_location'] == '' || data['clock_in_location'] == ',') {
            print('⚠️ WARNING: API received empty location data!');
          } else {
            print('✅ API successfully received location data');
          }
        }
      }

      if (response is Map<String, dynamic> && response['status'] == true) {

        // Check if geosentry initialization is required
        if (shouldUseGeosentry && response.containsKey('geosentry')) {
          final geosentry = response['geosentry'];
          final String userId = geosentry['user_id'] ?? '';
          final String apiKey = geosentry['api_key'] ?? '';
          final String cipherKey = geosentry['ciper_key'] ?? '';

          print('=== Initializing Geosentry SDK (Required) ===');

          // For geosentry, we need enhanced location permissions
          if (!hasLocationAlwaysPermission.value) {
            final shouldUpgrade = await _showAlwaysPermissionDialog();
            if (shouldUpgrade) {
              await Permission.locationAlways.request();
              await _updatePermissionStatus();
            }
          }

          try {
            // Show loading overlay during SDK initialization (use named parameters)
            LoadingService.to.show(
              message: 'Initializing Location Tracking...',
              color: appTheme.theme,
              backgroundColor: Colors.black.withOpacity(0.7),
            );

            await _initializeGeosentrySDKSafe(apiKey, cipherKey, userId);

            // Hide loading overlay after SDK initialization
            LoadingService.to.hide();

            await fetchDashboardData();

            final trackingMessage = hasLocationAlwaysPermission.value
                ? "You have successfully clocked in with full location tracking"
                : "You have successfully clocked in with basic location tracking";

            CustomSnackbar.show(
              context,
              title: "Clock In Successful",
              message: trackingMessage,
            );
            return true;

          } catch (sdkError) {
            print('Geosentry SDK initialization failed: $sdkError');

            // Hide loading overlay on error
            LoadingService.to.hide();

            await fetchDashboardData();

            CustomSnackbar.show(
              context,
              title: "Clock In Successful",
              message: "Clocked in successfully (limited location features)",
            );
            return true;
          }

        } else {
          // Simple clock in without geosentry
          print('✅ Simple clock in successful');
          await fetchDashboardData();

          final locationMessage = currentPosition != null
              ? "You have successfully clocked in with location data"
              : "You have successfully clocked in (location unavailable)";

          CustomSnackbar.show(
            context,
            title: "Clock In Successful",
            message: locationMessage,
          );
          return true;
        }
      } else {
        throw Exception('Clock in API failed');
      }

    } catch (err) {
      print('❌ Clock In Error: $err');
      print('❌ Error type: ${err.runtimeType}');

      // Make sure to hide loading if any error occurs
      if (LoadingService.to.isLoading) {
        LoadingService.to.hide();
      }

      CustomSnackbar.show(
        context,
        title: "Clock In Failed",
        message: "Failed to clock in. You have already clocked out for the day.",
      );
      return false;
    } finally {
      loading.value = false;
    }
  }


 */
  /// Get current location coordinates with enhanced debugging
  Future<Position?> _getCurrentLocation() async {
    try {
      print('🌍 === GET CURRENT LOCATION START ===');

      // Check location service status
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      print('📍 Location service enabled: $serviceEnabled');
      if (!serviceEnabled) {
        print('❌ Location services are disabled');

        // Try to prompt user to enable location services
        bool opened = await Geolocator.openLocationSettings();
        print('📍 Opened location settings: $opened');

        // Check again after potential user action
        serviceEnabled = await Geolocator.isLocationServiceEnabled();
        print('📍 Location service enabled after settings: $serviceEnabled');

        if (!serviceEnabled) {
          return null;
        }
      }

      // Check location permissions with detailed logging
      LocationPermission permission = await Geolocator.checkPermission();
      print('📍 Current permission status: $permission');

      if (permission == LocationPermission.denied) {
        print('📍 Permission denied, requesting...');
        permission = await Geolocator.requestPermission();
        print('📍 Permission after request: $permission');

        if (permission == LocationPermission.denied) {
          print('❌ Location permissions are denied after request');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('❌ Location permissions are permanently denied');
        return null;
      }

      print('✅ Permissions OK, getting position...');

      // Try multiple accuracy levels if high accuracy fails
      Position? position;

      try {
        print('📍 Trying high accuracy location...');
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 15),
        );
      } catch (timeoutError) {
        print('⚠️ High accuracy timed out, trying medium accuracy...');
        try {
          position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.medium,
            timeLimit: const Duration(seconds: 10),
          );
        } catch (mediumError) {
          print('⚠️ Medium accuracy failed, trying low accuracy...');
          position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.low,
            timeLimit: const Duration(seconds: 8),
          );
        }
      }

      if (position != null) {
        print('✅ Location obtained successfully:');
        print('   📍 Latitude: ${position.latitude}');
        print('   📍 Longitude: ${position.longitude}');
        print('   📍 Accuracy: ${position.accuracy}m');
        print('   📍 Timestamp: ${position.timestamp}');
        print('🌍 === GET CURRENT LOCATION SUCCESS ===');
        return position;
      } else {
        print('❌ Position is null');
        return null;
      }

    } catch (e) {
      print('❌ Error getting location: $e');
      print('❌ Error type: ${e.runtimeType}');
      return null;
    }
  }

  /// Enhanced check if location services are available
  Future<bool> _canGetLocation() async {
    try {
      print('🔍 Checking if we can get location...');

      // Check if location service is enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      print('📍 Service enabled: $serviceEnabled');
      if (!serviceEnabled) {
        return false;
      }

      // Check permission status with detailed logging
      LocationPermission permission = await Geolocator.checkPermission();
      print('📍 Permission status: $permission');

      bool canGet = permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;

      print('📍 Can get location: $canGet');
      return canGet;

    } catch (e) {
      print('❌ Error checking location availability: $e');
      return false;
    }
  }

  /// Test location immediately - for debugging
  Future<void> _testLocationNow() async {
    print('🧪 === TESTING LOCATION IMMEDIATELY ===');

    bool canGet = await _canGetLocation();
    print('🧪 Can get location: $canGet');

    if (canGet) {
      Position? pos = await _getCurrentLocation();
      if (pos != null) {
        print('🧪 Test successful: ${pos.latitude}, ${pos.longitude}');
      } else {
        print('🧪 Test failed: Position is null');
      }
    } else {
      print('🧪 Test skipped: Cannot get location');
    }

    print('🧪 === TEST LOCATION COMPLETE ===');
  }

  /// Check if location services are available and permission granted

  /// Show location service dialog
  Future<bool> _showLocationServiceDialog(BuildContext context) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: appTheme.whiteA700,
        title: const Text('Enable Location Services'),
        content: const Text(
          'Location services are required for accurate attendance tracking. Please enable location services and try again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back(result: true);
              await Geolocator.openLocationSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
  /// Flexible location permission check - same as your working code
  Future<bool> _checkLocationPermissionFlexible(BuildContext context) async {
    try {
      print('=== Checking Location Permission (Flexible) ===');

      // Check current permission status
      final locationStatus = await Permission.location.status;
      final locationAlwaysStatus = await Permission.locationAlways.status;

      print('Location permission status: $locationStatus');
      print('Location always permission status: $locationAlwaysStatus');

      // If any location permission is already granted, proceed
      if (locationStatus.isGranted || locationAlwaysStatus.isGranted) {
        print('✅ Location permission already granted');
        await _updatePermissionStatus();
        return true;
      }

      // Handle permanently denied case
      if (locationStatus.isPermanentlyDenied) {
        print('❌ Location permission permanently denied');
        await _showPermissionSettingsDialog(context);
        return false;
      }

      // For denied status, show explanation and request permission
      if (locationStatus.isDenied) {
        final shouldRequest = await _showPermissionExplanationDialog(context);
        if (!shouldRequest) {
          print('❌ User declined permission request');
          return false;
        }

        // Request location permissions (flexible approach)
        final results = await [
          Permission.location,
          Permission.locationWhenInUse,
        ].request();

        print('Permission request results: $results');

        // Check if any permission was granted
        final hasAnyLocationPermission = results.values.any((status) => status.isGranted);

        if (hasAnyLocationPermission) {
          print('✅ Location permission granted');
          await _updatePermissionStatus();
          return true;
        } else {
          print('❌ All location permissions denied');
          CustomSnackbar.show(
            context,
            title: "Permission Required",
            message: "Location permission is required for clock in functionality",
          );
          return false;
        }
      }

      return false;

    } catch (e) {
      print('❌ Error checking location permission: $e');
      // Don't crash - just return false
      return false;
    }
  }

  /// Safe SDK initialization with better error handling
  Future<void> _initializeGeosentrySDKSafe(String apiKey, String cipherKey, String userID) async {
    try {
      print('=== Initializing Geosentry SDK (Safe Mode) ===');

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

        if (!success && errorMessage.isNotEmpty) {
          print('❌ SDK initialization failed: $errorMessage');
          throw PlatformException(
            code: 'SDK_INIT_FAILED',
            message: 'SDK initialization failed',
            details: errorMessage,
          );
        }
      }

      print('✅ Geosentry SDK initialization SUCCESS');

    } catch (e) {
      print('❌ Geosentry SDK initialization FAILED: $e');
      rethrow;
    }
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
        print('Geosentry status: ${shouldUseGeosentry ? "Required" : "Not Required"}');

        if (dashboardData.value?.geosentryData != null) {
          final geoData = dashboardData.value!.geosentryData!;
          print('Geosentry ID: ${geoData.id}');
          print('Geosentry Status: ${geoData.status}');
        }

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

  /// Stop Geosentry SDK tracking

  /// Clock Out method with conditional geosentry stop
  /// Stop Geosentry SDK tracking
  Future<void> stopTracking() async {
    if (!shouldUseGeosentry) {
      print('ℹ️ Geosentry not required - skipping stop tracking');
      return;
    }

    try {
      print('=== Stopping Geosentry SDK Tracking ===');
      await platform.invokeMethod('stopTracking').timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw PlatformException(
            code: 'TIMEOUT',
            message: 'Stop tracking timed out',
          );
        },
      );
      print('✅ Geosentry SDK tracking stopped successfully');
    } catch (e) {
      print('❌ Failed to stop Geosentry SDK tracking: $e');
      // Don't rethrow - just log the error so clock-out continues
    }
  }


  /// Clock Out method with location tracking and conditional geosentry stop
  /*
  Future<bool> performClockOut(BuildContext context) async {
    loading.value = true;
    try {
      print('📍 Starting Clock Out Process with Location');

      // ✅ COLLECT LOCATION FOR CLOCK OUT (same as clock-in)
      Position? currentPosition;

      print('🗺️ Starting location collection for clock out...');

      // Check if location services are available
      if (await _canGetLocation()) {
        print('📍 Location services available, attempting to get coordinates...');

        try {
          // Get current position
          print('🔍 Getting current position for clock out...');
          currentPosition = await _getCurrentLocation();

          if (currentPosition == null) {
            print('⚠️ Current position is null, checking location services...');

            // Check if location services are disabled
            bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
            print('Service enabled after null result: $serviceEnabled');

            if (!serviceEnabled) {
              print('🚫 Location services disabled');
              // Continue without location - don't block clock-out
            }
          }
        } catch (e) {
          print('❌ Exception while getting location for clock out: $e');
          // Continue without location - don't block clock-out
        }
      } else {
        print('⚠️ Cannot get location - services not available or no permission');
        // Continue without location - don't block clock-out
      }

      // Enhanced logging for location status
      if (currentPosition != null) {
        print('✅ SUCCESS - Will clock out with coordinates');
        print('📍 Latitude: ${currentPosition.latitude}');
        print('📍 Longitude: ${currentPosition.longitude}');
        print('🎯 Accuracy: ${currentPosition.accuracy}m');
      } else {
        print('⚠️ WARNING - Will clock out WITHOUT coordinates');
        print('⚠️ This might cause empty location in API response');
      }

      // ✅ MAKE API CALL WITH LOCATION
      print('📤 Making Clock Out API call...');
      final response = await apiClient.clockOut(
        latitude: currentPosition?.latitude,
        longitude: currentPosition?.longitude,
      );

      print('✅ Clock Out API Response: $response');

      // Check the response for location data
      if (response is Map<String, dynamic> && response.containsKey('data')) {
        final data = response['data'];
        if (data is Map<String, dynamic> && data.containsKey('clockoutlocation')) {
          print('📍 API returned clockoutlocation: ${data['clockoutlocation']}');

          if (data['clockoutlocation'] == '' || data['clockoutlocation'] == null) {
            print('⚠️ WARNING - API received empty clock-out location data!');
          } else {
            print('✅ API successfully received clock-out location data');
          }
        }
      }

      // Stop SDK tracking only if geosentry was being used
      if (shouldUseGeosentry) {
        try {
          await stopTracking();
          print('✅ SDK tracking stopped successfully');
        } catch (sdkError) {
          print('❌ Error stopping SDK tracking: $sdkError');
          // Don't fail the clock-out if SDK stop fails
        }
      }

      // Refresh dashboard data to get updated attendance
      await fetchDashboardData();

      // Build success message
      final locationMessage = currentPosition != null
          ? 'with location data'
          : '(location unavailable)';

      final message = shouldUseGeosentry
          ? "You have successfully clocked out $locationMessage and location tracking has been stopped"
          : "You have successfully clocked out $locationMessage";

      CustomSnackbar.show(
        context,
        title: "Clock Out Successful",
        message: message,
      );
      return true;
    } catch (err) {
      print('❌ Clock Out Error: $err');
      print('❌ Error type: ${err.runtimeType}');
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


   */
  /*
  /// Clock Out method with conditional geosentry stop
  Future<bool> performClockOut(BuildContext context) async {
    loading.value = true;
    try {
      final response = await apiClient.clockOut();
      print('Clock Out Success: $response');

      // Stop SDK tracking only if geosentry was being used
      if (shouldUseGeosentry) {
        try {
          await stopTracking();
          print('✅ SDK tracking stopped successfully');
        } catch (sdkError) {
          print('❌ Error stopping SDK tracking: $sdkError');
          // Don't fail the clock-out if SDK stop fails
        }
      }

      // Refresh dashboard data to get updated attendance
      await fetchDashboardData();

      final message = shouldUseGeosentry
          ? "You have successfully clocked out and location tracking has been stopped"
          : "You have successfully clocked out";

      CustomSnackbar.show(
        context,
        title: "Clock Out Successful",
        message: message,
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
*/
  // Show explanation dialog before requesting permission
  Future<bool> _showPermissionExplanationDialog(BuildContext context) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: appTheme.whiteA700,
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
          'Please enable location permission in app settings to use attendance tracking.',
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

  // Get assigned leads count
  int get assignedLeads => dashboardData.value?.assignedLeads ?? 0;

  // Get assigned applications count
  int get assignedApplications => dashboardData.value?.assignedApplications ?? 0;
  int get sanctionedApplications => dashboardData.value?.sanctioned_applications ?? 0;
  int get inprogress => dashboardData.value?.in_progress_applications ?? 0;
  int get totalapplications =>dashboardData.value?.total_applications??0;


  // Get converted leads count
  int get convertedLeads => dashboardData.value?.convertedLeads ?? 0;

  // Refresh dashboard data
  Future<void> refreshDashboard() async {
    await fetchDashboardData();
  }
}

/*
class HomeController extends GetxController {
  final ApiClient apiClient = ApiClient();
  static const platform = MethodChannel('com.geosentry.sdk/channel');

  // Loading states
  var loading = false.obs;
  var dashboardLoading = false.obs;

  // Permission state - track both types of permissions
  var hasLocationPermission = false.obs;
  var hasLocationAlwaysPermission = false.obs;
  var permissionRequested = false.obs;

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
  /// Check if user has basic permission and prompt for Always permission
  Future<void> checkAndPromptForAlwaysPermission() async {
    try {
      await _updatePermissionStatus();

      // Only show if user has basic location but not Always permission
      if (hasLocationPermission.value && !hasLocationAlwaysPermission.value) {
        print('✅ User has "While Using App" - prompting for Always permission');

        final shouldUpgrade = await _showAlwaysPermissionDialog();
        if (shouldUpgrade) {
          final alwaysResult = await Permission.locationAlways.request();
          await _updatePermissionStatus();

          if (alwaysResult.isGranted) {
            CustomSnackbar.show(
              Get.context!,
              title: "Perfect!",
              message: "Full location tracking enabled for better attendance accuracy",
            );
          } else {
            CustomSnackbar.show(
              Get.context!,
              title: "Permission Status",
              message: "Continuing with 'While Using App' permission",
            );
          }
        }
      }
    } catch (e) {
      print('Error checking for Always permission: $e');
    }
  }

  /// Request location permission immediately when app starts - flexible approach
  /// Request location permission immediately when app starts - flexible approach
  Future<void> _requestLocationPermissionOnAppStart() async {
    if (permissionRequested.value) {
      return; // Already requested in this session
    }

    try {
      print('=== App Start - Requesting Location Permission ===');

      // Check current permission status for both types
      await _updatePermissionStatus();

      if (hasLocationAlwaysPermission.value) {
        print('✅ Already have "Allow all time" permission');
        return;
      }

      if (hasLocationPermission.value) {
        print('✅ Already have basic location permission');
        // NEW: Prompt for Always permission if user only has basic
        await checkAndPromptForAlwaysPermission();
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

      await _handleFlexiblePermissionRequest();

    } catch (e) {
      print('❌ Error requesting permission on app start: $e');
      // Don't crash - just continue without permission
    }
  }

  /// Update permission status for both permission types
  Future<void> _updatePermissionStatus() async {
    try {
      final locationStatus = await Permission.location.status;
      final locationAlwaysStatus = await Permission.locationAlways.status;

      hasLocationPermission.value = locationStatus.isGranted;
      hasLocationAlwaysPermission.value = locationAlwaysStatus.isGranted;

      print('Location permission: $locationStatus');
      print('Location Always permission: $locationAlwaysStatus');
    } catch (e) {
      print('Error updating permission status: $e');
      hasLocationPermission.value = false;
      hasLocationAlwaysPermission.value = false;
    }
  }

  /// Handle permission request with flexibility - accept both types
  Future<void> _handleFlexiblePermissionRequest() async {
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

      // Update status after basic permission
      await _updatePermissionStatus();

      // If basic permission granted, try for "Always" but don't force it
      if (hasLocationPermission.value && !hasLocationAlwaysPermission.value) {
        final shouldRequestAlways = await _showAlwaysPermissionDialog();
        if (shouldRequestAlways) {
          try {
            final alwaysResult = await Permission.locationAlways.request();
            await _updatePermissionStatus();

            if (alwaysResult.isGranted) {
              print('✅ Location Always permission granted');
              CustomSnackbar.show(
                Get.context!,
                title: "Perfect!",
                message: "Full location tracking enabled for best attendance accuracy",
              );
            } else {
              print('ℹ️ Location Always permission not granted, using basic permission');
              CustomSnackbar.show(
                Get.context!,
                title: "Permission Granted",
                message: "Basic location access granted. Consider enabling 'Always' for better accuracy",
              );
            }
          } catch (e) {
            print('Error requesting Always permission: $e');
            // Don't crash - basic permission is enough
          }
        }
      }

    } catch (e) {
      print('❌ Error in permission request flow: $e');
      // Update status to reflect current permissions
      await _updatePermissionStatus();
    }
  }

  /// Show recommendation for "Always" permission (non-blocking)
  void _showAlwaysPermissionRecommendation() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.context != null) {
        CustomSnackbar.show(
          Get.context!,
          title: "Tip",
          message: "For better accuracy, consider enabling 'Allow all the time' in app settings",
        );
      }
    });
  }

  /// Show dialog asking for "Always" permission (optional)
  Future<bool> _showAlwaysPermissionDialog() async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: appTheme.whiteA700,


        title: const Text('Enhanced Location Tracking'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enable "Allow all the time" for better accuracy?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
          ],
        ),
        actions: [
          // TextButton(
          //   onPressed: () => Get.back(result: false),
          //   child: const Text('Skip'),
          // ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: appTheme.theme,
              foregroundColor: appTheme.theme,
              textStyle: TextStyle(color: appTheme.whiteA700),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () => Get.back(result: true),
            child: const Text('Enable',style: TextStyle(color: Colors.white),),
          ),
        ],
      ),
      barrierDismissible: true,
    );
    return result ?? false;
  }

  /// Show permission dialog on app start
  Future<bool> _showAppStartPermissionDialog() async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: appTheme.whiteA700,
        title: const Text('Location Permission Required'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This app requires location access for attendance tracking.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text('Location is used for:'),
            Text('• Accurate attendance tracking'),
            Text('• Location-based clock in/out'),
            Text('• Compliance monitoring'),
            SizedBox(height: 12),
            Text(
              'We recommend "Allow all the time" but "While using the app" also works.',
              style: TextStyle(color: Colors.blue, fontSize: 12),
            ),
          ],
        ),
        actions: [
          // TextButton(
          //   onPressed: () => Get.back(result: false),
          //   child: const Text('Not Now'),
          // ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: appTheme.theme,
              foregroundColor: appTheme.theme,
              textStyle: TextStyle(color: appTheme.whiteA700),

              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () => Get.back(result: true),
            child: const Text('Grant Permission', style: TextStyle(color: Colors.white),),
          ),

        ],
      ),
      barrierDismissible: false,
    );
    return result ?? false;
  }

  /// Flexible clock in - works with any location permission
  Future<bool> performClockIn(BuildContext context) async {
    loading.value = true;

    try {
      print('=== Starting Clock In Process ===');

      // Update current permission status
      await _updatePermissionStatus();

      // Check if we have ANY location permission (flexible approach)
      if (!hasLocationPermission.value && !hasLocationAlwaysPermission.value) {
        print('❌ No location permission available');

        // Try to get permission through flexible check
        final hasPermission = await _checkLocationPermissionFlexible(context);
        if (!hasPermission) {
          CustomSnackbar.show(
            context,
            title: "Permission Required",
            message: "Location permission is needed for attendance tracking",
          );
          return false;
        }
      }

      final permissionType = hasLocationAlwaysPermission.value ? "Always" : "Basic";
      print('✅ Location permission confirmed: $permissionType');

      // Proceed with clock in API call
      final response = await apiClient.clockIn();
      print('Clock In API Response: $response');
      // ADD DETAILED DEBUGGING
      print('=== API RESPONSE DEBUGGING ===');
      print('Response type: ${response.runtimeType}');
      print('Full response: $response');

      if (response is Map<String, dynamic>) {
        print('Response keys: ${response.keys.toList()}');
        print('Status: ${response['status']}');
        print('Contains geosentry: ${response.containsKey('geosentry')}');

        if (response.containsKey('geosentry')) {
          print('Geosentry data: ${response['geosentry']}');
        } else {
          print('❌ NO GEOSENTRY DATA FOUND IN RESPONSE');
          print('Available keys: ${response.keys.toList()}');
        }
      }
      if (response is Map<String, dynamic> &&
          response['status'] == true &&
          response.containsKey('geosentry')) {

        final geosentry = response['geosentry'];
        final String userId = geosentry['user_id'] ?? '';
        final String apiKey = geosentry['api_key'] ?? '';
        final String cipherKey = geosentry['ciper_key'] ?? '';

        print('=== Geosentry SDK Initialization ===');

        try {
          // Initialize SDK with flexible permission handling
          await _initializeGeosentrySDKSafe(apiKey, cipherKey, userId);

          await fetchDashboardData();

          final trackingMessage = hasLocationAlwaysPermission.value
              ? "You have successfully clocked in with full location tracking"
              : "You have successfully clocked in with basic location tracking";

          CustomSnackbar.show(
            context,
            title: "Clock In Successful",
            message: trackingMessage,
          );
          return true;

        } catch (sdkError) {
          print('Geosentry SDK initialization failed: $sdkError');

          // Don't fail the clock-in, just show limited functionality
          await fetchDashboardData();

          CustomSnackbar.show(
            context,
            title: "Clock In Successful",
            message: "Clocked in successfully (limited location features)",
          );
          return true; // Still count as successful clock-in
        }
      } else {
        // Handle case where geosentry data is missing
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

  /// Flexible location permission check - same as your working code
  Future<bool> _checkLocationPermissionFlexible(BuildContext context) async {
    try {
      print('=== Checking Location Permission (Flexible) ===');

      // Check current permission status
      final locationStatus = await Permission.location.status;
      final locationAlwaysStatus = await Permission.locationAlways.status;

      print('Location permission status: $locationStatus');
      print('Location always permission status: $locationAlwaysStatus');

      // If any location permission is already granted, proceed
      if (locationStatus.isGranted || locationAlwaysStatus.isGranted) {
        print('✅ Location permission already granted');
        await _updatePermissionStatus();
        return true;
      }

      // Handle permanently denied case
      if (locationStatus.isPermanentlyDenied) {
        print('❌ Location permission permanently denied');
        await _showPermissionSettingsDialog(context);
        return false;
      }

      // For denied status, show explanation and request permission
      if (locationStatus.isDenied) {
        final shouldRequest = await _showPermissionExplanationDialog(context);
        if (!shouldRequest) {
          print('❌ User declined permission request');
          return false;
        }

        // Request location permissions (flexible approach)
        final results = await [
          Permission.location,
          Permission.locationWhenInUse,
        ].request();

        print('Permission request results: $results');

        // Check if any permission was granted
        final hasAnyLocationPermission = results.values.any((status) => status.isGranted);

        if (hasAnyLocationPermission) {
          print('✅ Location permission granted');
          await _updatePermissionStatus();
          return true;
        } else {
          print('❌ All location permissions denied');
          CustomSnackbar.show(
            context,
            title: "Permission Required",
            message: "Location permission is required for clock in functionality",
          );
          return false;
        }
      }

      return false;

    } catch (e) {
      print('❌ Error checking location permission: $e');
      // Don't crash - just return false
      return false;
    }
  }

  /// Safe SDK initialization with better error handling
  Future<void> _initializeGeosentrySDKSafe(String apiKey, String cipherKey, String userID) async {
    try {
      print('=== Initializing Geosentry SDK (Safe Mode) ===');

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

        if (!success && errorMessage.isNotEmpty) {
          print('❌ SDK initialization failed: $errorMessage');
          // Don't throw - let calling method handle gracefully
          throw PlatformException(
            code: 'SDK_INIT_FAILED',
            message: 'SDK initialization failed',
            details: errorMessage,
          );
        }
      }

      print('✅ Geosentry SDK initialization SUCCESS');

    } catch (e) {
      print('❌ Geosentry SDK initialization FAILED: $e');
      // Re-throw to be handled gracefully by calling method
      rethrow;
    }
  }

  // Rest of your existing methods remain the same...

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

  /// Stop Geosentry SDK tracking
  Future<void> stopTracking() async {
    try {
      print('=== Stopping Geosentry SDK Tracking ===');

      await platform.invokeMethod('stopTracking').timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw PlatformException(
            code: 'TIMEOUT',
            message: 'Stop tracking timed out',
          );
        },
      );

      print('✅ Geosentry SDK tracking stopped successfully');

    } catch (e) {
      print('❌ Failed to stop Geosentry SDK tracking: $e');
      // Don't rethrow - just log the error so clock-out continues
    }
  }

// Clock Out method
// Clock Out method
  Future<bool> performClockOut(BuildContext context) async {
    loading.value = true;
    try {
      final response = await apiClient.clockOut();
      print('Clock Out Success: $response');

      // Stop SDK tracking when user clocks out
      try {
        await stopTracking(); // Add 'await' here
        print('✅ SDK tracking stopped successfully');
      } catch (sdkError) {
        print('❌ Error stopping SDK tracking: $sdkError');
        // Don't fail the clock-out if SDK stop fails
      }

      // Refresh dashboard data to get updated attendance
      await fetchDashboardData();

      CustomSnackbar.show(
        context,
        title: "Clock Out Successful",
        message: "You have successfully clocked out and location tracking has been stopped",
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

  // Show explanation dialog before requesting permission
  Future<bool> _showPermissionExplanationDialog(BuildContext context) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: appTheme.whiteA700,
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
          'Please enable location permission in app settings to use attendance tracking.',
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

  // Debug method to manually test SDK initialization
  Future<void> testGeosentrySDK() async {
    // Test values - replace with actual values for testing
    await _initializeGeosentrySDKSafe(
        'test_api_key',
        'test_cipher_key',
        'test_user_id'
    );
  }
}
*/