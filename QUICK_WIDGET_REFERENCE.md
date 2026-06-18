# 🚀 QUICK START - MODERN UI WIDGETS REFERENCE

## Widget Usage Examples

---

### 1️⃣ **HallCard** - Modern Hall Card with Wishlist

```dart
import 'package:flutter/material.dart';
import 'widgets/hall_card_v2.dart';

// In your list
ListView.builder(
  itemCount: halls.length,
  itemBuilder: (context, index) {
    return HallCard(halls[index]);
  }
)

// Features included:
// ✅ Hall image with gradient overlay
// ✅ Wishlist heart button (top-left)
// ✅ Rating badge (top-right)
// ✅ Name, location, capacity, price
// ✅ Tap to view details
// ✅ No navigation on heart click
```

---

### 2️⃣ **RatingStars** - Reusable Star Rating Display

```dart
import 'widgets/rating_stars.dart';

// Simple display (non-interactive)
RatingStars(
  rating: 4.5,
  size: 24,
)

// Interactive (for user input)
RatingStars(
  rating: _userRating,
  size: 28,
  interactive: true,
  onRatingChanged: (newRating) {
    setState(() => _userRating = newRating);
  },
)

// With padding
RatingStars(
  rating: hall.rating,
  padding: EdgeInsets.all(8),
)
```

---

### 3️⃣ **PriceCard** - Smart Price Display

```dart
import 'widgets/price_card.dart';

// Base price
PriceCard(
  basePrice: 500000,
  label: "Base Price",
)

// With advance payment info
PriceCard(
  basePrice: 500000,
  advancePrice: 100000,
  label: "Total Price",
  showAdvance: true,
)

// Clickable card
PriceCard(
  basePrice: 500000,
  onTap: () {
    // Show price breakdown
  },
)

// Smart formatting examples:
// 500 → "₹500"
// 50,000 → "₹50K"
// 500,000 → "₹5L"
// 5,000,000 → "₹5Cr"
```

---

### 4️⃣ **LocationWidget** - Clickable Location

```dart
import 'widgets/location_widget.dart';

LocationWidget(
  locationText: "Mumbai, Maharashtra",
  onTap: () {
    print("Opening Google Maps...");
  },
)

// Opens Google Maps on tap
// Shows location in native Maps app (Android/iOS)
// Falls back to web Google Maps if needed
```

---

### 5️⃣ **FacilityIcon** - Amenity Display

```dart
import 'widgets/facility_icon.dart';

// Wrap in a grid
GridView.count(
  crossAxisCount: 3,
  children: hall.facilities
    .map((facility) => FacilityIcon(facilityName: facility))
    .toList(),
)

// Supported facilities:
// AC, WiFi, Parking, Catering, Bar, DJ, Sound System,
// Stage, Dance Floor, Garden, Mall Extension,
// Air Conditioning, Elevator, etc.
```

---

## 📱 Complete Screen Example

```dart
import 'package:flutter/material.dart';
import 'models/hall_model.dart';
import 'theme/app_theme.dart';
import 'widgets/hall_card_v2.dart';
import 'widgets/rating_stars.dart';
import 'widgets/price_card.dart';

class ModernHallListScreen extends StatelessWidget {
  final List<HallModel> halls;

  const ModernHallListScreen({required this.halls});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Velora Venues'),
        backgroundColor: AppTheme.primary,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: halls.length,
        itemBuilder: (context, index) {
          final hall = halls[index];
          
          return Column(
            children: [
              // Modern Card
              HallCard(hall),
              
              SizedBox(height: 8),
              
              // Price Info
              PriceCard(
                basePrice: hall.price,
                label: "Starting at",
              ),
              
              SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }
}
```

---

## 🎨 Design Tokens Quick Reference

```dart
import 'theme/app_theme.dart';

// Colors
AppTheme.primary           # F8BBD0 (Baby Pink)
AppTheme.primaryLight      # FCE4EC (Soft Pink)
AppTheme.primaryDark       # D81B60 (Dark Pink)
AppTheme.accent            # EC407A (Accent Pink)
AppTheme.gold              # Same as primary

// Spacing
AppTheme.paddingXs         # 8px
AppTheme.paddingSmall      # 12px
AppTheme.paddingMedium     # 16px (default)
AppTheme.paddingLarge      # 24px
AppTheme.paddingXl         # 32px

// Border Radius
AppTheme.borderRadiusSmall  # 12px (buttons)
AppTheme.borderRadiusMedium # 16px (dialogs)
AppTheme.borderRadiusLarge  # 20px (cards)

// Text Styles
Theme.of(context).textTheme.headlineSmall      # 22px Bold
Theme.of(context).textTheme.titleLarge         # 18px Bold
Theme.of(context).textTheme.titleMedium        # 16px SemiBold
Theme.of(context).textTheme.bodyLarge          # 16px Regular
Theme.of(context).textTheme.bodyMedium         # 14px Regular
Theme.of(context).textTheme.bodySmall          # 12px Regular
```

---

## 🎯 Common Patterns

### Complete Hall Card with Details

```dart
Container(
  margin: EdgeInsets.only(bottom: 16),
  child: Column(
    children: [
      // Hall Card (includes image, rating, wishlist)
      HallCard(hall),
      
      SizedBox(height: 8),
      
      // Price info
      PriceCard(
        basePrice: hall.price,
        advancePrice: hall.price * 0.2,
        label: "Starting at",
        showAdvance: true,
      ),
      
      SizedBox(height: 8),
      
      // Rating
      Row(
        children: [
          Text("Rating"),
          SizedBox(width: 8),
          RatingStars(rating: hall.rating),
        ],
      ),
    ],
  ),
)
```

### Detail Page Summary Card

```dart
Container(
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 12,
        offset: Offset(0, 4),
      ),
    ],
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Pricing',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(height: 12),
      PriceCard(
        basePrice: hall.price,
        label: "Base Price",
      ),
      SizedBox(height: 12),
      PriceCard(
        basePrice: hall.price * 0.2,
        label: "20% Advance",
      ),
    ],
  ),
)
```

---

## 🔧 Customization

### Change Colors
```dart
// In app_theme.dart
static const Color primary = Color(0xFFYourColor);
// All theme-aware widgets update automatically
```

### Adjust Spacing
```dart
// Use AppTheme constants throughout
Padding(
  padding: const EdgeInsets.all(AppTheme.paddingMedium),
  child: child,
)
```

### Custom Card Shadow
```dart
BoxDecoration(
  boxShadow: [
    BoxShadow(
      color: Colors.black.withOpacity(0.12),
      blurRadius: 16,
      offset: Offset(0, 6),
    ),
  ],
)
```

---

## ⚙️ Integration Checklist

- [ ] Create/update hall list screen using HallCard
- [ ] Replace manual price formatting with PriceCard
- [ ] Use RatingStars in detail and listing screens
- [ ] Integrate LocationWidget for location display
- [ ] Use AppTheme for all colors, spacing, radius
- [ ] Test on multiple device sizes
- [ ] Verify wishlist works without navigation
- [ ] Check image loading and error states
- [ ] Validate touch target sizes (min 48pt)

---

## 🐛 Troubleshooting

### "Image not loading in HallCard"
```dart
// Ensure ImageUtils.getImageUrl() is used
Image.network(
  ImageUtils.getImageUrl(hall.images[0]), ✅ Correct
  // NOT: hall.images[0] ❌ Wrong
)
```

### "Wishlist button navigating to details"
```dart
// Ensure separate GestureDetector
Stack(
  children: [
    GestureDetector(
      onTap: () => navigateToDetails(), // Image tap
      child: Image.network(...)
    ),
    Positioned(
      child: GestureDetector(
        onTap: () => _toggleWishlist(), // Heart tap
        child: IconButton(...)
      )
    ),
  ]
)
```

### "Price formatting looks wrong"
```dart
// PriceCard handles formatting automatically
PriceCard(basePrice: 500000)  // Shows "₹5L" ✅
// Don't format manually!
Text('₹${price/100000}L')  // ❌ Avoid this
```

---

## 📚 Files Reference

| Widget | File | Imports |
|--------|------|---------|
| HallCard | `lib/widgets/hall_card_v2.dart` | `package:flutter/material.dart`, riverpod, models, services |
| RatingStars | `lib/widgets/rating_stars.dart` | `package:flutter/material.dart`, theme |
| PriceCard | `lib/widgets/price_card.dart` | `package:flutter/material.dart`, theme |
| LocationWidget | `lib/widgets/location_widget.dart` | `package:flutter/material.dart`, url_launcher |
| FacilityIcon | `lib/widgets/facility_icon.dart` | `package:flutter/material.dart`, theme |
| AppTheme | `lib/theme/app_theme.dart` | `package:flutter/material.dart` |

---

## ✨ Tips & Tricks

1. **Use EdgeInsets.fromLTRB()** for asymmetric padding:
   ```dart
   padding: EdgeInsets.fromLTRB(16, 8, 16, 12)
   ```

2. **Combine colors with opacity**:
   ```dart
   Colors.black.withOpacity(0.08)  // Subtle shadow
   AppTheme.primary.withOpacity(0.5)  // Translucent overlay
   ```

3. **Use SizedBox for spacing** (better than Padding):
   ```dart
   SizedBox(height: AppTheme.paddingMedium)
   ```

4. **ClipRRect for rounded images**:
   ```dart
   ClipRRect(
     borderRadius: BorderRadius.circular(20),
     child: Image.network(...)
   )
   ```

5. **maxLines + overflow for text**:
   ```dart
   Text(
     longText,
     maxLines: 2,
     overflow: TextOverflow.ellipsis,
   )
   ```

---

**Created**: March 2026  
**Status**: Ready for Production ✅  
**Version**: 1.0
