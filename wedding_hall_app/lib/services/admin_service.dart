import 'package:wedding_hall_booking_app/models/admin_stats_model.dart';
import 'package:wedding_hall_booking_app/models/booking_model.dart';
import 'package:wedding_hall_booking_app/models/hall_model.dart';
import 'package:wedding_hall_booking_app/models/user_model.dart';
import 'api_service.dart';

class AdminService {
  final api = ApiService();

  /// Get Admin Statistics
  Future<AdminStatsModel> getStats() async {
    try {
      final res = await api.dio.get("/admin/stats");
      return AdminStatsModel.fromJson(res.data);
    } catch (e) {
      throw Exception("Failed to fetch stats: $e");
    }
  }

  /// Get All Halls
  Future<List<HallModel>> getAllHalls() async {
    try {
      final res = await api.dio.get("/admin/halls");
      final data = res.data as List<dynamic>;
      return data.map((hall) => HallModel.fromJson(hall)).toList();
    } catch (e) {
      throw Exception("Failed to fetch halls: $e");
    }
  }

  /// Get Pending Halls
  Future<List<HallModel>> getPendingHalls() async {
    try {
      final res = await api.dio.get("/admin/pending-halls");
      final data = res.data as List<dynamic>;
      return data.map((hall) => HallModel.fromJson(hall)).toList();
    } catch (e) {
      throw Exception("Failed to fetch pending halls: $e");
    }
  }

  /// Approve Hall
  Future<HallModel> approveHall(String hallId) async {
    try {
      final res = await api.dio.put("/admin/approve/$hallId");
      return HallModel.fromJson(res.data['hall']);
    } catch (e) {
      throw Exception("Failed to approve hall: $e");
    }
  }

  /// Reject Hall
  Future<HallModel> rejectHall(String hallId) async {
    try {
      final res = await api.dio.put("/admin/reject/$hallId");
      return HallModel.fromJson(res.data['hall']);
    } catch (e) {
      throw Exception("Failed to reject hall: $e");
    }
  }

  /// Get All Users
  Future<List<UserModel>> getAllUsers() async {
    try {
      final res = await api.dio.get("/admin/users");
      final data = res.data as List<dynamic>;
      return data.map((user) => UserModel.fromJson(user)).toList();
    } catch (e) {
      throw Exception("Failed to fetch users: $e");
    }
  }

  /// Delete User
  Future<UserModel> deleteUser(String userId) async {
    try {
      final res = await api.dio.delete("/admin/user/$userId");
      return UserModel.fromJson(res.data['user']);
    } catch (e) {
      throw Exception("Failed to delete user: $e");
    }
  }

  /// Get All Bookings
  Future<List<BookingModel>> getAllBookings() async {
    try {
      final res = await api.dio.get("/admin/bookings");
      final data = res.data as List<dynamic>;
      return data.map((booking) => BookingModel.fromJson(booking)).toList();
    } catch (e) {
      throw Exception("Failed to fetch bookings: $e");
    }
  }

  /// ✅ FIX #3: Delete Hall (Admin Only)
  Future<String> deleteHall(String hallId) async {
    try {
      final res = await api.dio.delete("/admin/halls/$hallId");
      return res.data["message"] ?? "Hall deleted successfully";
    } catch (e) {
      throw Exception("Failed to delete hall: $e");
    }
  }
}
