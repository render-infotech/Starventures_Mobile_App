import 'package:flutter/material.dart';

import 'package:starcapitalventures/app_export/app_export.dart';
import 'package:starcapitalventures/widgets/custom_text_form_field.dart'; // adjust import path if different
import 'package:starcapitalventures/widgets/custom_elevated_button.dart';

import '../../app_routes.dart';
import '../../core/utils/styles/AppTextStyles.dart';
import 'controller/login_controller.dart';  // adjust import path if different

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});
  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>(); // Add form key for validation
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  final SignInController _controller = Get.put(SignInController());

  // Validation function
  void _handleSignIn() {
    if (_formKey.currentState!.validate()) {
      // Form is valid, proceed with login
      _controller.login(
        _email.text.trim(),
        _password.text.trim(),
        context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size; // responsive spacing base  [13]
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF402110), Color(0xFF603711)],
          ),
        ), // gradient header [10]
        child: SafeArea(
          child: Column(
            children: [
              // App mark/title

              Padding(
                padding: const EdgeInsets.only(top:5),
                child: Center(
                  child: Container(
                    // decoration: BoxDecoration(color: appTheme.black900,  borderRadius: BorderRadius.circular(200)),
                      child: Image.asset(ImageConstant.logo, height: 175, fit: BoxFit.contain)),
                ),
              ),
              // header title
              const SizedBox(height: 5),
              const Spacer(),
              // Sheet
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(28)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 24,
                      offset: const Offset(0, -6),
                    ),
                  ],
                ), // rounded sheet [10]
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                  child: Form( // Wrap with Form widget
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Welcome Back',
                            style: AppTextStyles.title.copyWith(
                              color: Colors.black87,
                              fontSize: 24,
                            )), // heading
                        const SizedBox(height: 6),
                        Text('Enter your details below',
                            style: AppTextStyles.subtitle.copyWith(
                              color: Colors.black54,
                            )), // subtitle [12]
                        const SizedBox(height: 16),
                        // Email (CustomTextFormField)
                        CustomTextFormField(
                          controller: _email,
                          textInputType: TextInputType.emailAddress,
                          hintText: 'Email Address',
                          filled: true,
                          fillColor: const Color(0xFFF7F7F9),
                          prefix: const Icon(Icons.email_outlined, size: 20),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your email address';
                            }
                            return null;
                          },
                          defaultBorderDecoration: OutlineInputBorder(
                            borderRadius: AppRadii.lg,
                            borderSide: const BorderSide(
                              color: Color(0xFFE2E5EA),
                              width: 1,
                            ),
                          ),
                          enabledBorderDecoration: OutlineInputBorder(
                            borderRadius: AppRadii.lg,
                            borderSide: const BorderSide(
                              color: Color(0xFFE2E5EA),
                              width: 1,
                            ),
                          ),
                          focusedBorderDecoration: OutlineInputBorder(
                            borderRadius: AppRadii.lg,
                            borderSide: BorderSide(
                              color: appTheme.theme,
                              width: 1.2,
                            ),
                          ),
                        ), // rounded input with prefix [12][8]
                        const SizedBox(height: 12),
                        // Password (CustomTextFormField)
                        CustomTextFormField(
                          controller: _password,
                          obscureText: _obscure,
                          hintText: 'Password',
                          filled: true,
                          fillColor: const Color(0xFFF7F7F9),
                          prefix: const Icon(Icons.lock_outline, size: 20),
                          suffix: IconButton(
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                          defaultBorderDecoration: OutlineInputBorder(
                            borderRadius: AppRadii.lg,
                            borderSide: const BorderSide(
                              color: Color(0xFFE2E5EA),
                              width: 1,
                            ),
                          ),
                          enabledBorderDecoration: OutlineInputBorder(
                            borderRadius: AppRadii.lg,
                            borderSide: const BorderSide(
                              color: Color(0xFFE2E5EA),
                              width: 1,
                            ),
                          ),
                          focusedBorderDecoration: OutlineInputBorder(
                            borderRadius: AppRadii.lg,
                            borderSide: BorderSide(
                              color: appTheme.theme,
                              width: 1.2,
                            ),
                          ),
                        ), // password with visibility toggle [12][8]
                        const SizedBox(height: 18),
                        // Gradient button (CustomElevatedButton)
                        SizedBox(
                          width: double.infinity,
                          height: getHorizontalSize(48), // size utils applied [13]
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient:  LinearGradient(
                                colors: [appTheme.mintygreen, appTheme.theme2],
                              ),
                              borderRadius: AppRadii.pill,
                            ),
                            child: Obx(() => CustomElevatedButton(
                              onPressed: _controller.loading.value
                                  ? null
                                  : _handleSignIn, // Use validation function
                              text: _controller.loading.value ? 'Signing In...' : 'SIGN IN',
                              height: getHorizontalSize(48),
                              width: double.infinity,
                              buttonStyle: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: AppRadii.pill,
                                ),
                              ),
                              buttonTextStyle: AppTextStyles.semiBold.copyWith(color: Colors.white),
                            )),

                          ),
                        ),

                        const SizedBox(height: 12),
                      Center(
                        child: TextButton(
                          onPressed: () => Get.toNamed(AppRoutes.forgotPasswordScreen),
                          child: Text(
                            'Forgot your password?',
                            style: AppTextStyles.caption.copyWith(color: Colors.black54),
                          ),
                        ),
                      ),


                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
