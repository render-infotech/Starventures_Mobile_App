// lib/widgets/action_history_widget.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:starcapitalventures/app_export/app_export.dart';

import 'application_detail_controller/action_history_controller.dart';
import 'application_detail_controller/application_history_controller.dart';
import 'application_update_dialog.dart';
import 'model/action_history_model.dart';

class ActionHistoryWidget extends StatelessWidget {
  const ActionHistoryWidget({
    super.key,
    required this.applicationId,
    this.onUpdate,
  });

  final String applicationId;
  final VoidCallback? onUpdate;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ActionHistoryController(), tag: applicationId);

    // Fetch history when widget is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchActionHistory(applicationId);
    });

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.lg,
        border: Border.all(color: const Color(0xFFE9EDF5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: getPadding(all: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and update button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              ElevatedButton.icon(
                onPressed: () {
                  ApplicationUpdateDialog.show(
                    context,
                    applicationId: applicationId,
                    onSuccess: () {
                      // Refresh both the history and call parent callback
                      controller.refreshActionHistory(applicationId);
                      if (onUpdate != null) {
                        onUpdate!();
                      }
                    },
                  );
                },
                icon: const Icon(Icons.update, size: 16),
                label: const Text('Update'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: appTheme.theme2,
                  foregroundColor: Colors.white,
                  padding: getPadding(left: 12,top: 8,bottom: 8,right: 12),
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadii.sm,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: getVerticalSize(12)),

          // History content
          Obx(() {
            if (controller.isLoading.value) {
              return const Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (controller.hasError.value) {
              return Padding(
                padding: getPadding(all: 16),
                child: Column(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red.shade400,
                    ),
                    SizedBox(height: getVerticalSize(8)),
                    Text(
                      'Failed to load history',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.red.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: getVerticalSize(4)),
                    Text(
                      controller.errorMessage.value,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: getVerticalSize(12)),
                    TextButton(
                      onPressed: () => controller.refreshActionHistory(applicationId),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (controller.actionHistory.isEmpty) {
              return Padding(
                padding: getPadding(all: 32),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.history,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      SizedBox(height: getVerticalSize(8)),
                      Text(
                        'No action history yet',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Display history items
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.actionHistory.length,
              separatorBuilder: (context, index) => SizedBox(height: getVerticalSize(16)),
              itemBuilder: (context, index) {
                final item = controller.actionHistory[index];
                return _HistoryItem(item: item);
              },
            );
          }),
        ],
      ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  const _HistoryItem({required this.item});
  final ActionHistoryItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: getPadding(all: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: AppRadii.sm,
        border: Border.all(color: const Color(0xFFE9EDF5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.action,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A2036),
            ),
          ),
          SizedBox(height: getVerticalSize(4)),
          Text(
            item.remarks,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.black87,
            ),
          ),
          SizedBox(height: getVerticalSize(8)),
          Text(
            item.formattedDate,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
              fontSize: getFontSize(11),
            ),
          ),
        ],
      ),
    );
  }
}
