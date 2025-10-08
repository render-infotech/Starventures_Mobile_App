// lib/Screens/profile/edit_profile_screen.dart
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

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final ProfileController _controller;
  late final LogoutController _logout;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<ProfileController>();
    _logout = Get.put(LogoutController());
  }

  String _initials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '';
    final parts =
        trimmed.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    final first =
        parts.isNotEmpty && parts.first.isNotEmpty
            ? parts.first.characters.first
            : '';
    final last =
        parts.length > 1 && parts.last.isNotEmpty
            ? parts.last.characters.first
            : '';
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
      final emailCtrl = TextEditingController(
        text: _controller.userEmail.value,
      );
      final phoneCtrl = TextEditingController(
        text: _controller.userPhone.value,
      );
      final empIdCtrl = TextEditingController(
        text: _controller.employeeId.value,
      );

      return Scaffold(
        backgroundColor: const Color(0xFF1E2A38),
        body: Stack(
          children: [
            _buildHeader(context),
            Padding(
              padding: EdgeInsets.only(top: getVerticalSize(130)),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(getSize(30)),
                  ),
                ),
                child:
                    _controller.profileLoading.value
                        ? const Center(child: CircularProgressIndicator())
                        : SingleChildScrollView(
                          padding: getPadding(
                            left: 16,
                            right: 16,
                            top: 24,
                            bottom: 24,
                          ),
                          child: Column(
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap:
                                        _controller.loading.value
                                            ? null
                                            : _controller.pickImage,
                                    child: Container(
                                      width: getSize(70),
                                      height: getSize(70),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF4A2B1A),
                                        shape: BoxShape.circle,
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      alignment: Alignment.center,
                                      child: _buildAvatarImage(
                                        context,
                                        pickedPath,
                                        initials,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: getVerticalSize(6)),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name.isEmpty ? ' ' : name,
                                        style: TextStyle(
                                          fontSize: getFontSize(18),
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      SizedBox(height: getVerticalSize(4)),
                                      if (showEmpId &&
                                          _controller
                                              .employeeId
                                              .value
                                              .isNotEmpty)
                                        Text(
                                          'Employee ID: ${_controller.employeeId.value}',
                                          style: TextStyle(
                                            fontSize: getFontSize(13),
                                            color: Colors.black,
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: getVerticalSize(10)),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Full Name',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.labelLarge?.copyWith(
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
                                    contentPadding: getPadding(
                                      left: 14,
                                      right: 14,
                                      top: 14,
                                      bottom: 14,
                                    ),
                                    defaultBorderDecoration: OutlineInputBorder(
                                      borderRadius: AppRadii.lg,
                                      borderSide: BorderSide(
                                        color: appTheme.blueGray10001,
                                        width: 1,
                                      ),
                                    ),
                                    enabledBorderDecoration: OutlineInputBorder(
                                      borderRadius: AppRadii.lg,
                                      borderSide: BorderSide(
                                        color: appTheme.blueGray10001,
                                        width: 1,
                                      ),
                                    ),
                                    focusedBorderDecoration: OutlineInputBorder(
                                      borderRadius: AppRadii.lg,
                                      borderSide: BorderSide(
                                        color: appTheme.blueGray10001,
                                        width: 1,
                                      ),
                                    ),
                                    onChanged:
                                        (v) => _controller.userName.value = v,
                                  ),

                                  SizedBox(height: getVerticalSize(16)),

                                  Text(
                                    'Email Address',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.labelLarge?.copyWith(
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
                                    contentPadding: getPadding(
                                      left: 14,
                                      right: 14,
                                      top: 14,
                                      bottom: 14,
                                    ),
                                    defaultBorderDecoration: OutlineInputBorder(
                                      borderRadius: AppRadii.lg,
                                      borderSide: BorderSide(
                                        color: appTheme.blueGray10001,
                                        width: 1,
                                      ),
                                    ),
                                    enabledBorderDecoration: OutlineInputBorder(
                                      borderRadius: AppRadii.lg,
                                      borderSide: BorderSide(
                                        color: appTheme.blueGray10001,
                                        width: 1,
                                      ),
                                    ),
                                    focusedBorderDecoration: OutlineInputBorder(
                                      borderRadius: AppRadii.lg,
                                      borderSide: BorderSide(
                                        color: appTheme.blueGray10001,
                                        width: 1,
                                      ),
                                    ),
                                    onChanged:
                                        (v) => _controller.userEmail.value = v,
                                  ),
                                  SizedBox(height: getVerticalSize(16)),
                                  Text(
                                    'Phone Number',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.labelLarge?.copyWith(
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
                                    contentPadding: getPadding(
                                      left: 14,
                                      right: 14,
                                      top: 14,
                                      bottom: 14,
                                    ),
                                    defaultBorderDecoration: OutlineInputBorder(
                                      borderRadius: AppRadii.lg,
                                      borderSide: BorderSide(
                                        color: appTheme.blueGray10001,
                                        width: 1,
                                      ),
                                    ),
                                    enabledBorderDecoration: OutlineInputBorder(
                                      borderRadius: AppRadii.lg,
                                      borderSide: BorderSide(
                                        color: appTheme.blueGray10001,
                                        width: 1,
                                      ),
                                    ),
                                    focusedBorderDecoration: OutlineInputBorder(
                                      borderRadius: AppRadii.lg,
                                      borderSide: BorderSide(
                                        color: appTheme.blueGray10001,
                                        width: 1,
                                      ),
                                    ),
                                  ),

                                  if (showEmpId) ...[
                                    Text(
                                      'Employee ID',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.labelLarge?.copyWith(
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
                                      contentPadding: getPadding(
                                        left: 14,
                                        right: 14,
                                        top: 14,
                                        bottom: 14,
                                      ),
                                      defaultBorderDecoration:
                                          OutlineInputBorder(
                                            borderRadius: AppRadii.lg,
                                            borderSide: BorderSide(
                                              color: appTheme.blueGray10001,
                                              width: 1,
                                            ),
                                          ),
                                      enabledBorderDecoration:
                                          OutlineInputBorder(
                                            borderRadius: AppRadii.lg,
                                            borderSide: BorderSide(
                                              color: appTheme.blueGray10001,
                                              width: 1,
                                            ),
                                          ),
                                      focusedBorderDecoration:
                                          OutlineInputBorder(
                                            borderRadius: AppRadii.lg,
                                            borderSide: BorderSide(
                                              color: appTheme.blueGray10001,
                                              width: 1,
                                            ),
                                          ),
                                    ),
                                  ],

                                  SizedBox(height: getVerticalSize(25)),

                                  Obx(
                                    () => CustomElevatedButton(
                                      text:
                                          _controller.loading.value
                                              ? 'Updating...'
                                              : 'Update Profile',
                                      height: getVerticalSize(48),
                                      width: double.infinity,
                                      buttonStyle: ElevatedButton.styleFrom(
                                        minimumSize: Size(
                                          double.infinity,
                                          getVerticalSize(48),
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: AppRadii.lg,
                                        ),
                                        backgroundColor: appTheme.theme2,
                                        foregroundColor: Colors.white,
                                      ),
                                      buttonTextStyle: Theme.of(
                                        context,
                                      ).textTheme.titleSmall?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      onPressed:
                                          _controller.loading.value
                                              ? null
                                              : () {
                                                _controller.userName.value =
                                                    nameCtrl.text.trim();
                                                _controller.userEmail.value =
                                                    emailCtrl.text.trim();
                                                _controller.submitUpdate();
                                              },
                                    ),
                                  ),

                                  SizedBox(height: getVerticalSize(25)),

                                  Obx(
                                    () => GestureDetector(
                                      onTap:
                                          _controller.loading.value
                                              ? null
                                              : () async {
                                                final confirm =
                                                    await showLogoutDialog(
                                                      context,
                                                    );
                                                if (confirm) {
                                                  await _logout.performLogout(
                                                    context,
                                                  );
                                                }
                                              },
                                      child: Center(
                                        child: ClipOval(
                                          child: Container(
                                            color:
                                                _controller.loading.value
                                                    ? appTheme.blue50
                                                        .withValues(alpha: 0.5)
                                                    : appTheme.blue50,
                                            width: getHorizontalSize(50),
                                            height: getHorizontalSize(50),
                                            child:
                                                _controller.loading.value
                                                    ? Center(
                                                      child: SizedBox(
                                                        width: getSize(20),
                                                        height: getSize(20),
                                                        child: CircularProgressIndicator(
                                                          strokeWidth: getSize(
                                                            2,
                                                          ),
                                                          valueColor:
                                                              AlwaysStoppedAnimation<
                                                                Color
                                                              >(appTheme.theme),
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
                            ],
                          ),
                        ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: getVerticalSize(140),
      decoration: const BoxDecoration(color: Color(0xFF4A2B1A)),
      child: Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top,
          right: getHorizontalSize(20),
          bottom: getVerticalSize(20),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Back button
            GestureDetector(
              onTap: () => Get.back(),
              child: Padding(
                padding: EdgeInsets.only(left: getHorizontalSize(20)),
                child: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: getSize(24),
                ),
              ),
            ),

            // Logo
            Image.asset(
              'assets/images/logo.png',
              height: getVerticalSize(100),
              width: getHorizontalSize(150),
            ),
            const Spacer(),
            Stack(
              children: [
                Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                  size: getSize(28),
                ),
                Positioned(
                  right: getHorizontalSize(2),
                  top: getVerticalSize(2),
                  child: Container(
                    width: getSize(8),
                    height: getSize(8),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(width: getHorizontalSize(10)),
            // CircleAvatar(
            //   radius: getSize(15),
            //   backgroundColor: Colors.white,
            //   child: Text(
            //     'JD',
            //     style: TextStyle(
            //       color: Colors.brown,
            //       fontWeight: FontWeight.bold,
            //       fontSize: getFontSize(14),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarImage(
    BuildContext context,
    String? pickedPath,
    String initials,
  ) {
    // Priority: 1. Picked local image, 2. Server avatar, 3. Initials
    if (pickedPath != null && pickedPath.isNotEmpty) {
      return Image.file(
        File(pickedPath),
        fit: BoxFit.cover,
        width: getSize(70),
        height: getSize(70),
      );
    }

    if (_controller.avatarUrl.value != null &&
        _controller.avatarUrl.value!.isNotEmpty) {
      return Image.network(
        _controller.avatarUrl.value!,
        fit: BoxFit.cover,
        width: getSize(70),
        height: getSize(70),
        errorBuilder: (context, error, stackTrace) {
          // Fallback to initials if network image fails
          return Text(
            initials.isEmpty ? ' ' : initials,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: getFontSize(20),
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return CircularProgressIndicator(
            strokeWidth: getSize(2),
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
        fontSize: getFontSize(20),
      ),
    );
  }
}
