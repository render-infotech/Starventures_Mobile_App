// lib/Screens/applications/widget/application_card.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:starcapitalventures/core/utils/appTheme/app_theme.dart';
import 'package:starcapitalventures/core/utils/styles/size_utils.dart';
import '../../../app_export/app_export.dart';
import '../model/application_model.dart';
import '../controller/application_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ApplicationApiCard extends StatelessWidget {
  final Application application;

  const ApplicationApiCard({
    Key? key,
    required this.application,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: getMargin(bottom: 12),
      padding: getPadding(all: 16),
      decoration: BoxDecoration(
        color: appTheme.whiteA700,
        borderRadius: AppRadii.lg,
        border: Border.all(
          color: _getStatusColor().withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Name and Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  application.customerName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: appTheme.theme2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: getHorizontalSize(8)),
              _buildStatusBadge(),
            ],
          ),

          SizedBox(height: getVerticalSize(12)),

          // Loan Type and Amount Row
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                size: 16,
                color: Colors.grey.shade600,
              ),
              SizedBox(width: getHorizontalSize(6)),
              Expanded(
                child: Text(
                  application.loanType,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: getHorizontalSize(8)),
              Text(
                application.formattedAmount,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ],
          ),

          // Bank Name and Logo Row
          if (application.bank != null) ...[
            SizedBox(height: getVerticalSize(10)),
            Row(
              children: [
                // Bank Logo
                if (application.bank!.bankLogo != null)
                  Container(
                    width: 24,
                    height: 24,
                    margin: getMargin(right: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: CachedNetworkImage(
                        imageUrl: application.bank!.bankLogo!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey.shade200,
                          child: Icon(
                            Icons.account_balance,
                            size: 14,
                            color: Colors.grey.shade400,
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey.shade200,
                          child: Icon(
                            Icons.account_balance,
                            size: 14,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    width: 24,
                    height: 24,
                    margin: getMargin(right: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      Icons.account_balance,
                      size: 14,
                      color: Colors.grey.shade400,
                    ),
                  ),

                // Bank Name
                Expanded(
                  child: Text(
                    application.bank!.name,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],

          SizedBox(height: getVerticalSize(12)),

          // Contact Info Row
          Row(
            children: [
              Icon(
                Icons.phone_outlined,
                size: 14,
                color: Colors.grey.shade500,
              ),
              SizedBox(width: getHorizontalSize(4)),
              Text(
                application.phone,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.black,
                ),
              ),
              SizedBox(width: getHorizontalSize(16)),
              Icon(
                Icons.email_outlined,
                size: 14,
                color: Colors.grey.shade500,
              ),
              SizedBox(width: getHorizontalSize(4)),
              Expanded(
                child: Text(
                  application.email,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          SizedBox(height: getVerticalSize(8)),

          // Date Row with Delete Icon
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 14,
                color: Colors.grey.shade500,
              ),
              SizedBox(width: getHorizontalSize(4)),
              Expanded(
                child: Text(
                  _formatDate(application.createdAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.black,
                  ),
                ),
              ),

              // Delete Icon Button
              // InkWell(
              //   onTap: () => _showDeleteConfirmation(context),
              //   borderRadius: BorderRadius.circular(20),
              //   child: Container(
              //     padding: const EdgeInsets.all(6),
              //     decoration: BoxDecoration(
              //       color: Colors.red.shade50,
              //       shape: BoxShape.circle,
              //     ),
              //     child: Icon(
              //       Icons.delete_outline,
              //       size: 18,
              //       color: Colors.red.shade700,
              //     ),
              //   ),
              // ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Application'),
        content: Text(
          'Are you sure you want to delete this application for ${application.customerName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back(); // Close dialog
              await _handleDelete(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // ✅ FIXED: Properly refresh after delete
  Future<void> _handleDelete(BuildContext context) async {
    final controller = Get.find<ApplicationListController>();

    // Show loading
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      barrierDismissible: false,
    );

    final success = await controller.deleteApplication(application.id);

    // Close loading
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }

    if (success) {
      // ✅ Force immediate UI update
      controller.applications.refresh();

      Get.snackbar(
        'Success',
        'Application deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
        duration: const Duration(seconds: 2),
        icon: const Icon(Icons.check_circle, color: Colors.green),
      );
    }
  }

  Widget _buildStatusBadge() {
    final color = _getStatusColor();
    final status = _getStatusText();

    return Container(
      padding: getPadding(left: 10, right: 10, top: 6, bottom: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (application.statusEnum) {
      case ApplicationStatus.approved:
        return const Color(0xFF10B981);
      case ApplicationStatus.rejected:
        return const Color(0xFFEF4444);
      case ApplicationStatus.pending:
        return const Color(0xFFF59E0B);
      case ApplicationStatus.processing:
        return const Color(0xFF3B82F6);
    }
  }

  String _getStatusText() {
    return application.status;
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
