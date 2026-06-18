import 'package:flutter/foundation.dart';

class WishlistItemModel {
  final String id; // Wishlist item ID
  final String hallId; // Hall ID
  final String name;
  final String location;
  final double price;
  final double rating;
  final int capacity;
  final List<String> images;
  final List<String> facilities;
  final String description;
  final String? ownerId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  WishlistItemModel({
    required this.id,
    required this.hallId,
    required this.name,
    required this.location,
    required this.price,
    required this.rating,
    required this.capacity,
    required this.images,
    required this.facilities,
    required this.description,
    this.ownerId,
    required this.createdAt,
    this.updatedAt,
  });

  /// Safe factory constructor with null handling
  factory WishlistItemModel.fromJson(Map<String, dynamic> json) {
    try {
      // 📍 Debug: Print raw JSON
      debugPrint("🔍 WishlistItemModel.fromJson - Raw JSON: ${json.toString()}");

      // Extract wishlist item ID
      final id = json['_id']?.toString() ?? '';
      if (id.isEmpty) {
        debugPrint("⚠️ WARNING: Wishlist ID is empty");
      }

      // Extract hall data (could be nested or direct)
      final hallData =
          json['hall'] is Map<String, dynamic> ? json['hall'] as Map<String, dynamic> : json;

      debugPrint("📍 Hall Data: ${hallData.toString()}");

      // Extract hall ID safely
      final hallId = hallData['_id']?.toString() ?? '';
      if (hallId.isEmpty) {
        debugPrint("⚠️ WARNING: Hall ID is empty");
      }

      // Extract and validate fields with safe parsing
      final name = hallData['name']?.toString().trim() ?? 'Unknown Hall';

      final location = hallData['location']?.toString().trim() ?? '';

      // ✅ Safe price parsing
      double price = 0.0;
      try {
        if (hallData['price'] != null) {
          if (hallData['price'] is int) {
            price = (hallData['price'] as int).toDouble();
          } else if (hallData['price'] is double) {
            price = hallData['price'] as double;
          } else if (hallData['price'] is String) {
            price = double.tryParse(hallData['price'] as String) ?? 0.0;
          }
        }
      } catch (e) {
        debugPrint("❌ Error parsing price: $e");
        price = 0.0;
      }

      // ✅ Safe rating parsing
      double rating = 0.0;
      try {
        if (hallData['rating'] != null) {
          if (hallData['rating'] is int) {
            rating = (hallData['rating'] as int).toDouble();
          } else if (hallData['rating'] is double) {
            rating = hallData['rating'] as double;
          } else if (hallData['rating'] is String) {
            rating = double.tryParse(hallData['rating'] as String) ?? 0.0;
          }
        }
      } catch (e) {
        debugPrint("❌ Error parsing rating: $e");
        rating = 0.0;
      }

      // ✅ Safe capacity parsing
      int capacity = 0;
      try {
        if (hallData['capacity'] != null) {
          if (hallData['capacity'] is int) {
            capacity = hallData['capacity'] as int;
          } else if (hallData['capacity'] is double) {
            capacity = (hallData['capacity'] as double).toInt();
          } else if (hallData['capacity'] is String) {
            capacity = int.tryParse(hallData['capacity'] as String) ?? 0;
          }
        }
      } catch (e) {
        debugPrint("❌ Error parsing capacity: $e");
        capacity = 0;
      }

      // ✅ Safe images parsing
      List<String> images = [];
      try {
        if (hallData['images'] is List) {
          images =
              (hallData['images'] as List).map((img) => img.toString()).toList();
        }
      } catch (e) {
        debugPrint("❌ Error parsing images: $e");
        images = [];
      }

      // ✅ Safe facilities parsing
      List<String> facilities = [];
      try {
        if (hallData['facilities'] is List) {
          facilities = (hallData['facilities'] as List)
              .map((fac) => fac.toString())
              .toList();
        }
      } catch (e) {
        debugPrint("❌ Error parsing facilities: $e");
        facilities = [];
      }

      final description = hallData['description']?.toString().trim() ?? '';

      // Extract owner ID
      final ownerId = hallData['owner']?.toString();

      // Parse timestamps
      DateTime createdAt = DateTime.now();
      try {
        if (json['createdAt'] != null) {
          createdAt = DateTime.parse(json['createdAt'].toString());
        }
      } catch (e) {
        debugPrint("❌ Error parsing createdAt: $e");
      }

      DateTime? updatedAt;
      try {
        if (json['updatedAt'] != null) {
          updatedAt = DateTime.parse(json['updatedAt'].toString());
        }
      } catch (e) {
        debugPrint("❌ Error parsing updatedAt: $e");
      }

      debugPrint(
          "✅ WishlistItemModel parsed successfully: id=$id, name=$name, price=$price, rating=$rating");

      return WishlistItemModel(
        id: id,
        hallId: hallId,
        name: name,
        location: location,
        price: price,
        rating: rating,
        capacity: capacity,
        images: images,
        facilities: facilities,
        description: description,
        ownerId: ownerId,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
    } catch (e, stackTrace) {
      debugPrint("❌ CRITICAL ERROR in WishlistItemModel.fromJson: $e");
      debugPrint("📊 JSON data: ${json.toString()}");
      debugPrint("🔴 Stack: $stackTrace");
      rethrow;
    }
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'hall': {
        '_id': hallId,
        'name': name,
        'location': location,
        'price': price,
        'rating': rating,
        'capacity': capacity,
        'images': images,
        'facilities': facilities,
        'description': description,
        'owner': ownerId,
      },
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'WishlistItemModel(id: $id, hallId: $hallId, name: $name, price: $price, rating: $rating)';
  }
}
