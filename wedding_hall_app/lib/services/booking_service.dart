import 'package:dio/dio.dart';
import 'api_service.dart';
import '../models/booking_model.dart';

class BookingService {
  final api = ApiService();

  /// Utility: Check if date is in booked dates list
  bool isDateBooked(DateTime date, List<DateTime> bookedDates) {
    return bookedDates.any((d) =>
        d.year == date.year && d.month == date.month && d.day == date.day);
  }

  /// Utility: Get formatted date string
  String formatDate(DateTime date) {
    return date.toIso8601String().split('T')[0];
  }

  /// Utility: Compare two dates (ignore time)
  bool isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  /// ============ CREATE BOOKING ============
  /// Creates a new booking with complete form data
  Future<Map<String, dynamic>> createBooking(
    Map<String, dynamic> bookingData,
  ) async {
    try {
      final res = await api.dio.post(
        "/bookings",
        data: bookingData,
      );

      return {
        "bookingId": res.data["bookingId"] ?? res.data["booking"]?["_id"],
        "message": res.data["message"] ?? "Booking successful",
      };
    } on Exception catch (e) {
      if (e.toString().contains("already booked")) {
        throw Exception(
            "This date is already booked. Please select another date.");
      }
      rethrow;
    }
  }

  /// ============ VERIFY PAYMENT ============
  /// ✅ Verifies payment with backend after Razorpay success
  /// Validates payment and updates booking status
  Future<Map<String, dynamic>> verifyPayment({
    required String bookingId,
    required String paymentId,
    required String orderId,
    required String signature,
  }) async {
    try {
      print("🔐 Verifying payment for booking: $bookingId");
      print("   Payment ID: $paymentId");
      print("   Order ID: $orderId");

      final res = await api.dio.post(
        "/bookings/$bookingId/verify-payment",
        data: {
          "bookingId": bookingId,
          "paymentId": paymentId,
          "orderId": orderId,
          "signature": signature,
        },
      );

      print("✅ Payment verification response: ${res.data}");

      return {
        "success": res.data["success"] ?? true,
        "message": res.data["message"] ?? "Payment verified successfully",
        "booking": res.data["booking"],
      };
    } on DioException catch (e) {
      print("❌ Payment verification error: ${e.response?.data}");

      if (e.response != null) {
        final errorMsg = e.response!.data["message"] ??
            e.response!.data["error"] ??
            "Payment verification failed";
        return {
          "success": false,
          "message": errorMsg,
        };
      }

      return {
        "success": false,
        "message": "Network error: ${e.message}",
      };
    } catch (e) {
      print("❌ Unexpected error during payment verification: $e");
      return {
        "success": false,
        "message": "Payment verification failed: $e",
      };
    }
  }

  /// ============ GET BOOKING DETAILS ============
  /// Fetches detailed information for a specific booking
  Future<BookingModel> getBookingDetails(String bookingId) async {
    try {
      final res = await api.dio.get("/bookings/$bookingId");
      return BookingModel.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception("Failed to fetch booking details: $e");
    }
  }

  /// ============ LEGACY CREATE BOOKING ============
  /// Creates a simple booking (legacy method - kept for backward compatibility)
  @deprecated
  Future<String> createSimpleBooking(String hallId, String date) async {
    try {
      final parseDate = DateTime.parse(date);

      // Validate date is not in past
      if (parseDate.isBefore(DateTime.now())) {
        throw Exception("Cannot book for past dates");
      }

      final res = await api.dio.post(
        "/bookings",
        data: {
          "hallId": hallId,
          "date": date,
        },
      );

      return res.data["message"] ?? "Booking successful";
    } on Exception catch (e) {
      if (e.toString().contains("already booked")) {
        throw Exception(
            "This date is already booked. Please select another date.");
      }
      rethrow;
    }
  }

  /// ============ FETCH USER BOOKINGS ============
  /// Gets all bookings for the currently logged-in user
  Future<List<BookingModel>> getUserBookings() async {
    try {
      print("\n========== 🔍 BOOKING DEBUG START ==========");

      // 🔥 DEBUG 1: Check token
      final token = api.dio.options.headers['Authorization'];
      print("📋 Step 1: Check Token");
      print("  🔐 Authorization Header: $token");
      print("  ✓ Token Present: ${token != null && token.isNotEmpty}");

      if (token == null || token.isEmpty) {
        print("  ❌ CRITICAL: No authorization token found!");
        print("  💡 Solution: Make sure user is logged in and token is saved");
        throw Exception("No authorization token - user not authenticated");
      }

      // 🔥 DEBUG 2: API Call Details
      print("\n📋 Step 2: API Call Details");
      print("  📡 Endpoint: /bookings/user");
      print("  🔐 Auth Header: Bearer [${token.substring(token.length - 20)}]");
      print("  ⏳ Sending request...");

      final res = await api.dio.get("/bookings/user");

      // 🔥 DEBUG 3: Response Details
      print("\n📋 Step 3: Response Received");
      print("  ✅ Status Code: ${res.statusCode}");
      print("  📦 Response Type: ${res.data.runtimeType}");
      print("  📊 Response Body: ${res.data}");

      if (res.statusCode != 200) {
        print("  ⚠️ Unexpected status code: ${res.statusCode}");
      }

      if (res.data == null) {
        print("  ❌ Response data is null!");
        return [];
      }

      // 🔥 DEBUG 4: Parse Response
      print("\n📋 Step 4: Parse Response");

      final List<dynamic> data = res.data as List<dynamic>;
      print("  📊 Array Length: ${data.length}");
      print("  📋 Is Empty: ${data.isEmpty}");

      if (data.isEmpty) {
        print("  ⚠️ No bookings found in response");
        print("  💡 Check: Does user have any bookings in database?");
        return [];
      }

      // 🔥 DEBUG 5: Map Bookings
      print("\n📋 Step 5: Map Bookings");
      print("  🔄 Mapping ${data.length} booking(s)...");

      final bookings = <BookingModel>[];
      for (int i = 0; i < data.length; i++) {
        try {
          print("  • Booking $i:");
          final booking =
              BookingModel.fromJson(data[i] as Map<String, dynamic>);
          // Only include non-cancelled bookings
          if (!booking.isCancelled) {
            bookings.add(booking);
            print(
                "    ✅ Mapped: ID=${booking.id}, Hall=${booking.hallName}, Hall Model: ${booking.hall != null ? 'PRESENT' : 'NULL'}");
          } else {
            print(
                "    ⏭️  Skipped (cancelled): ID=${booking.id}, Hall=${booking.hallName}");
          }
        } catch (mapError, stackTrace) {
          print("    ❌ Error mapping booking $i: $mapError");
          print("    📋 Hall name: ${data[i]['hall']?['name'] ?? 'N/A'}");
          print("    🔴 Stack: $stackTrace");
        }
      }

      // 🔥 DEBUG 6: Final Summary
      print("\n📋 Step 6: Final Summary");
      print("  ✅ Successfully mapped ${bookings.length} bookings");

      for (var b in bookings) {
        print("    • ${b.hallName} (ID: ${b.id})");
        print("      Date: ${b.date}");
        print("      Amount: ₹${b.amount}");
        print("      Hall Data: ${b.hall != null ? 'YES' : 'NO (⚠️ Missing)'}");
      }

      print("\n========== ✅ BOOKING DEBUG END ==========\n");
      return bookings;
    } catch (e) {
      print("\n========== ❌ BOOKING FETCH ERROR ==========");
      print("Exception: $e");
      print("Type: ${e.runtimeType}");
      print("Stack Trace: ${StackTrace.current}");
      print("==========================================\n");
      rethrow;
    }
  }

  /// ============ GET ALL BOOKINGS (ADMIN) ============
  /// Gets all bookings in the system (admin only)
  Future<List<BookingModel>> getAllBookings() async {
    try {
      final res = await api.dio.get("/admin/bookings");
      final List<dynamic> data = res.data;
      return data
          .map((e) => BookingModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception("Failed to fetch all bookings: $e");
    }
  }

  /// ============ CANCEL BOOKING ============
  /// ✅ FIX #1: Cancels a booking with proper error handling for 2-day rule
  Future<String> cancelBooking(String bookingId) async {
    try {
      final res = await api.dio.put(
        "/bookings/cancel/$bookingId",
      );

      return res.data["message"] ?? "Booking cancelled successfully";
    } on DioException catch (e) {
      // ✅ FIX #1: Handle DioException properly
      if (e.response != null) {
        final message =
            e.response!.data["message"] ?? e.response!.data["error"];
        throw Exception(message ?? "Failed to cancel booking");
      }
      throw Exception("Network error: ${e.message}");
    } catch (e) {
      throw Exception("Failed to cancel booking: $e");
    }
  }

  /// ============ GET OWNER'S HALL BOOKINGS ============
  /// ✅ FIX #3: Fetches bookings and stats for a specific hall owner
  Future<Map<String, dynamic>> getOwnerHallBookings(String hallId) async {
    try {
      final res = await api.dio.get(
        "/bookings/owner/hall/$hallId",
      );

      // Parse bookings list
      final bookingsList = (res.data['bookings'] as List?)
              ?.map((b) => BookingModel.fromJson(b as Map<String, dynamic>))
              .toList() ??
          [];

      return {
        'bookings': bookingsList,
        'stats': res.data['stats'] ??
            {
              'totalBookings': 0,
              'activeBookings': 0,
              'totalRevenue': 0,
            }
      };
    } catch (e) {
      throw Exception("Failed to fetch hall bookings: $e");
    }
  }

  /// ============ GET BOOKED DATES ============
  /// Fetches all booked dates for a specific hall
  /// Returns a list of DateTime objects representing booked/unavailable dates
  Future<List<DateTime>> getBookedDates(String hallId) async {
    try {
      final res = await api.dio.get(
        "/bookings/hall/$hallId/booked-dates",
      );

      if (res.data == null || res.data is! List) {
        return [];
      }

      return (res.data as List)
          .map((e) {
            try {
              return DateTime.parse(e.toString());
            } catch (e) {
              return null;
            }
          })
          .whereType<DateTime>()
          .toList();
    } catch (e) {
      throw Exception("Failed to fetch booked dates: $e");
    }
  }

  /// ============ CHECK IF DATE IS AVAILABLE ============
  /// Returns true if the date is available for booking
  Future<bool> isDateAvailable(String hallId, DateTime date) async {
    try {
      final bookedDates = await getBookedDates(hallId);
      return !isDateBooked(date, bookedDates);
    } catch (e) {
      return false;
    }
  }

  /// ============ GET OWNER DASHBOARD ============
  /// ✅ FIX #2: Fetches dashboard data for owner (total halls, bookings, revenue)
  Future<Map<String, dynamic>> getOwnerDashboard() async {
    try {
      final res = await api.dio.get("/admin/owner/dashboard");

      return {
        'totalHalls': res.data['totalHalls'] ?? 0,
        'totalBookings': res.data['totalBookings'] ?? 0,
        'activeBookings': res.data['activeBookings'] ?? 0,
        'totalRevenue': res.data['totalRevenue'] ?? 0,
      };
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
            e.response!.data["message"] ?? "Failed to load dashboard");
      }
      throw Exception("Network error: ${e.message}");
    } catch (e) {
      throw Exception("Failed to load dashboard: $e");
    }
  }
}
