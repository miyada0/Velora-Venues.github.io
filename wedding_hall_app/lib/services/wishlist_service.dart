import 'package:flutter/foundation.dart';
import 'api_service.dart';
import '../models/wishlist_model.dart';

class WishlistService {
  final api = ApiService();

  /// ADD TO WISHLIST
  Future<Map<String, dynamic>> addToWishlist(String hallId) async {
    final res = await api.dio.post(
      "/wishlist",
      data: {
        "hallId": hallId,
      },
    );
    return res.data;
  }

  /// GET USER'S WISHLIST - Returns parsed WishlistItemModel list
  /// With full debug logging for troubleshooting
  Future<List<WishlistItemModel>> getWishlist() async {
    try {
      debugPrint("📍 Fetching wishlist from API...");
      final res = await api.dio.get("/wishlist");

      debugPrint("✅ Wishlist API Response - Status: ${res.statusCode}");
      debugPrint("📋 Raw Response: ${res.data.toString()}");

      // Extract data array
      final data = res.data["data"] ?? [];
      debugPrint("📦 Data array length: ${data.length}");

      // Parse each item safely
      final wishlistItems = <WishlistItemModel>[];

      for (int i = 0; i < data.length; i++) {
        try {
          debugPrint("🔄 Parsing item $i...");
          final item = WishlistItemModel.fromJson(data[i]);
          wishlistItems.add(item);
          debugPrint("✅ Successfully parsed item $i: ${item.name}");
        } catch (e, stackTrace) {
          debugPrint(
              "❌ ERROR parsing wishlist item $i: $e\n📊 Item data: ${data[i]}\n🔴 Stack: $stackTrace");
          rethrow; // Re-throw to stop processing if an item is invalid
        }
      }

      debugPrint("✅ Wishlist parsed successfully. Total items: ${wishlistItems.length}");
      return wishlistItems;
    } catch (e, stackTrace) {
      debugPrint("❌ CRITICAL ERROR in getWishlist: $e");
      debugPrint("🔴 Stack: $stackTrace");
      rethrow;
    }
  }

  /// REMOVE FROM WISHLIST
  /// Takes the wishlist item ID (not hall ID)
  Future<void> removeFromWishlist(String wishlistId) async {
    debugPrint("🗑️ Removing from wishlist: $wishlistId");
    await api.dio.delete("/wishlist/$wishlistId");
    debugPrint("✅ Removed from wishlist");
  }

  /// CHECK IF HALL IS IN WISHLIST
  /// Returns the wishlist ID if found, null otherwise
  Future<String?> isHallWishlisted(String hallId) async {
    try {
      final items = await getWishlist();
      for (var item in items) {
        if (item.hallId == hallId) {
          debugPrint("✅ Hall $hallId found in wishlist: ${item.id}");
          return item.id;
        }
      }
      debugPrint("⚠️ Hall $hallId not found in wishlist");
      return null;
    } catch (e) {
      debugPrint("❌ Error checking wishlist: $e");
      return null;
    }
  }
}
