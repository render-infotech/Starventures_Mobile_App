import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 1. Added this import
import 'package:get/get.dart';

import 'app_routes.dart';
import 'core/app_bindings/app_bindings.dart';

// 2. Added the platform channel and SDK function
const platform = MethodChannel('com.geosentry.sdk/channel');

Future<void> initializeSDK(
  String apiKey,
  String cipherKey,
  String userID,
) async {
  try {
    final result = await platform.invokeMethod('initializeSDK', {
      'apiKey': apiKey,
      'cipherKey': cipherKey,
      'userID': userID,
    });
    print('SDK Initialization Result: $result');
  } on PlatformException catch (e) {
    print("Failed to initialize SDK: '${e.message}'.");
  }
}

// 3. Updated the main function to initialize the SDK
void main() async {
  // Ensure Flutter is initialized before calling native code
  WidgetsFlutterBinding.ensureInitialized();

  // --- Your Keys Are Placed Here ---
  const String apiKey = "AIzaSyBkMBBzZgBeLkALU82VI43Nz-7W8jacAjE";
  const String cipherKey =
      "CiQAZ/P3uq2ESwSnvqCxYrmG4CvbtD5Mk1odfIWGQPSKQUZIKvgSWQDIjRS5Fab/vPOjIeF64tHgkKCWscJjQSwZuBpQro74vO0HR+Yu57Yp7Mq1T79mqchiAVY5nQwKDBtsbdQwBnwIlB7mjKF0OtqM9kEyjJKogS9QcHOfePw0";
  const String userID = "c2962969-0c42-42e1-8911-e729d36b6ef7";

  // Call the SDK initialization function before running the app
  await initializeSDK(apiKey, cipherKey, userID);

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

        // 1) Clamp TextScaler globally for consistent, accessible text.
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
