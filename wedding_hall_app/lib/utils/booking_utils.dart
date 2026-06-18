
class BookingUtils {
  /// Check if date is in the past
  static bool isDateInPast(DateTime date) {
    final now = DateTime.now();
    return date.isBefore(DateTime(now.year, now.month, now.day));
  }

  /// Check if date is in the future
  static bool isDateInFuture(DateTime date) {
    final now = DateTime.now();
    return date.isAfter(DateTime(now.year, now.month, now.day));
  }

  /// Check if date is today
  static bool isDateToday(DateTime date) {
    final now = DateTime.now();
    return isSameDay(date, now);
  }

  /// Compare two dates (ignoring time)
  static bool isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  /// Format datetime to display-friendly string
  static String formatDisplayDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  /// Format datetime to API-friendly string (YYYY-MM-DD)
  static String formatToIso(DateTime date) {
    return date.toIso8601String().split('T')[0];
  }

  /// Parse date string to datetime
  static DateTime parseDate(String dateString) {
    return DateTime.parse(dateString);
  }

  /// Check if a date is booked
  static bool isDateBooked(DateTime date, List<DateTime> bookedDates) {
    return bookedDates.any((d) => isSameDay(d, date));
  }

  /// Get available dates in a month
  static List<DateTime> getAvailableDates(
    DateTime month,
    List<DateTime> bookedDates,
  ) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);

    final availableDates = <DateTime>[];

    for (var i = 0; i <= lastDay.difference(firstDay).inDays; i++) {
      final date = firstDay.add(Duration(days: i));
      if (!isDateBooked(date, bookedDates) && !isDateInPast(date)) {
        availableDates.add(date);
      }
    }

    return availableDates;
  }

  /// Get booked dates in a month
  static List<DateTime> getBookedDatesInMonth(
    DateTime month,
    List<DateTime> bookedDates,
  ) {
    return bookedDates
        .where((date) => date.year == month.year && date.month == month.month)
        .toList();
  }

  /// Validate date for booking
  static String? validateBookingDate(
      DateTime selectedDate, List<DateTime> bookedDates) {
    if (isDateInPast(selectedDate)) {
      return "Cannot book for past dates";
    }

    if (isDateBooked(selectedDate, bookedDates)) {
      return "This date is already booked";
    }

    return null; // No error
  }

  /// Get days until booking
  static int daysUntilBooking(DateTime bookingDate) {
    final now = DateTime.now();
    return bookingDate.difference(now).inDays;
  }

  /// Check if booking can be cancelled (e.g., within 48 hours before date)
  static bool canCancelBooking(DateTime bookingDate,
      {int hoursBeforeDate = 48}) {
    final now = DateTime.now();
    final hoursUntil = bookingDate.difference(now).inHours;
    return hoursUntil > hoursBeforeDate;
  }
}
