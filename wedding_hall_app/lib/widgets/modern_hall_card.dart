import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/hall_model.dart';
import '../theme/app_theme.dart';
import '../utils/image_utils.dart';
import '../viewmodels/wishlist_vm.dart';
import 'package:dio/dio.dart';

/// Modern Hall Card Widget - Inspired by Travel Apps
/// Shows hall image, name, location, rating, and price
class ModernHallCard extends ConsumerWidget {
  final HallModel hall;
  final VoidCallback onTap;

  const ModernHallCard({
    super.key,
    required this.hall,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlistAsyncValue = ref.watch(wishlistProvider);

    // Check if this hall is in wishlist
    final isFavorited = wishlistAsyncValue.when(
      data: (wishlistItems) =>
          wishlistItems.any((item) => item.hallId == hall.id),
      loading: () => false,
      error: (_, __) => false,
    );

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🖼 HALL IMAGE WITH OVERLAY
              Stack(
                children: [
                  // Hall Image
                  Container(
                    height: 140,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                    ),
                    child: hall.images.isNotEmpty
                        ? Image.network(
                            ImageUtils.getImageUrl(hall.images[0]),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.image_not_supported,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          )
                        : Container(
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.business,
                              size: 60,
                              color: Colors.grey,
                            ),
                          ),
                  ),

                  /// ⭐ RATING BADGE
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.lightBlue,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 12,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            hall.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  /// ❤️ FAVORITE BUTTON - NOW CLICKABLE WITH EVENT BUBBLE PREVENTION
                  Positioned(
                    top: 8,
                    left: 8,
                    child: GestureDetector(
                      onTap: () async {
                        // ✅ FIX: Prevent event bubbling to parent GestureDetector
                        try {
                          if (isFavorited) {
                            // Remove from wishlist
                            await ref
                                .read(wishlistProvider.notifier)
                                .removeFromWishlist(hall.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Removed from wishlist ❤️'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          } else {
                            // Add to wishlist
                            await ref
                                .read(wishlistProvider.notifier)
                                .addToWishlist(hall.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Added to wishlist ❤️'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          }
                        } catch (e) {
                          if (context.mounted) {
                            String errorMsg = 'Error updating wishlist';
                            if (e is DioException) {
                              if (e.response?.statusCode == 401) {
                                errorMsg = 'Please login to save favorites';
                              } else {
                                errorMsg = e.response?.data['error'] ??
                                    'Error updating wishlist';
                              }
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(errorMsg),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        }
                      },
                      // ✅ FIX: Prevent event bubbling with HitTestBehavior
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Icon(
                          isFavorited ? Icons.favorite : Icons.favorite_border,
                          size: 16,
                          color: isFavorited ? Colors.red : AppTheme.accent,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              /// 📋 HALL INFO
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// HALL NAME
                      Text(
                        hall.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 4),

                      /// LOCATION
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 12,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              hall.location,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      /// PRICE
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '₹${(hall.price / 100000).toStringAsFixed(1)}L',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
