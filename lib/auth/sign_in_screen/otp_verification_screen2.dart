import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:otp_autofill/otp_autofill.dart';
import 'package:starcapitalventures/app_export/app_export.dart';
import 'package:starcapitalventures/widgets/custom_elevated_button.dart';

import '../../core/utils/styles/AppTextStyles.dart';
import 'controller/login_controller.dart';

class OtpVerificationScreen2 extends StatefulWidget {
  final String phoneNumber;

  const OtpVerificationScreen2({super.key, required this.phoneNumber});

  @override
  State<OtpVerificationScreen2> createState() => _OtpVerificationScreen2State();
}

class _OtpVerificationScreen2State extends State<OtpVerificationScreen2> {
  // ✅ FIXED: Use Get.put to ensure controller exists
  late final SignInController _controller;
  final TextEditingController _otpController = TextEditingController();
  late OTPTextEditController _otpTextController;

  @override
  void initState() {
    super.initState();
    // ✅ Initialize controller if not exists, or get existing one
    _controller = Get.put(SignInController());
    _initOtpListener();
  }

  Future<void> _initOtpListener() async {
    _otpTextController = OTPTextEditController(
      codeLength: 6,
      onCodeReceive: (code) {
        setState(() {
          _otpController.text = code;
        });
        print('📥 OTP Auto-filled: $code');
      },
    )..startListenUserConsent(
          (code) {
        // Extract 6-digit OTP from SMS
        final exp = RegExp(r'(\d{6})');
        return exp.stringMatch(code ?? '') ?? '';
      },
    );
  }

  void _handleVerifyOtp() {
    final otp = _otpController.text.trim();
    if (otp.isEmpty || otp.length != 6) {
      Get.snackbar('Error', 'Please enter valid 6-digit OTP');
      return;
    }
    _controller.verifyOtp(widget.phoneNumber, otp, context);
  }

  void _handleResendOtp() {
    _controller.resendOtpforotpverification2(widget.phoneNumber, context);
  }

  @override
  void dispose() {
    _otpController.dispose();
    _otpTextController.stopListen();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: TextStyle(
        fontSize: 20,
        color: appTheme.theme,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F9),
        border: Border.all(color: const Color(0xFFE2E5EA)),
        borderRadius: BorderRadius.circular(8),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: appTheme.theme, width: 2),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: const Color(0xFFF7F7F9),
        border: Border.all(color: appTheme.theme),
      ),
    );

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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  ImageConstant.logo,
                  height: 220,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 40),
                const Text(
                  'Verify OTP',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Enter the 6-digit code sent to',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.phoneNumber,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 40),
                Pinput(
                  controller: _otpController,
                  length: 6,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: focusedPinTheme,
                  submittedPinTheme: submittedPinTheme,
                  showCursor: true,
                  onCompleted: (pin) {
                    print('🔢 OTP Completed: $pin');
                    _handleVerifyOtp();
                  },
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: getVerticalSize(45),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [appTheme.mintygreen, appTheme.theme2],
                      ),
                      borderRadius: AppRadii.pill,
                    ),
                    child: Obx(
                          () => CustomElevatedButton(
                        onPressed: _controller.loading.value
                            ? null
                            : _handleVerifyOtp,
                        text: _controller.loading.value
                            ? 'Verifying...'
                            : 'VERIFY OTP',
                        height: getVerticalSize(48),
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
                const SizedBox(height: 20),
                TextButton(
                  onPressed: _handleResendOtp,
                  child: const Text(
                    'Resend OTP',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => Get.back(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.arrow_back, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Change Phone Number',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
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
}
