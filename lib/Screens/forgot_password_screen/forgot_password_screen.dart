import 'package:flutter/material.dart';

import 'package:starcapitalventures/Screens/forgot_password_screen/update_password_controller.dart';
import 'package:starcapitalventures/app_export/app_export.dart';
import '../../widgets/app_header.dart';
import '../../widgets/custom_text_form_field.dart';

class UpdatePasswordScreen extends StatelessWidget {
  UpdatePasswordScreen({super.key});

  final UpdatePasswordController _controller = Get.put(UpdatePasswordController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E2A38),
      body: Stack(
        children: [
          const AppHeader(
            height: 160,
            topPadding: 40,
            bottomPadding: 40,
            showProfileAvatar: false,
          ),
          Padding(
            padding: EdgeInsets.only(top: getVerticalSize(160)),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(getSize(30)),
                  topRight: Radius.circular(getSize(30)),
                ),
              ),
              child: SingleChildScrollView(
                padding: getPadding(
                  left: 16,
                  right: 16,
                  top: 24,
                  bottom: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      'Update Password',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: const Color(0xFF1A2036),
                        fontWeight: FontWeight.bold,
                        fontSize: getFontSize(22),
                      ),
                    ),
                    SizedBox(height: getVerticalSize(8)),
                    Text(
                      'Please enter your current password and choose a new password',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.black54,
                        fontSize: getFontSize(14),
                      ),
                    ),
                    SizedBox(height: getVerticalSize(32)),

                    // Current Password
                    Text(
                      'Current Password',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: const Color(0xFF1A2036),
                        fontWeight: FontWeight.w600,
                        fontSize: getFontSize(13),
                      ),
                    ),
                    SizedBox(height: getVerticalSize(8)),
                    Obx(
                          () => CustomTextFormField(
                        controller: _controller.currentPasswordController,
                        hintText: 'Enter current password',
                        obscureText: !_controller.showCurrentPassword.value,
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: getPadding(
                          left: 14,
                          right: 14,
                          top: 14,
                          bottom: 14,
                        ),
                        suffix: IconButton(
                          icon: Icon(
                            _controller.showCurrentPassword.value
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.grey,
                            size: getSize(20),
                          ),
                          onPressed: _controller.toggleCurrentPasswordVisibility,
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
                    ),

                    SizedBox(height: getVerticalSize(20)),

                    // New Password
                    Text(
                      'New Password',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: const Color(0xFF1A2036),
                        fontWeight: FontWeight.w600,
                        fontSize: getFontSize(13),
                      ),
                    ),
                    SizedBox(height: getVerticalSize(8)),
                    Obx(
                          () => CustomTextFormField(
                        controller: _controller.newPasswordController,
                        hintText: 'Enter new password',
                        obscureText: !_controller.showNewPassword.value,
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: getPadding(
                          left: 14,
                          right: 14,
                          top: 14,
                          bottom: 14,
                        ),
                        suffix: IconButton(
                          icon: Icon(
                            _controller.showNewPassword.value
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.grey,
                            size: getSize(20),
                          ),
                          onPressed: _controller.toggleNewPasswordVisibility,
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
                    ),
                    SizedBox(height: getVerticalSize(8)),
                    Text(
                      'Password must be at least 8 characters long',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.black45,
                        fontSize: getFontSize(12),
                      ),
                    ),

                    SizedBox(height: getVerticalSize(20)),

                    // Confirm Password
                    Text(
                      'Confirm Password',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: const Color(0xFF1A2036),
                        fontWeight: FontWeight.w600,
                        fontSize: getFontSize(13),
                      ),
                    ),
                    SizedBox(height: getVerticalSize(8)),
                    Obx(
                          () => CustomTextFormField(
                        controller: _controller.confirmPasswordController,
                        hintText: 'Re-enter new password',
                        obscureText: !_controller.showConfirmPassword.value,
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: getPadding(
                          left: 14,
                          right: 14,
                          top: 14,
                          bottom: 14,
                        ),
                        suffix: IconButton(
                          icon: Icon(
                            _controller.showConfirmPassword.value
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.grey,
                            size: getSize(20),
                          ),
                          onPressed: _controller.toggleConfirmPasswordVisibility,
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
                    ),

                    SizedBox(height: getVerticalSize(32)),

                    // Update Button
                    Obx(
                          () => CustomElevatedButton(
                        text: _controller.loading.value
                            ? 'Updating...'
                            : 'Update Password',
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
                        buttonTextStyle: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        onPressed: _controller.loading.value
                            ? null
                            : _controller.submitUpdatePassword,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
