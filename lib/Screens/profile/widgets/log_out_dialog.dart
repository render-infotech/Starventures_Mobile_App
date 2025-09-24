import 'package:flutter/material.dart';
import 'package:starcapitalventures/app_export/app_export.dart';

Future<bool> showLogoutDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (ctx) {
      return Dialog(
        insetPadding: getPadding(left: 24, right: 24),
        shape: RoundedRectangleBorder(borderRadius: AppRadii.lg),
        child: Padding(
          padding: getPadding(all: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: getHorizontalSize(40),
                    height: getHorizontalSize(40),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1F1),
                      borderRadius: AppRadii.md,
                      border: Border.all(color: const Color(0xFFFFD6D6)),
                    ),
                    alignment: Alignment.center,
                    child: Icon(Icons.logout, color: appTheme.navyBlue),
                  ),
                  SizedBox(width: getHorizontalSize(12)),
                  Expanded(
                    child: Text(
                      'Log out',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A2036),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: getVerticalSize(12)),
              Text(
                'Are you sure you want to log out?',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black87),
              ),
              SizedBox(height: getVerticalSize(20)),
              Row(
                children: [
                  Expanded(
                    child: CustomElevatedButton(
                      height: 40,
                      buttonStyle: OutlinedButton.styleFrom(
                        minimumSize: Size(double.infinity, getVerticalSize(44)),
                        side: const BorderSide(color: Color(0xFFE1E6EF)),
                        shape: RoundedRectangleBorder(borderRadius: AppRadii.lg),
                      ),
                      onPressed: () => Navigator.of(ctx).pop(false),
                      text: 'Cancel',
                      buttonTextStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF1A2036),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(width: getHorizontalSize(12)),
                  Expanded(
                    child: CustomElevatedButton(
                      height: 40,
                      buttonStyle: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, getVerticalSize(44)),
                        backgroundColor: appTheme.mintygreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: AppRadii.lg),
                      ),
                      onPressed: () => Navigator.of(ctx).pop(true), // Return true to confirm logout
                      text: 'Log out',
                      buttonTextStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: appTheme.whiteA700,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
  return result ?? false;
}
