// 📊 Analytics Provider - State Management with Riverpod
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wedding_hall_booking_app/services/analyticsService.dart';

class AnalyticsState {
  final List<Map<String, dynamic>> bookingsTrend;
  final List<Map<String, dynamic>> revenueTrend;
  final List<Map<String, dynamic>> topHalls;
  final List<Map<String, dynamic>> ratings;
  final Map<String, dynamic> summary;
  final bool isLoading;
  final String errorMessage;

  AnalyticsState({
    this.bookingsTrend = const [],
    this.revenueTrend = const [],
    this.topHalls = const [],
    this.ratings = const [],
    this.summary = const {
      "totalBookings": 0,
      "totalRevenue": 0,
      "totalHalls": 0,
      "totalUsers": 0,
    },
    this.isLoading = false,
    this.errorMessage = "",
  });

  AnalyticsState copyWith({
    List<Map<String, dynamic>>? bookingsTrend,
    List<Map<String, dynamic>>? revenueTrend,
    List<Map<String, dynamic>>? topHalls,
    List<Map<String, dynamic>>? ratings,
    Map<String, dynamic>? summary,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AnalyticsState(
      bookingsTrend: bookingsTrend ?? this.bookingsTrend,
      revenueTrend: revenueTrend ?? this.revenueTrend,
      topHalls: topHalls ?? this.topHalls,
      ratings: ratings ?? this.ratings,
      summary: summary ?? this.summary,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class AnalyticsNotifier extends StateNotifier<AnalyticsState> {
  AnalyticsNotifier() : super(AnalyticsState());

  // ✅ Load admin analytics
  Future<void> loadAdminAnalytics() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: "");

      final data = await AnalyticsService.getAdminAnalytics();

      state = state.copyWith(
        bookingsTrend:
            List<Map<String, dynamic>>.from(data["bookingsTrend"] ?? []),
        revenueTrend:
            List<Map<String, dynamic>>.from(data["revenueTrend"] ?? []),
        topHalls: List<Map<String, dynamic>>.from(data["topHalls"] ?? []),
        ratings: List<Map<String, dynamic>>.from(data["ratings"] ?? []),
        summary: Map<String, dynamic>.from(data["summary"] ?? {}),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString(),
        isLoading: false,
      );
    }
  }

  // ✅ Load owner analytics
  Future<void> loadOwnerAnalytics(String ownerId) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: "");

      final data = await AnalyticsService.getOwnerAnalytics(ownerId);

      state = state.copyWith(
        bookingsTrend:
            List<Map<String, dynamic>>.from(data["bookingsTrend"] ?? []),
        revenueTrend:
            List<Map<String, dynamic>>.from(data["revenueTrend"] ?? []),
        topHalls: List<Map<String, dynamic>>.from(data["topHalls"] ?? []),
        ratings: List<Map<String, dynamic>>.from(data["ratings"] ?? []),
        summary: Map<String, dynamic>.from(data["summary"] ?? {}),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString(),
        isLoading: false,
      );
    }
  }

  // ✅ Helper to format currency
  String formatCurrency(dynamic amount) {
    if (amount == null) return "₹0";
    final value = amount is int ? amount : int.parse(amount.toString());
    return "₹${value.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}";
  }

  // ✅ Helper to get trend data for charts
  Map<String, dynamic> getTrendChartData() {
    final dates = state.bookingsTrend.map((e) => e['_id']).toList();
    final bookings =
        state.bookingsTrend.map((e) => (e['count'] ?? 0).toDouble()).toList();

    return {
      "dates": dates,
      "bookings": bookings,
    };
  }

  // ✅ Helper to get revenue trend data for charts
  Map<String, dynamic> getRevenueTrendChartData() {
    final months = state.revenueTrend.map((e) => e['_id']).toList();
    final revenues = state.revenueTrend
        .map((e) => (e['totalRevenue'] ?? 0).toDouble())
        .toList();

    return {
      "months": months,
      "revenues": revenues,
    };
  }
}

// ✅ Riverpod Provider
final analyticsProvider =
    StateNotifierProvider<AnalyticsNotifier, AnalyticsState>(
  (ref) => AnalyticsNotifier(),
);
