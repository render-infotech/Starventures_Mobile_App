import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:starcapitalventures/app_export/app_export.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../app_routes.dart';
import '../../widgets/app_header.dart';
import '../emi_calculator/emi_calculator.dart';
import '../home_screen/widgets/loan_category_horizontal_list.dart';
import '../profile/controller/profile_controller.dart';
import '../home_screen_main/controller/home_screen_controller.dart';
import '../applications/controller/application_controller.dart';
import '../applications/model/application_model.dart';
import '../application_detail/application_details_screen.dart';

class HomeScreenCustomer extends StatefulWidget {
  const HomeScreenCustomer({super.key});

  @override
  State<HomeScreenCustomer> createState() => _HomeScreenCustomerState();
}

class _HomeScreenCustomerState extends State<HomeScreenCustomer> {
  late final ProfileController _profile;
  late final ApplicationListController _applicationController;

  final CarouselSliderController _carouselController = CarouselSliderController();
  final RxInt _currentCarouselIndex = 0.obs;

  @override
  void initState() {
    super.initState();
    _profile = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController());

    _applicationController = Get.isRegistered<ApplicationListController>()
        ? Get.find<ApplicationListController>()
        : Get.put(ApplicationListController());

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      print('🏠 HomeScreenCustomer: Fetching applications...');
      await _applicationController.fetchApplications();
    });
  }

  // ✅ Add refresh method
  Future<void> _refreshData() async {
    print('🔄 HomeScreenCustomer: Refresh triggered');
    await _applicationController.fetchApplications();
    print('✅ HomeScreenCustomer: Refresh completed');
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
        backgroundColor: const Color(0xFF4A2B1A),
        body: RefreshIndicator(  // ✅ Added RefreshIndicator
          onRefresh: _refreshData,
          color: appTheme.theme2,
          backgroundColor: Colors.white,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),  // ✅ Enable pull-to-refresh
            child: Column(
              children: [
                const AppHeader(height: 150, topPadding: 40, bottomPadding: 40),
                Container(
                  width: double.infinity,
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height - 150,  // ✅ Ensure minimum height
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF3F4F6),
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
                      bottom: 120,  // ✅ Increased bottom padding to prevent overflow
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const LoanCategoryHorizontalList(),
                        const SizedBox(height: 16),

                        // EMI button at top
                        EmiCalculatorButton(
                          onTap: () {
                            Get.toNamed(AppRoutes.emiCalculatorScreen);
                          },
                          background: Colors.white,
                          foreground: Colors.brown.shade900,
                        ),

                        SizedBox(height: getVerticalSize(20)),

                        // Application Status Carousel
                        _buildApplicationStatusCarousel(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildApplicationStatusCarousel() {
    return Obx(() {
      if (_applicationController.isLoading.value) {
        return Container(
          width: double.infinity,
          padding: getPadding(all: 40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(getSize(16)),
          ),
          child: Center(
            child: CircularProgressIndicator(
              color: appTheme.theme2,
            ),
          ),
        );
      }

      if (_applicationController.hasError.value ||
          _applicationController.applications.isEmpty) {
        return _buildEmptyApplicationState();
      }

      final recentApps = _applicationController.recentApplications;

      if (recentApps.length == 1) {
        return _buildApplicationStatusCard(recentApps[0]);
      }

      return Column(
        children: [
          CarouselSlider.builder(
            carouselController: _carouselController,
            itemCount: recentApps.length,
            itemBuilder: (context, index, realIndex) {
              return _buildApplicationStatusCard(recentApps[index]);
            },
            options: CarouselOptions(
              height: null,  // ✅ Changed to null to auto-adjust height
              aspectRatio: 0.75,  // ✅ Added aspect ratio for better sizing
              viewportFraction: 1.0,
              enlargeCenterPage: false,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 5),
              autoPlayAnimationDuration: const Duration(milliseconds: 800),
              autoPlayCurve: Curves.fastOutSlowIn,
              onPageChanged: (index, reason) {
                _currentCarouselIndex.value = index;
              },
            ),
          ),

          SizedBox(height: getVerticalSize(16)),
          Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: recentApps.asMap().entries.map((entry) {
              return GestureDetector(
                onTap: () {
                  _carouselController.animateToPage(
                    entry.key,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: Container(
                  width: _currentCarouselIndex.value == entry.key ? 24.0 : 8.0,
                  height: 8.0,
                  margin: EdgeInsets.symmetric(
                    horizontal: getHorizontalSize(4),
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: _currentCarouselIndex.value == entry.key
                        ? appTheme.theme2
                        : Colors.grey.shade400,
                  ),
                ),
              );
            }).toList(),
          )),
        ],
      );
    });
  }

  Widget _buildApplicationStatusCard(Application recentApp) {
    final currentStatus = recentApp.status;

    return GestureDetector(
      onTap: () {
        Get.to(() => ApplicationDetailScreen(
          userId: '',
          applicationId: recentApp.id,
        ));
      },
      child: Container(
        width: double.infinity,
        margin: getMargin(left: 4, right: 4),
        padding: getPadding(all: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFE6F4F1),
          borderRadius: BorderRadius.circular(getSize(16)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Application Status',
                        style: TextStyle(
                          fontSize: getFontSize(18),
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: getVerticalSize(4)),
                      Text(
                        recentApp.loanType,
                        style: TextStyle(
                          fontSize: getFontSize(13),
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                if (recentApp.bank != null)
                  Container(
                    padding: getPadding(left: 10, right: 10, top: 6, bottom: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(getSize(12)),
                      border: Border.all(
                        color: Colors.blue.shade200,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (recentApp.bank!.bankLogo != null)
                          Container(
                            width: 20,
                            height: 20,
                            margin: getMargin(right: 6),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: CachedNetworkImage(
                                imageUrl: recentApp.bank!.bankLogo!,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Icon(
                                  Icons.account_balance,
                                  size: 14,
                                  color: Colors.grey.shade400,
                                ),
                                errorWidget: (context, url, error) => Icon(
                                  Icons.account_balance,
                                  size: 14,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ),
                          ),
                        Text(
                          recentApp.bank!.name,
                          style: TextStyle(
                            fontSize: getFontSize(12),
                            color: Colors.blue.shade800,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            SizedBox(height: getVerticalSize(8)),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ID: ${recentApp.id}',
                  style: TextStyle(
                    fontSize: getFontSize(12),
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  recentApp.formattedAmount,
                  style: TextStyle(
                    fontSize: getFontSize(16),
                    fontWeight: FontWeight.bold,
                    color: appTheme.theme2,
                  ),
                ),
              ],
            ),

            SizedBox(height: getVerticalSize(20)),

            ..._buildProgressSteps(currentStatus),

            SizedBox(height: getVerticalSize(16)),

            Container(
              width: double.infinity,
              padding: getPadding(top: 10, bottom: 10),
              decoration: BoxDecoration(
                color: appTheme.theme2,
                borderRadius: BorderRadius.circular(getSize(8)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'View Full Details',
                    style: TextStyle(
                      fontSize: getFontSize(14),
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: getHorizontalSize(6)),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildProgressSteps(String currentStatus) {
    final statusOrder = [
      {'name': 'Login', 'subtitle': 'Application submitted'},
      {'name': 'Technical', 'subtitle': 'Technical verification'},
      {'name': 'FI-Legal', 'subtitle': 'Financial & legal check'},
      {'name': 'PD', 'subtitle': 'Personal discussion'},
      {'name': 'Sanction', 'subtitle': 'Sanction process'},
      {'name': 'Agreement', 'subtitle': 'Agreement signing'},
      {'name': 'MODT-Registration', 'subtitle': 'MODT & registration'},
      {'name': 'Disbursement', 'subtitle': 'Amount disbursement'},
    ];

    int currentIndex = statusOrder.indexWhere(
          (status) => status['name']!.toLowerCase() == currentStatus.toLowerCase(),
    );
    if (currentIndex == -1) currentIndex = 0;

    return statusOrder.asMap().entries.map((entry) {
      int index = entry.key;
      Map<String, String> status = entry.value;

      bool isComplete = index < currentIndex;
      bool isActive = index == currentIndex;
      bool isLast = index == statusOrder.length - 1;

      return _buildProgressStep(
        status['name']!,
        status['subtitle']!,
        isComplete,
        isActive,
        isLast,
      );
    }).toList();
  }

  Widget _buildProgressStep(
      String title,
      String subtitle,
      bool isComplete,
      bool isActive,
      bool isLast,
      ) {
    final circleColor = isComplete
        ? const Color(0xFF22A16B)
        : isActive
        ? const Color(0xFFFF9800)
        : Colors.grey.shade300;

    final backgroundColor = isComplete
        ? const Color(0xFFE8FFF4)
        : isActive
        ? const Color(0xFFFFF3E0)
        : Colors.grey.shade100;

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
                  color: backgroundColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: circleColor, width: 2),
                ),
                child: Center(
                  child: isComplete
                      ? Icon(
                    Icons.check,
                    size: getSize(14),
                    color: const Color(0xFF22A16B),
                  )
                      : isActive
                      ? Icon(
                    Icons.hourglass_top,
                    size: getSize(14),
                    color: const Color(0xFFFF9800),
                  )
                      : Container(
                    width: getSize(8),
                    height: getSize(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: getSize(2),
                    height: getVerticalSize(32),
                    color: isComplete
                        ? const Color(0xFF22A16B).withOpacity(0.3)
                        : Colors.grey.shade300,
                  ),
                ),
            ],
          ),
          SizedBox(width: getHorizontalSize(12)),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                top: getVerticalSize(2),
                bottom: isLast ? 0 : getVerticalSize(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: getFontSize(14),
                      fontWeight: FontWeight.w600,
                      color: (isActive || isComplete)
                          ? Colors.black87
                          : Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: getVerticalSize(2)),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: getFontSize(12),
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyApplicationState() {
    return Container(
      width: double.infinity,
      padding: getPadding(all: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(getSize(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.description_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: getVerticalSize(16)),
          Text(
            'No Applications Yet',
            style: TextStyle(
              fontSize: getFontSize(18),
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: getVerticalSize(8)),
          Text(
            'Apply for a loan to see your application status here',
            style: TextStyle(
              fontSize: getFontSize(14),
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: getVerticalSize(20)),
          ElevatedButton(
            onPressed: () {
              final homeController = Get.find<HomeOneContainer1Controller>();
              homeController.selectedIndex.value = 1;
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: appTheme.theme2,
              foregroundColor: Colors.white,
              padding: getPadding(left: 24, right: 24, top: 12, bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(getSize(10)),
              ),
            ),
            child: const Text('Apply for Loan'),
          ),
        ],
      ),
    );
  }
}
