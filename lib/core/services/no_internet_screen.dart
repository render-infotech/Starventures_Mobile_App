import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/connectivity_service.dart';

class NoInternetScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ConnectivityService connectivityService = Get.find<ConnectivityService>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // WiFi Off Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.wifi_off_rounded,
                  size: 60,
                  color: Colors.grey.shade400,
                ),
              ),

              SizedBox(height: 32),

              Text(
                'Whoops!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 12),

              Text(
                'No Internet Connection',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 16),

              Text(
                'Please check your internet connection and try again. Make sure WiFi or mobile data is turned on.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 40),

              // Try Again Button
              Obx(() => Container(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    if (connectivityService.isOnline.value) {
                      Get.offAllNamed(connectivityService.previousRoute.value);
                    } else {
                      bool hasConn = await connectivityService.hasConnection;

                      if (hasConn) {
                        connectivityService.isOnline.value = true;
                        Get.offAllNamed(connectivityService.previousRoute.value);
                      } else {
                        Get.snackbar(
                          'Still No Connection',
                          'Please check your internet settings',
                          backgroundColor: Colors.red.shade100,
                          colorText: Colors.red.shade800,
                          icon: Icon(Icons.wifi_off, color: Colors.red.shade600),
                          duration: Duration(seconds: 2),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: connectivityService.isOnline.value
                        ? Colors.green
                        : Color(0xFF402110),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    connectivityService.isOnline.value ? 'Continue' : 'Try Again',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )),

              SizedBox(height: 20),

              // Connection Status
              Obx(() => AnimatedContainer(
                duration: Duration(milliseconds: 300),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: connectivityService.isOnline.value
                      ? Colors.green.shade50
                      : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: connectivityService.isOnline.value
                        ? Colors.green.shade200
                        : Colors.red.shade200,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      connectivityService.isOnline.value ? Icons.wifi : Icons.wifi_off,
                      size: 16,
                      color: connectivityService.isOnline.value
                          ? Colors.green.shade600
                          : Colors.red.shade600,
                    ),
                    SizedBox(width: 8),
                    Text(
                      connectivityService.isOnline.value
                          ? 'Connected (${connectivityService.connectionType})'
                          : 'No Connection',
                      style: TextStyle(
                        color: connectivityService.isOnline.value
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              )),

              SizedBox(height: 30),

              Text(
                'Connection will be restored automatically',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade400,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
