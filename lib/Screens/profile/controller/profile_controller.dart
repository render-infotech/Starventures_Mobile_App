import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/data/api_client/api_client.dart';

// Models
import '../../../core/data/api_constant/api_constant.dart';
import '../model/profile_models.dart';
import '../model/relationship_manager_model.dart';

class ProfileController extends GetxController {
  final ApiClient _api = ApiClient();

  final loading = false.obs;
  final profileLoading = false.obs;
  final rmLoading = false.obs; // ✅ Add RM loading state

  final userName = ''.obs;
  final userEmail = ''.obs;
  final userPhone = ''.obs;
  final employeeId = ''.obs;
  final role = 'employee'.obs;
  final avatarUrl = RxnString();

  // ✅ Add RM observables
  final rmName = RxnString();
  final rmPhone = RxnString();

  final pickedImagePath = RxnString();
  File? get pickedImageFile =>
      pickedImagePath.value == null ? null : File(pickedImagePath.value!);

  final _picker = ImagePicker();
  ProfileResponse? profile;
  RelationshipManagerResponse? relationshipManager; // ✅ Add RM response
// ✅ Add feedback submission state
  final isFeedbackSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
    loadRelationshipManager(); // ✅ Load RM on init
  }

  Future<void> loadProfile() async {
    profileLoading.value = true;
    print('[Profile] loadProfile() -> start');
    try {
      final map = await _api.fetchProfile();
      print('[Profile] loadProfile() -> success');
      print('[Profile] loadProfile() -> raw response: $map');
      final res = ProfileResponse.fromJson(map);
      profile = res;

      final name = res.data.user.name.isNotEmpty
          ? res.data.user.name
          : res.data.employee.name;

      userName.value = name;
      userEmail.value = res.data.employee.email ?? res.data.user.email;

      // ✅ FIX: Check both employee.phone and user.phone
      userPhone.value = res.data.employee.phone ?? res.data.user.phone ?? '';

      employeeId.value = res.data.employee.employeeId ?? '';
      role.value = res.data.user.type ?? 'employee';

      avatarUrl.value = res.data.avatarUrl?.isNotEmpty == true
          ? res.data.avatarUrl
          : null;

      print('[Profile] loadProfile() mapped fields: '
          'name="$name", email="${userEmail.value}", phone="${userPhone.value}", '
          'employeeId="${employeeId.value}", role="${role.value}", avatar="${avatarUrl.value}"');
    } catch (e, st) {
      print('[Profile] loadProfile() -> ERROR: $e\n$st');
      //Get.snackbar('Error', 'Failed to load profile');
    } finally {
      profileLoading.value = false;
      print('[Profile] loadProfile() -> end');
    }
  }

  // ✅ Load Relationship Manager
// lib/Screens/profile/controller/profile_controller.dart

// ✅ UPDATED: Clear RM data before loading
  Future<void> loadRelationshipManager() async {
    rmLoading.value = true;

    // ✅ CRITICAL: Reset RM data FIRST to clear previous login data
    rmName.value = null;
    rmPhone.value = null;
    relationshipManager = null;

    print('[RM] loadRelationshipManager() -> start');
    try {
      final map = await _api.fetchRelationshipManager();
      print('[RM] loadRelationshipManager() -> success');
      print('[RM] loadRelationshipManager() -> raw response: $map');

      final res = RelationshipManagerResponse.fromJson(map);
      relationshipManager = res;

      rmName.value = res.data.relationshipManager.name;
      rmPhone.value = res.data.relationshipManager.phone;

      print('[RM] loadRelationshipManager() mapped fields: '
          'name="${rmName.value}", phone="${rmPhone.value}"');
    } catch (e, st) {
      print('[RM] loadRelationshipManager() -> ERROR: $e\n$st');
      // ✅ Already cleared at the start, so this is safe
      rmName.value = null;
      rmPhone.value = null;
    } finally {
      rmLoading.value = false;
      print('[RM] loadRelationshipManager() -> end');
    }
  }

// ✅ Updated messageRM - Simple approach with proper error handling
  Future<void> messageRM() async {
    if (rmPhone.value == null || rmPhone.value!.isEmpty) {
      Get.snackbar('Error', 'No phone number available');
      return;
    }

    final cleanPhone = rmPhone.value!.replaceAll(RegExp(r'[^\d+]'), '');
    print('[RM] messageRM() -> Opening SMS for: $cleanPhone');

    try {
      final uri = Uri.parse('sms:$cleanPhone');

      if (await canLaunchUrl(uri)) {
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );

        if (!launched) {
          throw Exception('Failed to launch SMS app');
        }

        print('[RM] messageRM() -> SMS app opened successfully');
      } else {
        throw Exception('No SMS app available');
      }
    } catch (e) {
      print('[RM] messageRM() -> ERROR: $e');

      // Show phone number as fallback
      Get.snackbar(
        'Unable to Open Messaging App',
        'Please send a message to: $cleanPhone',
        duration: const Duration(seconds: 5),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.black87,
        isDismissible: true,
      );
    }
  }

// ✅ Updated callRM - Ensure it uses proper error handling too
  Future<void> callRM() async {
    if (rmPhone.value == null || rmPhone.value!.isEmpty) {
      Get.snackbar('Error', 'No phone number available');
      return;
    }

    final cleanPhone = rmPhone.value!.replaceAll(RegExp(r'[^\d+]'), '');
    print('[RM] callRM() -> Dialing: $cleanPhone');

    try {
      final uri = Uri.parse('tel:$cleanPhone');

      if (await canLaunchUrl(uri)) {
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );

        if (!launched) {
          throw Exception('Failed to launch phone dialer');
        }

        print('[RM] callRM() -> Phone dialer opened successfully');
      } else {
        throw Exception('No phone dialer available');
      }
    } catch (e) {
      print('[RM] callRM() -> ERROR: $e');

      Get.snackbar(
        'Unable to Make Call',
        'Please manually dial: $cleanPhone',
        duration: const Duration(seconds: 5),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.black87,
        isDismissible: true,
      );
    }
  }

  Future<void> submitUpdate() async {
    loading.value = true;
    final name = userName.value.trim();
    final email = userEmail.value.trim();
    final imgPath = pickedImagePath.value;

    print('[Profile] submitUpdate() -> start');
    print('[Profile] submitUpdate() payload: name="$name", email="$email", '
        'image=${imgPath == null ? 'null' : imgPath}');

    try {
      final map = await _api.updateProfileMultipart(
        name: name.isNotEmpty ? name : null,
        email: email.isNotEmpty ? email : null,
        profileImage: pickedImageFile,
      );

      print('[Profile] submitUpdate() -> API success');
      print('[Profile] submitUpdate() -> response: $map');
      final res = ProfileResponse.fromJson(map);
      profile = res;

      final newName = res.data.user.name.isNotEmpty
          ? res.data.user.name
          : res.data.employee.name;

      userName.value = newName;
      userEmail.value = res.data.employee.email ?? res.data.user.email;

      avatarUrl.value = res.data.avatarUrl?.isNotEmpty == true
          ? res.data.avatarUrl
          : null;

      pickedImagePath.value = null;

      print('[Profile] submitUpdate() -> mapped new fields: '
          'name="$newName", email="${userEmail.value}", avatar="${avatarUrl.value}"');

      Get.snackbar('Success', 'Profile updated');
    } catch (e, st) {
      print('[Profile] submitUpdate() -> ERROR: $e\n$st');
      Get.snackbar('Error', 'Update failed');
    } finally {
      loading.value = false;
      print('[Profile] submitUpdate() -> end');
    }
  }

  Future<void> pickImage() async {
    print('[Profile] pickImage() -> opening gallery');
    try {
      final xfile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (xfile != null) {
        pickedImagePath.value = xfile.path;
        print('[Profile] pickImage() -> picked: ${xfile.path}');
      } else {
        print('[Profile] pickImage() -> canceled by user');
      }
    } catch (e, st) {
      print('[Profile] pickImage() -> ERROR: $e\n$st');
      Get.snackbar('Error', 'Failed to pick image');
    }
  }

  Future<void> performLogout(BuildContext context) async {
    loading.value = true;
    print('[Profile] performLogout() -> start');
    try {
      final ok = await _api.logout();
      print('[Profile] performLogout() -> serverOk=$ok');
      if (!ok) {
        Get.snackbar('Notice', 'Logged out locally, server unreachable');
      }
      Get.offAllNamed('/login');
    } catch (e, st) {
      print('[Profile] performLogout() -> ERROR: $e\n$st');
      Get.snackbar('Error', 'Logout failed');
    } finally {
      loading.value = false;
      print('[Profile] performLogout() -> end');
    }
  }
  // ✅ Add feedback submission method
  Future<bool> submitCustomerFeedback({
    required String issueType,
    String? remarks,
  }) async {
    // Validate RM data
    if (rmName.value == null || rmName.value!.isEmpty) {
      Get.snackbar(
        'Error',
        'Relationship manager information not available',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return false;
    }

    if (rmPhone.value == null || rmPhone.value!.isEmpty) {
      Get.snackbar(
        'Error',
        'Relationship manager phone number not available',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return false;
    }

    try {
      isFeedbackSubmitting(true);
      print('[Feedback] Submitting feedback...');
      print('[Feedback] RM Name: ${rmName.value}');
      print('[Feedback] RM Phone: ${rmPhone.value}');
      print('[Feedback] Issue Type: $issueType');
      print('[Feedback] Remarks: $remarks');

      final response = await _api.submitCustomerFeedback(
        rmName: rmName.value!,
        rmNumber: rmPhone.value!,
        issueType: issueType,
        remarks: remarks,
      );

      print('[Feedback] Response: $response');

      Get.snackbar(
        'Success! ✅',
        'Thank you for your feedback. Our team will review it and get back to you soon.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: const Icon(Icons.check_circle, color: Colors.green),
      );

      return true;
    } catch (e, st) {
      print('[Feedback] Error: $e');
      print('[Feedback] Stack trace: $st');

      Get.snackbar(
        'Submission Failed',
        'Failed to submit feedback. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        duration: const Duration(seconds: 3),
      );

      return false;
    } finally {
      isFeedbackSubmitting(false);
    }
  }
}
