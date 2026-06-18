import 'api_service.dart';
import '../models/hall_model.dart';

class HallService {
  final api = ApiService();

  /* ================= GET HALLS ================= */

  Future<List<HallModel>> getHalls({
    List<String>? locations,
    double? minPrice,
    double? maxPrice,
    double? minCapacity,
    double? maxCapacity,
    double? minRating,
    double? maxRating,
    List<String>? facilities,
    String? sort,
    String? search,
  }) async {
    try {
      final query = {
        if (locations != null && locations.isNotEmpty)
          "locations": locations.join(","),
        if (minPrice != null) "minPrice": minPrice.toString(),
        if (maxPrice != null) "maxPrice": maxPrice.toString(),
        if (minCapacity != null) "minCapacity": minCapacity.toString(),
        if (maxCapacity != null) "maxCapacity": maxCapacity.toString(),
        if (minRating != null) "minRating": minRating.toString(),
        if (maxRating != null) "maxRating": maxRating.toString(),
        if (facilities != null && facilities.isNotEmpty)
          "facilities": facilities.join(","),
        if (sort != null) "sort": sort,
        if (search != null) "search": search,
      };

      final res = await api.dio.get(
        "/halls",
        queryParameters: query,
      );

      final data = res.data;

      if (data is List) {
        print("🏛️ Fetched ${data.length} halls from API");
        final halls = data.map((e) {
          final hall = HallModel.fromJson(e);
          print("   Hall: ${hall.name}, Status: ${hall.status}");
          return hall;
        }).toList();
        return halls;
      }

      return [];
    } catch (e) {
      print("HALL ERROR: $e");
      throw Exception("Failed to load halls");
    }
  }

  /* ================= REGISTER HALL ================= */

  Future<String> registerHall(Map<String, dynamic> data) async {
    try {
      final res = await api.dio.post(
        "/halls",
        data: data,
      );

      return res.data["name"] ?? "Hall";
    } catch (e) {
      print("REGISTER HALL ERROR: $e");
      throw Exception("Failed to register hall");
    }
  }

  /* ================= GET MY HALLS ================= */

  Future<List<HallModel>> getMyHalls() async {
    try {
      final res = await api.dio.get("/halls/owner/halls");

      final data = res.data;

      if (data is List) {
        print("🏛️ Fetched ${data.length} MY halls");
        final halls = data.map((e) {
          final hall = HallModel.fromJson(e);
          print("   MY Hall: ${hall.name}, Status: ${hall.status}");
          return hall;
        }).toList();
        return halls;
      }

      return [];
    } catch (e) {
      print("GET MY HALLS ERROR: $e");
      throw Exception("Failed to load your halls");
    }
  }

  /* ================= GET OWNER HALLS (Endpoint: /halls/my) ================= */
  // ✅ FIX #2: New method that calls the /halls/my endpoint
  Future<List<HallModel>> getOwnerHalls() async {
    try {
      final res = await api.dio.get("/halls/my");

      final data = res.data;

      if (data is List) {
        print("🏛️ Fetched ${data.length} OWNER halls");
        final halls = data.map((e) {
          final hall = HallModel.fromJson(e);
          print("   OWNER Hall: ${hall.name}, Status: ${hall.status}");
          return hall;
        }).toList();
        return halls;
      }

      return [];
    } catch (e) {
      print("GET OWNER HALLS ERROR: $e");
      throw Exception("Failed to load your halls: ${e.toString()}");
    }
  }

  /* ================= DELETE HALL ================= */

  /// ✅ FIX #3: Deletes a hall (admin only)
  Future<String> deleteHall(String hallId) async {
    try {
      final res = await api.dio.delete("/admin/halls/$hallId");
      return res.data["message"] ?? "Hall deleted successfully";
    } catch (e) {
      print("DELETE HALL ERROR: $e");
      throw Exception("Failed to delete hall: $e");
    }
  }
}
