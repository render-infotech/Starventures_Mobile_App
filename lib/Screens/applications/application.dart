import 'package:flutter/material.dart';
import 'package:starcapitalventures/core/utils/appTheme/app_theme.dart';
import 'package:starcapitalventures/core/utils/styles/size_utils.dart';
import '../../app_export/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../application_detail/application_details_screen.dart';
import 'controller/application_controller.dart';
import 'widget/application_card.dart';

class Application extends StatefulWidget {
  const Application({super.key});

  @override
  State<Application> createState() => _ApplicationState();
}

class _ApplicationState extends State<Application> {
  late final ApplicationListController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ApplicationListController();
    _controller.fetch(userId: 'U123'); // dummy user
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.gray100,
      appBar: CustomAppBar(
        backgroundColor: appTheme.mintygreen,
        useGreeting: false,
        pageTitle: 'Applications',
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final items = _controller.items;
          return ListView.builder(
            padding: getPadding(left: 16, right: 16, top: 16, bottom: 16),
            itemCount: items.length,
            itemBuilder: (context, i) {
              final it = items[i];
              return InkWell(
                borderRadius: AppRadii.lg,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ApplicationDetailScreen(
                        userId: it.userId,
                        applicationId: it.applicationId,
                      ),
                    ),
                  );
                },
                child: ApplicationCard(item: it),
              );
            },
          );
        },
      ),
    );
  }
}
