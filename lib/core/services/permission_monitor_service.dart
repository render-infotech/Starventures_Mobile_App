import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../app_routes.dart';

class PermissionMonitorService extends GetxService {
  static PermissionMonitorService get to => Get.find();

  Timer? _permissionTimer;
  bool _isMonitoring = false;
  bool _wasPermissionGranted = false;

  /// Start monitoring location permission
  void startMonitoring() {
    if (_isMonitoring) return;

    print('🔍 Starting permission monitoring...');
    _isMonitoring = true;

    // Check initial permission status
    _checkInitialPermission();

    // Monitor every 2 seconds
    _permissionTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _checkPermissionStatus();
    });
  }

  /// Stop monitoring location permission
  void stopMonitoring() {
    print('🛑 Stopping permission monitoring...');
    _isMonitoring = false;
    _permissionTimer?.cancel();
    _permissionTimer = null;
  }

  /// Check initial permission status
  Future<void> _checkInitialPermission() async {
    try {
      final alwaysStatus = await Permission.locationAlways.status;
      _wasPermissionGranted = alwaysStatus.isGranted;
      print('📍 Initial permission status: $_wasPermissionGranted');
    } catch (e) {
      print('❌ Error checking initial permission: $e');
    }
  }

  /// Check current permission status
  Future<void> _checkPermissionStatus() async {
    try {
      final alwaysStatus = await Permission.locationAlways.status;
      final isCurrentlyGranted = alwaysStatus.isGranted;

      // If permission was granted but now it's not, redirect to permission screen
      if (_wasPermissionGranted && !isCurrentlyGranted) {
        print('🚨 PERMISSION REMOVED! Redirecting to permission screen...');

        // Stop monitoring while redirecting
        stopMonitoring();

        // Show immediate feedback
        Get.snackbar(
          '⚠️ Permission Removed',
          'Location permission was removed. Redirecting to permission screen...',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
          isDismissible: false,
        );

        // Wait a moment for snackbar visibility
        await Future.delayed(const Duration(milliseconds: 500));

        // Redirect to permission screen
        Get.offAllNamed(AppRoutes.permissionGate);
      }

      // Update the tracked status
      _wasPermissionGranted = isCurrentlyGranted;

    } catch (e) {
      print('❌ Error checking permission status: $e');
    }
  }

  @override
  void onClose() {
    stopMonitoring();
    super.onClose();
  }
}
