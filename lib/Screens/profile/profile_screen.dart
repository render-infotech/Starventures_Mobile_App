// lib/Screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starcapitalventures/Screens/profile/widgets/log_out_dialog.dart';

import 'controller/profile_controller.dart';
import 'logout_controller.dart';
import 'edit_profile_screen.dart';
import 'package:starcapitalventures/app_export/app_export.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileController _controller;
  late final LogoutController _logout;

  // Issues selection state
  String? selectedIssue;
  final List<String> issueOptions = [
    'RM not calling back',
    'RM not responding',
    'I want to change my RM',
  ];

  @override
  void initState() {
    super.initState();
    _controller = Get.find<ProfileController>();
    _logout = Get.put(LogoutController());
  }

  String _initials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '';
    final parts =
        trimmed.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    final first =
        parts.isNotEmpty && parts.first.isNotEmpty
            ? parts.first.characters.first
            : '';
    final last =
        parts.length > 1 && parts.last.isNotEmpty
            ? parts.last.characters.first
            : '';
    final init = (first + last).isEmpty ? first : (first + last);
    return init.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final name = _controller.userName.value;
      final email = _controller.userEmail.value;
      final role = _controller.role.value;
      final initials = name.isEmpty ? '' : _initials(name);
      final isCustomer = role == 'customer';

      return Scaffold(
        backgroundColor: const Color(0xFF4A2B1A),
        body:
            isCustomer
                ? SingleChildScrollView(
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
                          padding: getPadding(
                            left: 20,
                            top: 26,
                            right: 20,
                            bottom: 100,
                          ),
                          child: _buildProfileContent(),
                        ),
                      ),
                    ],
                  ),
                )
                : Column(
                  children: [
                    _buildHeader(context),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30.0),
                            topRight: Radius.circular(30.0),
                          ),
                        ),
                        child: Padding(
                          padding: getPadding(
                            left: 20,
                            top: 26,
                            right: 20,
                            bottom: 100,
                          ),
                          child: _buildProfileContent(),
                        ),
                      ),
                    ),
                  ],
                ),
      );
    });
  }

  Widget _buildProfileContent() {
    final name = _controller.userName.value;
    final email = _controller.userEmail.value;
    final role = _controller.role.value;
    final initials = name.isEmpty ? '' : _initials(name);
    final isCustomer = role == 'customer';

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: getPadding(all: 22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(getSize(16)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: getSize(80),
                height: getSize(80),
                decoration: const BoxDecoration(
                  color: Color(0xFF4A2B1A),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    initials.isEmpty ? 'JD' : initials,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: getFontSize(24),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: getVerticalSize(16)),
              // Name
              Text(
                name.isEmpty ? 'James Doe' : name,
                style: TextStyle(
                  fontSize: getFontSize(20),
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: getVerticalSize(4)),
              // Email
              Text(
                email.isEmpty ? 'james.doe@email.com' : email,
                style: TextStyle(
                  fontSize: getFontSize(14),
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: getVerticalSize(24)),

        // Menu Options
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(getSize(16)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildMenuItem(
                icon: Icons.edit_outlined,
                title: 'Edit Profile',
                onTap: () => Get.to(() => const EditProfileScreen()),
              ),
              _buildDivider(),
              _buildMenuItem(
                icon: Icons.folder_outlined,
                title: 'My Documents',
                onTap: () {
                  // Navigate to documents
                },
              ),
              _buildDivider(),
              _buildMenuItem(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                onTap: () {
                  // Navigate to notifications
                },
              ),
              _buildDivider(),
              _buildMenuItem(
                icon: Icons.logout,
                title: 'Logout',
                titleColor: Colors.red,
                onTap: () async {
                  final confirm = await showLogoutDialog(context);
                  if (confirm) {
                    await _logout.performLogout(context);
                  }
                },
              ),
            ],
          ),
        ),

        if (isCustomer) ...[
          SizedBox(height: getVerticalSize(24)),

          // Relationship Manager Section
          Container(
            width: double.infinity,
            padding: getPadding(all: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(getSize(16)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Relationship Manager',
                  style: TextStyle(
                    fontSize: getFontSize(16),
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: getVerticalSize(16)),
                Row(
                  children: [
                    Container(
                      width: getSize(50),
                      height: getSize(50),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(getSize(12)),
                      ),
                      child: Center(
                        child: Text(
                          'MK',
                          style: TextStyle(
                            fontSize: getFontSize(16),
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4A2B1A),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: getHorizontalSize(12)),
                    // RM Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mani Kumar',
                            style: TextStyle(
                              fontSize: getFontSize(16),
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: getVerticalSize(2)),
                          Text(
                            'Available to help',
                            style: TextStyle(
                              fontSize: getFontSize(13),
                              color: Colors.grey.shade900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Action Buttons
                    Row(
                      children: [
                        Container(
                          width: getSize(40),
                          height: getSize(40),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(getSize(20)),
                          ),
                          child: Icon(
                            Icons.phone,
                            size: getSize(20),
                            color: const Color(0xFF4A2B1A),
                          ),
                        ),
                        SizedBox(width: getHorizontalSize(8)),
                        Container(
                          width: getSize(40),
                          height: getSize(40),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(getSize(20)),
                          ),
                          child: Icon(
                            Icons.chat_bubble_outline,
                            size: getSize(20),
                            color: const Color(0xFF4A2B1A),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: getVerticalSize(24)),

          // Issues Section
          Container(
            width: double.infinity,
            padding: getPadding(all: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(getSize(16)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Issues with my RM?',
                  style: TextStyle(
                    fontSize: getFontSize(16),
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: getVerticalSize(8)),
                Text(
                  'We are sorry for the trouble. Please let us know the issue.',
                  style: TextStyle(
                    fontSize: getFontSize(12),
                    color: Colors.grey.shade900,
                  ),
                ),
                SizedBox(height: getVerticalSize(16)),
                // Issue options
                ...issueOptions.map((issue) => _buildIssueOption(issue)),
                SizedBox(height: getVerticalSize(20)),
                // Submit button
                CustomElevatedButton(
                  text: 'Submit Feedback',
                  height: getVerticalSize(44),
                  width: double.infinity,
                  buttonStyle: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, getVerticalSize(44)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(getSize(12)),
                    ),
                    backgroundColor: const Color(0xFF4A2B1A),
                    foregroundColor: Colors.white,
                  ),
                  buttonTextStyle: TextStyle(
                    color: Colors.white,
                    fontSize: getFontSize(14),
                    fontWeight: FontWeight.w600,
                  ),
                  onPressed: _submitIssue,
                ),
              ],
            ),
          ),

          SizedBox(height: getVerticalSize(24)),
        ], // End of customer-only sections
      ],
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
            // CircleAvatar(
            //   radius: getSize(15),
            //   backgroundColor: Colors.white,
            //   child: Text(
            //     'JD',
            //     style: TextStyle(
            //       color: Colors.brown,
            //       fontWeight: FontWeight.bold,
            //       fontSize: getFontSize(14),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? titleColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: getPadding(left: 20, right: 20, top: 16, bottom: 16),
        child: Row(
          children: [
            Icon(
              icon,
              size: getSize(28),
              color: titleColor ?? const Color(0xFF4A2B1A),
            ),
            SizedBox(width: getHorizontalSize(16)),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: getFontSize(16),
                  fontWeight: FontWeight.w500,
                  color: titleColor ?? Colors.black87,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: getSize(20),
              color: const Color(0xFF4A2B1A),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey.shade200,
      indent: getHorizontalSize(60),
      endIndent: getHorizontalSize(20),
    );
  }

  Widget _buildIssueOption(String issue) {
    final isSelected = selectedIssue == issue;
    return Padding(
      padding: EdgeInsets.only(bottom: getVerticalSize(12)),
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedIssue = isSelected ? null : issue;
          });
        },
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              size: getSize(20),
              color:
                  isSelected
                      ? const Color(0xFF4A2B1A)
                      : const Color(0xFF4A2B1A),
            ),
            SizedBox(width: getHorizontalSize(8)),
            Expanded(
              child: Text(
                issue,
                style: TextStyle(
                  fontSize: getFontSize(14),
                  color: isSelected ? Colors.black87 : Colors.grey.shade600,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitIssue() {
    if (selectedIssue != null) {
      // Show success message
      Get.snackbar(
        'Feedback Submitted',
        'Your feedback "$selectedIssue" has been submitted successfully. Our team will contact you soon.',
        backgroundColor: Colors.transparent,
        colorText: Colors.green.shade800,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
        margin: EdgeInsets.all(getSize(16)),
        borderRadius: getSize(8),
      );

      // Reset selection
      setState(() {
        selectedIssue = null;
      });
    }
  }
}
