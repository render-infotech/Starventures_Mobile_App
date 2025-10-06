import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:starcapitalventures/core/utils/styles/size_utils.dart';
import 'package:starcapitalventures/core/utils/appTheme/app_theme.dart';

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
          message: message ?? 'Loading...',
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

  // Static method to return widget for direct use in build methods
  static Widget widget({
    String? message,
    Color? color,
    Color? backgroundColor,
  }) {
    return _LoadingOverlay(
      message: message ?? 'Loading...',
      color: color,
      backgroundColor: backgroundColor,
    );
  }
}

// Private overlay widget
class _LoadingOverlay extends StatefulWidget {
  final String message;
  final Color? color;
  final Color? backgroundColor;

  const _LoadingOverlay({
    required this.message,
    this.color,
    this.backgroundColor,
  });

  @override
  State<_LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<_LoadingOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: widget.backgroundColor ?? Colors.black.withOpacity(0.5),
      child: Center(
        child: Container(
          padding: getPadding(all: 20),
          margin: getPadding(left: 40, right: 40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RotationTransition(
                turns: _animation,
                child: SizedBox(
                  width: getHorizontalSize(40),
                  height: getHorizontalSize(40),
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      widget.color ?? appTheme.mintygreen ?? const Color(0xFF3FC2A2),
                    ),
                  ),
                ),
              ),
              SizedBox(height: getVerticalSize(16)),
              Text(
                widget.message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1A2036),
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
