// lib/Screens/leads/edit_lead_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:starcapitalventures/app_export/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_text_form_field.dart';
import '../../widgets/success_dialog.dart';
import '../lead_detail/lead_detail_controller.dart';

class EditLeadScreen extends StatefulWidget {
  const EditLeadScreen({super.key});

  @override
  State<EditLeadScreen> createState() => _EditLeadScreenState();
}

class _EditLeadScreenState extends State<EditLeadScreen> {
  final LeadDetailController _controller = Get.find<LeadDetailController>();

  // Text controllers - created once in initState
  late final TextEditingController nameCtrl;
  late final TextEditingController phoneCtrl;
  late final TextEditingController notesCtrl;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with current lead data
    final lead = _controller.leadDetail.value;
    nameCtrl = TextEditingController(text: lead?.name ?? '');
    phoneCtrl = TextEditingController(text: lead?.phone ?? '');
    notesCtrl = TextEditingController(text: lead?.notes ?? '');
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    // Validation
    if (nameCtrl.text.trim().isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Name is required',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return;
    }

    if (phoneCtrl.text.trim().isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Phone is required',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return;
    }

    // Submit update
    final success = await _controller.updateLead(
      name: nameCtrl.text.trim(),
      phone: phoneCtrl.text.trim(),
      notes: notesCtrl.text.trim(),
    );

    if (success) {
      // Show success dialog
      Get.dialog(
        SuccessDialog(
          title: 'Success!',
          message: 'Lead updated successfully',
          onClose: () {
            Get.back(); // Close dialog
            Get.back(result: true); // Go back to detail screen with success result
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.gray100,
      appBar: CustomAppBar(
        backgroundColor: appTheme.mintygreen,
        useGreeting: false,
        pageTitle: 'Edit Lead',
        showBack: true,
      ),
      body: Obx(() {
        if (_controller.isUpdating.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: appTheme.theme2),
                SizedBox(height: getVerticalSize(16)),
                Text(
                  'Updating lead...',
                  style: TextStyle(
                    fontSize: getFontSize(16),
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: getPadding(left: 16, right: 16, top: 24, bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name Field
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
                contentPadding: getPadding(
                  left: 14,
                  right: 14,
                  top: 14,
                  bottom: 14,
                ),
                defaultBorderDecoration: OutlineInputBorder(
                  borderRadius: AppRadii.lg,
                  borderSide: BorderSide(
                    color: const Color(0xFFE9EDF5),
                    width: 1,
                  ),
                ),
                enabledBorderDecoration: OutlineInputBorder(
                  borderRadius: AppRadii.lg,
                  borderSide: BorderSide(
                    color: const Color(0xFFE9EDF5),
                    width: 1,
                  ),
                ),
                focusedBorderDecoration: OutlineInputBorder(
                  borderRadius: AppRadii.lg,
                  borderSide: BorderSide(
                    color: appTheme.theme2,
                    width: 1,
                  ),
                ),
              ),

              SizedBox(height: getVerticalSize(16)),

              // Phone Field
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
                controller: phoneCtrl,
                hintText: 'Enter phone number',
                filled: true,
                fillColor: Colors.white,
                textInputType:TextInputType.phone ,
                contentPadding: getPadding(
                  left: 14,
                  right: 14,
                  top: 14,
                  bottom: 14,
                ),
                defaultBorderDecoration: OutlineInputBorder(
                  borderRadius: AppRadii.lg,
                  borderSide: BorderSide(
                    color: const Color(0xFFE9EDF5),
                    width: 1,
                  ),
                ),
                enabledBorderDecoration: OutlineInputBorder(
                  borderRadius: AppRadii.lg,
                  borderSide: BorderSide(
                    color: const Color(0xFFE9EDF5),
                    width: 1,
                  ),
                ),
                focusedBorderDecoration: OutlineInputBorder(
                  borderRadius: AppRadii.lg,
                  borderSide: BorderSide(
                    color: appTheme.theme2,
                    width: 1,
                  ),
                ),
              ),

              SizedBox(height: getVerticalSize(16)),

              // Notes Field
              Text(
                'Notes (Optional)',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: const Color(0xFF1A2036),
                  fontWeight: FontWeight.w600,
                  fontSize: getFontSize(13),
                ),
              ),
              SizedBox(height: getVerticalSize(8)),
              CustomTextFormField(
                controller: notesCtrl,
                hintText: 'Enter notes',
                filled: true,
                fillColor: Colors.white,
                maxLines: 4,
                contentPadding: getPadding(
                  left: 14,
                  right: 14,
                  top: 14,
                  bottom: 14,
                ),
                defaultBorderDecoration: OutlineInputBorder(
                  borderRadius: AppRadii.lg,
                  borderSide: BorderSide(
                    color: const Color(0xFFE9EDF5),
                    width: 1,
                  ),
                ),
                enabledBorderDecoration: OutlineInputBorder(
                  borderRadius: AppRadii.lg,
                  borderSide: BorderSide(
                    color: const Color(0xFFE9EDF5),
                    width: 1,
                  ),
                ),
                focusedBorderDecoration: OutlineInputBorder(
                  borderRadius: AppRadii.lg,
                  borderSide: BorderSide(
                    color: appTheme.theme2,
                    width: 1,
                  ),
                ),
              ),

              SizedBox(height: getVerticalSize(32)),

              // Update Button
              CustomElevatedButton(
                text: 'Update Lead',
                height: getVerticalSize(48),
                width: double.infinity,
                buttonStyle: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, getVerticalSize(48)),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadii.lg,
                  ),
                  backgroundColor: appTheme.theme2,
                  foregroundColor: Colors.white,
                ),
                buttonTextStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                onPressed: _handleSubmit,
              ),
            ],
          ),
        );
      }),
    );
  }
}
