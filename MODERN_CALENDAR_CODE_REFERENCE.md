# Modern Calendar - Code Reference

## Quick Integration Example

### How to Use the Calendar Widget

```dart
// In your screen/state:
DateTime today = DateTime.now();
DateTime selectedDay = DateTime.now();
List<DateTime> bookedDates = [];

// In your build method:
ModernBookingCalendar(
  currentMonth: today,
  selectedDate: selectedDay,
  bookedDates: bookedDates,
  onDateSelected: (date) {
    setState(() {
      selectedDay = date;
    });
    // Show feedback or proceed to booking
  },
  onMonthChanged: (month) {
    setState(() {
      today = month;
    });
  },
)
```

---

## Color Logic Implementation

### The `_getDateColor()` Method
```dart
Color _getDateColor(DateTime date) {
  // 1. Past dates: light grey
  if (BookingUtils.isDateInPast(date)) {
    return Colors.grey.shade300;  // Light grey
  }
  // 2. Booked dates: red
  else if (BookingUtils.isDateBooked(date, widget.bookedDates)) {
    return Colors.red;  // Bright red
  }
  // 3. Selected date: blue
  else if (BookingUtils.isSameDay(date, widget.selectedDate)) {
    return Colors.blue;  // Bright blue
  }
  // 4. Available dates: green (default)
  else {
    return Colors.green;  // Bright green
  }
}
```

### Text Color for Readability
```dart
Color _getTextColor(DateTime date) {
  // Only grey text for past dates, white for everything else
  if (BookingUtils.isDateInPast(date)) {
    return Colors.grey.shade700;  // Dark grey
  }
  return Colors.white;  // White for other states
}
```

---

## The Calendar Grid Layout

### How Dates are Arranged
```dart
GridView.builder(
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 7,  // 7 columns = Sun, Mon, Tue, Wed, Thu, Fri, Sat
    childAspectRatio: 1.2,  // Slightly taller than wide for good spacing
    mainAxisSpacing: 8,  // Space between rows
    crossAxisSpacing: 8,  // Space between columns
  ),
  itemCount: calendarDays.length,  // All days in month + empty cells
  itemBuilder: (context, index) {
    // Each cell is a date circle or empty
  },
)
```

### Building Calendar Days Array
```dart
List<DateTime?> _getCalendarDays() {
  final firstDay = DateTime(displayMonth.year, displayMonth.month, 1);
  final lastDay = DateTime(displayMonth.year, displayMonth.month + 1, 0);
  final firstWeekday = firstDay.weekday; // 1=Mon, 7=Sun
  
  final days = <DateTime?>[];
  
  // Add empty cells at start (for alignment to correct weekday)
  for (int i = 0; i < (firstWeekday % 7); i++) {
    days.add(null);  // Empty cell
  }
  
  // Add all dates
  for (int i = 1; i <= lastDay.day; i++) {
    days.add(DateTime(displayMonth.year, displayMonth.month, i));
  }
  
  return days;
}
```

---

## Date Selection Validation

### Preventing Invalid Selections
```dart
void _onDateTap(DateTime date) {
  // Use BookingUtils to validate
  final error = BookingUtils.validateBookingDate(date, widget.bookedDates);
  
  if (error != null) {
    // Show error to user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error),
        backgroundColor: Colors.red.shade600,
      ),
    );
    return;
  }
  
  // Valid date - allow selection
  widget.onDateSelected(date);
}
```

### Error Messages
```dart
// From BookingUtils.validateBookingDate():
"Cannot book for past dates"  // If date is in past
"This date is already booked"  // If date is booked
null  // If date is valid (no error)
```

---

## Month Navigation

### Previous Month
```dart
void _previousMonth() {
  setState(() {
    displayMonth = DateTime(displayMonth.year, displayMonth.month - 1);
    widget.onMonthChanged(displayMonth);
  });
}
```

### Next Month
```dart
void _nextMonth() {
  setState(() {
    displayMonth = DateTime(displayMonth.year, displayMonth.month + 1);
    widget.onMonthChanged(displayMonth);
  });
}
```

### Month Header Format
```dart
String _getMonthHeader() {
  const months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  return '${months[displayMonth.month - 1]} ${displayMonth.year}';
  // Output: "March 2026"
}
```

---

## Legend Display

### _LegendItem Widget
```dart
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
            color: color,  // The color circle
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,  // "Available", "Booked", etc.
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
```

### Legend Container
```dart
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
      _LegendItem(color: Colors.green, label: 'Available'),
      _LegendItem(color: Colors.red, label: 'Booked'),
      _LegendItem(color: Colors.blue, label: 'Selected'),
      _LegendItem(color: Colors.grey.shade300, label: 'Past'),
    ],
  ),
)
```

---

## Selected Date Display Box

```dart
Container(
  padding: const EdgeInsets.all(AppTheme.paddingMedium),
  decoration: BoxDecoration(
    color: AppTheme.primaryLight,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: AppTheme.primary, width: 1),
  ),
  child: Row(
    children: [
      const Icon(Icons.calendar_today, color: AppTheme.primaryDark),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Your Selected Date", style: TextStyle(fontSize: 12)),
            Text(
              BookingUtils.formatDisplayDate(selectedDay),  // "26 Mar 2026"
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.green.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          "${BookingUtils.daysUntilBooking(selectedDay)} days away",
          style: TextStyle(fontSize: 12, color: Colors.green.shade700),
        ),
      ),
    ],
  ),
)
```

---

## Proceed Button Implementation

```dart
SizedBox(
  width: double.infinity,
  height: 56,
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppTheme.primaryDark,
      disabledBackgroundColor: Colors.grey.shade300,  // Disable state
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
    ),
    // Button only enabled when date is valid
    onPressed: BookingUtils.validateBookingDate(selectedDay, bookedDates) == null
        ? () {
            // Navigate to booking form
            Navigator.push(context, ...);
          }
        : null,  // Disabled
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.calendar_month, color: Colors.white),
        const SizedBox(width: 8),
        const Text(
          "Proceed to Booking",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    ),
  ),
)
```

---

## Import Statements Needed

```dart
// In your screen file:
import 'package:flutter/material.dart';
import '../../widgets/modern_booking_calendar.dart';
import '../../utils/booking_utils.dart';

// The calendar widget only uses:
// - Flutter: Material, Colors, Icons, Widget classes
// - Project: BookingUtils (for date validation logic)
// - No third-party packages required!
```

---

## Key Utilities Used

From `BookingUtils`:
```dart
BookingUtils.isDateInPast(date)           // Check if date is past
BookingUtils.isDateBooked(date, dates)    // Check if date is booked
BookingUtils.isSameDay(d1, d2)            // Compare dates (ignoring time)
BookingUtils.formatDisplayDate(date)      // Format: "26 Mar 2026"
BookingUtils.daysUntilBooking(date)       // Get days until date
BookingUtils.validateBookingDate(...)     // Validate date for booking
```

---

## Date Comparison Logic

Why `isSameDay()` is important:
```dart
DateTime date1 = DateTime(2026, 3, 26, 10, 30, 0);
DateTime date2 = DateTime(2026, 3, 26, 14, 45, 0);

// ❌ WRONG: date1 == date2  → false (different times)
// ✅ CORRECT: BookingUtils.isSameDay(date1, date2)  → true
```

---

## Common Error Messages

```
"Cannot book for past dates"
→ User tried to select a date before today

"This date is already booked"
→ User tried to select a date that's in the bookedDates list

No error (null)
→ Date is valid, selection allowed
```

---

## Performance Notes

- Calendar recalculates grid layout only when month changes
- Date validation uses simple list lookup with `.any()` (O(n) but n is small)
- No animation overhead - uses standard Flutter widgets
- Efficient for up to 365 days of bookings per year

---

**Last Updated**: March 27, 2026
**Status**: Ready for use and deployment
