import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class ConnectivityService extends GetxService {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  var connectionStatus = ConnectivityResult.none.obs;
  var isOnline = true.obs;
  var previousRoute = '/homeScreenMain'.obs;

  Future<bool> get hasConnection async {
    final results = await _connectivity.checkConnectivity();
    return results.any((result) =>
    result != ConnectivityResult.none &&
        (result == ConnectivityResult.mobile ||
            result == ConnectivityResult.wifi ||
            result == ConnectivityResult.ethernet)
    );
  }

  @override
  void onInit() {
    super.onInit();
    _initConnectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> _initConnectivity() async {
    late List<ConnectivityResult> results;
    try {
      results = await _connectivity.checkConnectivity();
    } catch (e) {
      print('Could not check connectivity status: $e');
      return;
    }
    _updateConnectionStatus(results);
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    if (results.isNotEmpty) {
      connectionStatus.value = results.first;

      bool hasNetworkConnection = results.any((result) =>
      result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.ethernet
      );

      print('🌐 Connection Status: $hasNetworkConnection - ${results.first}');

      if (isOnline.value != hasNetworkConnection) {
        isOnline.value = hasNetworkConnection;

        if (!hasNetworkConnection) {
          if (Get.currentRoute != '/no-internet') {
            previousRoute.value = Get.currentRoute;
          }
          _showNoInternetPage();
        } else {
          _hideNoInternetPage();
        }
      }
    }
  }

  void _showNoInternetPage() {
    print('🚫 Showing no internet page');
    if (Get.currentRoute != '/no-internet') {
      Get.offAllNamed('/no-internet');
    }
  }

  void _hideNoInternetPage() {
    print('✅ Connection restored, returning to: ${previousRoute.value}');
    if (Get.currentRoute == '/no-internet') {
      Get.offAllNamed(previousRoute.value);
    }
  }

  Future<void> retryConnection() async {
    print('🔄 Manually checking connection...');
    final results = await _connectivity.checkConnectivity();
    _updateConnectionStatus(results);
  }

  String get connectionType {
    switch (connectionStatus.value) {
      case ConnectivityResult.mobile:
        return 'Mobile';
      case ConnectivityResult.wifi:
        return 'WiFi';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      default:
        return 'None';
    }
  }

  @override
  void onClose() {
    _connectivitySubscription.cancel();
    super.onClose();
  }
}
