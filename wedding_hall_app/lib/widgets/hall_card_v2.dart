import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/hall_model.dart';
import '../services/wishlist_service.dart';
import '../views/hall/hall_details_screen.dart';
import '../theme/app_theme.dart';
import '../viewmodels/auth_vm.dart';
import '../utils/image_utils.dart';

/// ✨ MODERN HALL CARD WITH WISHLIST
/// Displays hall info with integrated wishlist button
class HallCard extends ConsumerStatefulWidget {
  final HallModel hall;

  const HallCard(this.hall, {super.key});

  @override
  ConsumerState<HallCard> createState() => _HallCardState();
}

class _HallCardState extends ConsumerState<HallCard> {
  final WishlistService _wishlistService = WishlistService();
  String? _wishlistId;
  bool _isWishlisted = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkWishlistStatus();
  }

  /// Check if hall is in user's wishlist
  Future<void> _checkWishlistStatus() async {
    try {
      final wishlistId =
          await _wishlistService.isHallWishlisted(widget.hall.id);
      if (mounted) {
        setState(() {
          _wishlistId = wishlistId;
          _isWishlisted = wishlistId != null;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Toggle wishlist status
  Future<void> _toggleWishlist() async {
    final user = ref.read(authProvider);
    final messenger = ScaffoldMessenger.of(context);

    // Check if user is logged in BEFORE attempting the operation
    if (user == null) {
      if (!mounted) return;
      _showLoginPrompt(messenger);
      return;
    }

    try {
      if (_isWishlisted && _wishlistId != null) {
        /// Remove from wishlist
        setState(() => _isWishlisted = false);
        await _wishlistService.removeFromWishlist(_wishlistId!);

        messenger.showSnackBar(
          const SnackBar(
            content: Text("Removed from wishlist"),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        /// Add to wishlist
        setState(() => _isWishlisted = true);
        final response = await _wishlistService.addToWishlist(widget.hall.id);

        if (response["data"] != null) {
          setState(() => _wishlistId = response["data"]["_id"]);
        }

        messenger.showSnackBar(
          const SnackBar(
            content: Text("Added to wishlist ❤️"),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      /// Revert state on error
      setState(() => _isWishlisted = !_isWishlisted);

      messenger.showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showLoginPrompt(ScaffoldMessengerState messenger) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text("Login Required"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppTheme.lightBeige,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_border,
                size: 40,
                color: AppTheme.gold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Login to Save Favorites",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Sign in to add this hall to your wishlist.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Not Now"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.gold,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushNamed(context, '/login');
            },
            child: const Text(
              "Login",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// IMAGE + OVERLAYS
          Stack(
            children: [
              /// HALL IMAGE - Main background
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HallDetailsScreen(hall: widget.hall),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppTheme.borderRadiusLarge),
                  ),
                  child: Stack(
                    children: [
                      /// Image
                      Image.network(
                        ImageUtils.getImageUrl(
                          widget.hall.images.isNotEmpty
                              ? widget.hall.images[0]
                              : "",
                        ),
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            color: Colors.grey[300],
                            child: Icon(Icons.broken_image,
                                color: Colors.grey[600]),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 200,
                            color: Colors.grey[300],
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        },
                      ),

                      /// GRADIENT OVERLAY
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.3),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              /// ⭐ RATING BADGE - Top right
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.lightBlue,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.star,
                        size: 16,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.hall.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              /// ❤️ WISHLIST BUTTON - Top left
              Positioned(
                top: 10,
                left: 10,
                child: GestureDetector(
                  onTap: _toggleWishlist,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 48,
                            height: 48,
                            child: Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          )
                        : IconButton(
                            icon: Icon(
                              _isWishlisted
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: Colors.red,
                              size: 22,
                            ),
                            onPressed: null,
                          ),
                  ),
                ),
              ),
            ],
          ),

          /// DETAILS SECTION
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HallDetailsScreen(hall: widget.hall),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// HALL NAME
                  Text(
                    widget.hall.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  /// LOCATION
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          widget.hall.location,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                            height: 1.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  /// CAPACITY & PRICE ROW
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      /// CAPACITY
                      Row(
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "${widget.hall.capacity} guests",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),

                      /// PRICE
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryLight,
                          borderRadius:
                              BorderRadius.circular(AppTheme.borderRadiusSmall),
                        ),
                        child: Text(
                          '₹${(widget.hall.price / 100000).toStringAsFixed(1)}L',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
