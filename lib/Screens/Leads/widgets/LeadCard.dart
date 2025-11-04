import 'package:flutter/material.dart';
import 'package:starcapitalventures/app_export/app_export.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:starcapitalventures/app_export/app_export.dart';
import '../leads_controller.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:starcapitalventures/app_export/app_export.dart';
import '../leads_controller.dart';

class LeadCard extends StatelessWidget {
  const LeadCard({
    super.key,
    required this.leadId,
    required this.name,
    required this.source,
    required this.phone,
    required this.email,
    required this.note,
    required this.addedWhen,
    this.onConvert,
    this.accentColor = const Color(0xFF3FC2A2),
  });

  final String leadId;
  final String name;
  final String source;
  final String phone;
  final String email;
  final String note;
  final String addedWhen;
  final VoidCallback? onConvert;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LeadsController>();

    return Container(
      margin: getMargin(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.lg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: getHorizontalSize(10),
            offset: Offset(0, getVerticalSize(4)),
          ),
        ],
        border: Border.all(color: const Color(0xFFE9EDF5), width: getHorizontalSize(1)),
      ),
      child: Row(
        children: [
          // Left accent strip
          Container(
            width: getHorizontalSize(6),
            height: getVerticalSize(120),
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
            ),
          ),

          // Content
          Expanded(
            child: Padding(
              padding: getPadding(all: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + Delete button
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1A2036),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Obx(
                      //       () => _DeleteButton(
                      //     onTap: controller.isDeletingLead(leadId)
                      //         ? null
                      //         : () => controller.deleteLead(context, leadId, name),
                      //     isLoading: controller.isDeletingLead(leadId),
                      //   ),
                      // ),
                    ],
                  ),
                  SizedBox(height: getVerticalSize(6)),

                  // phone • email
                  Text(
                    '$phone • $email',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.black54,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: getVerticalSize(10)),

                  // Note
                  Text(
                    note,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.black87,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: getVerticalSize(10)),

                  // Footer: added when
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          addedWhen,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.black45,
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
    );
  }
}

class _DeleteButton extends StatelessWidget {
  const _DeleteButton({
    required this.onTap,
    this.isLoading = false,
  });

  final VoidCallback? onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: AppRadii.pill,
      child: Container(
        padding: getPadding(left: 10, right: 10, top: 6, bottom: 6),
        decoration: BoxDecoration(
          color: isLoading
              ? Colors.grey.shade300
              : appTheme.red600.withOpacity(0.1),
          borderRadius: AppRadii.pill,
          border: Border.all(
            color: isLoading
                ? Colors.grey.shade400
                : appTheme.red600.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: isLoading
            ? SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(appTheme.red600),
          ),
        )
            : Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.delete_outline,
              size: 14,
              color: appTheme.red600,
            ),
            const SizedBox(width: 4),
            Text(
              'Delete',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: appTheme.red600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _Delete extends StatelessWidget {
  const _Delete({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: getPadding(left: 10, right: 10, top: 6, bottom: 6),
      decoration: BoxDecoration(
        color: appTheme.red600.withOpacity(0.8),
        borderRadius: AppRadii.pill,
        border: Border.all(color: const Color(0xFFE1E6EF), width: 1),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: appTheme.black900,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ConvertButton extends StatelessWidget {
  const _ConvertButton({this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: AppRadii.pill,
      onTap: onTap,
      child: Container(
        padding: getPadding(left: 14, right: 14, top: 8, bottom: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F4FA),
          borderRadius: AppRadii.pill,
          border: Border.all(color: const Color(0xFFE1E6EF), width: 1),
        ),
        child: Text(
          'Convert',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: const Color(0xFF1A2036),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
