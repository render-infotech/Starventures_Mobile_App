import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:starcapitalventures/app_export/app_export.dart';
import '../app_routes.dart';
import '../Screens/home_screen_main/controller/home_screen_controller.dart';

class ApplyLoanScreen extends StatelessWidget {
  const ApplyLoanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4A2B1A),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
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
                child: Column(
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
                    // Loan Types List
                    _buildLoanTypeItem(
                      Icons.description,
                      'Mortgage Loan',
                      () => Get.toNamed(AppRoutes.newapplication),
                    ),
                    _buildLoanTypeItem(
                      Icons.home,
                      'Home Loan',
                      () => Get.toNamed(AppRoutes.newapplication),
                    ),
                    _buildLoanTypeItem(
                      Icons.location_on,
                      'Site Purchase',
                      () => Get.toNamed(AppRoutes.newapplication),
                    ),
                    _buildLoanTypeItem(
                      Icons.construction,
                      'Construction',
                      () => Get.toNamed(AppRoutes.newapplication),
                    ),
                    _buildLoanTypeItem(
                      Icons.business,
                      'Building Purchase',
                      () => Get.toNamed(AppRoutes.newapplication),
                    ),
                    _buildLoanTypeItem(
                      Icons.map,
                      'Site Lap',
                      () => Get.toNamed(AppRoutes.newapplication),
                    ),
                    _buildLoanTypeItem(
                      Icons.directions_car,
                      'Car Loan',
                      () => Get.toNamed(AppRoutes.newapplication),
                    ),
                    _buildLoanTypeItem(
                      Icons.person,
                      'Personal Loan',
                      () => Get.toNamed(AppRoutes.newapplication),
                    ),
                    _buildLoanTypeItem(
                      Icons.business_center,
                      'Business Loan',
                      () => Get.toNamed(AppRoutes.newapplication),
                    ),
                    _buildLoanTypeItem(
                      Icons.local_shipping,
                      'Commercial Vehicle Loan',
                      () => Get.toNamed(AppRoutes.newapplication),
                    ),
                    _buildLoanTypeItem(
                      Icons.credit_card,
                      'Credit Card',
                      () => Get.toNamed(AppRoutes.newapplication),
                    ),
                    _buildLoanTypeItem(
                      Icons.shield_outlined,
                      'Car Insurance',
                      () => Get.toNamed(AppRoutes.newapplication),
                    ),
                    _buildLoanTypeItem(
                      Icons.health_and_safety_outlined,
                      'Health Insurance',
                      () => Get.toNamed(AppRoutes.newapplication),
                      isLast: true, // Mark the new last item
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: getVerticalSize(140),
      decoration: const BoxDecoration(color: Color(0xFF4A2B1A)),
      child: Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top,
          right: getHorizontalSize(20),
          bottom: getVerticalSize(20),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: getVerticalSize(100),
              width: getHorizontalSize(150),
            ),
            const Spacer(),
            Stack(
              children: [
                Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                  size: getSize(28),
                ),
                Positioned(
                  right: getHorizontalSize(2),
                  top: getVerticalSize(2),
                  child: Container(
                    width: getSize(8),
                    height: getSize(8),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(width: getHorizontalSize(10)),
            GestureDetector(
              onTap: () {
                try {
                  // Navigate to profile tab (index 3 for customers)
                  final homeController =
                      Get.find<HomeOneContainer1Controller>();
                  homeController.selectedIndex.value = 3;
                } catch (e) {
                  // Fallback to direct navigation if controller not found
                  Get.toNamed(AppRoutes.profileScreen);
                }
              },
              child: CircleAvatar(
                radius: getSize(15),
                backgroundColor: Colors.white,
                child: Text(
                  'JD',
                  style: TextStyle(
                    color: Colors.brown,
                    fontWeight: FontWeight.bold,
                    fontSize: getFontSize(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
