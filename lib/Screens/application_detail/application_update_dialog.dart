// lib/widgets/application_update_dialog.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:starcapitalventures/app_export/app_export.dart';
import '../../core/utils/custom_snackbar.dart';
import 'application_detail_controller/application_history_controller.dart';
import 'application_detail_controller/action_history_controller.dart';

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
                  onPressed: () {
                    controller.resetForm();
                    Navigator.of(context).pop();
                  },
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
                contentPadding: getPadding(left: 16, top: 12, bottom: 12, right: 16),
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
                contentPadding: getPadding(left: 16, top: 12, bottom: 12, right: 16),
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
                    Navigator.of(context).pop();
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
                    print('🔵 Update button clicked');

                    final success = await controller.updateApplicationHistory(applicationId);

                    print('🔵 Update result: $success');

                    if (success) {
                      print('✅ Update successful, starting refresh...');

                      // ✅ IMMEDIATELY fetch updated action history BEFORE closing dialog
                      try {
                        // Try to find the controller with tag first (more specific)
                        final actionHistoryController = Get.find<ActionHistoryController>(tag: applicationId);
                        print('🔵 Found ActionHistoryController with tag: $applicationId');
                        await actionHistoryController.fetchActionHistory(applicationId);
                        print('✅ ActionHistoryController fetched with tag: $applicationId');
                      } catch (e) {
                        print('⚠️ Could not find ActionHistoryController with tag: $e');
                        // If tagged controller not found, try without tag
                        try {
                          final actionHistoryController = Get.find<ActionHistoryController>();
                          print('🔵 Found ActionHistoryController without tag');
                          await actionHistoryController.fetchActionHistory(applicationId);
                          print('✅ ActionHistoryController fetched without tag');
                        } catch (e2) {
                          print('⚠️ Could not find ActionHistoryController: $e2');
                        }
                      }

                      print('🔵 Attempting to close dialog...');

                      // ✅ Close dialog after fetching
                      if (context.mounted) {
                        Navigator.of(context).pop(true);
                        print('✅ Dialog closed successfully');
                      } else {
                        print('⚠️ Context not mounted, cannot close dialog');
                      }

                      // Small delay before showing snackbar
                      await Future.delayed(const Duration(milliseconds: 100));

                      // ✅ Show success snackbar
                      if (context.mounted) {
                        CustomSnackbar.show(
                          context,
                          title: "Success",
                          message: "Application status updated successfully",
                        );
                        print('✅ Snackbar shown');
                      }

                      // ✅ Call parent success callback to refresh application detail
                      if (onSuccess != null) {
                        onSuccess!();
                        print('✅ onSuccess callback executed');
                      }
                    } else {
                      print('❌ Update failed');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appTheme.theme,
                    foregroundColor: Colors.white,
                    padding: getPadding(left: 20, right: 20, top: 12, bottom: 12),
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
