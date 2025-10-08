import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:starcapitalventures/app_export/app_export.dart';
import 'package:starcapitalventures/widgets/custom_text_form_field.dart';
import 'package:starcapitalventures/widgets/custom_elevated_button.dart';
import '../../app_routes.dart';
import '../../core/utils/styles/AppTextStyles.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  // Controllers for the input fields
  final _fullName = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

  // State for toggling password visibility
  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // 1. Using the EXACT same LinearGradient from your SignInScreen
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF402110), Color(0xFF603711)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            // Added to prevent overflow on small screens
            child: Column(
              children: [
                // Back button at the top left
                SizedBox(height: 70), // Adjusted padding
                // --- App Logo (Same as SignInScreen) ---
                Image.asset(
                  ImageConstant.logo,
                  height: 120, // Slightly smaller to fit more content
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 20),
                // --- Welcome Text (Styled like SignInScreen) ---
                const Text(
                  "Create Your Account",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 30),

                // --- Input Fields Column ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    children: [
                      // Using your CustomTextFormField for consistency
                      _buildCustomTextField(
                        controller: _fullName,
                        hintText: 'Full Name',
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 20),
                      _buildCustomTextField(
                        controller: _email,
                        hintText: 'Email Address',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 20),
                      _buildCustomTextField(
                        controller: _password,
                        hintText: 'Password',
                        icon: Icons.lock_outline,
                        isPassword: true,
                        isObscured: _isPasswordObscured,
                        onToggleVisibility: () {
                          setState(() {
                            _isPasswordObscured = !_isPasswordObscured;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildCustomTextField(
                        controller: _confirmPassword,
                        hintText: 'Confirm Password',
                        icon: Icons.lock_outline,
                        isPassword: true,
                        isObscured: _isConfirmPasswordObscured,
                        onToggleVisibility: () {
                          setState(() {
                            _isConfirmPasswordObscured =
                                !_isConfirmPasswordObscured;
                          });
                        },
                      ),
                      const SizedBox(height: 30),

                      SizedBox(
                        width: double.infinity,
                        height: getHorizontalSize(48),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [appTheme.mintygreen, appTheme.theme2],
                            ),
                            borderRadius: AppRadii.lg,
                          ),
                          child: CustomElevatedButton(
                            onPressed: () {},
                            text: 'CREATE ACCOUNT',
                            buttonStyle: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: AppRadii.md,
                              ),
                            ),
                            buttonTextStyle: AppTextStyles.semiBold.copyWith(
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // --- Log In Link ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already have an account?",
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          TextButton(
                            onPressed:
                                () => Get.offNamed(AppRoutes.signinscreen),
                            child: Text(
                              'Log In',
                              style: AppTextStyles.caption.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper widget to build your CustomTextFormField consistently
  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    bool isObscured = false,
    VoidCallback? onToggleVisibility,
    TextInputType? keyboardType,
  }) {
    return CustomTextFormField(
      controller: controller,
      hintText: hintText,
      textInputType: keyboardType ?? TextInputType.text,
      obscureText: isObscured,
      filled: true,
      fillColor: const Color(0xFFF7F7F9),
      prefix: Icon(icon, size: 20),
      suffix:
          isPassword
              ? IconButton(
                icon: Icon(
                  isObscured ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: onToggleVisibility,
              )
              : null,
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
    );
  }
}
