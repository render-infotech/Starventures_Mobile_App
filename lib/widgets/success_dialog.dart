import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:get/get.dart';
import '../core/utils/appTheme/app_theme.dart';
import '../core/utils/styles/size_utils.dart';
import '../core/utils/styles/custom_border_radius.dart';

class SuccessDialog extends StatefulWidget {
  final String title;
  final String message;
  final VoidCallback? onClose;

  const SuccessDialog({
    Key? key,
    required this.title,
    required this.message,
    this.onClose,
  }) : super(key: key);

  @override
  State<SuccessDialog> createState() => _SuccessDialogState();
}

class _SuccessDialogState extends State<SuccessDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: getPadding(all: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadii.xl,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Lottie Animation
            SizedBox(
              width: getHorizontalSize(150),
              height: getVerticalSize(150),
              child: Lottie.asset(
                'assets/success.json',
                controller: _controller,
                onLoaded: (composition) {
                  _controller
                    ..duration = composition.duration
                    ..forward();
                },
              ),
            ),
            SizedBox(height: getVerticalSize(16)),

            // Title
            Text(
              widget.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A2036),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: getVerticalSize(8)),

            // Message
            Text(
              widget.message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: getVerticalSize(24)),

            // Close Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                  if (widget.onClose != null) {
                    widget.onClose!();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: appTheme.theme2,
                  foregroundColor: Colors.white,
                  padding: getPadding(top: 14, bottom: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadii.lg,
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Done',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ✅ Updated helper function with optional role parameter
void showSuccessDialog({
  required String title,
  required String message,
  VoidCallback? onClose,
  String? userRole, // ✅ Add optional role parameter
  Map<String, dynamic>? arguments, // ✅ Add optional arguments
}) {
  Get.dialog(
    SuccessDialog(
      title: title,
      message: message,
      onClose: onClose,
    ),
    barrierDismissible: false,
  );
}
