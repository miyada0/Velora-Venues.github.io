import 'package:flutter/material.dart';
import '../../services/booking_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/invoice_generator.dart';

class BookingSuccessScreen extends StatefulWidget {
  final String bookingId;
  final String hallName;
  final DateTime bookingDate;
  final double totalAmount;
  final double advanceAmount;
  final String customerName;

  const BookingSuccessScreen({
    super.key,
    required this.bookingId,
    required this.hallName,
    required this.bookingDate,
    required this.totalAmount,
    required this.advanceAmount,
    required this.customerName,
  });

  @override
  State<BookingSuccessScreen> createState() => _BookingSuccessScreenState();
}

class _BookingSuccessScreenState extends State<BookingSuccessScreen> {
  final BookingService bookingService = BookingService();
  bool isGeneratingPDF = false;

  Future<void> _downloadInvoice() async {
    setState(() {
      isGeneratingPDF = true;
    });

    try {
      // Fetch full booking details
      final booking = await bookingService.getBookingDetails(widget.bookingId);

      // Generate PDF
      final pdfData = await InvoiceGenerator.generateInvoicePDF(
        bookingId: widget.bookingId,
        customerName: booking.fullName,
        customerEmail: booking.email,
        customerPhone: booking.phone,
        hallName: booking.hallName,
        hallLocation: booking.hall?.location ?? 'N/A',
        bookingDate: widget.bookingDate,
        startTime: booking.startTime,
        endTime: booking.endTime,
        numberOfGuests: booking.numberOfGuests,
        hallPrice: booking.amount,
        totalAmount: booking.totalAmount,
        advanceAmount: booking.advanceAmount,
        eventType: booking.eventType,
        catering: booking.cateringRequired,
        decoration: booking.decorationRequired,
        photography: booking.photographyRequired,
        specialRequests:
            booking.specialRequests.isEmpty ? null : booking.specialRequests,
      );

      if (!mounted) return;

      // Print/Share PDF
      await InvoiceGenerator.printPDF(
        pdfData,
        'Booking_Invoice_${widget.bookingId}.pdf',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invoice downloaded successfully!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error generating invoice: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isGeneratingPDF = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Booking Confirmed"),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
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
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),

                /// SUCCESS ICON
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    size: 60,
                    color: Colors.green.shade700,
                  ),
                ),

                const SizedBox(height: 24),

                /// SUCCESS MESSAGE
                Text(
                  "Booking Successful!",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                Text(
                  "Your booking has been confirmed.",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                /// BOOKING DETAILS CARD
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow(
                        "Booking ID",
                        widget.bookingId,
                        isBold: true,
                        color: AppTheme.gold,
                      ),
                      const SizedBox(height: 16),
                      _buildDetailRow("Hall Name", widget.hallName),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        "Booking Date",
                        "${widget.bookingDate.day}/${widget.bookingDate.month}/${widget.bookingDate.year}",
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow("Guest Name", widget.customerName),
                      const SizedBox(height: 16),
                      const Divider(thickness: 1),
                      const SizedBox(height: 16),
                      _buildDetailRow(
                        "Total Amount",
                        "₹${widget.totalAmount.toStringAsFixed(0)}",
                        color: Colors.green,
                        isBold: true,
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        "Advance Amount (20%)",
                        "₹${widget.advanceAmount.toStringAsFixed(0)}",
                        color: Colors.orange,
                        isBold: true,
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        "Balance Due",
                        "₹${(widget.totalAmount - widget.advanceAmount).toStringAsFixed(0)}",
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                /// INFO CARD
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info,
                            color: Colors.blue.shade700,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "Important Information",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildBulletPoint(
                        "Advance amount is required to confirm your booking",
                      ),
                      _buildBulletPoint(
                        "Remaining balance must be paid 7 days before the event",
                      ),
                      _buildBulletPoint(
                        "A confirmation email will be sent to your registered email address",
                      ),
                      _buildBulletPoint(
                        "For any changes or queries, contact us at least 3 days in advance",
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                /// DOWNLOAD INVOICE BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: isGeneratingPDF ? null : _downloadInvoice,
                    icon: isGeneratingPDF
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.download, size: 24),
                    label: Text(
                      isGeneratingPDF
                          ? "Generating Invoice..."
                          : "Download Invoice (PDF)",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.gold,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                /// CONTINUE SHOPPING BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context)
                          .pushNamedAndRemoveUntil('/', (route) => false);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.gold,
                      side: const BorderSide(color: AppTheme.gold, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Continue Shopping",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build detail row widget
  Widget _buildDetailRow(
    String label,
    String value, {
    Color? color,
    bool isBold = false,
  }) {
    return Row(
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
            fontSize: 15,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: color ?? Colors.black,
          ),
        ),
      ],
    );
  }

  /// Build bullet point
  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6, right: 12),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.blue.shade700,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Colors.blue.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
