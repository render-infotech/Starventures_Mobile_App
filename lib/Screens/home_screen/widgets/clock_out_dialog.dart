import 'package:flutter/material.dart';
import 'package:starcapitalventures/app_export/app_export.dart';

class ClockOutDialog {
  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true, // User must tap a button
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: appTheme.whiteA700
          ,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadii.lg,
          ),
          title: Row(
            children: [
              Icon(
                Icons.logout,
                color: appTheme.red600,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Clock Out',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: appTheme.black900 ,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to clock out?',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: appTheme.black900 ,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Return false for cancel
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: appTheme.gray500,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(width: getHorizontalSize(30)),
            CustomElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Return true for confirm
              },
              text: 'Clock Out',
              height: getVerticalSize(40), // Use responsive height
              width: getHorizontalSize(100), // Use responsive width
              buttonStyle: ElevatedButton.styleFrom(
                backgroundColor: appTheme.red600,
                foregroundColor: appTheme.whiteA700,
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadii.md,
                ),
                minimumSize: Size(getHorizontalSize(100), getVerticalSize(40)), // Ensure minimum size
              ),
              buttonTextStyle: AppTextStyles.medium.copyWith(
                color: appTheme.whiteA700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
      },
    );
  }
}
