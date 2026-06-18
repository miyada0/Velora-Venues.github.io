import 'package:flutter/material.dart';
import '../utils/booking_utils.dart';

class ModernBookingCalendar extends StatefulWidget {
  final DateTime currentMonth;
  final DateTime selectedDate;
  final List<DateTime> bookedDates;
  final ValueChanged<DateTime> onDateSelected;
  final ValueChanged<DateTime> onMonthChanged;

  const ModernBookingCalendar({
    super.key,
    required this.currentMonth,
    required this.selectedDate,
    required this.bookedDates,
    required this.onDateSelected,
    required this.onMonthChanged,
  });

  @override
  State<ModernBookingCalendar> createState() => _ModernBookingCalendarState();
}

class _ModernBookingCalendarState extends State<ModernBookingCalendar> {
  late DateTime displayMonth;

  @override
  void initState() {
    super.initState();
    displayMonth =
        DateTime(widget.currentMonth.year, widget.currentMonth.month);
  }

  @override
  void didUpdateWidget(ModernBookingCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentMonth != widget.currentMonth) {
      displayMonth =
          DateTime(widget.currentMonth.year, widget.currentMonth.month);
    }
  }

  /// Get color for a specific date based on booking state
  Color _getDateColor(DateTime date) {
    // Past dates: light grey
    if (BookingUtils.isDateInPast(date)) {
      return Colors.grey.shade300;
    }
    // Booked dates: red
    else if (BookingUtils.isDateBooked(date, widget.bookedDates)) {
      return Colors.red;
    }
    // Selected date: blue
    else if (BookingUtils.isSameDay(date, widget.selectedDate)) {
      return Colors.blue;
    }
    // Available dates: green
    else {
      return Colors.green;
    }
  }

  /// Get text color for a date (white for most, dark grey for past)
  Color _getTextColor(DateTime date) {
    if (BookingUtils.isDateInPast(date)) {
      return Colors.grey.shade700;
    }
    return Colors.white;
  }

  /// Check if date is clickable
  bool _isDateClickable(DateTime date) {
    return !BookingUtils.isDateInPast(date) &&
        !BookingUtils.isDateBooked(date, widget.bookedDates);
  }

  /// Handle date selection
  void _onDateTap(DateTime date) {
    final error = BookingUtils.validateBookingDate(date, widget.bookedDates);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.red.shade600,
        ),
      );
      return;
    }

    widget.onDateSelected(date);
  }

  /// Go to previous month
  void _previousMonth() {
    setState(() {
      displayMonth = DateTime(displayMonth.year, displayMonth.month - 1);
      widget.onMonthChanged(displayMonth);
    });
  }

  /// Go to next month
  void _nextMonth() {
    setState(() {
      displayMonth = DateTime(displayMonth.year, displayMonth.month + 1);
      widget.onMonthChanged(displayMonth);
    });
  }

  /// Get month and year header
  String _getMonthHeader() {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[displayMonth.month - 1]} ${displayMonth.year}';
  }

  /// Get calendar days for display (includes empty cells for alignment)
  List<DateTime?> _getCalendarDays() {
    final firstDay = DateTime(displayMonth.year, displayMonth.month, 1);
    final lastDay = DateTime(displayMonth.year, displayMonth.month + 1, 0);

    final firstWeekday = firstDay.weekday; // Monday=1, Sunday=7
    final daysInMonth = lastDay.day;

    final days = <DateTime?>[];

    // Add empty cells for days before the first day of month
    for (int i = 0; i < (firstWeekday % 7); i++) {
      days.add(null);
    }

    // Add all days of the month
    for (int i = 1; i <= daysInMonth; i++) {
      days.add(DateTime(displayMonth.year, displayMonth.month, i));
    }

    return days;
  }

  @override
  Widget build(BuildContext context) {
    final calendarDays = _getCalendarDays();
    const weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// 📊 LEGEND
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const _LegendItem(color: Colors.green, label: 'Available'),
              const _LegendItem(color: Colors.red, label: 'Booked'),
              const _LegendItem(color: Colors.blue, label: 'Selected'),
              _LegendItem(color: Colors.grey.shade300, label: 'Past'),
            ],
          ),
        ),

        const SizedBox(height: 16),

        /// 📅 CALENDAR CONTAINER
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              /// 📍 MONTH/YEAR HEADER WITH NAVIGATION
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  /// Previous Month Button
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _previousMonth,
                    tooltip: 'Previous month',
                  ),

                  /// Month & Year Title
                  Expanded(
                    child: Text(
                      _getMonthHeader(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  /// Next Month Button
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _nextMonth,
                    tooltip: 'Next month',
                  ),
                ],
              ),

              const SizedBox(height: 16),

              /// 🗓️ WEEKDAY HEADERS
              Row(
                children: weekdays
                    .map(
                      (day) => Expanded(
                        child: Text(
                          day,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),

              const SizedBox(height: 8),

              /// 📆 CALENDAR GRID
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: 1.2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: calendarDays.length,
                itemBuilder: (context, index) {
                  final date = calendarDays[index];

                  // Empty cell for alignment
                  if (date == null) {
                    return const SizedBox.expand();
                  }

                  final isClickable = _isDateClickable(date);
                  final backgroundColor = _getDateColor(date);
                  final textColor = _getTextColor(date);
                  final isSelected =
                      BookingUtils.isSameDay(date, widget.selectedDate);

                  return GestureDetector(
                    onTap: isClickable ? () => _onDateTap(date) : null,
                    child: Container(
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(
                                color: Color.alphaBlend(
                                    Colors.white.withOpacity(0.5),
                                    backgroundColor),
                                width: 2)
                            : null,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: backgroundColor.withOpacity(0.4),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: isClickable ? () => _onDateTap(date) : null,
                          customBorder: const CircleBorder(),
                          child: Center(
                            child: Text(
                              date.day.toString(),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Legend item widget
class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
