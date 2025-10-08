// lib/widgets/application_update_dialog.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:starcapitalventures/app_export/app_export.dart';
import '../../core/utils/custom_snackbar.dart';
import 'application_detail_controller/application_history_controller.dart';

// lib/widgets/application_update_dialog.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:starcapitalventures/app_export/app_export.dart';
import '../../core/utils/custom_snackbar.dart';
import 'application_detail_controller/application_history_controller.dart';
import 'application_detail_controller/action_history_controller.dart'; // Add this import

class ApplicationUpdateDialog extends StatelessWidget {
  final String applicationId;
  final VoidCallback? onSuccess;

  const ApplicationUpdateDialog({
    super.key,
    required this.applicationId,
    this.onSuccess,
  });

  static Future<bool?> show(
      BuildContext context, {
        required String applicationId,
        VoidCallback? onSuccess,
      }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ApplicationUpdateDialog(
        applicationId: applicationId,
        onSuccess: onSuccess,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ApplicationHistoryController());

    return Dialog(
      backgroundColor: appTheme.whiteA700,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadii.lg,
      ),
      child: Container(
        padding: getPadding(all: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Update Application Status',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A2036),
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),

            SizedBox(height: getVerticalSize(4)),
            Text(
              'Add status update and remarks for this application',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.black54,
              ),
            ),

            SizedBox(height: getVerticalSize(20)),

            // Action Field
            Text(
              'Action',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A2036),
              ),
            ),
            SizedBox(height: getVerticalSize(8)),
            TextFormField(
              controller: controller.actionController,
              decoration: InputDecoration(
                hintText: 'Enter action (e.g., Status Changed)',
                filled: true,
                fillColor: const Color(0xFFF8F9FA),
                border: OutlineInputBorder(
                  borderRadius: AppRadii.sm,
                  borderSide: const BorderSide(color: Color(0xFFE9EDF5)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: AppRadii.sm,
                  borderSide: const BorderSide(color: Color(0xFFE9EDF5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppRadii.sm,
                  borderSide: BorderSide(color: appTheme.theme),
                ),
                contentPadding: getPadding(left: 16,top: 12,bottom: 12,right: 16),
              ),
            ),

            SizedBox(height: getVerticalSize(16)),

            // Remarks Field
            Text(
              'Remarks',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A2036),
              ),
            ),
            SizedBox(height: getVerticalSize(8)),
            TextFormField(
              controller: controller.remarksController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter remarks about the status update...',
                filled: true,
                fillColor: const Color(0xFFF8F9FA),
                border: OutlineInputBorder(
                  borderRadius: AppRadii.sm,
                  borderSide: const BorderSide(color: Color(0xFFE9EDF5)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: AppRadii.sm,
                  borderSide: const BorderSide(color: Color(0xFFE9EDF5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppRadii.sm,
                  borderSide: BorderSide(color: appTheme.theme),
                ),
                contentPadding: getPadding(left: 16,top: 12,bottom: 12,right: 16),
              ),
            ),

            // Error message
            Obx(() {
              if (controller.errorMessage.value.isNotEmpty) {
                return Padding(
                  padding: getPadding(top: 8),
                  child: Text(
                    controller.errorMessage.value,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.red,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),

            SizedBox(height: getVerticalSize(24)),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    controller.resetForm();
                    Get.back();
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                SizedBox(width: getHorizontalSize(12)),

                Obx(() => ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () async {
                    final success = await controller.updateApplicationHistory(applicationId);

                    if (success) {
                      // Show immediate success message
                      CustomSnackbar.show(
                        context,
                        title: "Success",
                        message: "Application status updated successfully",
                      );

                      // IMMEDIATELY REFRESH ACTION HISTORY CONTROLLER
                      try {
                        // Try to find the controller with tag first (more specific)
                        final actionHistoryController = Get.find<ActionHistoryController>(tag: applicationId);
                        await actionHistoryController.refreshActionHistory(applicationId);
                        print('✅ ActionHistoryController refreshed with tag: $applicationId');
                      } catch (e) {
                        // If tagged controller not found, try without tag
                        try {
                          final actionHistoryController = Get.find<ActionHistoryController>();
                          await actionHistoryController.refreshActionHistory(applicationId);
                          print('✅ ActionHistoryController refreshed without tag');
                        } catch (e2) {
                          print('⚠️ Could not find ActionHistoryController: $e2');
                        }
                      }

                      // Call the parent success callback
                      if (onSuccess != null) {
                        onSuccess!();
                      }

                      // Close the dialog
                      Get.back(result: true);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appTheme.theme,
                    foregroundColor: Colors.white,
                    padding: getPadding(left: 20,right: 20,top: 12,bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadii.sm,
                    ),
                  ),
                  child: controller.isLoading.value
                      ? SizedBox(
                    width: getHorizontalSize(20),
                    height: getHorizontalSize(20),
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : const Text(
                    'Update Status',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
