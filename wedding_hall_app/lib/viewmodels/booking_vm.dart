import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/booking_model.dart';
import '../services/booking_service.dart';

final bookingServiceProvider = Provider((ref) => BookingService());

final bookingProvider = StateNotifierProvider<BookingViewModel, List<dynamic>>(
  (ref) => BookingViewModel(),
);

/// 📅 Provider to fetch booked dates for a specific hall
/// Supports real-time updates by calling refresh() when needed
final bookedDatesProvider = FutureProvider.family<List<DateTime>, String>(
  (ref, hallId) async {
    final bookingService = ref.watch(bookingServiceProvider);
    return bookingService.getBookedDates(hallId);
  },
);

/// ⚡ Refresh booked dates after booking or cancellation
final refreshBookedDatesProvider =
    Provider.autoDispose<Future<void> Function(String)>(
  (ref) {
    return (hallId) async {
      // ignore: unused_result
      ref.refresh(bookedDatesProvider(hallId));
    };
  },
);

/// 👤 Provider for user's bookings
final userBookingsProvider = FutureProvider<List<BookingModel>>(
  (ref) async {
    final bookingService = ref.watch(bookingServiceProvider);
    return bookingService.getUserBookings();
  },
);

class BookingViewModel extends StateNotifier<List<dynamic>> {
  BookingViewModel() : super([]);

  final BookingService _service = BookingService();

  bool isLoading = false;

  // 📅 Load User Bookings
  Future<void> loadUserBookings() async {
    try {
      isLoading = true;

      final data = await _service.getUserBookings();

      state = data;

      isLoading = false;
    } catch (e) {
      isLoading = false;
    }
  }

  // 📅 Create Booking
  Future<String> createBooking(String hallId, String date) async {
    try {
      final result = await _service.createBooking({
        'hallId': hallId,
        'date': date,
      });
      return result['message'] ?? result.toString();
    } catch (e) {
      rethrow;
    }
  }

  // ❌ Cancel Booking
  Future<String> cancelBooking(String bookingId) async {
    try {
      return await _service.cancelBooking(bookingId);
    } catch (e) {
      rethrow;
    }
  }
}
