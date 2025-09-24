import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starcapitalventures/app_export/app_export.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    Key? key,
    this.titleName,                  // e.g., "Vishwa" for greeting
    this.useGreeting = true,         // true = greeting/subtitle mode, false = page-title mode
    this.pageTitle,                  // when useGreeting=false, show this as the title
    this.showBack = false,
    this.onBack,
    this.backgroundColor = Colors.white,
    this.elevation = 0,
    this.arrowAsset = 'assets/svg/arrow.svg',
  }) : super(key: key);

  // Greeting mode options
  final String? titleName;
  final bool useGreeting;

  // Page title mode
  final String? pageTitle;

  // Navigation
  final bool showBack;
  final VoidCallback? onBack;

  // Style
  final Color backgroundColor;
  final double elevation;
  final String arrowAsset;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 12);

  @override
  Widget build(BuildContext context) {
    final String greetingTitle = 'Good Morning, ${titleName ?? ''}'.trim();
    const String greetingSubtitle = 'Here is your view';

    return AppBar(
      backgroundColor: backgroundColor,
      elevation: elevation,
      automaticallyImplyLeading: false,
      leadingWidth: showBack ? 56 : 0,
      leading: showBack
          ? IconButton(
        onPressed: onBack ?? () => Navigator.of(context).maybePop(),
        icon: SvgPicture.asset(
          arrowAsset,
          height: 32,
          width: 22,
          colorFilter:  ColorFilter.mode(appTheme.gray100, BlendMode.srcIn),
        ),
        tooltip: 'Back',
      )
          : null,
      titleSpacing: showBack ? 0 : 16,
      centerTitle: false,

      // Title switches between greeting mode and page-title mode
      title: useGreeting
          ? Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greetingTitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            greetingSubtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white,
            ),
          ),
        ],
      )
          : Text(
        pageTitle ?? '',
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: Colors.white,
          fontSize: 20,
        ),
      ),
    );
  }
}
