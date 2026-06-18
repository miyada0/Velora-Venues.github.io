import 'api_service.dart';
import '../models/booking_model.dart';
import '../models/hall_model.dart';

class OwnerService {
  final ApiService api = ApiService();

  /* ================= OWNER DASHBOARD STATS ================= */

  Future<Map<String, dynamic>> getOwnerStats() async {
    final res = await api.dio.get("/bookings/owner/stats");
    return res.data;
  }

  /* ================= GET SINGLE HALL STATS ================= */

  Future<Map<String, dynamic>> getHallStats(String hallId) async {
    final res = await api.dio.get("/halls/owner/stats/$hallId");
    return res.data;
  }

  /* ================= OWNER BOOKINGS ================= */

  Future<List<BookingModel>> getOwnerBookings() async {
    final res = await api.dio.get("/bookings/owner");
    return (res.data as List)
        .map((e) => BookingModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /* ================= GET OWNER HALLS ================= */

  Future<List<HallModel>> getMyHalls() async {
    try {
      print("\n🏢 OwnerService: Fetching owner halls...");
      final res = await api.dio.get("/halls/owner/halls");

      final data = res.data;

      print("✅ Owner halls received: ${data.length} halls");

      if (data is List) {
        return data
            .map((e) => HallModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      print("❌ Error fetching owner halls: $e");
      rethrow;
    }
  }

  /* ================= GET OWNER HALL (deprecated - returns Map for backward compatibility) ================= */

  Future<Map<String, dynamic>> getMyHall() async {
    final res = await api.dio.get("/halls/owner/my-hall");
    return res.data;
  }

  /* ================= GET SINGLE HALL BY ID ================= */

  Future<HallModel> getHallById(String hallId) async {
    try {
      final res = await api.dio.get("/halls/$hallId");
      return HallModel.fromJson(res.data);
    } catch (e) {
      print("GET HALL BY ID ERROR: $e");
      throw Exception("Failed to load hall details");
    }
  }

  /* ================= UPDATE HALL ================= */

  Future<String> updateHall(String hallId, Map<String, dynamic> data) async {
    final res = await api.dio.put(
      "/halls/$hallId",
      data: data,
    );
    return res.data["name"] ?? "Updated";
  }

  /* ================= DELETE HALL ================= */

  Future<String> deleteHall(String hallId) async {
    final res = await api.dio.delete("/halls/$hallId");
    return res.data["message"] ?? "Hall deleted";
  }

  /* ================= REPLY TO REVIEW ================= */

  Future<String> replyToReview(String reviewId, String message) async {
    final res = await api.dio.put(
      "/reviews/reply/$reviewId",
      data: {"message": message},
    );
    return res.data["message"] ?? "Reply added";
  }
}
