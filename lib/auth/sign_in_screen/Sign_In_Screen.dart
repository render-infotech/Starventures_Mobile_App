import 'package:flutter/material.dart';

import 'package:starcapitalventures/app_export/app_export.dart';
import 'package:starcapitalventures/widgets/custom_text_form_field.dart'; // adjust import path if different
import 'package:starcapitalventures/widgets/custom_elevated_button.dart';

import '../../app_routes.dart';
import '../../core/utils/styles/AppTextStyles.dart';
import 'controller/login_controller.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});
  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  final SignInController _controller = Get.put(SignInController());

  void _handleSignIn() {
    _controller.login(_email.text.trim(), _password.text.trim(), context);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
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
              Padding(
                padding: const EdgeInsets.only(top: 100),
                child: Center(
                  child: Container(
                    // decoration: BoxDecoration(color: appTheme.black900,  borderRadius: BorderRadius.circular(200)),
                    child: Image.asset(
                      ImageConstant.logo,
                      height: 175,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Welcome',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
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
                        // Allow empty fields for customer demo
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
                    ),
                    SizedBox(height: 20),
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
                          _obscure ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                      validator: (value) {
                        // Allow empty fields for customer demo
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
                    ),
                    SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: getHorizontalSize(48), // size utils applied [13]
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [appTheme.mintygreen, appTheme.theme2],
                          ),
                          borderRadius: AppRadii.pill,
                        ),
                        child: Obx(
                          () => CustomElevatedButton(
                            onPressed:
                                _controller.loading.value
                                    ? null
                                    : _handleSignIn, // Use validation function
                            text:
                                _controller.loading.value
                                    ? 'Signing In...'
                                    : 'SIGN IN',
                            height: getHorizontalSize(48),
                            width: double.infinity,
                            buttonStyle: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shadowColor: Colors.transparent,
                              shape: const RoundedRectangleBorder(
                                borderRadius: AppRadii.md,
                              ),
                            ),
                            buttonTextStyle: AppTextStyles.semiBold.copyWith(
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ), // rounded input with prefix [12][8]
              // const SizedBox(height: 12),
              // password with visibility toggle [12][8]
              // const SizedBox(height: 18),
              // Gradient button (CustomElevatedButton)
              SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: () => Get.toNamed(AppRoutes.forgotPasswordScreen),
                  child: Text(
                    'Forgot your password?',
                    style: AppTextStyles.caption.copyWith(color: Colors.white),
                  ),
                ),
              ),
              Center(
                child: TextButton(
                  onPressed: () => Get.offNamed(AppRoutes.createAccountScreen),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Are you a new customer',
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Click to create an account',
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.white,
                        ),
                      ),
                    ],
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
