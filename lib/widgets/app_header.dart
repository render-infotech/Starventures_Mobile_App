import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Screens/profile/controller/profile_controller.dart';
import '../app_routes.dart';
import 'package:starcapitalventures/app_export/app_export.dart';

class AppHeader extends StatelessWidget {
  final double height;
  final double topPadding;
  final double bottomPadding;
  final bool showProfileAvatar;

  const AppHeader({
    super.key,
    this.height = 160,
    this.topPadding = 40,
    this.bottomPadding = 40,
    this.showProfileAvatar = true,
  });

  String _initials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'JD';
    final parts = trimmed.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    final first = parts.isNotEmpty && parts.first.isNotEmpty
        ? parts.first.characters.first
        : '';
    final last = parts.length > 1 && parts.last.isNotEmpty
        ? parts.last.characters.first
        : '';
    final init = (first + last).isEmpty ? first : (first + last);
    return init.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final ProfileController? profileController = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : null;

    return Container(
      height: getVerticalSize(height),
      decoration: BoxDecoration(
        color: appTheme.theme,
      ),
      child: Padding(
        padding: EdgeInsets.only(
          top: getVerticalSize(topPadding),
          left: getHorizontalSize(16),
          right: getHorizontalSize(20),
          bottom: getVerticalSize(bottomPadding),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ✅ Logo with fire icon and name below
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo image
                Image.asset(
                  'assets/images/starlogo.png',
                  height: getVerticalSize(70),
                  width: getHorizontalSize(120),
                ),
                SizedBox(height: getVerticalSize(6)),
                // Fire emoji + Dynamic profile name
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '👋 ',  // Waving hand emoji
                      style: TextStyle(fontSize: getFontSize(16)),
                    ),
                    Text(


                      'Hi ' ,
                      style: TextStyle(fontSize: getFontSize(16), color: appTheme.whiteA700),
                    ),
                    SizedBox(width: getHorizontalSize(4)),
                    if (profileController != null)
                      Obx(() => Text(
                        profileController.userName.value.isNotEmpty
                            ? profileController.userName.value.toUpperCase()
                            : 'USER NAME',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: getFontSize(16),
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ))
                    else
                      Text(
                        'USER NAME',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: getFontSize(14),
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const Spacer(),
            // Stack(
            //   children: [
            //     Icon(
            //       Icons.notifications_outlined,
            //       color: Colors.white,
            //       size: getSize(28),
            //     ),
            //     Positioned(
            //       right: getHorizontalSize(2),
            //       top: getVerticalSize(2),
            //       child: Container(
            //         width: getSize(8),
            //         height: getSize(8),
            //         decoration: const BoxDecoration(
            //           color: Colors.red,
            //           shape: BoxShape.circle,
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
            SizedBox(width: getHorizontalSize(10)),
            if (showProfileAvatar)
              GestureDetector(
                onTap: () {
                  Get.toNamed(AppRoutes.profileScreen);
                },
                child: profileController != null
                    ? Obx(() => _buildAvatarWidget(profileController))
                    : _buildDefaultAvatar(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarWidget(ProfileController controller) {
    final name = controller.userName.value;
    final initials = _initials(name);
    final avatarUrl = controller.avatarUrl.value;

    return Container(
      width: getSize(32),
      height: getSize(32),
      decoration: BoxDecoration(
        color: appTheme.whiteA700,
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: _buildAvatarImage(avatarUrl, initials),
    );
  }

  Widget _buildAvatarImage(String? avatarUrl, String initials) {
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return Image.network(
        avatarUrl,
        fit: BoxFit.cover,
        width: getSize(32),
        height: getSize(32),
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Text(
              initials.isEmpty ? 'JD' : initials,
              style: TextStyle(
                color: appTheme.theme,
                fontSize: getFontSize(12),
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: SizedBox(
              width: getSize(15),
              height: getSize(15),
              child: CircularProgressIndicator(
                strokeWidth: getSize(2),
                valueColor: AlwaysStoppedAnimation<Color>(appTheme.theme),
              ),
            ),
          );
        },
      );
    }

    return Center(
      child: Text(
        initials.isEmpty ? 'JD' : initials,
        style: TextStyle(
          color: appTheme.theme,
          fontSize: getFontSize(12),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return CircleAvatar(
      radius: getSize(16),
      backgroundColor: appTheme.whiteA700,
      child: Text(
        'JD',
        style: TextStyle(
          color: appTheme.theme,
          fontWeight: FontWeight.bold,
          fontSize: getFontSize(12),
        ),
      ),
    );
  }
}
