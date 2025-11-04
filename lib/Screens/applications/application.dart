// lib/Screens/applications/application.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:starcapitalventures/Screens/applications/widget/application_card.dart';
import 'package:starcapitalventures/core/utils/appTheme/app_theme.dart';
import 'package:starcapitalventures/core/utils/styles/size_utils.dart';
import '../../app_export/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../application_detail/application_details_screen.dart';
import 'controller/application_controller.dart';

class Application extends StatefulWidget {
  const Application({super.key});

  @override
  State<Application> createState() => _ApplicationState();
}

class _ApplicationState extends State<Application> {
  late final ApplicationListController _controller;
  late final ScrollController _scrollController;

  // ✅ Remove AutomaticKeepAliveClientMixin - this was causing the caching issue!

  @override
  void initState() {
    super.initState();
    print('🚀 Application Screen initState');

    if (Get.isRegistered<ApplicationListController>()) {
      _controller = Get.find<ApplicationListController>();
      print('♻️ Found existing controller');
    } else {
      _controller = Get.put(ApplicationListController());
      print('✨ Created new controller');
    }

    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🔄 Force refreshing applications on screen open');
      _controller.refreshApplications();
    });
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_controller.isLoadingMore.value && _controller.hasNextPage.value) {
        print('📜 Reached scroll threshold - Loading next page');
        _controller.loadNextPage();
      }
    }
  }

  @override
  void dispose() {
    print('🔴 Application Screen dispose');
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Removed super.build(context) - not needed without AutomaticKeepAliveClientMixin

    return Scaffold(
      backgroundColor: appTheme.gray100,
      appBar: CustomAppBar(
        backgroundColor: appTheme.mintygreen,
        useGreeting: false,
        pageTitle: 'Applications',
      ),
      body: Obx(() {
        // ✅ Direct reactive rebuild - no caching
        final listLength = _controller.applications.length;
        print('🔄 Building with ${listLength} applications');

        // Loading state
        if (_controller.isLoading.value && _controller.applications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: appTheme.theme2),
                SizedBox(height: getVerticalSize(16)),
                Text(
                  'Loading applications...',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          );
        }

        // Error state
        if (_controller.hasError.value && _controller.applications.isEmpty) {
          return Center(
            child: Padding(
              padding: getPadding(all: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 80,
                    color: Colors.orange.shade400,
                  ),
                  SizedBox(height: getVerticalSize(24)),
                  Text(
                    'Unable to Load Applications',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: getVerticalSize(8)),
                  Padding(
                    padding: getPadding(left: 20, right: 20),
                    child: Text(
                      _controller.errorMessage.value.isNotEmpty
                          ? _controller.errorMessage.value
                          : 'Something went wrong. Please try again.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: getVerticalSize(24)),
                  ElevatedButton.icon(
                    onPressed: () {
                      print('🔄 Retry button pressed');
                      _controller.refreshApplications();
                    },
                    icon: const Icon(Icons.refresh, size: 20),
                    label: const Text('Try Again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appTheme.theme2,
                      foregroundColor: Colors.white,
                      padding: getPadding(
                          left: 24, right: 24, top: 12, bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Empty state
        if (_controller.applications.isEmpty) {
          return Center(
            child: Padding(
              padding: getPadding(all: 32),
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
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: getVerticalSize(8)),
                  Text(
                    'Applications will appear here once they are submitted',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: getVerticalSize(24)),
                  TextButton.icon(
                    onPressed: () {
                      print('🔄 Refresh button pressed');
                      _controller.refreshApplications();
                    },
                    icon: const Icon(Icons.refresh, size: 20),
                    label: const Text('Refresh'),
                    style: TextButton.styleFrom(
                      foregroundColor: appTheme.theme2,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // ✅ Applications list - completely reactive
        return RefreshIndicator(
          color: appTheme.theme2,
          onRefresh: () {
            print('🔄 Pull to refresh triggered');
            return _controller.refreshApplications();
          },
          child: ListView.builder(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: getPadding(left: 16, right: 16, top: 16, bottom: 90),
            itemCount: _controller.applications.length +
                (_controller.isLoadingMore.value || _controller.hasNextPage.value ? 1 : 0),
            itemBuilder: (context, index) {
              // Show loading indicator at the end
              if (index == _controller.applications.length) {
                return Padding(
                  padding: getPadding(all: 16),
                  child: Center(
                    child: _controller.isLoadingMore.value
                        ? Column(
                      children: [
                        CircularProgressIndicator(
                          color: appTheme.theme2,
                          strokeWidth: 2,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Loading more...',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    )
                        : _controller.hasNextPage.value
                        ? Container(
                      padding: getPadding(all: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Scroll to load more',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    )
                        : Text(
                      'No more applications',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                );
              }

              final application = _controller.applications[index];
              return InkWell(
                borderRadius: AppRadii.lg,
                onTap: () {
                  print('📱 Opening application detail: ${application.id}');
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ApplicationDetailScreen(
                        userId: '',
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
