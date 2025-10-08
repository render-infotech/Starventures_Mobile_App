import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app_routes.dart';
import 'core/app_bindings/app_bindings.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Star Capital Ventures',
      initialBinding: AppBinding(), // Initialize services

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      builder: (context, child) {
        // MediaQuery is available here.
        final mq = MediaQuery.of(context);

        final clamped = mq.textScaler.clamp(
          minScaleFactor: 0.9,
          maxScaleFactor: 1.6,
        );

        return MediaQuery(
          data: mq.copyWith(textScaler: clamped),
          child: child ?? const SizedBox.shrink(),
        );
      },
      initialRoute: AppRoutes.intialScreen,
      getPages: AppRoutes.pages,
    );
  }
}
