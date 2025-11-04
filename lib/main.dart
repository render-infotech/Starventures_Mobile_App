import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:starcapitalventures/app_export/app_export.dart';

import 'app_routes.dart';
import 'core/app_bindings/app_bindings.dart';
import 'core/services/connectivity_service.dart';
import 'core/services/session_service.dart';
import 'Screens/home_screen/controller/home_controller.dart';

void main() {
  // ✅ Initialize global services before running app
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  Get.put(ConnectivityService(), permanent: true);
  Get.put(SessionService(), permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // ✅ Setup global session monitoring
    _setupSessionMonitoring();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// ✅ Setup global session expiration monitoring
  void _setupSessionMonitoring() {
    if (Get.isRegistered<SessionService>()) {
      final sessionService = Get.find<SessionService>();

      // Listen to session expiration events
      sessionService.onSessionExpired = () {
        _handleSessionExpired();
      };
    }
  }

  /// ✅ Handle session expiration globally
  void _handleSessionExpired() {
    final currentRoute = Get.currentRoute;

    // Don't redirect if already on sign-in screen
    if (currentRoute == AppRoutes.signinscreen ||
        currentRoute == AppRoutes.intialScreen) {
      return;
    }

    print('🚫 Session expired - Redirecting to sign-in screen');

    // Show custom snackbar notification
    final context = Get.context;
    if (context != null) {
      _showCustomSnackbar(
        context,
        title: '⚠️ Session Expired',
        message: 'Your session has expired. Please sign in again.',
        backgroundColor: Colors.red,
      );
    }

    // Redirect to sign-in screen and clear navigation stack
    Future.delayed(const Duration(milliseconds: 500), () {
      Get.offAllNamed(AppRoutes.signinscreen);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Check permission when app resumes from background
    if (state == AppLifecycleState.resumed) {
      _checkGlobalPermission();
    }
  }

  Future<void> _checkGlobalPermission() async {
    try {
      final currentRoute = Get.currentRoute;

      // Don't check if user is on these screens
      if (currentRoute == AppRoutes.signinscreen ||
          currentRoute == AppRoutes.permissionGate ||
          currentRoute == AppRoutes.intialScreen ||
          currentRoute == '/no-internet') {
        return;
      }

      // Check if we need permission monitoring
      if (Get.isRegistered<HomeController>()) {
        final controller = Get.find<HomeController>();

        // Only check if geosentry is required
        if (controller.shouldUseGeosentry) {
          final alwaysStatus = await Permission.locationAlways.status;

          if (!alwaysStatus.isGranted) {
            print('🚨 Global permission check: Permission removed!');

            final context = Get.context;
            if (context != null) {
              _showCustomSnackbar(
                context,
                title: '⚠️ Permission Required',
                message: 'Location permission was removed. Redirecting...',
                backgroundColor: Colors.orange,
              );
            }

            // Redirect to permission gate
            Future.delayed(const Duration(milliseconds: 500), () {
              Get.offAllNamed(AppRoutes.permissionGate);
            });
          }
        }
      }
    } catch (e) {
      print('Error in global permission check: $e');
    }
  }

  /// ✅ Show professional custom snackbar at bottom
  void _showCustomSnackbar(
      BuildContext context, {
        required String title,
        required String message,
        Color? backgroundColor,
        Duration duration = const Duration(seconds: 3),
      }) {
    final snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      elevation: 6,
      backgroundColor: backgroundColor ?? appTheme.theme,
      margin: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
      duration: duration,
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Star Capital Ventures',
      initialBinding: AppBinding(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF402110)),
        primaryColor: Color(0xFF402110),
      ),
      builder: (context, child) {
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
