import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/wishlist_model.dart';
import '../services/wishlist_service.dart';

/// ❤️ WISHLIST STATE MANAGEMENT
/// Provides access to user's wishlist items and operations
class WishlistNotifier
    extends StateNotifier<AsyncValue<List<WishlistItemModel>>> {
  final WishlistService _wishlistService = WishlistService();

  WishlistNotifier() : super(const AsyncValue.loading()) {
    _loadWishlist();
  }

  /// Load wishlist from API
  Future<void> _loadWishlist() async {
    try {
      state = const AsyncValue.loading();
      final items = await _wishlistService.getWishlist();
      state = AsyncValue.data(items);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Add hall to wishlist
  Future<void> addToWishlist(String hallId) async {
    try {
      await _wishlistService.addToWishlist(hallId);
      // Reload wishlist to keep in sync
      await _loadWishlist();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  /// Remove hall from wishlist
  Future<void> removeFromWishlist(String hallId) async {
    try {
      final currentState = state;
      if (currentState is AsyncData<List<WishlistItemModel>>) {
        // Find the wishlist item ID for this hall
        final wishlistItem = currentState.value.firstWhere(
          (item) => item.hallId == hallId,
          orElse: () => throw Exception('Hall not found in wishlist'),
        );

        // Remove from API
        await _wishlistService.removeFromWishlist(wishlistItem.id);

        // Update local state
        final updatedList =
            currentState.value.where((item) => item.hallId != hallId).toList();
        state = AsyncValue.data(updatedList);
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  /// Refresh wishlist from API
  Future<void> refresh() async {
    await _loadWishlist();
  }
}

/// Riverpod Provider for Wishlist State
final wishlistProvider = StateNotifierProvider<WishlistNotifier,
    AsyncValue<List<WishlistItemModel>>>((ref) {
  return WishlistNotifier();
});
