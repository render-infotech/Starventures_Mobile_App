// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'custom_image_view.dart';
import '../Screens/home_screen_main/controller/home_screen_controller.dart';



import 'package:starcapitalventures/app_export/app_export.dart';
/*
class CustomBottomBar extends StatelessWidget {
  CustomBottomBar({
    Key? key,
    this.onChanged,
    required this.role, // 'employee' or 'agent'
  }) : super(key: key);

  final String role;
  final double outerRadius = 20.0;
  final double borderWidth = 1.5;

  final Function(int)? onChanged;

  // Controller
  final HomeOneContainer1Controller homeController = Get.put(HomeOneContainer1Controller());

  // Original styled menu model list (complete)
  final List<BottomMenuModel> bottomMenuList = [
    BottomMenuModel(
      icon: ImageConstant.home,
      activeIcon: ImageConstant.home,
      title: "Home".tr,
      type: BottomBarEnum.Home,
    ),
    BottomMenuModel(
      icon: ImageConstant.leads,
      activeIcon: ImageConstant.leads,
      title: "Leads".tr,
      type: BottomBarEnum.wishlist,
    ),
    BottomMenuModel(
      icon: ImageConstant.application,
      activeIcon: ImageConstant.application,
      title: "Application".tr,
      type: BottomBarEnum.MixandMatch,
    ),
    BottomMenuModel(
      icon: ImageConstant.documents,
      activeIcon: ImageConstant.documents,
      title: "Documents".tr,
      type: BottomBarEnum.My_Cart,
    ),
    BottomMenuModel(
      icon: ImageConstant.profile,
      activeIcon: ImageConstant.profile,
      title: "Profile".tr,
      type: BottomBarEnum.Profile,
    ),
  ]; // standard BottomNavigationBar items support dynamic lengths [web:12]

  // Role-based filtered list (hide Documents for non-employee)
  List<BottomMenuModel> _itemsForRole() {
    if (role == 'employee') return bottomMenuList;
    return bottomMenuList.where((e) => e.type != BottomBarEnum.My_Cart).toList();
  } // conditional list building per role [web:9]

  @override
  Widget build(BuildContext context) {
    final items = _itemsForRole();

    return Obx(
          () => ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(outerRadius),
          topRight: Radius.circular(outerRadius),
        ),
        clipBehavior: Clip.antiAlias,
        child: Container(
          height: getVerticalSize(95),
          padding: const EdgeInsets.only(bottom: 1),
          decoration: BoxDecoration(
            color: appTheme.whiteA700,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(outerRadius),
              topRight: Radius.circular(outerRadius),
            ),
            border: Border.all(
              color: appTheme.mintygreen,
              width: borderWidth,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(outerRadius - borderWidth),
              topRight: Radius.circular(outerRadius - borderWidth),
            ),
            clipBehavior: Clip.antiAlias,
            child: BottomNavigationBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              selectedLabelStyle: theme.textTheme.labelLarge!
                  .copyWith(color: theme.colorScheme.primary),
              currentIndex: homeController.selectedIndex.value.clamp(0, items.length - 1),
              type: BottomNavigationBarType.fixed,
              items: List.generate(items.length, (index) {
                final m = items[index];
                return BottomNavigationBarItem(
                  icon: Container(
                    padding: getPadding(top: 12),
                    child: CustomImageView(
                      svgPath: m.icon,
                      height: getSize(24),
                      width: getSize(24),
                      color: appTheme.gray500,
                    ),
                  ),
                  activeIcon: Container(
                    padding: getPadding(top: 12),
                    child: Container(
                      margin: getMargin(bottom: 5),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                        color: appTheme.mintygreen,
                      ),
                      child: CustomImageView(
                        svgPath: m.activeIcon,
                        height: getSize(24),
                        width: getSize(24),
                        color: Colors.white,
                        margin: getMargin(left: 7, top: 8, right: 7, bottom: 8),
                      ),
                    ),
                  ),
                  label: m.title ?? "",
                );
              }),
              onTap: (index) => onChanged?.call(index),
            ),
          ),
        ),
      ),
    );
  }
}
*/
///   UN COMMENT AND USE THIS WHILE IN API INTEGRATION  IT IS  MANUAL PROFILE TYPE HANDLING UNWANTED

class CustomBottomBar extends StatelessWidget {
  CustomBottomBar({
    Key? key,
    this.onChanged,
  }) : super(key: key);

  final double outerRadius = 20.0;
  final double borderWidth = 1.5;

  final Function(int)? onChanged;

  // Controller
  final HomeOneContainer1Controller homeController =
  Get.put(HomeOneContainer1Controller());

  final List<BottomMenuModel> bottomMenuList = [
    BottomMenuModel(
      icon: ImageConstant.home,
      activeIcon: ImageConstant.home,
      title: "Home".tr,
      type: BottomBarEnum.Home,
    ),
    BottomMenuModel(
      icon: ImageConstant.leads,
      activeIcon: ImageConstant.leads,
      title: "Leads".tr,
      type: BottomBarEnum.wishlist,
    ),
    BottomMenuModel(
      icon: ImageConstant.application,
      activeIcon: ImageConstant.application,
      title: "Application".tr,
      type: BottomBarEnum.MixandMatch,
    ),
    BottomMenuModel(
      icon: ImageConstant.documents,
      activeIcon: ImageConstant.documents,
      title: "Documents".tr,
      type: BottomBarEnum.My_Cart,
    ),
    BottomMenuModel(
      icon: ImageConstant.profile,
      activeIcon: ImageConstant.profile,
      title: "Profile".tr,
      type: BottomBarEnum.Profile,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(
          () => ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(outerRadius),
          topRight: Radius.circular(outerRadius),
        ),
        clipBehavior: Clip.antiAlias, // smooth clipping
        child: Container(
          height: getVerticalSize(95),
          padding: const EdgeInsets.only(bottom: 1),
          decoration: BoxDecoration(
            color: appTheme.whiteA700,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(outerRadius),
              topRight: Radius.circular(outerRadius),
            ),
            border: Border.all(
              color: appTheme.theme,
              width: borderWidth,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: ClipRRect(
            // slightly smaller to avoid hairline seam against the stroke
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(outerRadius - borderWidth),
              topRight: Radius.circular(outerRadius - borderWidth),
            ),
            clipBehavior: Clip.antiAlias,
            child: BottomNavigationBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              selectedLabelStyle: theme.textTheme.labelLarge!
                  .copyWith(color: theme.colorScheme.primary),
              currentIndex: homeController.selectedIndex.value,
              type: BottomNavigationBarType.fixed,
              items: List.generate(bottomMenuList.length, (index) {
                return BottomNavigationBarItem(
                  icon: Container(
                    padding: getPadding(top: 12),
                    child: CustomImageView(
                      svgPath: bottomMenuList[index].icon,
                      height: getSize(24),
                      width: getSize(24),
                      color: appTheme.gray500,
                    ),
                  ),
                  activeIcon: Container(
                    padding: getPadding(top: 12),
                    child: Container(
                      margin: getMargin(bottom: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: appTheme.theme,
                        // borderRadius can be added if inner highlight needs rounding
                      ),
                      child: CustomImageView(
                        svgPath: bottomMenuList[index].activeIcon,
                        height: getSize(24),
                        width: getSize(24),
                        color: Colors.white,
                        margin:
                        getMargin(left: 7, top: 8, right: 7, bottom: 8),
                      ),
                    ),
                  ),
                  label: bottomMenuList[index].title ?? "",
                );
              }),
              onTap: (index) => onChanged?.call(index),
            ),
          ),
        ),
      ),
    );
  }
}

enum BottomBarEnum {
  Home,
  wishlist,
  MixandMatch,
  My_Cart,
  Profile,
}

class BottomMenuModel {
  BottomMenuModel({
    required this.icon,
    required this.activeIcon,
    this.title,
    required this.type,
  });

  String icon;
  String activeIcon;
  String? title;
  BottomBarEnum type;
}


class DefaultWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(10),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Please replace the respective Widget here',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


/* Container(
        height: getVerticalSize(90),
        child: BottomNavigationBar(
          backgroundColor: appTheme.whiteA700,
          showSelectedLabels: true,
          showUnselectedLabels: false,
          elevation: 7,
          selectedLabelStyle: theme.textTheme.labelLarge!.copyWith(
            color: theme.colorScheme.primary,
          ),
          currentIndex: homeController.selectedIndex.value,
          type: BottomNavigationBarType.fixed,
          items: List.generate(bottomMenuList.length, (index) {
            return BottomNavigationBarItem(
              icon: Container(
                padding: getPadding(
                  // left: 29,
                  // top: 20,
                  // right: 29,
                  // bottom: 20,
                ),
                decoration: AppDecoration.white,
                child: CustomImageView(
                  svgPath: bottomMenuList[index].icon,
                  height: getSize(
                    24,
                  ),
                  width: getSize(
                    24,
                  ),
                  color: appTheme.gray500,
                  // margin: getMargin(
                  //   top: 20,
                  //   bottom: 20,
                  // ),
                ),
              ),
              activeIcon: Container(
                padding: getPadding(
                  // left: 21,
                  // top: 12,
                  // right: 21,
                  // bottom: 12,
                ),
                child: Container(
                  margin: getMargin(
                    bottom: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Color(0xFFFF7229), // Custom background color
                    borderRadius: BorderRadiusStyle.circleBorder20,
                  ),
                  child: CustomImageView(
                    svgPath: bottomMenuList[index].activeIcon,
                    height: getSize(
                      24,
                    ),
                    width: getSize(
                      24,
                    ),
                    color: Colors.white, // Set icon color to white
                    margin: getMargin(
                      left: 7,
                      top: 8,
                      right: 7,
                      bottom: 8,
                    ),
                  ),
                ),
              ),
              label: bottomMenuList[index].title ?? "",
            );
          }),
          onTap: (index) {
            // homeController.selectedIndex.value = index;
            onChanged?.call(index);
          },
        ),


      ),*/