import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../core/data/api_client/api_client.dart';
import '../../../core/utils/custom_snackbar.dart';

class HomeController extends GetxController {
  final ApiClient apiClient = ApiClient();
  var loading = false.obs;

  // Clock In method
  Future<bool> performClockIn(BuildContext context) async {
    loading.value = true;
    try {
      final response = await apiClient.clockIn();
      print('Clock In Success: $response');

      CustomSnackbar.show(
        context,
        title: "Clock In Successful",
        message: "You have successfully clocked in",
      );
      return true;
    } catch (err) {
      print('Clock In Error: $err');
      CustomSnackbar.show(
        context,
        title: "Clock In Failed",
        message: "Failed to clock in. Please try again",
      );
      return false;
    } finally {
      loading.value = false;
    }
  }

  // Clock Out method
  Future<bool> performClockOut(BuildContext context) async {
    loading.value = true;
    try {
      final response = await apiClient.clockOut();
      print('Clock Out Success: $response');

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
}
