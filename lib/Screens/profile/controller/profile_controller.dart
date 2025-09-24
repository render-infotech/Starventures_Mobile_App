// lib/Screens/profile/controller/profile_controller.dart

import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
 import '../../../core/data/api_client/api_client.dart';

// Models
import '../model/profile_models.dart';

// Direct API access (no repository)

class ProfileController extends GetxController {
  // Remove repo concept; use ApiClient directly
  final ApiClient _api = ApiClient();

  final loading = false.obs;
  final profileLoading = false.obs;

  final userName = ''.obs;
  final userEmail = ''.obs;
  final userPhone = ''.obs;
  final employeeId = ''.obs;
  final role = 'employee'.obs;

  final pickedImagePath = RxnString(); // preview path
  File? get pickedImageFile =>
      pickedImagePath.value == null ? null : File(pickedImagePath.value!);

  final _picker = ImagePicker();
  ProfileResponse? profile;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    profileLoading.value = true;
    print('[Profile] loadProfile() -> start');
    try {
      final map = await _api.fetchProfile();
      print('[Profile] loadProfile() -> success');
      final res = ProfileResponse.fromJson(map);
      profile = res;

      final name = res.data.employee.name.isNotEmpty
          ? res.data.employee.name
          : res.data.user.name;

      userName.value = name;
      userEmail.value = res.data.employee.email ?? res.data.user.email;
      userPhone.value = res.data.employee.phone ?? '';
      employeeId.value = res.data.employee.employeeId ?? '';
      role.value = res.data.user.type ?? 'employee';

      print('[Profile] loadProfile() mapped fields: '
          'name="$name", email="${userEmail.value}", phone="${userPhone.value}", '
          'employeeId="${employeeId.value}", role="${role.value}"');
    } catch (e, st) {
      print('[Profile] loadProfile() -> ERROR: $e\n$st');
      Get.snackbar('Error', 'Failed to load profile');
    } finally {
      profileLoading.value = false;
      print('[Profile] loadProfile() -> end');
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
        name: name,
        email: email,
        profileImage: pickedImageFile,
      );

      print('[Profile] submitUpdate() -> API success');
      final res = ProfileResponse.fromJson(map);
      profile = res;

      final newName = res.data.employee.name.isNotEmpty
          ? res.data.employee.name
          : res.data.user.name;

      userName.value = newName;
      userEmail.value = res.data.employee.email ?? res.data.user.email;

      pickedImagePath.value = null;
      print('[Profile] submitUpdate() -> mapped new fields: '
          'name="$newName", email="${userEmail.value}"');

      Get.snackbar('Success', 'Profile updated');
    } catch (e, st) {
      print('[Profile] submitUpdate() -> ERROR: $e\n$st');
      Get.snackbar('Error', 'Update failed');
    } finally {
      loading.value = false;
      print('[Profile] submitUpdate() -> end');
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
}
