import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:starcapitalventures/app_export/app_export.dart';
import '../app_routes.dart';
import '../Screens/home_screen_main/controller/home_screen_controller.dart';
import '../widgets/app_header.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:starcapitalventures/app_export/app_export.dart';
import '../app_routes.dart';
import '../Screens/home_screen_main/controller/home_screen_controller.dart';
import '../Screens/new_application/controller/application_type_controller.dart';
import '../Screens/new_application/model/application_type_model.dart';
import '../widgets/app_header.dart';

class ApplyLoanScreen extends StatelessWidget {
  const ApplyLoanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ Get ApplicationTypeController
    final ApplicationTypeController typeController = ApplicationTypeController.to;

    return Scaffold(
      backgroundColor: const Color(0xFF4A2B1A),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const AppHeader(
              height: 155,
              topPadding: 40,
              bottomPadding: 40,
              showProfileAvatar: false,
            ),
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFF3F4F6),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  topRight: Radius.circular(30.0),
                ),
              ),
              child: Padding(
                padding: getPadding(left: 16, top: 24, right: 16, bottom: 100),
                child: Obx(() {
                  // ✅ Show loading state
                  if (typeController.isLoading.value) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: appTheme.theme,
                      ),
                    );
                  }

                  // ✅ Show error state
                  if (typeController.errorMessage.value.isNotEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.orange.shade400,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Failed to load loan types',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () => typeController.refreshApplicationTypes(),
                            icon: Icon(Icons.refresh),
                            label: Text('Retry'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: appTheme.theme,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // ✅ Show loan types dynamically from API
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Apply for a Loan or Service',
                        style: TextStyle(
                          fontSize: getFontSize(20),
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: getVerticalSize(20)),

                      // ✅ Dynamic loan types from API
                      ...typeController.applicationTypes.asMap().entries.map((entry) {
                        final index = entry.key;
                        final loanType = entry.value;
                        final isLast = index == typeController.applicationTypes.length - 1;

                        return _buildLoanTypeItem(
                          _getIconForLoanType(loanType.name),
                          loanType.name,
                              () => _navigateWithSelectedType(loanType),
                          isLast: isLast,
                        );
                      }).toList(),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Navigate with selected loan type
  void _navigateWithSelectedType(ApplicationTypeModel loanType) {
    Get.toNamed(
      AppRoutes.newapplication,
      arguments: {'selectedApplicationType': loanType},
    );
  }

  // ✅ Map loan type names to icons
  IconData _getIconForLoanType(String loanTypeName) {
    final name = loanTypeName.toLowerCase();

    if (name.contains('mortgage')) {
      return Icons.description;
    } else if (name.contains('home')) {
      return Icons.home;
    } else if (name.contains('site') && name.contains('purchase')) {
      return Icons.location_on;
    } else if (name.contains('construction')) {
      return Icons.construction;
    } else if (name.contains('building')) {
      return Icons.business;
    } else if (name.contains('lap')) {
      return Icons.map;
    } else if (name.contains('car') || name.contains('vehicle') || name.contains('auto')) {
      return Icons.directions_car;
    } else if (name.contains('personal')) {
      return Icons.person;
    } else if (name.contains('business')) {
      return Icons.business_center;
    } else if (name.contains('commercial') && name.contains('vehicle')) {
      return Icons.local_shipping;
    } else if (name.contains('credit') || name.contains('card')) {
      return Icons.credit_card;
    } else if (name.contains('insurance') && name.contains('car')) {
      return Icons.shield_outlined;
    } else if (name.contains('insurance') && name.contains('health')) {
      return Icons.health_and_safety_outlined;
    } else if (name.contains('gold')) {
      return Icons.star;
    } else if (name.contains('education') || name.contains('student')) {
      return Icons.school;
    } else if (name.contains('agriculture') || name.contains('farm')) {
      return Icons.agriculture;
    } else {
      return Icons.account_balance; // Default
    }
  }

  Widget _buildLoanTypeItem(
      IconData icon,
      String title,
      VoidCallback onTap, {
        bool isLast = false,
      }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : getVerticalSize(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(getSize(12)),
        child: Container(
          width: double.infinity,
          padding: getPadding(left: 16, right: 16, top: 16, bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(getSize(12)),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Container(
                width: getSize(40),
                height: getSize(40),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A2B1A).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(getSize(8)),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF4A2B1A),
                  size: getSize(20),
                ),
              ),
              SizedBox(width: getHorizontalSize(16)),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: getFontSize(16),
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey.shade400,
                size: getSize(24),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
