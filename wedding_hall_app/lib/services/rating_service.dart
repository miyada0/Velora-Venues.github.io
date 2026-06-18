import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'api_service.dart';

class RatingService {
  final api = ApiService();

  /// ======== SUBMIT USER RATING ========
  /// POST /api/ratings/:hallId
  /// Body: { "rating": number }
  /// ✅ Ensures rating is always sent as numeric value
  Future<Map<String, dynamic>> submitRating({
    required String hallId,
    required double rating,
  }) async {
    try {
      // ✅ Ensure rating is double, not string
      final numericRating = double.parse(rating.toString());

      debugPrint(
          "🔵 [RatingService] Submitting rating: $numericRating (type: ${numericRating.runtimeType})");

      final response = await api.dio.post(
        "/ratings/$hallId",
        data: {
          "rating": numericRating, // ✅ Always numeric
        },
      );

      // ✅ Validate response is a Map
      if (response.data is! Map<String, dynamic>) {
        throw Exception("Invalid response format");
      }

      debugPrint("🟢 [RatingService] Response: ${response.data}");
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      debugPrint("🔴 [RatingService] Error: ${e.response?.statusCode}");
      throw Exception(
        "Failed to submit rating: ${e.response?.data?['message'] ?? e.message}",
      );
    }
  }

  /// ======== GET HALL RATING DATA ========
  /// GET /api/ratings/:hallId
  /// ✅ Returns rating as number for safe calculations
  Future<Map<String, dynamic>> getHallRatingData(String hallId) async {
    try {
      final response = await api.dio.get("/ratings/$hallId");

      if (response.data is! Map<String, dynamic>) {
        throw Exception("Invalid response format");
      }

      final data = response.data as Map<String, dynamic>;

      // ✅ Ensure rating in response is numeric
      if (data['rating'] != null) {
        data['rating'] = _parseRatingToDouble(data['rating']);
      }

      return data;
    } on DioException catch (e) {
      throw Exception(
        "Failed to fetch rating data: ${e.response?.data?['message'] ?? e.message}",
      );
    }
  }

  /// ======== GET USER'S RATING FOR HALL ========
  /// GET /api/ratings/:hallId/my-rating
  /// ✅ Safely converts rating from any type to double
  Future<Map<String, dynamic>?> getUserRatingForHall(String hallId) async {
    try {
      final response = await api.dio.get("/ratings/$hallId/my-rating");

      if (response.data is! Map<String, dynamic>) {
        throw Exception("Invalid response format");
      }

      final data = response.data as Map<String, dynamic>;

      // ✅ Ensure rating is always double, regardless of backend format
      if (data['rating'] != null) {
        data['rating'] = _parseRatingToDouble(data['rating']);
      }

      return data;
    } on DioException catch (e) {
      // 404 means user hasn't rated this hall yet - that's ok
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw Exception(
        "Failed to fetch user rating: ${e.response?.data?['message'] ?? e.message}",
      );
    }
  }

  /// ✅ HELPER: Safe rating conversion from any type
  /// Handles: double, int, String, null
  static double _parseRatingToDouble(dynamic value) {
    if (value == null) return 0.0;

    if (value is double) return value;
    if (value is int) return value.toDouble();

    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }

    return 0.0; // Default fallback
  }
}
