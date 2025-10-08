import 'package:starcapitalventures/Screens/home_screen/widgets/clock_out_dialog.dart';
import 'package:starcapitalventures/app_export/app_export.dart';
import '../../app_routes.dart';
import '../../core/data/api_client/api_client.dart';
import '../../widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:starcapitalventures/app_export/app_export.dart';
import '../profile/controller/profile_controller.dart';
import '../profile/controller/profile_repository.dart';
import 'controller/home_controller.dart';
import 'model/holiday_model.dart';
import '../profile/controller/profile_controller.dart';
// lib/Screens/home_screen/home_screen.dart

import 'package:starcapitalventures/Screens/home_screen/widgets/clock_out_dialog.dart';
import 'package:starcapitalventures/app_export/app_export.dart';
import '../../app_routes.dart';
import '../../core/data/api_client/api_client.dart';
import '../../widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../profile/controller/profile_controller.dart';
import 'controller/home_controller.dart';
import 'model/dashboard_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeController _controller = Get.put(HomeController());
  late final ProfileController _profile;

  @override
  void initState() {
    super.initState();

    // Either find the globally provided controller or create one
    _profile =
        Get.isRegistered<ProfileController>()
            ? Get.find<ProfileController>()
            : Get.put(ProfileController());
  }

  String _firstName(String fullName) {
    final name = fullName.trim();
    if (name.isEmpty) return 'Guest';
    final parts =
        name.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    return parts.isNotEmpty ? parts.first : name;
  }

  void _handleSwitchChange(bool value) async {
    final attendance = _controller.attendanceData.value;

    if (attendance != null && attendance.isClockedIn && !value) {
      // User wants to clock out
      final bool? shouldClockOut = await ClockOutDialog.show(context);
      if (shouldClockOut == true) {
        await _controller.performClockOut(context);
      }
    } else if ((attendance == null || attendance.isReadyToClockIn) && value) {
      // User wants to clock in
      await _controller.performClockIn(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final fullName = _profile.userName.value;
      final firstName = _firstName(fullName);

      return Scaffold(
        backgroundColor: appTheme.whiteA700,
        appBar: CustomAppBar(
          backgroundColor: appTheme.mintygreen,
          useGreeting: true,
          titleName: firstName,
          showBack: false,
        ),
        body:
            _controller.dashboardLoading.value
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                  onRefresh: _controller.refreshDashboard,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.zero,
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        // Clock In/Out Section
                        Padding(
                          padding: getPadding(top: 20, right: 6, left: 6),
                          child: Container(
                            height: getVerticalSize(140),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: appTheme.orange100,
                              borderRadius: AppRadii.xl,
                            ),
                            padding: getPadding(all: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            _controller.clockButtonText,
                                            style: Theme.of(
                                              context,
                                            ).textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          SizedBox(height: getVerticalSize(2)),
                                          Text(
                                            _controller.displayTime,
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodySmall?.copyWith(
                                              fontSize: getFontSize(12),
                                              color: Colors.black54,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Obx(
                                      () => Switch(
                                        value: _controller.switchValue,
                                        onChanged:
                                            _controller.loading.value
                                                ? null
                                                : _handleSwitchChange,
                                        activeColor: appTheme.greenA700,
                                        activeTrackColor: appTheme.mintygreen,
                                        inactiveThumbColor: appTheme.red600,
                                        inactiveTrackColor:
                                            appTheme.shadowColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                CustomElevatedButton(
                                  text: 'View Attendance',
                                  height: 40,
                                  width: double.infinity,
                                  buttonStyle: ElevatedButton.styleFrom(
                                    minimumSize: const Size.fromHeight(40),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: AppRadii.lg,
                                    ),
                                    backgroundColor: appTheme.theme2,
                                    foregroundColor: Colors.white,
                                  ),
                                  buttonTextStyle: Theme.of(
                                    context,
                                  ).textTheme.labelLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  onPressed: () {
                                    // Navigate to attendance screen
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Dashboard Grid
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: GridView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: 4,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 1.4,
                                ),
                            itemBuilder: (context, index) {
                              final tiles = <_Tile>[
                                _Tile(
                                  svg: ImageConstant.application,
                                  title: 'Active Applications',
                                  value:
                                      _controller.assignedApplications
                                          .toString(),
                                ),
                                _Tile(
                                  svg: ImageConstant.leads,
                                  title: 'New Leads',
                                  value: _controller.assignedLeads.toString(),
                                ),
                                _Tile(
                                  svg: ImageConstant.application,
                                  title: 'New Application',
                                ),
                                _Tile(
                                  svg: ImageConstant.profile,
                                  title: 'Add Lead',
                                ),
                              ];
                              final t = tiles[index];

                              return InkWell(
                                borderRadius: AppRadii.lg,
                                onTap: () {
                                  switch (index) {
                                    case 2:
                                      Get.toNamed(AppRoutes.newapplication);
                                      break;
                                    case 3:
                                      Get.toNamed(AppRoutes.addLead);
                                      break;
                                  }
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
                                    border: Border.all(
                                      color: const Color(0xFFE9EDF5),
                                      width: 1,
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  child: _GridTileContent(tile: t),
                                ),
                              );
                            },
                          ),
                        ),

                        // Holidays Section
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Upcoming Holidays',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),

                        // Holiday List
                        Obx(
                          () =>
                              _controller.holidays.isEmpty
                                  ? Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[50],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'No upcoming holidays',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(color: Colors.grey[600]),
                                      ),
                                    ),
                                  )
                                  : Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: ListView.separated(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: _controller.holidays.length,
                                      separatorBuilder:
                                          (_, __) => const SizedBox(height: 10),
                                      itemBuilder: (context, index) {
                                        final holiday =
                                            _controller.holidays[index];
                                        return HolidayCard(
                                          dateLabel: holiday.formattedDate,
                                          title: holiday.occasion,
                                          stripeColor: _getHolidayColor(index),
                                        );
                                      },
                                    ),
                                  ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
      );
    });
  }

  Color _getHolidayColor(int index) {
    const colors = [
      Color(0xFF19A97B),
      Color(0xFFFFA000),
      Color(0xFF3A57E8),
      Color(0xFFE53E3E),
    ];
    return colors[index % colors.length];
  }
}

// Rest of your existing classes remain the same...
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
              color: const Color(0xFF3A57E8),
              fontWeight: FontWeight.w700,
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
          Icon(
            Icons.insert_drive_file_outlined,
            size: 28,
            color: Colors.black54,
          ),
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

// Holiday Card Widget
class HolidayCard extends StatelessWidget {
  final String dateLabel;
  final String title;
  final Color stripeColor;

  const HolidayCard({
    super.key,
    required this.dateLabel,
    required this.title,
    required this.stripeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFE9EDF5), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 60,
            decoration: BoxDecoration(
              color: stripeColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateLabel,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.black54),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
