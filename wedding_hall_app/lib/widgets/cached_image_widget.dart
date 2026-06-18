import 'package:flutter/material.dart';
import '../utils/image_utils.dart';

/// ✅ REUSABLE IMAGE WIDGET WITH SHIMMER LOADING
/// Ensures all images use ImageUtils and have consistent error/loading handling
class CachedImageWidget extends StatelessWidget {
  final String imageUrl;
  final double? height;
  final double? width;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final double borderRadiusValue;

  const CachedImageWidget({
    required this.imageUrl,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.borderRadiusValue = 12,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(borderRadiusValue);

    return ClipRRect(
      borderRadius: radius,
      child: Image.network(
        ImageUtils.getImageUrl(imageUrl),
        height: height,
        width: width,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: height ?? 200,
            width: width ?? double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: radius,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.broken_image,
                  size: 48,
                  color: Colors.grey[600],
                ),
                const SizedBox(height: 8),
                Text(
                  "Image not available",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;

          // Show shimmer loader while image is loading
          return Container(
            height: height ?? 200,
            width: width ?? double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: radius,
            ),
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.grey[400]!,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// ✅ SHIMMER LOADING EFFECT FOR IMAGES
class ShimmerImageLoader extends StatelessWidget {
  final double height;
  final double width;
  final double borderRadius;

  const ShimmerImageLoader({
    this.height = 200,
    this.width = double.infinity,
    this.borderRadius = 12,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      ),
    );
  }
}
