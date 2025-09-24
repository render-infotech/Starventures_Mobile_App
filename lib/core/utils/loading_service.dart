import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:starcapitalventures/app_export/app_export.dart';

class LoadingService extends GetxService {
  static LoadingService get to => Get.find();

  final _isLoading = false.obs;
  OverlayEntry? _overlayEntry;

  bool get isLoading => _isLoading.value;

  // Show loading overlay
  void show({
    String? message,
    Color? color,
    Color? backgroundColor,
  }) {
    if (_isLoading.value) return; // Prevent multiple overlays

    _isLoading.value = true;

    final context = Get.overlayContext;
    if (context != null) {
      _overlayEntry = OverlayEntry(
        builder: (context) => _LoadingOverlay(
          message: message,
          color: color,
          backgroundColor: backgroundColor,
        ),
      );

      Overlay.of(context).insert(_overlayEntry!);
    }
  }

  // Hide loading overlay
  void hide() {
    if (!_isLoading.value) return;

    _isLoading.value = false;
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  // Convenient wrapper for async operations
  Future<T> during<T>(Future<T> future, {
    String? message,
    Color? color,
    Color? backgroundColor,
  }) async {
    show(message: message, color: color, backgroundColor: backgroundColor);
    try {
      final result = await future;
      hide();
      return result;
    } catch (e) {
      hide();
      rethrow;
    }
  }
}

// Private overlay widget
class _LoadingOverlay extends StatelessWidget {
  final String? message;
  final Color? color;
  final Color? backgroundColor;

  const _LoadingOverlay({
    this.message,
    this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor ?? Colors.black.withOpacity(0.3),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    color ??appTheme.theme2,
                  ),
                ),
              ),
              if (message != null) ...[
                const SizedBox(height: 16),
                Text(
                  message!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
