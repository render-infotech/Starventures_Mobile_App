import 'package:flutter/material.dart';
import 'package:starcapitalventures/core/utils/styles/size_utils.dart';
import 'package:starcapitalventures/core/utils/styles/custom_border_radius.dart';
import 'package:intl/intl.dart';
import '../model/application_model.dart';

class ApplicationApiCard extends StatelessWidget {
  const ApplicationApiCard({super.key, required this.application});
  final Application application;

  @override
  Widget build(BuildContext context) {
    final (chipLabel, chipBg, chipFg) = _statusChip(application.statusEnum);
    final formattedDate = DateFormat('MMM dd, yyyy').format(application.createdAt);

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
              color: _getAccentColor(application.statusEnum),
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
                          application.customerName, // Using customerName from API
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

                  // Loan type and amount
                  Text(
                    '${application.loanType} • ${application.formattedAmount}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: getVerticalSize(10)),

                  // Created date • App ID
                  Text(
                    'Applied on $formattedDate • ID: ${application.id}',
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

  Color _getAccentColor(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.processing:
        return const Color(0xFF4F8BFF);
      case ApplicationStatus.approved:
        return const Color(0xFF22A16B);
      case ApplicationStatus.pending:
        return const Color(0xFFFFC85C);
      case ApplicationStatus.rejected:
        return const Color(0xFFFF8080);
    }
  }

  (String, Color, Color) _statusChip(ApplicationStatus status) {
    switch (status) {
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
