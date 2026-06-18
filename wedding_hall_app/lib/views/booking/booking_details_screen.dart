import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/booking_model.dart';
import '../../services/booking_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/image_utils.dart';

class BookingDetailsScreen extends ConsumerStatefulWidget {
  final BookingModel booking;

  const BookingDetailsScreen({
    required this.booking,
    super.key,
  });

  @override
  ConsumerState<BookingDetailsScreen> createState() =>
      _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends ConsumerState<BookingDetailsScreen> {
  final BookingService _bookingService = BookingService();
  bool _isCancelling = false;
  bool _isLocalCancelled = false;

  @override
  Widget build(BuildContext context) {
    final bookingDate = DateTime.parse(widget.booking.date);
    final now = DateTime.now();
    final isUpcoming = bookingDate.isAfter(now);
    final isCancelled = widget.booking.isCancelled || _isLocalCancelled;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Booking Details",
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Card
              _buildStatusCard(isUpcoming, isCancelled),
              const SizedBox(height: 24),

              // Hall Information
              _buildSectionTitle("Hall Information"),
              _buildHallCard(),
              const SizedBox(height: 24),

              // Booking Details
              _buildSectionTitle("Booking Details"),
              _buildDetailCardField("Booking Date", widget.booking.date),
              _buildDetailCardField(
                "Check-in Time",
                widget.booking.startTime,
              ),
              _buildDetailCardField(
                "Number of Guests",
                "${widget.booking.numberOfGuests} guests",
              ),
              const SizedBox(height: 16),

              // Payment Information
              _buildSectionTitle("Payment Information"),
              _buildDetailCardField(
                  "Total Amount", "₹${widget.booking.amount}"),
              _buildDetailCardField(
                "Advance Paid",
                "₹${widget.booking.advanceAmount}",
              ),
              _buildDetailCardField(
                "Payment Status",
                widget.booking.paymentStatus,
                valueColor:
                    _getPaymentStatusColor(widget.booking.paymentStatus),
              ),
              const SizedBox(height: 16),

              // Special Requests
              if (widget.booking.specialRequests.isNotEmpty) ...[
                _buildSectionTitle("Special Requests"),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(AppTheme.borderRadiusMedium),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Text(
                    widget.booking.specialRequests,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Action Buttons
              if (!isCancelled && isUpcoming)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed:
                        _isCancelling ? null : () => _showCancelConfirmation(),
                    icon: _isCancelling
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.close),
                    label: Text(
                        _isCancelling ? "Cancelling..." : "Cancel Booking"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(bool isUpcoming, bool isCancelled) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (isCancelled) {
      statusColor = Colors.red;
      statusText = "CANCELLED";
      statusIcon = Icons.cancel;
    } else if (isUpcoming) {
      statusColor = Colors.green;
      statusText = "UPCOMING";
      statusIcon = Icons.check_circle;
    } else {
      statusColor = Colors.blue;
      statusText = "COMPLETED";
      statusIcon = Icons.verified;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        border: Border.all(color: statusColor),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 28),
          const SizedBox(width: 12),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHallCard() {
    final hall = widget.booking.hall;
    if (hall == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Text(
          widget.booking.hallName,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          // Hall Image
          if (hall.images.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppTheme.borderRadiusMedium),
                topRight: Radius.circular(AppTheme.borderRadiusMedium),
              ),
              child: Image.network(
                ImageUtils.getImageUrl(hall.images.first),
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 180,
                    color: Colors.grey[300],
                    child: Icon(Icons.broken_image, color: Colors.grey[600]),
                  );
                },
              ),
            ),
          // Hall Details
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hall.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        hall.location,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "₹${hall.price} per day",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildDetailCardField(
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Color _getPaymentStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case "paid":
        return Colors.green;
      case "pending":
        return Colors.orange;
      case "failed":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showCancelConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cancel Booking?"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Are you sure you want to cancel this booking?"),
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
                      "Booking for ${DateFormat("MMM dd").format(DateTime.parse(widget.booking.date))}",
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
              _cancelBooking();
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

  Future<void> _cancelBooking() async {
    setState(() {
      _isCancelling = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Cancelling booking..."),
          ],
        ),
      ),
    );

    try {
      // 🔥 FIX #1: Debug log - API call starting
      print(
          "[CANCEL_BOOKING] Starting cancellation for booking: ${widget.booking.id}");

      final response = await _bookingService.cancelBooking(widget.booking.id);

      // 🔥 FIX #2: Debug log - API response received
      print("[CANCEL_BOOKING] API Response: $response");

      if (mounted) {
        // 🔥 FIX #3: Set cancelled state immediately before closing dialog
        setState(() {
          _isLocalCancelled = true;
        });

        // 🔥 FIX #4: Close loading dialog
        Navigator.pop(context);

        // 🔥 FIX #5: Show success message immediately
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Booking cancelled successfully"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // 🔥 FIX #6: Wait for snackbar to show, then navigate back
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          // 🔥 FIX #7: Pop back to booking history
          Navigator.pop(context);
          print("[CANCEL_BOOKING] Navigation completed");
        }
      }
    } catch (e) {
      // 🔥 FIX #8: Debug log - error occurred
      print("[CANCEL_BOOKING] Error occurred: ${e.toString()}");

      if (mounted) {
        Navigator.pop(context); // Close loading dialog

        String errorMessage = "Failed to cancel booking";

        // 🔥 FIX #9: Extract error message from exception
        final errorStr = e.toString();
        if (errorStr.contains("Cannot cancel booking within 2 days")) {
          errorMessage = "Cannot cancel within 2 days of event date";
        } else if (errorStr.contains("Unauthorized")) {
          errorMessage = "You are not authorized to cancel this booking";
        } else if (errorStr.contains("not found")) {
          errorMessage = "Booking not found";
        } else if (errorStr.contains("Network error") ||
            errorStr.contains("Connection")) {
          errorMessage = "Network error. Please check your connection";
        } else {
          // 🔥 FIX #10: Use original error message
          errorMessage = errorStr.split(": ").length > 1
              ? errorStr.split(": ").last
              : "Failed to cancel booking";
        }

        // 🔥 FIX #11: Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );

        print("[CANCEL_BOOKING] Error message shown: $errorMessage");
      }
    } finally {
      // 🔥 FIX #12: Always reset loading state
      if (mounted) {
        setState(() {
          _isCancelling = false;
        });
        print("[CANCEL_BOOKING] Loading state reset");
      }
    }
  }
}
