import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:starcapitalventures/Screens/home_screen_Lead/widgets/holiday_cards.dart';
import 'package:starcapitalventures/app_export/app_export.dart';
import '../../app_routes.dart';
import '../../widgets/app_header.dart';
import '../../widgets/custom_app_bar.dart';
import '../applications/controller/application_controller.dart';
import '../home_screen/controller/home_controller.dart';
import '../home_screen/widgets/loan_category_horizontal_list.dart';
import '../profile/controller/profile_controller.dart';
import 'model/holiday_model.dart';
class HomeScreenLead extends StatefulWidget {
  const HomeScreenLead({super.key});
  @override
  State<HomeScreenLead> createState() => _HomeScreenLeadState();
}

class _HomeScreenLeadState extends State<HomeScreenLead>  {
  final HomeController _controller = Get.put(HomeController());
  final ApplicationListController _appController = Get.put(ApplicationListController()); // ✅ Add this

  String formattedDateTime = '';
  late final ProfileController _profile;

  void initState() {
    super.initState();
    final now = DateTime.now();
    formattedDateTime = DateFormat('hh:mm a • dd MMM yyyy').format(now);
    _profile = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController());

    // ✅ Refresh applications when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _appController.refreshApplications();
    });
  }
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final fullName = _profile.userName.value;

      return Scaffold(
        backgroundColor: appTheme.theme, // match HomeScreen background behind header
        body: SingleChildScrollView(
          child: Stack(
            children: [
              const AppHeader(height: 160, topPadding: 40, bottomPadding: 40),
              Padding(
                padding: const EdgeInsets.only(top: 140), // align with HomeScreen header overlap
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white, // main card area
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30.0),
                      topRight: Radius.circular(30.0),
                    ),
                  ),
                  child: Padding(
                    padding: getPadding(left: 16, right: 16, top: 16, bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: GridView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: 3,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3, // ✅ Changed to 3 columns
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 12,
                              childAspectRatio: 1.0, // ✅ Adjusted for square tiles
                            ),
                            itemBuilder: (context, index) {
                              final tiles = <_Tile>[
                                _Tile(
                                  svg: ImageConstant.application,
                                  title: 'Total Applications',
                                  value: _controller.totalapplications.toString(),
                                ),

                                _Tile(
                                  svg: ImageConstant.application,
                                  title: 'Inprogress Applications',
                                  value: _controller.inprogress.toString(),
                                ),
                                _Tile(
                                  svg: ImageConstant.leads,
                                  title: 'Disbursed Applications',
                                  value: _controller.sanctionedApplications.toString(),
                                ),
                              ];
                              final t = tiles[index];

                              return InkWell(
                                borderRadius: AppRadii.lg,
                                onTap: () {
                                  // Handle tap actions
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: AppRadii.lg,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.06),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                    border: Border.all(color: const Color(0xFFE9EDF5), width: 1),
                                  ),
                                  padding: const EdgeInsets.all(8),
                                  child: _GridTileContent(tile: t),
                                ),
                              );
                            },
                          ),
                        ),
                        // Dashboard Grid
                        // Padding(
                        //   padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                        //   child: GridView.builder(
                        //     padding: EdgeInsets.zero,
                        //     shrinkWrap: true,
                        //     physics: const NeverScrollableScrollPhysics(),
                        //     itemCount: 4,
                        //     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        //       crossAxisCount: 2,
                        //       crossAxisSpacing: 12,
                        //       mainAxisSpacing: 12,
                        //       childAspectRatio: 1.2,
                        //     ),
                        //     itemBuilder: (context, index) {
                        //       final tiles = <GridTileItem>[
                        //         GridTileItem(svg: ImageConstant.application, title: 'Active Applications', value: '0'),
                        //       //  GridTileItem(svg: ImageConstant.application, title: 'Active Applications', value: '0'),
                        //         GridTileItem(svg: ImageConstant.leads,       title: 'New Leads',           value: '0'),
                        //         //GridTileItem(svg: ImageConstant.leads,       title: 'New Leads',           value: '0'),
                        //         GridTileItem(svg: ImageConstant.application, title: 'New Application'),
                        //         GridTileItem(svg: ImageConstant.profile,     title: 'Add Lead'),
                        //       ];
                        //       final t = tiles[index];
                        //
                        //       return InkWell(
                        //         borderRadius: AppRadii.lg,
                        //         onTap: () {
                        //           switch (index) {
                        //             case 0: // Active Applications - navigate to applications list
                        //               Get.toNamed(AppRoutes.application);
                        //               break;
                        //             case 1: // New Leads - navigate to leads screen
                        //               Get.toNamed(AppRoutes.leads);
                        //               break;
                        //             case 2: // New Application - navigate to applications list
                        //               Get.toNamed(AppRoutes.newapplication);
                        //               break;
                        //             // case 3: // Add Lead
                        //             //   Get.toNamed(AppRoutes.addLead);
                        //             //   break;
                        //             //   case 4: Get.toNamed(AppRoutes.newapplication); break;
                        //             //   case 5: Get.toNamed(AppRoutes.addLead); break;
                        //           }
                        //         },
                        //         // onTap: () {
                        //         //   switch (index) {
                        //         //     case 4: Get.toNamed(AppRoutes.newapplication); break;
                        //         //     case 5: Get.toNamed(AppRoutes.addLead); break;
                        //         //   }
                        //         // },
                        //         child: Container(
                        //           decoration: BoxDecoration(
                        //             color: Colors.white,
                        //             borderRadius: AppRadii.lg,
                        //             boxShadow: [
                        //               BoxShadow(
                        //                 color: Colors.black.withOpacity(0.06),
                        //                 blurRadius: 10,
                        //                 offset: const Offset(0, 4),
                        //               ),
                        //             ],
                        //             border: Border.all(color: const Color(0xFFE9EDF5), width: 1),
                        //           ),
                        //           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        //           child: GridTileContent(tile: t),
                        //         ),
                        //       );
                        //     },
                        //   ),
                        // ),

                        SizedBox(height: getVerticalSize(5)),
                        const LoanCategoryHorizontalList(),
                        SizedBox(height: getVerticalSize(30)),
                        // EMI button at top


                        Padding(
                          padding: const EdgeInsets.only(left: 8, bottom: 8),
                          child: Text(
                            'Recent Activity',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),

                        Obx(() {
                          final recent3Apps = _appController.recentApplications; // Get first 3

                          // Show loading state
                          if (_appController.isLoading.value) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          // Show error state
                          if (_appController.hasError.value) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Text(
                                  'Failed to load applications',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            );
                          }

                          // Show empty state
                          if (recent3Apps.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Text(
                                  'No recent applications',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                            );
                          }

                          // Show first 3 applications
                          return MediaQuery.removePadding(
                            context: context,
                            removeTop: true,
                            child: ListView.separated(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: recent3Apps.length, // ✅ Only first 3
                              separatorBuilder: (_, __) => SizedBox(height: getVerticalSize(5)),
                              itemBuilder: (context, i) {
                                final app = recent3Apps[i]; // ✅ Get application from API

                                // ✅ Calculate time ago
                                final now = DateTime.now();
                                final difference = now.difference(app.createdAt);
                                String timeAgo;
                                if (difference.inDays > 0) {
                                  timeAgo = '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
                                } else if (difference.inHours > 0) {
                                  timeAgo = '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
                                } else if (difference.inMinutes > 0) {
                                  timeAgo = '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
                                } else {
                                  timeAgo = 'Just now';
                                }

                                // ✅ Get status colors
                                final (statusBg, statusFg) = _getStatusColors(app.status);

                                return InkWell(
                                  onTap: () {
                                    // Navigate to application detail
                                    Get.toNamed(
                                      AppRoutes.applicationDetails,
                                      arguments: {
                                        'userId': app.createdBy?.id.toString() ?? '',
                                        'applicationId': app.id,
                                      },
                                    );
                                  },
                                  child: LeadActivityCard(
                                    title: app.customerName, // ✅ Customer name
                                    subtitle: '${app.loanType} • ${app.formattedAmount}', // ✅ Loan type and amount
                                    timeAgo: timeAgo, // ✅ Calculated time ago
                                    statusLabel: app.status.toUpperCase(), // ✅ Raw status from API
                                    statusBg: statusBg,
                                    statusFg: statusFg,
                                  ),
                                );
                              },
                            ),
                          );
                        }),


                        SizedBox(height: getVerticalSize(190)),
                      ],
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
}

class GridTileItem {
  GridTileItem({required this.svg, required this.title, this.value});
  final String svg;
  final String title;
  final String? value;
}
class GridTileContent extends StatelessWidget {
  const GridTileContent({super.key, required this.tile});
  final GridTileItem tile;

  @override
  Widget build(BuildContext context) {
    final hasValue = tile.value != null;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (hasValue) ...[
          Text(
            tile.value!,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: const Color(0xFF3A57E8),
                fontWeight: FontWeight.w800,
                fontSize: 20
            ),
          ),
          const SizedBox(height: 4),
          Text(
            tile.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
        ] else ...[
          const SizedBox(height: 4),
          // Show different icons based on tile title
          Image.asset(
            tile.title == 'Add Lead'
                ? 'assets/images/agent_icon.png'
                : 'assets/images/application_icon.png',
            width: 28,
            height: 28,

          ),
          const SizedBox(height: 12),
          Text(
            tile.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF1A2036),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}


class _StatTile extends StatelessWidget {
  const _StatTile({required this.title, required this.value});
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.lg,
        border: Border.all(color: const Color(0xFFE9EDF5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: getHorizontalSize(10),
            offset: Offset(0, getVerticalSize(4)),
          ),
        ],
      ),
      padding: getPadding(left: 12, right: 12, top: 14, bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: const Color(0xFF3A57E8),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.icon, required this.label, this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: AppRadii.lg,
      onTap: onTap,
      child: Container(
        height: getVerticalSize(84),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadii.lg,
          border: Border.all(color: const Color(0xFFE9EDF5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: getHorizontalSize(10),
              offset: Offset(0, getVerticalSize(4)),
            ),
          ],
        ),
        padding: getPadding(all: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF4C5B7E)),
            SizedBox(height: getVerticalSize(8)),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF1A2036),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EarningsCard extends StatelessWidget {
  const _EarningsCard({
    required this.leftLabel,
    required this.leftValue,
    required this.rightLabel,
    required this.rightValue,
  });

  final String leftLabel;
  final String leftValue;
  final String rightLabel;
  final String rightValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.lg,
        border: Border.all(color: const Color(0xFFE9EDF5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: getHorizontalSize(10),
            offset: Offset(0, getVerticalSize(4)),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: getPadding(all: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('This Month\'s Earnings',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A2036),
                    )),
                SizedBox(height: getVerticalSize(4)),
                Text(
                  'Commission breakdown',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: const Color(0xFFE9EDF5)),
          // Values
          Padding(
            padding: getPadding(all: 12),
            child: Row(
              children: [
                Expanded(
                  child: _ValueBlock(label: leftLabel, value: leftValue),
                ),
                Container(width: 1, height: getVerticalSize(36), color: const Color(0xFFE9EDF5)),
                Expanded(
                  child: _ValueBlock(label: rightLabel, value: rightValue),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ValueBlock extends StatelessWidget {
  const _ValueBlock({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: getPadding(left: 10, right: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: const Color(0xFF3A57E8),
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: getVerticalSize(4)),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
class _Tile {
  _Tile({required this.svg, required this.title, this.value});
  final String svg;
  final String title;
  final String? value;
}
class _GridTileContent extends StatelessWidget {
  const _GridTileContent({super.key, required this.tile});
  final _Tile tile;

  @override
  Widget build(BuildContext context) {
    final hasValue = tile.value != null;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (hasValue) ...[
          Text(
            tile.value!,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: appTheme.theme,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            tile.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
        ] else ...[
          const SizedBox(height: 4),
          Icon(Icons.insert_drive_file_outlined, size: 28, color: Colors.black54),
          const SizedBox(height: 12),
          Text(
            tile.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}
// ✅ Helper method to get status colors based on raw status
(Color, Color) _getStatusColors(String status) {
  final lowerStatus = status.toLowerCase().trim();

  if (lowerStatus.contains('approv') || lowerStatus.contains('sanction')) {
    return (const Color(0xFFE8FFF4), const Color(0xFF22A16B)); // Green - Success
  } else if (lowerStatus.contains('reject') || lowerStatus.contains('lost')) {
    return (const Color(0xFFFFE6E6), const Color(0xFFD22E2E)); // Red - Rejected
  } else if (lowerStatus.contains('pend') || lowerStatus.contains('pd')) {
    return (const Color(0xFFFFF3D7), const Color(0xFFB78900)); // Yellow - Pending
  } else if (lowerStatus.contains('agreement') || lowerStatus.contains('disburs')) {
    return (const Color(0xFFE8FFF4), const Color(0xFF22A16B)); // Green - Agreement/Disbursement
  } else if (lowerStatus.contains('fi-legal') || lowerStatus.contains('technical')) {
    return (const Color(0xFFE7F0FF), const Color(0xFF4F8BFF)); // Blue - Processing
  } else {
    return (const Color(0xFFE7F0FF), const Color(0xFF4F8BFF)); // Blue - Default
  }
}
