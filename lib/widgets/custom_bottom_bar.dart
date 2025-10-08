import 'package:starcapitalventures/Screens/home_screen_main/controller/home_screen_controller.dart';
import 'package:starcapitalventures/app_export/app_export.dart';

class CustomBottomBar extends StatelessWidget {
  CustomBottomBar({Key? key, this.onChanged, required this.role})
    : super(key: key);

  final double outerRadius = 20.0;
  final double borderWidth = 1.5;
  final String role;

  final Function(int)? onChanged;

  final HomeOneContainer1Controller homeController = Get.put(
    HomeOneContainer1Controller(),
  );

  List<BottomMenuModel> get bottomMenuList {
    print('🔧 CustomBottomBar building menu for role: "$role"');
    if (role == 'customer') {
      print('✅ Building customer bottom navigation (4 items)');
      return [
        BottomMenuModel(
          icon: ImageConstant.home,
          activeIcon: ImageConstant.home,
          title: "Dashboard".tr,
          type: BottomBarEnum.Home,
        ),
        BottomMenuModel(
          icon: ImageConstant.application,
          activeIcon: ImageConstant.application,
          title: "Apply Loan".tr,
          type: BottomBarEnum.MixandMatch,
        ),
        BottomMenuModel(
          icon: ImageConstant.leads,
          activeIcon: ImageConstant.leads,
          title: "Applications".tr,
          type: BottomBarEnum.wishlist,
        ),
        BottomMenuModel(
          icon: ImageConstant.profile,
          activeIcon: ImageConstant.profile,
          title: "Profile".tr,
          type: BottomBarEnum.Profile,
        ),
      ];
    } else {
      print('✅ Building employee/lead bottom navigation (5 items)');
      return [
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
    }
  }

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
            border: Border.all(color: appTheme.theme, width: borderWidth),
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
              selectedLabelStyle: theme.textTheme.labelLarge!.copyWith(
                color: theme.colorScheme.primary,
              ),
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
                      ),
                      child: CustomImageView(
                        svgPath: bottomMenuList[index].activeIcon,
                        height: getSize(24),
                        width: getSize(24),
                        color: Colors.white,
                        margin: getMargin(left: 7, top: 8, right: 7, bottom: 8),
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

enum BottomBarEnum { Home, wishlist, MixandMatch, My_Cart, Profile }

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
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
