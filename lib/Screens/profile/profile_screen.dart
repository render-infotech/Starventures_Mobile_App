// lib/Screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:starcapitalventures/Screens/profile/widgets/log_out_dialog.dart';
import 'package:starcapitalventures/app_routes.dart';
import '../../widgets/app_header.dart';
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

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _remarksController = TextEditingController();
  final GlobalKey _rmSectionKey = GlobalKey();

  // ✅ FIXED: Use Map for issue options
  String? selectedIssue;
  final Map<String, String> issueOptions = {
    'RM not calling back': 'not_calling_back',
    'RM not responding': 'not_responding',
    'I want to change my RM': 'change_rm',
  };

  @override
  void initState() {
    super.initState();
    _controller = Get.find<ProfileController>();
    _logout = Get.put(LogoutController());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.loadProfile();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  void _scrollToRMSection() {
    if (_rmSectionKey.currentContext != null) {
      Scrollable.ensureVisible(
        _rmSectionKey.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        alignment: 0.0,
      );
    }
  }

  String _initials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '';
    final parts = trimmed.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    final first = parts.isNotEmpty && parts.first.isNotEmpty ? parts.first.characters.first : '';
    final last = parts.length > 1 && parts.last.isNotEmpty ? parts.last.characters.first : '';
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
        backgroundColor: appTheme.theme,
        body: RefreshIndicator(  // ✅ Added RefreshIndicator
          onRefresh: _refreshProfile,  // ✅ Refresh callback
          color: appTheme.theme2,  // ✅ Spinner color
          backgroundColor: Colors.white,
          child: Stack(
            children: [
              const AppHeader(height: 190, topPadding: 40, bottomPadding: 40),

              Padding(
                padding: EdgeInsets.only(top: getVerticalSize(160)),
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30.0),
                      topRight: Radius.circular(30.0),
                    ),
                  ),
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),  // ✅ Enable pull-to-refresh on empty screens
                    padding: getPadding(
                      left: 20,
                      top: 26,
                      right: 20,
                      bottom: 350,
                    ),
                    child: _buildProfileContent(),
                  ),
                ),
              ),

              if (isCustomer)
                Positioned(
                  top: getVerticalSize(145),
                  right: getHorizontalSize(16),
                  child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(getSize(20)),
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _scrollToRMSection,
                      borderRadius: BorderRadius.circular(getSize(20)),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: getHorizontalSize(14),
                          vertical: getVerticalSize(8),
                        ),
                        decoration: BoxDecoration(
                          color: appTheme.theme2,
                          borderRadius: BorderRadius.circular(getSize(20)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.help_outline, color: Colors.white, size: getSize(16)),
                            SizedBox(width: getHorizontalSize(4)),
                            Text(
                              'Need Help?',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: getFontSize(12),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

// ✅ Add this refresh method
  Future<void> _refreshProfile() async {
    print('[Profile] Pull-to-refresh triggered');

    // Load both profile and RM data in parallel
    await Future.wait([
      _controller.loadProfile(),
      _controller.loadRelationshipManager(),
    ]);

    print('[Profile] Pull-to-refresh completed');
  }

  Widget _buildProfileContent() {
    final name = _controller.userName.value;
    final email = _controller.userEmail.value;
    final role = _controller.role.value;
    final initials = name.isEmpty ? '' : _initials(name);
    final isCustomer = role == 'customer';
    final isAgent = role == 'agent';

    return Column(
      children: [
        // Profile Card
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
                clipBehavior: Clip.antiAlias,
                child: _buildAvatarImage(initials),
              ),
              SizedBox(height: getVerticalSize(16)),
              Text(
                name.isEmpty ? 'James Doe' : name,
                style: TextStyle(
                  fontSize: getFontSize(20),
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: getVerticalSize(4)),
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
                onTap: () async {
                  await Get.to(() => const EditProfileScreen());
                  _controller.loadProfile();
                },
              ),
              _buildDivider(),

              if (!isCustomer ) ...[
                _buildMenuItem(
                  icon: Icons.folder_outlined,
                  title: 'My Documents',
                  onTap: () => Get.toNamed(AppRoutes.documentsScreen),
                ),
                _buildDivider(),
              ],
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

        // ✅ Customer-specific sections - ONLY show if customer AND RM is assigned
        if (isCustomer) ...[
          SizedBox(height: getVerticalSize(24)),
          _buildRMSection(),

          // ✅ UPDATED: Show Issues Section ONLY if RM is assigned
          Obx(() {
            final rmName = _controller.rmName.value;
            final isRMAssigned = rmName != null && rmName.isNotEmpty;

            // Only show Issues section if RM is assigned
            if (isRMAssigned) {
              return Column(
                children: [
                  SizedBox(height: getVerticalSize(24)),
                  _buildIssuesSection(),
                ],
              );
            }

            // Return empty container if no RM
            return const SizedBox.shrink();
          }),
        ],
      ],
    );
  }

  // ✅ Relationship Manager Section
  Widget _buildRMSection() {
    return Obx(() {
      final rmName = _controller.rmName.value;
      final rmPhone = _controller.rmPhone.value;
      final isRMAvailable = rmName != null && rmName.isNotEmpty;
      final rmInitials = isRMAvailable ? _initials(rmName) : 'RM';

      return Container(
        key: _rmSectionKey,
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

            if (_controller.rmLoading.value)
              Center(child: CircularProgressIndicator(color: appTheme.theme2))
            else if (!isRMAvailable)
              Text(
                'No relationship manager assigned yet',
                style: TextStyle(
                  fontSize: getFontSize(14),
                  color: Colors.grey.shade600,
                ),
              )
            else
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
                        rmInitials,
                        style: TextStyle(
                          fontSize: getFontSize(16),
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A2B1A),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: getHorizontalSize(12)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rmName,
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
                  if (rmPhone != null && rmPhone.isNotEmpty)
                    Row(
                      children: [
                        InkWell(
                          onTap: () => _controller.callRM(),
                          borderRadius: BorderRadius.circular(getSize(20)),
                          child: Container(
                            width: getSize(40),
                            height: getSize(40),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(getSize(20)),
                            ),
                            child: Icon(Icons.phone, size: getSize(20), color: const Color(0xFF4A2B1A)),
                          ),
                        ),
                        SizedBox(width: getHorizontalSize(8)),
                        InkWell(
                          onTap: () => _controller.messageRM(),
                          borderRadius: BorderRadius.circular(getSize(20)),
                          child: Container(
                            width: getSize(40),
                            height: getSize(40),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(getSize(20)),
                            ),
                            child: Icon(Icons.chat_bubble_outline, size: getSize(20), color: const Color(0xFF4A2B1A)),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
          ],
        ),
      );
    });
  }

  // ✅ Issues Section with Remarks
  Widget _buildIssuesSection() {
    return Container(
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
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: getVerticalSize(16)),

          // Issue options
          ...issueOptions.keys.map((issue) => _buildIssueOption(issue)),

          SizedBox(height: getVerticalSize(16)),

          // Remarks Text Field
          Text(
            'Additional Comments (Optional)',
            style: TextStyle(
              fontSize: getFontSize(13),
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: getVerticalSize(8)),
          TextField(
            controller: _remarksController,
            maxLines: 3,
            maxLength: 200,
            style: TextStyle(
              fontSize: getFontSize(13),
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              hintText: 'Share more details about your concern...',
              hintStyle: TextStyle(
                fontSize: getFontSize(12),
                color: Colors.grey.shade500,
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(getSize(10)),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(getSize(10)),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(getSize(10)),
                borderSide: BorderSide(color: const Color(0xFF4A2B1A), width: 1.5),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: getHorizontalSize(12),
                vertical: getVerticalSize(10),
              ),
            ),
          ),

          SizedBox(height: getVerticalSize(16)),

          // Submit button with loading state
          Obx(() => CustomElevatedButton(
            text: _controller.isFeedbackSubmitting.value ? 'Submitting...' : 'Submit Feedback',
            height: getVerticalSize(44),
            width: double.infinity,
            buttonStyle: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, getVerticalSize(44)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(getSize(12)),
              ),
              backgroundColor: _controller.isFeedbackSubmitting.value
                  ? Colors.grey.shade400
                  : const Color(0xFF4A2B1A),
              foregroundColor: Colors.white,
            ),
            buttonTextStyle: TextStyle(
              color: Colors.white,
              fontSize: getFontSize(14),
              fontWeight: FontWeight.w600,
            ),
            onPressed: _controller.isFeedbackSubmitting.value ? null : _submitIssue,
          )),
        ],
      ),
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
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              size: getSize(20),
              color: const Color(0xFF4A2B1A),
            ),
            SizedBox(width: getHorizontalSize(10)),
            Expanded(
              child: Text(
                issue,
                style: TextStyle(
                  fontSize: getFontSize(13),
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

  Future<void> _submitIssue() async {
    if (selectedIssue == null) {
      Get.snackbar(
        'Selection Required',
        'Please select an issue type',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade900,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    final issueTypeKey = issueOptions[selectedIssue];
    if (issueTypeKey == null) return;

    final remarks = _remarksController.text.trim();

    final success = await _controller.submitCustomerFeedback(
      issueType: issueTypeKey,
      remarks: remarks.isNotEmpty ? remarks : null,
    );

    if (success) {
      setState(() {
        selectedIssue = null;
        _remarksController.clear();
      });
    }
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
            Icon(icon, size: getSize(28), color: titleColor ?? const Color(0xFF4A2B1A)),
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
            Icon(Icons.chevron_right, size: getSize(20), color: const Color(0xFF4A2B1A)),
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

  Widget _buildAvatarImage(String initials) {
    if (_controller.avatarUrl.value != null && _controller.avatarUrl.value!.isNotEmpty) {
      return Image.network(
        _controller.avatarUrl.value!,
        fit: BoxFit.contain,
        width: getSize(80),
        height: getSize(80),
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Text(
              initials.isEmpty ? 'JD' : initials,
              style: TextStyle(
                color: Colors.white,
                fontSize: getFontSize(24),
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              strokeWidth: getSize(2),
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          );
        },
      );
    }

    return Center(
      child: Text(
        initials.isEmpty ? 'JD' : initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: getFontSize(24),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
