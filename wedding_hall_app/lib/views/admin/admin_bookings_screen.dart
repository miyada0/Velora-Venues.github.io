import 'package:flutter/material.dart';
import '../../models/booking_model.dart';
import '../../services/admin_service.dart';

class AdminBookingsScreen extends StatefulWidget {
  const AdminBookingsScreen({super.key});

  @override
  State<AdminBookingsScreen> createState() => _AdminBookingsScreenState();
}

class _AdminBookingsScreenState extends State<AdminBookingsScreen> {
  final AdminService service = AdminService();
  late Future<List<BookingModel>> bookingsFuture;

  @override
  void initState() {
    super.initState();
    bookingsFuture = service.getAllBookings();
  }

  Future<void> _refreshBookings() async {
    setState(() {
      bookingsFuture = service.getAllBookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Bookings"),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshBookings,
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _refreshBookings,
        child: FutureBuilder<List<BookingModel>>(
          future: bookingsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline,
                        size: 50, color: Colors.red.shade600),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "Error: ${snapshot.error}",
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _refreshBookings,
                      child: const Text("Retry"),
                    ),
                  ],
                ),
              );
            }

            final bookings = snapshot.data ?? [];

            if (bookings.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_bag, size: 60, color: Colors.grey),
                    SizedBox(height: 16),
                    Text("No bookings found"),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// HALL NAME
                        Text(
                          booking.hall?.name ?? "Unknown Hall",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        /// USER NAME - FIXED (using getter)
                        Text(
                          "User: ${booking.userName}",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 6),

                        /// USER EMAIL
                        if (booking.userEmail.isNotEmpty)
                          Text(
                            "Email: ${booking.userEmail}",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),

                        const SizedBox(height: 8),

                        /// DATE
                        Text(
                          "Date: ${booking.date}",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),

                        const SizedBox(height: 6),

                        /// AMOUNT
                        Text(
                          "Amount: ₹${booking.amount.toStringAsFixed(0)}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),

                        const SizedBox(height: 6),

                        /// STATUS
                        Text(
                          booking.isCancelled == true
                              ? "Status: Cancelled"
                              : "Status: Active",
                          style: TextStyle(
                            color: booking.isCancelled == true
                                ? Colors.red
                                : Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        /// PAYMENT STATUS BADGE
                        Chip(
                          label: Text(
                            "Payment: ${booking.paymentStatus.toUpperCase()}",
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: booking.paymentStatus == "paid"
                              ? Colors.green
                              : booking.paymentStatus == "failed"
                                  ? Colors.red
                                  : Colors.orange,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
