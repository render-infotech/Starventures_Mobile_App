import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


import 'package:starcapitalventures/app_export/app_export.dart';
class HolidayCard extends StatelessWidget {
  const HolidayCard({
    Key? key,
    required this.dateLabel,
    required this.title,
    required this.stripeColor,
  }) : super(key: key);

  final String dateLabel;
  final String title;
  final Color stripeColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.lg, // rounded like screenshot
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFE9EDF5), width: 1),
      ),
      child: Row(
        children: [
          // Left colored stripe with matching rounded corners
          Container(
            width: 6,
            height: 64,
            decoration: BoxDecoration(
              color: stripeColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
            ),
          ),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateLabel,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A2036),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
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
