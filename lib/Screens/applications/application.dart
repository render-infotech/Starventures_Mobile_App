import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:starcapitalventures/Screens/applications/widget/application_card.dart';
import 'package:starcapitalventures/core/utils/appTheme/app_theme.dart';
import 'package:starcapitalventures/core/utils/styles/size_utils.dart';
import '../../app_export/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../application_detail/application_details_screen.dart';
import 'controller/application_controller.dart';


class Application extends StatelessWidget {
  const Application({super.key});

  @override
  Widget build(BuildContext context) {
    final ApplicationListController controller = Get.put(ApplicationListController());

    return Scaffold(
      backgroundColor: appTheme.gray100,
      appBar: CustomAppBar(
        backgroundColor: appTheme.mintygreen,
        useGreeting: false,
        pageTitle: 'Applications',
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.hasError.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red.shade400,
                ),
                SizedBox(height: getVerticalSize(16)),
                Text(
                  'Failed to load applications',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: getVerticalSize(8)),
                Text(
                  controller.errorMessage.value,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: getVerticalSize(16)),
                ElevatedButton(
                  onPressed: () => controller.refreshApplications(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (controller.applications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.description_outlined,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                SizedBox(height: getVerticalSize(16)),
                Text(
                  'No applications found',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: getVerticalSize(8)),
                Text(
                  'Applications will appear here once they are submitted',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.refreshApplications(),
          child: ListView.builder(
            padding: getPadding(left: 16, right: 16, top: 16, bottom: 16),
            itemCount: controller.applications.length,
            itemBuilder: (context, index) {
              final application = controller.applications[index];
              return InkWell(
                borderRadius: AppRadii.lg,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ApplicationDetailScreen(
                        userId: '', // You can add userId if needed
                        applicationId: application.id,
                      ),
                    ),
                  );
                },
                child: ApplicationApiCard(application: application),
              );
            },
          ),
        );
      }),
    );
  }
}
