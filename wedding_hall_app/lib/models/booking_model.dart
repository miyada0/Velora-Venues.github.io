import 'package:wedding_hall_booking_app/models/hall_model.dart';

class BookingModel {
  final String id;
  final String date;
  final String hallName;
  final String hallId;
  final String userId;
  final double amount;
  final bool isCancelled;
  final String paymentStatus;
  final DateTime createdAt;
  final HallModel? hall;
  final Map<String, dynamic>? user;

  // NEW BOOKING FORM FIELDS
  final String fullName;
  final String phone;
  final String email;
  final String eventType;
  final String startTime;
  final String endTime;
  final int numberOfGuests;
  final double totalAmount;
  final double advanceAmount;
  final String specialRequests;
  final bool cateringRequired;
  final bool decorationRequired;
  final bool photographyRequired;
  final String bookingStatus;
  final String adminApproval;
  final String paymentMethod;

  BookingModel({
    required this.id,
    required this.date,
    required this.hallName,
    required this.hallId,
    required this.userId,
    required this.amount,
    required this.isCancelled,
    required this.paymentStatus,
    required this.createdAt,
    this.hall,
    this.user,
    required this.fullName,
    required this.phone,
    required this.email,
    required this.eventType,
    required this.startTime,
    required this.endTime,
    required this.numberOfGuests,
    required this.totalAmount,
    required this.advanceAmount,
    required this.specialRequests,
    required this.cateringRequired,
    required this.decorationRequired,
    required this.photographyRequired,
    required this.bookingStatus,
    required this.adminApproval,
    required this.paymentMethod,
  });

  factory BookingModel.fromJson(Map<String, dynamic> j) {
    try {
      /// ✅ SAFE HALL PARSING
      HallModel? hallModel;
      if (j['hall'] != null && j['hall'] is Map<String, dynamic>) {
        hallModel = HallModel.fromJson(j['hall'] as Map<String, dynamic>);
      }

      /// ✅ FIX: USER CAN BE STRING OR OBJECT
      String userId = "";
      Map<String, dynamic>? userObj;
      if (j['user'] is String) {
        userId = j['user'];
      } else if (j['user'] is Map<String, dynamic>) {
        userObj = j['user'] as Map<String, dynamic>;
        userId = j['user']['_id'] ?? "";
      }

      /// ✅ FIX: HALL SAFE ACCESS
      String hallName = "Unknown Hall";
      String hallId = "";

      if (j['hall'] is Map<String, dynamic>) {
        hallName = j['hall']['name'] ?? "Unknown Hall";
        hallId = j['hall']['_id'] ?? "";
      } else {
        hallId = j['hallId'] ?? "";
      }

      return BookingModel(
        id: j['_id'] ?? '',
        date: j['date'] ?? '',
        hallName: hallName,
        hallId: hallId,
        userId: userId,
        amount: (j['amount'] is int)
            ? (j['amount'] as int).toDouble()
            : double.tryParse(j['amount'].toString()) ?? 0.0,
        isCancelled: j['isCancelled'] ?? false,
        paymentStatus: j['paymentStatus'] ?? 'pending',
        createdAt: j['createdAt'] != null
            ? DateTime.parse(j['createdAt'])
            : DateTime.now(),
        hall: hallModel,
        user: userObj,
        // NEW FIELDS
        fullName: j['fullName'] ?? '',
        phone: j['phone'] ?? '',
        email: j['email'] ?? '',
        eventType: j['eventType'] ?? 'wedding',
        startTime: j['startTime'] ?? '',
        endTime: j['endTime'] ?? '',
        numberOfGuests: j['numberOfGuests'] ?? 0,
        totalAmount: (j['totalAmount'] is int)
            ? (j['totalAmount'] as int).toDouble()
            : double.tryParse(j['totalAmount'].toString()) ?? 0.0,
        advanceAmount: (j['advanceAmount'] is int)
            ? (j['advanceAmount'] as int).toDouble()
            : double.tryParse(j['advanceAmount'].toString()) ?? 0.0,
        specialRequests: j['specialRequests'] ?? '',
        cateringRequired: j['cateringRequired'] ?? false,
        decorationRequired: j['decorationRequired'] ?? false,
        photographyRequired: j['photographyRequired'] ?? false,
        bookingStatus: j['bookingStatus'] ?? 'confirmed',
        adminApproval: j['adminApproval'] ?? 'pending',
        paymentMethod: j['paymentMethod'] ?? 'card',
      );
    } catch (e, stackTrace) {
      print("❌ BookingModel.fromJson ERROR: $e");
      print("📊 JSON data: $j");
      print("🔴 Stack: $stackTrace");
      rethrow;
    }
  }

  /// Check if booking is on a specific date
  bool isOnDate(DateTime compareDate) {
    final bookingDate = DateTime.parse(date);
    return bookingDate.year == compareDate.year &&
        bookingDate.month == compareDate.month &&
        bookingDate.day == compareDate.day;
  }

  /// Check if booking is active
  bool isActive() {
    return !isCancelled && DateTime.parse(date).isAfter(DateTime.now());
  }

  /// Get user name safely
  String get userName => user?["name"] ?? "Unknown User";

  /// Get user email safely
  String get userEmail => user?["email"] ?? "";
}
