import 'package:flutter/material.dart';
import 'package:starcapitalventures/core/utils/styles/size_utils.dart';
import 'package:starcapitalventures/core/utils/styles/custom_border_radius.dart';
import '../model/application_model.dart';

class ApplicationCard extends StatelessWidget {
  const ApplicationCard({super.key, required this.item});
  final ApplicationItem item;

  @override
  Widget build(BuildContext context) {
    final number = item.amount;
    final displayAmount = _formatINR(number);

    final (chipLabel, chipBg, chipFg) = _statusChip(item.status);

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
          // Left accent
          Container(
            width: getHorizontalSize(6),
            height: getVerticalSize(110),
            decoration: BoxDecoration(
              color: item.accentColor,
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
                  // Name + status chip
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.applicantName,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1A2036),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _StatusChip(label: chipLabel, bg: chipBg, fg: chipFg),
                    ],
                  ),

                  SizedBox(height: getVerticalSize(6)),

                  // Loan type • amount
                  Text(
                    '${item.loanType} • ₹$displayAmount',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: getVerticalSize(10)),

                  // Applied ago • App ID
                  Text(
                    '${item.appliedAgo} • App ID: ${item.appId}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.black45,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Formats as 5,00,000 style (Indian grouping)
  String _formatINR(int amount) {
    final s = amount.toString();
    if (s.length <= 3) return s;
    final last3 = s.substring(s.length - 3);
    String rest = s.substring(0, s.length - 3);
    final buf = StringBuffer();
    while (rest.length > 2) {
      buf.write('${rest.substring(rest.length - 2)},');
      rest = rest.substring(0, rest.length - 2);
    }
    if (rest.isNotEmpty) buf.write(rest);
    final commas = buf.toString().split('').reversed.join();
    return '$commas,$last3';
  }

  (String, Color, Color) _statusChip(ApplicationStatus st) {
    switch (st) {
      case ApplicationStatus.processing:
        return ('PROCESSING', const Color(0xFFE7F0FF), const Color(0xFF4F8BFF));
      case ApplicationStatus.approved:
        return ('APPROVED', const Color(0xFFE8FFF4), const Color(0xFF22A16B));
      case ApplicationStatus.pending:
        return ('PENDING', const Color(0xFFFFF3D7), const Color(0xFFB78900));
      case ApplicationStatus.rejected:
        return ('REJECTED', const Color(0xFFFFE6E6), const Color(0xFFD22E2E));
    }
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.bg, required this.fg});
  final String label;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: getPadding(left: 12, right: 12, top: 6, bottom: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadii.pill,
        border: Border.all(color: bg.withOpacity(0.6), width: 1),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: fg,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
