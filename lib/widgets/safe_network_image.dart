import 'package:flutter/material.dart';

/// Widget to safely load network images with fallback placeholder
class SafeNetworkImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Color? placeholderColor;
  final IconData placeholderIcon;
  final double placeholderIconSize;

  const SafeNetworkImage({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholderColor,
    this.placeholderIcon = Icons.person,
    this.placeholderIconSize = 48,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // If no URL provided, show placeholder immediately
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildPlaceholder();
    }

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: Image.network(
        imageUrl!,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;

          // Show loading indicator
          return _buildLoadingIndicator(loadingProgress);
        },
        errorBuilder: (context, error, stackTrace) {
          // Silently handle error and show placeholder
          return _buildPlaceholder();
        },
      ),
    );
  }

  /// Build placeholder widget with icon
  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: placeholderColor ?? Colors.grey[200],
        borderRadius: borderRadius,
      ),
      child: Center(
        child: Icon(
          placeholderIcon,
          size: placeholderIconSize,
          color: Colors.grey[400],
        ),
      ),
    );
  }

  /// Build loading indicator
  Widget _buildLoadingIndicator(ImageChunkEvent loadingProgress) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: placeholderColor ?? Colors.grey[100],
        borderRadius: borderRadius,
      ),
      child: Center(
        child: CircularProgressIndicator(
          value: loadingProgress.expectedTotalBytes != null
              ? loadingProgress.cumulativeBytesLoaded /
              loadingProgress.expectedTotalBytes!
              : null,
          strokeWidth: 2,
          color: Colors.grey[400],
        ),
      ),
    );
  }
}

/// Widget specifically for avatar/profile images
class SafeAvatarImage extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final Color? backgroundColor;

  const SafeAvatarImage({
    Key? key,
    required this.imageUrl,
    this.radius = 24,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? Colors.grey[200],
      child: imageUrl == null || imageUrl!.isEmpty
          ? Icon(
        Icons.person,
        size: radius * 1.2,
        color: Colors.grey[400],
      )
          : ClipOval(
        child: Image.network(
          imageUrl!,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.person,
              size: radius * 1.2,
              color: Colors.grey[400],
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: 2,
                color: Colors.grey[400],
              ),
            );
          },
        ),
      ),
    );
  }
}
