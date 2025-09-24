import 'package:flutter/material.dart';

import '../../app_export/app_export.dart';
import '../../app_routes.dart';
import '../../widgets/custom_text_form_field.dart';
import '../../widgets/custom_elevated_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPassword = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentPassword.dispose();
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // shifts for keyboard
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF402110), Color(0xFF603711)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    // push content above keyboard area
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        Center(
                          child: Image.asset(
                            ImageConstant.logo,
                            height: 175,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // White sheet that fills to bottom
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 24,
                                offset: const Offset(0, -6),
                              ),
                            ],
                          ),
                          child: Padding(
                            // add bottom padding so white extends over keyboard/safe area
                            padding: EdgeInsets.fromLTRB(
                              20,
                              24,
                              20,
                              24 + MediaQuery.of(context).padding.bottom + MediaQuery.of(context).viewInsets.bottom,
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Forgot Password',
                                    style: AppTextStyles.title.copyWith(
                                      color: Colors.black87,
                                      fontSize: 24,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Enter your details below',
                                    style: AppTextStyles.subtitle.copyWith(color: Colors.black54),
                                  ),
                                  const SizedBox(height: 16),

                                  // Current password
                                  CustomTextFormField(
                                    controller: _currentPassword,
                                    obscureText: true,
                                    hintText: 'Current Password',
                                    filled: true,
                                    fillColor: const Color(0xFFF7F7F9),
                                    prefix: const Icon(Icons.lock_outline, size: 20),
                                    validator: (v) =>
                                    (v == null || v.trim().isEmpty) ? 'Enter current password' : null,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                    defaultBorderDecoration: OutlineInputBorder(
                                      borderRadius: AppRadii.lg,
                                      borderSide: const BorderSide(color: Color(0xFFE2E5EA), width: 1),
                                    ),
                                    enabledBorderDecoration: OutlineInputBorder(
                                      borderRadius: AppRadii.lg,
                                      borderSide: const BorderSide(color: Color(0xFFE2E5EA), width: 1),
                                    ),
                                    focusedBorderDecoration: OutlineInputBorder(
                                      borderRadius: AppRadii.lg,
                                      borderSide: BorderSide(color: appTheme.theme, width: 1.2),
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  // New password
                                  CustomTextFormField(
                                    controller: _newPassword,
                                    obscureText: _obscureNew,
                                    hintText: 'New Password',
                                    filled: true,
                                    fillColor: const Color(0xFFF7F7F9),
                                    prefix: const Icon(Icons.lock_reset_outlined, size: 20),
                                    suffix: IconButton(
                                      icon: Icon(_obscureNew ? Icons.visibility_off : Icons.visibility),
                                      onPressed: () => setState(() => _obscureNew = !_obscureNew),
                                    ),
                                    validator: (v) =>
                                    (v == null || v.trim().isEmpty) ? 'Enter new password' : null,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                    defaultBorderDecoration: OutlineInputBorder(
                                      borderRadius: AppRadii.lg,
                                      borderSide: const BorderSide(color: Color(0xFFE2E5EA), width: 1),
                                    ),
                                    enabledBorderDecoration: OutlineInputBorder(
                                      borderRadius: AppRadii.lg,
                                      borderSide: const BorderSide(color: Color(0xFFE2E5EA), width: 1),
                                    ),
                                    focusedBorderDecoration: OutlineInputBorder(
                                      borderRadius: AppRadii.lg,
                                      borderSide: BorderSide(color: appTheme.theme, width: 1.2),
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  // Confirm password
                                  CustomTextFormField(
                                    controller: _confirmPassword,
                                    obscureText: _obscureConfirm,
                                    hintText: 'Confirm Password',
                                    filled: true,
                                    fillColor: const Color(0xFFF7F7F9),
                                    prefix: const Icon(Icons.lock_outline, size: 20),
                                    suffix: IconButton(
                                      icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility),
                                      onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                                    ),
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty) {
                                        return 'Confirm your password';
                                      }
                                      if (v != _newPassword.text) {
                                        return 'Passwords do not match';
                                      }
                                      return null;
                                    },
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                    defaultBorderDecoration: OutlineInputBorder(
                                      borderRadius: AppRadii.lg,
                                      borderSide: const BorderSide(color: Color(0xFFE2E5EA), width: 1),
                                    ),
                                    enabledBorderDecoration: OutlineInputBorder(
                                      borderRadius: AppRadii.lg,
                                      borderSide: const BorderSide(color: Color(0xFFE2E5EA), width: 1),
                                    ),
                                    focusedBorderDecoration: OutlineInputBorder(
                                      borderRadius: AppRadii.lg,
                                      borderSide: BorderSide(color: appTheme.theme, width: 1.2),
                                    ),
                                  ),
                                  const SizedBox(height: 18),

                                  // Gradient button with visible background
                                  DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [appTheme.mintygreen, appTheme.theme2],
                                      ),
                                      borderRadius: AppRadii.pill,
                                    ),
                                    child: CustomElevatedButton(
                                      onPressed: () {
                                        if (_formKey.currentState!.validate()) {
                                          // submit logic
                                        }
                                      },
                                      text: 'SUBMIT',
                                      height: getHorizontalSize(48),
                                      width: double.infinity,
                                      buttonStyle: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        shape: const RoundedRectangleBorder(borderRadius: AppRadii.pill),
                                      ),
                                      buttonTextStyle: AppTextStyles.semiBold.copyWith(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // ... inside the Form > Column children, right after the DecoratedBox(CustomElevatedButton)
                        const SizedBox(height: 12),

// Filler to extend white all the way to bottom (covers safe area + keyboard)
                        Container(
                          width: double.infinity,
                          height: MediaQuery.of(context).padding.bottom +
                              MediaQuery.of(context).viewInsets.bottom +
                              12, // small extra breathing space
                          color: Colors.white,
                        ),

                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
