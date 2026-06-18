class HallModel {
  final String id;
  final String name;
  final String location;
  final double price;
  final List<String> images;
  final List<String> facilities;
  final int capacity;
  final String description;
  final double rating;
  final String status;
  final String? ownerId;
  final Map<String, dynamic>? ownerData;

  HallModel({
    required this.id,
    required this.name,
    required this.location,
    required this.price,
    required this.images,
    required this.facilities,
    required this.capacity,
    required this.description,
    required this.rating,
    required this.status,
    this.ownerId,
    this.ownerData,
  });

  factory HallModel.fromJson(Map<String, dynamic> json) {
    try {
      // Safely extract images
      List<String> imagesList = [];
      if (json["images"] is List) {
        for (var img in json["images"] as List) {
          if (img is String) {
            imagesList.add(img);
          } else if (img != null) {
            imagesList.add(img.toString());
          }
        }
      }

      // Safely extract facilities
      List<String> facilitiesList = [];
      if (json["facilities"] is List) {
        for (var fac in json["facilities"] as List) {
          if (fac is String) {
            facilitiesList.add(fac);
          } else if (fac != null) {
            facilitiesList.add(fac.toString());
          }
        }
      }

      // Handle owner field (can be string ID or object)
      String? ownerId;
      Map<String, dynamic>? ownerData;

      if (json["owner"] != null) {
        if (json["owner"] is String) {
          ownerId = json["owner"];
        } else if (json["owner"] is Map<String, dynamic>) {
          ownerData = json["owner"] as Map<String, dynamic>;
          ownerId = ownerData["_id"] ?? ownerData["id"];
        }
      }

      // ✅ DEBUG: Log hall status from API
      print("Hall status from API: ${json['status']}");

      return HallModel(
        id: json["_id"] ?? "",
        name: json["name"] ?? "",
        location: json["location"] ?? "",
        price: (json["price"] ?? 0).toDouble(),
        images: imagesList,
        facilities: facilitiesList,
        capacity: json["capacity"] ?? 0,
        description: json["description"] ?? "",
        rating: (json["rating"] ?? 0).toDouble(),
        status: json["status"] ?? "pending",
        ownerId: ownerId,
        ownerData: ownerData,
      );
    } catch (e, stackTrace) {
      print("❌ HallModel.fromJson ERROR: $e");
      print("📊 JSON data: $json");
      print("🔴 Stack: $stackTrace");
      rethrow;
    }
  }

  /// Get owner name safely
  String get ownerName => ownerData?["name"] ?? "Unknown Owner";

  /// Get owner email safely
  String get ownerEmail => ownerData?["email"] ?? "";
}
