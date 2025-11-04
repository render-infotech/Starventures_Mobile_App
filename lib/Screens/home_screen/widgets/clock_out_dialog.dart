import 'package:flutter/material.dart';
import 'package:starcapitalventures/app_export/app_export.dart';

class ClockOutDialog {
  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: appTheme.whiteA700,
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
                  color: appTheme.black900,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to clock out?',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: appTheme.black900,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(

                  borderRadius: AppRadii.sm,

                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: appTheme.orange100,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Once you do, your next clock-in will be available only tomorrow.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: appTheme.black900,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
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
                Navigator.of(context).pop(true);
              },
              text: 'Clock Out',
              height: getVerticalSize(40),
              width: getHorizontalSize(100),
              buttonStyle: ElevatedButton.styleFrom(
                backgroundColor: appTheme.red600,
                foregroundColor: appTheme.whiteA700,
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadii.md,
                ),
                minimumSize: Size(getHorizontalSize(100), getVerticalSize(40)),
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
