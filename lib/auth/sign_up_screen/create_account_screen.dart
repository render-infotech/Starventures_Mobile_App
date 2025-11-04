import 'package:starcapitalventures/app_export/app_export.dart';
import 'package:starcapitalventures/widgets/custom_text_form_field.dart';
import 'package:starcapitalventures/widgets/custom_elevated_button.dart';
import '../../app_routes.dart';
import '../../core/utils/custom_snackbar.dart';
import '../../core/utils/styles/AppTextStyles.dart';

import 'create_account_controller.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for the input fields
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();

  final CreateAccountController _controller = Get.put(CreateAccountController());

  void _handleCreateAccount() {
    // Validate inputs
    String name = _fullNameController.text.trim();
    String email = _emailController.text.trim();
    String phone = _phoneController.text.trim();
    String dob = _dobController.text.trim();

    if (name.isEmpty) {
      CustomSnackbar.show(
        context,
        title: 'Validation Error',
        message: 'Please enter your full name',
        backgroundColor: appTheme.theme,
      );
      return;
    }

    if (email.isEmpty || !email.contains('@')) {
      CustomSnackbar.show(
        context,
        title: 'Validation Error',
        message: 'Please enter a valid email address',
        backgroundColor: appTheme.theme,
      );
      return;
    }

    if (phone.isEmpty) {
      CustomSnackbar.show(
        context,
        title: 'Validation Error',
        message: 'Please enter phone number',
        backgroundColor: appTheme.theme,
      );
      return;
    }

    // Ensure phone starts with country code
    if (!phone.startsWith('+')) {
      phone = '+91$phone'; // Default to India
    }

    if (dob.isEmpty) {
      CustomSnackbar.show(
        context,
        title: 'Validation Error',
        message: 'Please select date of birth',
        backgroundColor: Colors.red.shade600,
      );
      return;
    }

    // Call controller to register
    _controller.registerCustomer(
      name: name,
      phone: phone,
      email: email,
      dob: dob,
      context: context,
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: appTheme.theme,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dobController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 70),
                Image.asset(
                  ImageConstant.logo,
                  height: 120,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 20),
                const Text(
                  "Create Your Customer Account",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 30),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildCustomTextField(
                          controller: _fullNameController,
                          hintText: 'Full Name',
                          icon: Icons.person_outline,
                        ),
                        const SizedBox(height: 20),
                        _buildCustomTextField(
                          controller: _emailController,
                          hintText: 'Email Address',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 20),
                        _buildCustomTextField(
                          maxLength: 10,
                          controller: _phoneController,
                          hintText: 'Mobile Number',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () => _selectDate(context),
                          child: AbsorbPointer(
                            child: _buildCustomTextField(
                              controller: _dobController,
                              hintText: 'Date of Birth (YYYY-MM-DD)',
                              icon: Icons.calendar_today_outlined,
                            ),
                          ),
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
                            child: Obx(
                                  () => CustomElevatedButton(
                                onPressed: _controller.loading.value
                                    ? null
                                    : _handleCreateAccount,
                                text: _controller.loading.value
                                    ? 'CREATING ACCOUNT...'
                                    : 'CREATE ACCOUNT',
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
                        ),
                        const SizedBox(height: 20),

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
                              onPressed: () => Get.offNamed(AppRoutes.signinscreen),
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType? keyboardType,
    int? maxLength,
  }) {
    return CustomTextFormField(
      maxLength: maxLength,
      controller: controller,
      hintText: hintText,
      textInputType: keyboardType ?? TextInputType.text,
      filled: true,
      fillColor: const Color(0xFFF7F7F9),
      prefix: Icon(icon, size: 20),
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
