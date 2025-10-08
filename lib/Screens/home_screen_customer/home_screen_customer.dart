import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:starcapitalventures/app_export/app_export.dart';
import '../../app_routes.dart';
import '../profile/controller/profile_controller.dart';
import '../home_screen_main/controller/home_screen_controller.dart';

class HomeScreenCustomer extends StatefulWidget {
  const HomeScreenCustomer({super.key});

  @override
  State<HomeScreenCustomer> createState() => _HomeScreenCustomerState();
}

class _HomeScreenCustomerState extends State<HomeScreenCustomer> {
  late final ProfileController _profile;

  @override
  void initState() {
    super.initState();
    _profile =
        Get.isRegistered<ProfileController>()
            ? Get.find<ProfileController>()
            : Get.put(ProfileController());
  }

  String getInitials(String fullName) {
    if (fullName.isEmpty) return '';
    List<String> names = fullName.split(' ');
    String initials = '';
    if (names.isNotEmpty) {
      initials += names[0][0];
      if (names.length > 1) {
        initials += names[names.length - 1][0];
      }
    }
    return initials.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final fullName = _profile.userName.value;
      final initials = getInitials(fullName);

      return Scaffold(
        backgroundColor: Color(0xFF4A2B1A),
        body: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(initials),
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(
                    0xFFF3F4F6,
                  ), // Light grey background for the sheet
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0),
                  ),
                ),
                child: Padding(
                  padding: getPadding(
                    left: 16,
                    top: 24,
                    right: 16,
                    bottom: 100,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLoanChoiceCard(),
                      SizedBox(height: getVerticalSize(20)),
                      Padding(
                        padding: getPadding(left: 10, right: 10),
                        child: _buildApplicationStatusCard(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildHeader(String initials) {
    return Container(
      height: getVerticalSize(140),
      decoration: BoxDecoration(
        color: Color(0xFF4A2B1A),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(getSize(30)),
          bottomRight: Radius.circular(getSize(30)),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top,
          // left: 20,
          right: getHorizontalSize(20),
          bottom: getVerticalSize(20),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png', // Assuming you have a logo asset
              height: getVerticalSize(100),
              width: getHorizontalSize(150),
              // fit: BoxFit.contain,
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

  Widget _buildLoanChoiceCard() {
    return Column(
      children: [
        Padding(
          padding: getPadding(left: 10, right: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Choose your Loan',
                style: TextStyle(
                  fontSize: getFontSize(20),
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              InkWell(
                onTap: () {
                  // Switch to Apply Loan tab (index 1) in bottom navigation
                  final homeController =
                      Get.find<HomeOneContainer1Controller>();
                  homeController.selectedIndex.value = 1;
                },
                child: Text(
                  'View All',
                  style: TextStyle(
                    fontSize: getFontSize(14),
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: getVerticalSize(20)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildLoanTypeItem(
              Icons.home,
              'Home Loan',
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
              Icons.credit_card,
              'Credit Card',
              () => Get.toNamed(AppRoutes.newapplication),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoanTypeItem(IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: getSize(60),
            height: getSize(60),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(getSize(16)),
            ),
            child: Icon(
              icon,
              size: getSize(28),
              color: const Color(0xFF4A2B1A),
            ),
          ),
          SizedBox(height: getVerticalSize(8)),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: getFontSize(12),
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationStatusCard() {
    return Container(
      width: double.infinity,
      padding: getPadding(all: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F4F1), // Light cyan color
        borderRadius: BorderRadius.circular(getSize(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Application Status',
                style: TextStyle(
                  fontSize: getFontSize(18),
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: getPadding(left: 12, right: 12, top: 6, bottom: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(getSize(12)),
                ),
                child: Text(
                  'ICICI Bank',
                  style: TextStyle(
                    fontSize: getFontSize(12),
                    color: Colors.blue.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: getVerticalSize(20)),
          _buildProgressStep('Technical', 'In progress', true, false),
          _buildProgressStep('FI - Legal', '', false, false),
          _buildProgressStep('PD (Personal Discussion)', '', false, false),
          _buildProgressStep('Sanction', '', false, false),
          _buildProgressStep('Agreement', '', false, false),
          _buildProgressStep('MODT Registration', '', false, false),
          _buildProgressStep('Disbursement', '', false, true),

          SizedBox(height: getVerticalSize(20)),
        ],
      ),
    );
  }

  Widget _buildProgressStep(
    String title,
    String subtitle,
    bool isActive,
    bool isLast,
  ) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: getSize(24),
                height: getSize(24),
                decoration: BoxDecoration(
                  color: isActive ? Colors.orange : Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isActive ? Icons.hourglass_top : Icons.watch_later_outlined,
                  size: getSize(14),
                  color: isActive ? Colors.white : Colors.grey.shade600,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: getSize(2),
                    color: Colors.grey.shade300,
                  ),
                ),
            ],
          ),
          SizedBox(width: getHorizontalSize(16)),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                top: getVerticalSize(2),
                bottom: isLast ? 0 : getVerticalSize(32),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: getFontSize(14),
                      fontWeight: FontWeight.w600,
                      color: isActive ? Colors.black87 : Colors.grey.shade600,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    SizedBox(height: getVerticalSize(2)),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: getFontSize(12),
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
