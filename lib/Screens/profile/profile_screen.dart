// lib/Screens/profile/profile_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starcapitalventures/Screens/profile/widgets/log_out_dialog.dart';

import 'controller/profile_controller.dart';
import 'logout_controller.dart';
import 'package:starcapitalventures/app_export/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_text_form_field.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileController _controller;
  late final LogoutController _logout;

  @override
  void initState() {
    super.initState();
    // Use global instances created in AppBinding
    _controller = Get.find<ProfileController>();
    _logout = Get.put(LogoutController());
  }

  String _initials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '';
    final parts = trimmed.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    final first = parts.isNotEmpty && parts.first.isNotEmpty ? parts.first.characters.first : '';
    final last = parts.length > 1 && parts.last.isNotEmpty ? parts.last.characters.first : '';
    final init = (first + last).isEmpty ? first : (first + last);
    return init.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final showEmpId = _controller.role.value == 'employee';
      final name = _controller.userName.value;
      final initials = name.isEmpty ? '' : _initials(name);
      final pickedPath = _controller.pickedImagePath.value;

      // Controllers created from latest Rx values each build to keep UI in sync
      final nameCtrl = TextEditingController(text: _controller.userName.value);
      final emailCtrl = TextEditingController(text: _controller.userEmail.value);
      final phoneCtrl = TextEditingController(text: _controller.userPhone.value);
      final empIdCtrl = TextEditingController(text: _controller.employeeId.value);

      return Scaffold(
        backgroundColor: appTheme.gray100,
        appBar: CustomAppBar(
          backgroundColor: appTheme.mintygreen,
          useGreeting: false,
          pageTitle: 'Profile',
          showBack: true,
          onBack: () => Get.back(),
        ),
        body: _controller.profileLoading.value
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding: getPadding(left: 16, right: 16, top: 16, bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _controller.loading.value ? null : _controller.pickImage,
                      child: Container(
                        width: getHorizontalSize(96),
                        height: getHorizontalSize(96),
                        decoration: const BoxDecoration(
                          color: Color(0xFF2E2E2E),
                          shape: BoxShape.circle,
                        ),
                        clipBehavior: Clip.antiAlias,
                        alignment: Alignment.center,
                        child: _buildAvatarImage(context, pickedPath, initials),
                      ),

                      /*
                      child: Container(
                        width: getHorizontalSize(96),
                        height: getHorizontalSize(96),
                        decoration: const BoxDecoration(
                          color: Color(0xFF2E2E2E),
                          shape: BoxShape.circle,
                        ),
                        clipBehavior: Clip.antiAlias,
                        alignment: Alignment.center,
                        child: pickedPath != null && pickedPath.isNotEmpty
                            ? Image.file(
                          File(pickedPath),
                          fit: BoxFit.cover,
                          width: getHorizontalSize(96),
                          height: getHorizontalSize(96),
                        )
                            : Text(
                          initials.isEmpty ? ' ' : initials,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: getFontSize(22),
                          ),
                        ),
                      ),

                       */
                    ),
                    SizedBox(height: getVerticalSize(12)),
                    Text(
                      name.isEmpty ? ' ' : name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A2036),
                      ),
                    ),
                    SizedBox(height: getVerticalSize(4)),
                    if (showEmpId && _controller.employeeId.value.isNotEmpty)
                      Text(
                        'Employee ID: ${_controller.employeeId.value}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black45),
                      ),
                  ],
                ),
              ),

              SizedBox(height: getVerticalSize(20)),

              Text(
                'Full Name',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: const Color(0xFF1A2036),
                  fontWeight: FontWeight.w600,
                  fontSize: getFontSize(13),
                ),
              ),
              SizedBox(height: getVerticalSize(8)),
              CustomTextFormField(
                controller: nameCtrl,
                hintText: 'Enter full name',
                filled: true,
                fillColor: Colors.white,
                contentPadding: getPadding(left: 14, right: 14, top: 14, bottom: 14),
                defaultBorderDecoration: OutlineInputBorder(
                  borderRadius: AppRadii.lg,
                  borderSide: BorderSide(color: appTheme.blueGray10001, width: 1),
                ),
                enabledBorderDecoration: OutlineInputBorder(
                  borderRadius: AppRadii.lg,
                  borderSide: BorderSide(color: appTheme.blueGray10001, width: 1),
                ),
                focusedBorderDecoration: OutlineInputBorder(
                  borderRadius: AppRadii.lg,
                  borderSide: BorderSide(color: appTheme.blueGray10001, width: 1),
                ),
                onChanged: (v) => _controller.userName.value = v,
              ),

              SizedBox(height: getVerticalSize(16)),

              Text(
                'Email Address',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: const Color(0xFF1A2036),
                  fontWeight: FontWeight.w600,
                  fontSize: getFontSize(13),
                ),
              ),
              SizedBox(height: getVerticalSize(8)),
              CustomTextFormField(
                controller: emailCtrl,
                hintText: 'Email Address',
                filled: true,
                fillColor: Colors.white,
                contentPadding: getPadding(left: 14, right: 14, top: 14, bottom: 14),
                defaultBorderDecoration: OutlineInputBorder(
                  borderRadius: AppRadii.lg,
                  borderSide: BorderSide(color: appTheme.blueGray10001, width: 1),
                ),
                enabledBorderDecoration: OutlineInputBorder(
                  borderRadius: AppRadii.lg,
                  borderSide: BorderSide(color: appTheme.blueGray10001, width: 1),
                ),
                focusedBorderDecoration: OutlineInputBorder(
                  borderRadius: AppRadii.lg,
                  borderSide: BorderSide(color: appTheme.blueGray10001, width: 1),
                ),
                onChanged: (v) => _controller.userEmail.value = v,
              ),

              Text(
                'Phone Number',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: const Color(0xFF1A2036),
                  fontWeight: FontWeight.w600,
                  fontSize: getFontSize(13),
                ),
              ),
              SizedBox(height: getVerticalSize(8)),
              CustomTextFormField(
                readOnly: true,
                controller: phoneCtrl,
                hintText: 'Phone Number',
                filled: true,
                fillColor: Colors.white,
                contentPadding: getPadding(left: 14, right: 14, top: 14, bottom: 14),
                defaultBorderDecoration: OutlineInputBorder(
                  borderRadius: AppRadii.lg,
                  borderSide: BorderSide(color: appTheme.blueGray10001, width: 1),
                ),
                enabledBorderDecoration: OutlineInputBorder(
                  borderRadius: AppRadii.lg,
                  borderSide: BorderSide(color: appTheme.blueGray10001, width: 1),
                ),
                focusedBorderDecoration: OutlineInputBorder(
                  borderRadius: AppRadii.lg,
                  borderSide: BorderSide(color: appTheme.blueGray10001, width: 1),
                ),
              ),

              if (showEmpId) ...[
                Text(
                  'Employee ID',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: const Color(0xFF1A2036),
                    fontWeight: FontWeight.w600,
                    fontSize: getFontSize(13),
                  ),
                ),
                SizedBox(height: getVerticalSize(8)),
                CustomTextFormField(
                  readOnly: true,
                  controller: empIdCtrl,
                  hintText: 'Employee ID',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: getPadding(left: 14, right: 14, top: 14, bottom: 14),
                  defaultBorderDecoration: OutlineInputBorder(
                    borderRadius: AppRadii.lg,
                    borderSide: BorderSide(color: appTheme.blueGray10001, width: 1),
                  ),
                  enabledBorderDecoration: OutlineInputBorder(
                    borderRadius: AppRadii.lg,
                    borderSide: BorderSide(color: appTheme.blueGray10001, width: 1),
                  ),
                  focusedBorderDecoration: OutlineInputBorder(
                    borderRadius: AppRadii.lg,
                    borderSide: BorderSide(color: appTheme.blueGray10001, width: 1),
                  ),
                ),
              ],

              SizedBox(height: getVerticalSize(25)),

              Obx(() => CustomElevatedButton(
                text: _controller.loading.value ? 'Updating...' : 'Update Profile',
                height: getVerticalSize(48),
                width: double.infinity,
                buttonStyle: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, getVerticalSize(48)),
                  shape: RoundedRectangleBorder(borderRadius: AppRadii.lg),
                  backgroundColor: appTheme.theme2,
                  foregroundColor: Colors.white,
                ),
                buttonTextStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                onPressed: _controller.loading.value
                    ? null
                    : () {
                  _controller.userName.value = nameCtrl.text.trim();
                  _controller.userEmail.value = emailCtrl.text.trim();
                  _controller.submitUpdate();
                },
              )),

              SizedBox(height: getVerticalSize(25)),

              Obx(
                    () => GestureDetector(
                  onTap: _controller.loading.value
                      ? null
                      : () async {
                    final confirm = await showLogoutDialog(context);
                    if (confirm) {
                      await _logout.performLogout(context);
                    }
                  },
                  child: Center(
                    child: ClipOval(
                      child: Container(
                        color: _controller.loading.value
                            ? appTheme.blue50.withOpacity(0.5)
                            : appTheme.blue50,
                        width: getHorizontalSize(50),
                        height: getHorizontalSize(50),
                        child: _controller.loading.value
                            ? Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(appTheme.theme),
                            ),
                          ),
                        )
                            : SvgPicture.asset(
                          ImageConstant.logout,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
  Widget _buildAvatarImage(BuildContext context, String? pickedPath, String initials) {
    // Priority: 1. Picked local image, 2. Server avatar, 3. Initials
    if (pickedPath != null && pickedPath.isNotEmpty) {
      return Image.file(
        File(pickedPath),
        fit: BoxFit.cover,
        width: getHorizontalSize(96),
        height: getHorizontalSize(96),
      );
    }

    if (_controller.avatarUrl.value != null && _controller.avatarUrl.value!.isNotEmpty) {
      return Image.network(
        _controller.avatarUrl.value!,
        fit: BoxFit.cover,
        width: getHorizontalSize(96),
        height: getHorizontalSize(96),
        errorBuilder: (context, error, stackTrace) {
          // Fallback to initials if network image fails
          return Text(
            initials.isEmpty ? ' ' : initials,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: getFontSize(22),
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          );
        },
      );
    }

    // Default to initials
    return Text(
      initials.isEmpty ? ' ' : initials,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w700,
        fontSize: getFontSize(22),
      ),
    );
  }

}
