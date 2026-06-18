import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../../services/api_service.dart';
import '../../services/safe_api.dart';
import '../../viewmodels/auth_vm.dart';
import '../../models/booking_model.dart';
import '../auth/login_screen.dart';

class BookingHistoryScreen extends ConsumerStatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  ConsumerState<BookingHistoryScreen> createState() =>
      _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends ConsumerState<BookingHistoryScreen> {
  List<BookingModel> bookings = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadBookings();
  }

  Future loadBookings() async {
    final authState = ref.read(authProvider);

    if (authState == null) {
      setState(() => loading = false);
      return;
    }

    try {
      final api = ApiService();

      final res = await api.dio.get("/bookings/user");

      if (mounted) {
        setState(() {
          bookings = (res.data as List)
              .map((e) => BookingModel.fromJson(e as Map<String, dynamic>))
              .toList();
          loading = false;
          error = null;
        });
      }
    } catch (e) {
      if (!mounted) return;

      // ✅ FIX: Check if 401 Unauthorized
      bool is401 = false;
      if (e is DioException) {
        is401 = e.response?.statusCode == 401;
      }

      if (is401) {
        SafeApi.handle401(context, ref);
      } else {
        final errorMsg = e is DioException
            ? (e.response?.data["error"] ??
                e.message ??
                "Failed to load bookings")
            : "Failed to load bookings";

        setState(() {
          error = errorMsg;
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    if (authState == null) {
      return Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const LoginScreen(),
                ),
              );
            },
            child: const Text("Login to View Bookings"),
          ),
        ),
      );
    }

    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("My Bookings"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 60, color: Colors.red.shade400),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  error ?? "Something went wrong",
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    loading = true;
                    error = null;
                  });
                  loadBookings();
                },
                icon: const Icon(Icons.refresh),
                label: const Text("Try Again"),
              ),
            ],
          ),
        ),
      );
    }

    if (bookings.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text("No bookings yet"),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Bookings"),
      ),
      body: ListView.builder(
        itemCount: bookings.length,
        itemBuilder: (_, i) {
          final booking = bookings[i];

          // Determine status based on isCancelled and booking date
          final bookingDate = DateTime.parse(booking.date);
          final isUpcoming = bookingDate.isAfter(DateTime.now());
          final status = booking.isCancelled
              ? "Cancelled"
              : (isUpcoming ? "Upcoming" : "Completed");

          return Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              title: Text(booking.hallName),
              subtitle: Text("Date: ${booking.date.substring(0, 10)}"),
              trailing: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: status == "Upcoming"
                      ? Colors.green.shade100
                      : status == "Cancelled"
                          ? Colors.red.shade100
                          : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: status == "Upcoming"
                        ? Colors.green
                        : status == "Cancelled"
                            ? Colors.red
                            : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
