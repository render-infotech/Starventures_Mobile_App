// lib/styles/typography.dart
import 'package:flutter/material.dart';

class AppTextStyles {
  // Base styles
  static const TextStyle regular = TextStyle(
    fontSize: 14,
    height: 1.4,
    letterSpacing: 0.2,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle medium = TextStyle(
    fontSize: 14,
    height: 1.4,
    letterSpacing: 0.2,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle semiBold = TextStyle(
    fontSize: 16,
    height: 1.35,
    letterSpacing: 0.1,
    fontWeight: FontWeight.w600,
  );

  // Semantic roles
  static const TextStyle title = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.35,
    color: Colors.black54,
  );

  static const TextStyle body = regular;

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.3,
    color: Colors.black45,
  );

  // Variants via decoration
  static TextStyle underline(TextStyle base) =>
      base.copyWith(decoration: TextDecoration.underline);

  static TextStyle strike(TextStyle base) =>
      base.copyWith(decoration: TextDecoration.lineThrough);

  // Map into TextTheme so ThemeData can use them
  static TextTheme toTextTheme(Color onBg) {
    return TextTheme(
      headlineSmall: title.copyWith(color: onBg),
      titleMedium: subtitle.copyWith(color: onBg.withOpacity(0.8)),
      bodyMedium: body.copyWith(color: onBg),
      bodySmall: caption.copyWith(color: onBg.withOpacity(0.6)),
      labelLarge: semiBold.copyWith(color: onBg),
    );
  }
}
