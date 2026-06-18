import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../../models/hall_model.dart';
import '../../services/booking_service.dart';
import '../../services/safe_api.dart';
import '../../utils/booking_utils.dart';
import '../../utils/image_utils.dart';
import '../../viewmodels/auth_vm.dart';
import '../../theme/app_theme.dart';
import '../../widgets/facility_icon.dart';
import '../../widgets/location_widget.dart';
import '../../widgets/hall_rating_widget.dart';
import '../../widgets/modern_booking_calendar.dart';
import '../auth/login_screen.dart';
import '../booking/booking_form_screen.dart';

class HallDetailsScreen extends ConsumerStatefulWidget {
  final HallModel hall;

  const HallDetailsScreen({super.key, required this.hall});

  @override
  ConsumerState<HallDetailsScreen> createState() => _HallDetailsScreenState();
}

class _HallDetailsScreenState extends ConsumerState<HallDetailsScreen> {
  DateTime today = DateTime.now();
  DateTime selectedDay = DateTime.now();

  List<DateTime> bookedDates = [];
  late double currentHallRating;

  @override
  void initState() {
    super.initState();
    currentHallRating = widget.hall.rating;
    fetchBookedDates();
  }

  Future<void> fetchBookedDates() async {
    final bookingService = BookingService();

    try {
      final dates = await bookingService.getBookedDates(widget.hall.id);

      if (mounted) {
        setState(() {
          bookedDates = dates;
        });
      }
    } catch (e) {
      // ✅ FIX: Check if 401 Unauthorized
      bool is401 = false;
      if (e is DioException) {
        is401 = e.response?.statusCode == 401;
      }

      if (is401) {
        if (mounted) {
          SafeApi.handle401(context, ref);
        }
      }
      // For other errors, silently ignore booked dates (non-critical)
    }
  }

  @override
  Widget build(BuildContext context) {
    final hall = widget.hall;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Venue Details"),
        elevation: 0,
        backgroundColor: Colors.white,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🖼 IMAGES CAROUSEL
              SizedBox(
                height: 260,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: hall.images.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(
                        left: index == 0 ? AppTheme.paddingMedium : 0,
                        right: AppTheme.paddingMedium,
                      ),
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(AppTheme.borderRadiusLarge),
                        child: Image.network(
                          ImageUtils.getImageUrl(hall.images[index]),
                          width: 360,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 360,
                              color: Colors.grey[300],
                              child: Icon(
                                Icons.broken_image,
                                size: 50,
                                color: Colors.grey[600],
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              width: 360,
                              color: Colors.grey[300],
                              child: const Center(
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: AppTheme.paddingMedium),

              /// NAME + RATING + LOCATION
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.paddingMedium,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            hall.name,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppTheme.paddingSmall),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryLight,
                            borderRadius: BorderRadius.circular(
                                AppTheme.borderRadiusSmall),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star,
                                  color: Colors.amber, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                hall.rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppTheme.primaryDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    /// 🗺️ LOCATION (CLICKABLE - OPENS GOOGLE MAPS)
                    LocationWidget(
                      locationText: hall.location,
                    ),

                    const SizedBox(height: AppTheme.paddingLarge),

                    /// INFO CARDS (Capacity & Price)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(AppTheme.borderRadiusMedium),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(AppTheme.paddingMedium),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildInfoChip(Icons.people, "${hall.capacity}",
                              "Guest Capacity"),
                          const SizedBox(width: AppTheme.paddingMedium),
                          _buildInfoChip(
                            Icons.currency_rupee,
                            "₹${(hall.price / 100000).toStringAsFixed(1)}L",
                            "Base Price",
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppTheme.paddingLarge),

                    /// DESCRIPTION
                    if (hall.description.isNotEmpty) ...[
                      const Text(
                        "About",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppTheme.paddingSmall),
                      Text(
                        hall.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: AppTheme.paddingLarge),
                    ],

                    /// FACILITIES
                    const Text(
                      "Amenities & Features",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppTheme.paddingMedium),

                    Wrap(
                      spacing: AppTheme.paddingSmall,
                      runSpacing: AppTheme.paddingSmall,
                      children: hall.facilities.map((facility) {
                        return FacilityIcon(facilityName: facility);
                      }).toList(),
                    ),

                    const SizedBox(height: AppTheme.paddingLarge),
                  ],
                ),
              ),

              /// ⭐ RATING WIDGET
              HallRatingWidget(
                hallId: hall.id,
                currentAverageRating: currentHallRating,
                onRatingSubmitted: () {
                  // Optional: Refresh hall data or update rating
                  // For now, just show that it was submitted
                },
              ),

              /// 📅 DATE SELECTION SECTION
              Container(
                margin: const EdgeInsets.symmetric(
                    horizontal: AppTheme.paddingMedium),
                padding: const EdgeInsets.all(AppTheme.paddingMedium),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(AppTheme.borderRadiusMedium),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Select Your Booking Date",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppTheme.paddingMedium),

                    /// � MODERN BOOKING CALENDAR
                    ModernBookingCalendar(
                      currentMonth: today,
                      selectedDate: selectedDay,
                      bookedDates: bookedDates,
                      onDateSelected: (date) {
                        setState(() {
                          selectedDay = date;
                        });

                        // Show selection feedback
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Selected: ${BookingUtils.formatDisplayDate(date)}",
                            ),
                            duration: const Duration(seconds: 1),
                            backgroundColor: Colors.green.shade600,
                          ),
                        );
                      },
                      onMonthChanged: (month) {
                        setState(() {
                          today = month;
                        });
                      },
                    ),

                    /// END CALENDAR
                    const SizedBox(height: AppTheme.paddingMedium),

                    /// 📊 SELECTED DATE DISPLAY
                    Container(
                      padding: const EdgeInsets.all(AppTheme.paddingMedium),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.primary, width: 1),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              color: AppTheme.primaryDark),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Your Selected Date",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  BookingUtils.formatDisplayDate(selectedDay),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "${BookingUtils.daysUntilBooking(selectedDay)} days away",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              /// END CALENDAR CONTAINER

              const SizedBox(height: AppTheme.paddingLarge),

              /// ✅ PROCEED TO BOOKING BUTTON
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.paddingMedium,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryDark,
                      disabledBackgroundColor: Colors.grey.shade300,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.borderRadiusMedium),
                      ),
                    ),
                    onPressed: BookingUtils.validateBookingDate(
                                selectedDay, bookedDates) ==
                            null
                        ? () async {
                            final auth = ref.read(authProvider);

                            /// ❌ NOT LOGGED IN
                            if (auth == null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginScreen(),
                                ),
                              );
                              return;
                            }

                            /// 🔐 SHOW CONFIRMATION DIALOG
                            if (!mounted) return;
                            _showBookingConfirmationDialog(
                              context,
                              hall,
                              selectedDay,
                              ref,
                            );
                          }
                        : null,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.calendar_month,
                            color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          "Proceed to Booking",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: BookingUtils.validateBookingDate(
                                        selectedDay, bookedDates) ==
                                    null
                                ? Colors.white
                                : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔐 BOOKING CONFIRMATION DIALOG
  void _showBookingConfirmationDialog(
    BuildContext context,
    HallModel hall,
    DateTime selectedDate,
    WidgetRef ref,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Confirm Booking"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "You are about to book:",
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 12),
              _buildBookingDetailRow(Icons.location_on, hall.name),
              _buildBookingDetailRow(
                Icons.calendar_today,
                BookingUtils.formatDisplayDate(selectedDate),
              ),
              _buildBookingDetailRow(
                Icons.currency_rupee,
                "₹${hall.price}",
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info, color: Colors.amber, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "This date will be reserved for you",
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Cancel"),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.pop(dialogContext); // Close dialog

                await _processBooking(
                  context,
                  hall.id,
                  selectedDate,
                  ref,
                );
              },
              icon: const Icon(Icons.check_circle),
              label: const Text("Confirm & Pay"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
              ),
            ),
          ],
        );
      },
    );
  }

  /// 📋 BUILD DETAIL ROW FOR DIALOG
  Widget _buildBookingDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 14)),
        ),
      ],
    );
  }

  /// 💳 PROCESS BOOKING - NAVIGATE TO BOOKING FORM
  Future<void> _processBooking(
    BuildContext context,
    String hallId,
    DateTime selectedDate,
    WidgetRef ref,
  ) async {
    // Find the hall object
    final hall = widget.hall;

    // Navigate to BookingFormScreen
    if (!mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BookingFormScreen(
          hall: hall,
          selectedDate: selectedDate,
        ),
      ),
    );
  }

  /// Helper widget for info chips
  Widget _buildInfoChip(IconData icon, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppTheme.primaryGold, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
