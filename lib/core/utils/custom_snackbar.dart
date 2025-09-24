import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'appTheme/app_theme.dart';

class CustomSnackbar {
  static void show(
      BuildContext context, {
        required String title,
        required String message,
        Color? backgroundColor,
        Duration duration = const Duration(seconds: 2),
      }) {
    final snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      elevation: 6,
      backgroundColor: backgroundColor ?? appTheme.mintygreen, // Use your theme color
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 2),
          Text(message, style: const TextStyle(color: Colors.white)),
        ],
      ),
      duration: duration,
      animation: CurvedAnimation(
        parent: AnimationController(
          duration: const Duration(milliseconds: 300),
          vsync: ScaffoldMessenger.of(context),
        ),
        curve: Curves.easeInOut,
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}
