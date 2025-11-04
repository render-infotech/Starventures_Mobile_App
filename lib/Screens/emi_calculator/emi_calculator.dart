import 'package:flutter/material.dart';

import '../../app_export/app_export.dart';
class EmiCalculatorButton extends StatelessWidget {
  final VoidCallback onTap;
  final String title;
  final Color? background;
  final Color? foreground;

  const EmiCalculatorButton({
    super.key,
    required this.onTap,
    this.title = 'EMI CALCULATOR',
    this.background,
    this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    final bg = background ?? Colors.white;
    final fg = foreground ?? Colors.black87;
    final radius = 14.0;

    return Padding(
      padding: getPadding(left: 10,right: 10),
      child: Material(
        color: bg,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(.5),
        borderRadius: BorderRadius.circular(radius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                Container(
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F7F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.calculate_outlined,
                      size: 22, color: fg),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: .3,
                      color: fg,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
