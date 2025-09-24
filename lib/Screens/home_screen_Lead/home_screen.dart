import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:starcapitalventures/Screens/home_screen_Lead/widgets/holiday_cards.dart';
import 'package:starcapitalventures/app_export/app_export.dart';
import '../../app_routes.dart';
import '../../widgets/custom_app_bar.dart';
import '../profile/controller/profile_controller.dart';
import 'model/holiday_model.dart';

class HomeScreenLead extends StatefulWidget {
  const HomeScreenLead({super.key});
  @override
  State<HomeScreenLead> createState() => _HomeScreenLeadState();
}

class _HomeScreenLeadState extends State<HomeScreenLead>  {
  String formattedDateTime = '';
  late final ProfileController _profile; // reuse the shared controller

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    formattedDateTime = DateFormat('hh:mm a • dd MMM yyyy').format(now);
    _profile = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController());
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final fullName = _profile.userName.value;

      return Scaffold(
        backgroundColor: appTheme.whiteA700,
        appBar: CustomAppBar(
          backgroundColor: appTheme.mintygreen,
          useGreeting: true,
          titleName: fullName, // dynamic name here
          showBack: false,
        ),
        body: SingleChildScrollView(
          padding: getPadding(left: 16, right: 16, top: 12, bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats 2×2
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                child: GridView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 6, // 2 columns × 3 rows
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.2,
                  ),
                  itemBuilder: (context, index) {
                    final tiles = <GridTileItem>[
                      GridTileItem(svg: ImageConstant.application, title: 'Active Applications', value: '12'),
                      GridTileItem(svg: ImageConstant.application, title: 'Active Applications', value: '12'),
                      GridTileItem(svg: ImageConstant.leads,       title: 'New Leads',           value: '8'),
                      GridTileItem(svg: ImageConstant.leads,       title: 'New Leads',           value: '8'),
                      GridTileItem(svg: ImageConstant.application, title: 'New Application'),
                      GridTileItem(svg: ImageConstant.profile,     title: 'Add Lead'),
                      //GridTileItem(svg: ImageConstant.documents,   title: 'Documents'),
                      //GridTileItem(svg: ImageConstant.profile,     title: 'My Profile'),
                    ];
                    final t = tiles[index];

                    return InkWell(
                      borderRadius: AppRadii.lg,
                      onTap: () {
                        switch (index) {
                          case 4: Get.toNamed(AppRoutes.newapplication); break;
                          case 5: Get.toNamed(AppRoutes.addLead); break;
                         // case 4: Get.toNamed(AppRoutes.documentsScreen); break;
                         // case 5: Get.toNamed(AppRoutes.profileScreen); break;
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
                          border: Border.all(color: const Color(0xFFE9EDF5), width: 1),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        child: GridTileContent(tile: t),
                      ),
                    );
                  },
                ),
              ),


              // SizedBox(height: getVerticalSize(16)),
              //
              // // Earnings card
              // _EarningsCard(
              //   leftLabel: 'Commission Earned',
              //   leftValue: '₹45,000',
              //   rightLabel: 'Total Earnings',
              //   rightValue: '₹60,000',
              // ),

              SizedBox(height: getVerticalSize(16)),

              Text(
                'Recent Activity',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A2036),
                ),
              ),
              SizedBox(height: getVerticalSize(10)),

              // Recent Activity list
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: leadUpdates.length,
                separatorBuilder: (_, __) => SizedBox(height: getVerticalSize(10)),
                itemBuilder: (context, i) {
                  final it = leadUpdates[i];
                  return LeadActivityCard(
                    title: it.title,
                    subtitle: it.subtitle,
                    timeAgo: it.timeAgo,
                    statusLabel: it.statusLabel,
                    statusBg: it.statusBg,
                    statusFg: it.statusFg,
                  );

                },
              ),
            ],
          ),
        ),
        );
    }
    );
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
          Icon(Icons.insert_drive_file_outlined, size: 28, color: Colors.black54),
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
