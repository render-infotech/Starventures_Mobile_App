import 'package:flutter/material.dart';
import 'package:starcapitalventures/app_export/app_export.dart';

class LeadActivityCard extends StatelessWidget {
  const LeadActivityCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.timeAgo,
    required this.statusLabel,
    required this.statusBg,
    required this.statusFg,
  });

  final String title;
  final String subtitle;
  final String timeAgo;      // e.g., '2 hours ago'
  final String statusLabel;  // e.g., 'SUCCESS' or 'NEW'
  final Color statusBg;
  final Color statusFg;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.lg,
        border: Border.all(color: const Color(0xFFE9EDF5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: getHorizontalSize(10),
            offset: Offset(0, getVerticalSize(4)),
          ),
        ],
      ),
      child: Padding(
        padding: getPadding(all: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // title + status chip
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A2036),
                    ),
                  ),
                ),
                Container(
                  padding: getPadding(left: 10, right: 10, top: 6, bottom: 6),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: AppRadii.pill,
                    border: Border.all(color: statusBg.withOpacity(0.5)),
                  ),
                  child: Text(
                    statusLabel,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: statusFg,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: getVerticalSize(6)),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54),
            ),
            SizedBox(height: getVerticalSize(8)),
            Text(
              timeAgo,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black45),
            ),
          ],
        ),
      ),
    );
  }
}
