import 'package:flutter/material.dart';
import 'package:starcapitalventures/core/utils/styles/size_utils.dart';
import 'package:starcapitalventures/core/utils/styles/custom_border_radius.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label, required this.bg, required this.fg});
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
        border: Border.all(color: bg.withOpacity(0.6), width: getHorizontalSize(1)),
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
