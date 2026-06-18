// 📊 Analytics Service - Handles API calls for analytics data
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AnalyticsService {
  static const String baseUrl = "http://192.168.243.148:5000/api/analytics";

  // ✅ Get admin analytics data (all system data)
  static Future<Map<String, dynamic>> getAdminAnalytics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";

      final response = await http.get(
        Uri.parse("$baseUrl/admin"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["data"];
      } else {
        throw "Failed to fetch admin analytics";
      }
    } catch (e) {
      throw "Error: $e";
    }
  }

  // ✅ Get owner analytics data (only their halls)
  static Future<Map<String, dynamic>> getOwnerAnalytics(String ownerId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";

      final response = await http.get(
        Uri.parse("$baseUrl/owner/$ownerId"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["data"];
      } else {
        throw "Failed to fetch owner analytics";
      }
    } catch (e) {
      throw "Error: $e";
    }
  }
}
