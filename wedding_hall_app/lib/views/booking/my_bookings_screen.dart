import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';

import '../../models/booking_model.dart';
import '../../services/booking_service.dart';
import '../../theme/app_theme.dart';
import '../../viewmodels/auth_vm.dart';
import '../auth/login_screen.dart';

class MyBookingsScreen extends ConsumerStatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  ConsumerState<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends ConsumerState<MyBookingsScreen> {
  final BookingService _bookingService = BookingService();

  List<BookingModel> bookings = [];
  bool isLoading = true;
  String? errorMessage;
  bool isUnauthorized = false;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    print("\n🔄 _loadBookings() called");

    setState(() {
      isLoading = true;
      errorMessage = null;
      isUnauthorized = false;
    });

    try {
      print("  Calling _bookingService.getUserBookings()...");
      final data = await _bookingService.getUserBookings();

      print("\n✅ Data received from BookingService:");
      print("  Total bookings: ${data.length}");

      if (mounted) {
        setState(() {
          bookings = data;
          isLoading = false;
          errorMessage = null;
        });
      }
    } catch (e) {
      print("\n❌ Error in _loadBookings():");
      print("  Exception: $e");

      // ✅ FIX: Check if 401 Unauthorized - DON'T auto-redirect
      // Only show message to user
      bool is401 = false;
      if (e is DioException) {
        is401 = e.response?.statusCode == 401;
      }

      if (is401) {
        // ✅ FIX: Don't call handle401 here - just show message
        // The API layer will handle auto-logout if needed
        if (mounted) {
          setState(() {
            isLoading = false;
            errorMessage =
                "Session expired. Please login to view your bookings.";
          });
        }
      } else {
        final errorMsg = e is DioException
            ? (e.response?.data["error"] ??
                e.message ??
                "Failed to load bookings")
            : "Failed to load bookings";

        if (mounted) {
          setState(() {
            isLoading = false;
            errorMessage = errorMsg;
            isUnauthorized = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);

    if (user == null) {
      // ✅ FIX: Show proper login UI instead of plain text
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            "My Bookings",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          backgroundColor: Colors.white,
          foregroundColor: AppTheme.textPrimary,
          elevation: 0,
        ),
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF87CEFA),
                Color(0xFFFFFFFF),
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 24),
                Text(
                  "Please Log In",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Sign in to view your bookings and manage reservations",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () async {
                    // Navigate to login screen
                    final result = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );

                    // If user logged in successfully, reload bookings
                    if (result == true && mounted) {
                      _loadBookings();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppTheme.borderRadiusMedium,
                      ),
                    ),
                  ),
                  child: const Text(
                    "Go to Login",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Bookings",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF87CEFA),
              Color(0xFFFFFFFF),
            ],
          ),
        ),
        child: _buildBody(),
      ),
      floatingActionButton:
          bookings.isNotEmpty && !isLoading && errorMessage == null
              ? FloatingActionButton(
                  onPressed: _loadBookings,
                  backgroundColor: AppTheme.gold,
                  child: const Icon(Icons.refresh, color: Colors.white),
                )
              : null,
    );
  }

  /// Build body based on state
  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              errorMessage ?? "Something went wrong",
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadBookings,
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.gold),
              icon: const Icon(Icons.refresh),
              label: const Text("Retry"),
            ),
          ],
        ),
      );
    }

    if (bookings.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppTheme.lightBeige,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(
                  Icons.calendar_month,
                  size: 50,
                  color: AppTheme.gold,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "No Bookings Yet",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Book your favorite wedding halls\nand track them here",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: bookings.length,
      itemBuilder: (context, index) => _buildBookingCard(bookings[index]),
    );
  }

  /// Build individual booking card
  Widget _buildBookingCard(BookingModel booking) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Hall Name & Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    booking.hallName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: booking.isCancelled
                        ? Colors.red.shade100
                        : booking.paymentStatus == "paid"
                            ? Colors.green.shade100
                            : Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    booking.isCancelled
                        ? "CANCELLED"
                        : booking.paymentStatus.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: booking.isCancelled
                          ? Colors.red.shade700
                          : booking.paymentStatus == "paid"
                              ? Colors.green.shade700
                              : Colors.orange.shade700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            /// Date & Time
            Row(
              children: [
                Icon(Icons.calendar_today,
                    size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(
                  DateFormat("MMM dd, yyyy")
                      .format(DateTime.parse(booking.date)),
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                ),
              ],
            ),
            const SizedBox(height: 8),

            /// Guests
            Row(
              children: [
                Icon(Icons.people, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(
                  "${booking.numberOfGuests} guests",
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                ),
              ],
            ),
            const SizedBox(height: 12),

            /// Amount
            Text(
              "Total: ₹${booking.totalAmount.toStringAsFixed(0)}",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.gold,
              ),
            ),
            const SizedBox(height: 16),

            /// Action Buttons Row
            Row(
              children: [
                /// View Details Button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/booking-details',
                        arguments: booking,
                      );
                    },
                    icon: const Icon(Icons.details),
                    label: const Text("Details"),
                  ),
                ),
                const SizedBox(width: 12),

                /// Cancel Button (only if not already cancelled)
                if (!booking.isCancelled)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showCancelConfirmation(booking),
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text("Cancel"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Show confirmation dialog for cancellation
  void _showCancelConfirmation(BookingModel booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cancel Booking?"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Are you sure you want to cancel this booking?",
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Booking for ${DateFormat("MMM dd").format(DateTime.parse(booking.date))}",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("No, Keep It"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _cancelBooking(booking);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text("Yes, Cancel"),
          ),
        ],
      ),
    );
  }

  /// Actual cancel booking API call
  Future<void> _cancelBooking(BookingModel booking) async {
    print("\n🔄 Cancelling booking: ${booking.id}");

    // Show loading indicator
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Dialog(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text("Cancelling booking..."),
            ],
          ),
        ),
      ),
    );

    try {
      // Call API to cancel booking
      final result = await _bookingService.cancelBooking(booking.id);

      if (!mounted) return;

      // Close loading dialog
      Navigator.pop(context);

      print("✅ Booking cancelled: $result");

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Booking cancelled successfully"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // Refresh bookings list
      await _loadBookings();
    } catch (e) {
      if (!mounted) return;

      // Close loading dialog
      Navigator.pop(context);

      print("❌ Cancel booking error: $e");

      // Show error message
      String errorMsg = e.toString();
      if (errorMsg.contains("Cannot cancel booking within 2 days")) {
        errorMsg = "Cannot cancel booking within 2 days of the event date";
      } else if (errorMsg.contains("Unauthorized")) {
        errorMsg = "You can only cancel your own bookings";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ $errorMsg"),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
