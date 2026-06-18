import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../services/wishlist_service.dart';
import '../../services/safe_api.dart';
import '../../views/hall/hall_details_screen.dart';
import '../../models/hall_model.dart';
import '../../models/wishlist_model.dart';
import '../../theme/app_theme.dart';
import '../../utils/error_handler.dart';
import '../../utils/image_utils.dart';
//import '../../widgets/rating_stars.dart';
//import '../../widgets/price_card.dart';

/// ❤️ MODERN WISHLIST SCREEN - Saved Venues
class WishlistScreen extends ConsumerStatefulWidget {
  const WishlistScreen({super.key});

  @override
  ConsumerState<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends ConsumerState<WishlistScreen> {
  final WishlistService _wishlistService = WishlistService();
  List<WishlistItemModel> _wishlistItems = [];
  bool _isLoading = true;
  String? _error;
  bool _isUnauthorized = false;

  @override
  void initState() {
    super.initState();
    _loadWishlist();
  }

  /// Fetch wishlist from server with proper error handling
  Future<void> _loadWishlist() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
        _isUnauthorized = false;
      });

      final items = await _wishlistService.getWishlist();
      if (mounted) {
        setState(() {
          _wishlistItems = items;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        // ✅ FIX: Check if 401 Unauthorized
        bool is401 = false;
        if (e is DioException) {
          is401 = e.response?.statusCode == 401;
        }

        if (is401) {
          // ✅ Use SafeApi.handle401() for centralized logout handling
          SafeApi.handle401(context, ref);
        } else {
          final errorMsg = e is DioException
              ? (e.response?.data["error"] ??
                  e.message ??
                  "Failed to load wishlist")
              : ErrorHandler.getMessage(e);

          setState(() {
            _isUnauthorized = false;
            _error = errorMsg;
            _isLoading = false;
          });
        }
      }
    }
  }

  /// Remove item from wishlist
  Future<void> _removeFromWishlist(String wishlistId, int index) async {
    try {
      await _wishlistService.removeFromWishlist(wishlistId);

      if (mounted) {
        setState(() {
          _wishlistItems.removeAt(index);
        });

        ErrorHandler.showSuccess(
          context,
          "Removed from wishlist ❤️",
        );
      }
    } catch (e) {
      if (mounted) {
        // ✅ FIX: Check if 401 Unauthorized
        bool is401 = false;
        if (e is DioException) {
          is401 = e.response?.statusCode == 401;
        }

        if (is401) {
          SafeApi.handle401(context, ref);
        } else {
          final errorMsg = e is DioException
              ? (e.response?.data["error"] ??
                  e.message ??
                  "Failed to remove from wishlist")
              : ErrorHandler.getMessage(e);
          ErrorHandler.showError(context, errorMsg);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Wishlist ❤️"),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textPrimary,
      ),
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF87CEFA),
              Color(0xFFFFFFFF),
            ],
          ),
        ),
        child: _buildBody(),
      ),
      floatingActionButton:
          _wishlistItems.isNotEmpty && !_isLoading && _error == null
              ? FloatingActionButton(
                  onPressed: _loadWishlist,
                  backgroundColor: AppTheme.primaryBlue,
                  child: const Icon(Icons.refresh, color: Colors.white),
                )
              : null,
    );
  }

  /// Build the body based on state
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // ✅ FIX: Handle 401 Unauthorized - Show login button
    if (_isUnauthorized) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline,
                size: 60,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                _error ?? "Something went wrong",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    // Navigate to login
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/login',
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.login, color: Colors.white),
                  label: const Text(
                    "Go to Login",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_error != null && !_isUnauthorized) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                _error ?? "Something went wrong",
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadWishlist,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.gold,
              ),
              icon: const Icon(Icons.refresh),
              label: const Text("Try Again"),
            ),
          ],
        ),
      );
    }

    if (_wishlistItems.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppTheme.lightBeige,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(
                  Icons.favorite_border,
                  size: 50,
                  color: AppTheme.gold,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "No Halls Saved Yet",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Add your favorite halls to wishlist\nand visit them anytime",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.home),
                  label: const Text("Explore Halls"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.gold,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: _wishlistItems.length,
      itemBuilder: (context, index) {
        final wishlistItem = _wishlistItems[index];

        // ✅ FIX: Convert to HallModel for display
        // Note: Wishlist items are only for approved halls (default to approved)
        final hall = HallModel(
          id: wishlistItem.hallId,
          name: wishlistItem.name,
          location: wishlistItem.location,
          price: wishlistItem.price,
          images: wishlistItem.images,
          facilities: wishlistItem.facilities,
          capacity: wishlistItem.capacity,
          description: wishlistItem.description,
          rating: wishlistItem.rating,
          status: "approved",
          ownerId: wishlistItem.ownerId,
        );

        return _buildWishlistCard(context, hall, wishlistItem.id, index);
      },
    );
  }

  /// Build individual wishlist item card
  Widget _buildWishlistCard(
    BuildContext context,
    HallModel hall,
    String wishlistId,
    int index,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // 🔥 FIX #1: Move GestureDetector INSIDE Stack and wrap ONLY the Row
          GestureDetector(
            onTap: () {
              print("[WISHLIST] Navigating to hall details: ${hall.id}");
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HallDetailsScreen(hall: hall),
                ),
              );
            },
            child: Row(
              children: [
                /// Hall Image
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    bottomLeft: Radius.circular(18),
                  ),
                  child: Image.network(
                    ImageUtils.getImageUrl(
                      hall.images.isNotEmpty ? hall.images[0] : "",
                    ),
                    width: 140,
                    height: 140,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 140,
                        height: 140,
                        color: Colors.grey[300],
                        child: Icon(Icons.image, color: Colors.grey[600]),
                      );
                    },
                  ),
                ),

                /// Hall Details
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        /// Name
                        Text(
                          hall.name,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 8),

                        /// Location
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 16,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                hall.location,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        /// Price and Rating Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            /// Price
                            Text(
                              "₹${hall.price.toStringAsFixed(0)}",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.gold,
                              ),
                            ),

                            /// Rating
                            if (hall.rating > 0)
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    size: 14,
                                    color: Colors.amber[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    hall.rating.toStringAsFixed(1),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// 🔥 FIX #2: Delete Button in separate GestureDetector (NOT wrapped by card tap handler)
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              // 🔥 FIX #3: Stop event propagation to parent GestureDetector
              onTap: () {
                print("[WISHLIST] Delete button tapped for: ${hall.id}");
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Remove from Wishlist?"),
                    content: Text("Remove ${hall.name} from wishlist?"),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          print(
                              "[WISHLIST] Removing from wishlist: ${hall.id}");
                          _removeFromWishlist(wishlistId, index);
                        },
                        child: const Text(
                          "Remove",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: const IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                    size: 20,
                  ),
                  onPressed: null, // Handled by GestureDetector.onTap
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
