import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/booking_service.dart';
import '../../models/booking_model.dart';
import '../../theme/app_theme.dart';

class HallStatsScreen extends ConsumerStatefulWidget {
  final String hallId;

  const HallStatsScreen({required this.hallId, super.key});

  @override
  ConsumerState<HallStatsScreen> createState() => _HallStatsScreenState();
}

class _HallStatsScreenState extends ConsumerState<HallStatsScreen> {
  final BookingService _bookingService = BookingService();
  List<BookingModel> _bookings = [];
  Map<String, dynamic>? _stats;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHallBookings();
  }

  /// ✅ FIX #3: Load owner's hall bookings and stats from backend
  Future<void> _loadHallBookings() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Call the backend endpoint: GET /bookings/owner/hall/:hallId
      final response =
          await _bookingService.getOwnerHallBookings(widget.hallId);

      if (mounted) {
        setState(() {
          _bookings = response['bookings'] ?? [];
          _stats = response['stats'] ?? {};
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = "Failed to load booking stats: ${e.toString()}";
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Hall Statistics",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loadHallBookings,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      backgroundColor: AppTheme.lightBg,
      body: _buildBody(),
    );
  }

  /// Build the body based on state
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              _error ?? "Something went wrong",
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadHallBookings,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
              ),
              icon: const Icon(Icons.refresh),
              label: const Text("Try Again"),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ STATS CARDS
          _buildStatsSection(),
          const SizedBox(height: 28),

          // ✅ BOOKINGS LIST
          const Text(
            "Recent Bookings",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          if (_bookings.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Column(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 60, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      "No bookings yet",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _bookings.length,
              itemBuilder: (context, index) {
                return _buildBookingCard(_bookings[index]);
              },
            ),
        ],
      ),
    );
  }

  /// Build stats section
  Widget _buildStatsSection() {
    final stats = _stats ?? {};
    final totalBookings = stats['totalBookings'] ?? 0;
    final activeBookings = stats['activeBookings'] ?? 0;
    final totalRevenue = stats['totalRevenue'] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Overview",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.0,
          children: [
            _buildStatCard(
              icon: Icons.calendar_today,
              label: "Total Bookings",
              value: totalBookings.toString(),
              color: Colors.blue,
            ),
            _buildStatCard(
              icon: Icons.check_circle,
              label: "Active",
              value: activeBookings.toString(),
              color: Colors.green,
            ),
            _buildStatCard(
              icon: Icons.trending_up,
              label: "Revenue",
              value: "₹${totalRevenue.toStringAsFixed(0)}",
              color: AppTheme.primary,
            ),
            _buildStatCard(
              icon: Icons.percent,
              label: "Occupancy",
              value:
                  "${((activeBookings / (totalBookings > 0 ? totalBookings : 1)) * 100).toStringAsFixed(0)}%",
              color: Colors.orange,
            ),
          ],
        ),
      ],
    );
  }

  /// Build individual stat card
  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: color),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Build individual booking card
  Widget _buildBookingCard(BookingModel booking) {
    final bookingDate = DateTime.parse(booking.date);
    final isUpcoming = bookingDate.isAfter(DateTime.now());
    final isCancelled = booking.isCancelled;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCancelled
              ? Colors.red.shade200
              : isUpcoming
                  ? Colors.green.shade200
                  : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.fullName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      booking.email,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isCancelled
                      ? Colors.red.shade100
                      : isUpcoming
                          ? Colors.green.shade100
                          : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isCancelled
                      ? "CANCELLED"
                      : isUpcoming
                          ? "UPCOMING"
                          : "COMPLETED",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isCancelled
                        ? Colors.red.shade700
                        : isUpcoming
                            ? Colors.green.shade700
                            : Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Date",
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    "${bookingDate.day}/${bookingDate.month}/${bookingDate.year}",
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Amount",
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    "₹${booking.amount.toStringAsFixed(0)}",
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Guests",
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    "${booking.numberOfGuests}",
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
