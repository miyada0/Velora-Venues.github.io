# 💻 CODE SNIPPETS - COPY & PASTE READY

## Quick Copy-Paste Solutions

---

## 1️⃣ Complete Home Screen with Modern Cards

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'widgets/hall_card_v2.dart';
import 'theme/app_theme.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hallAsyncValue = ref.watch(hallProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Velora Venues💍'),
        backgroundColor: AppTheme.primary,
        elevation: 0,
      ),
      body: hallAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text('Error: $err'),
        ),
        data: (halls) => ListView.builder(
          padding: const EdgeInsets.all(AppTheme.paddingMedium),
          itemCount: halls.length,
          itemBuilder: (context, index) => HallCard(halls[index]),
        ),
      ),
    );
  }
}
```

---

## 2️⃣ Hall Card with Price Below

```dart
Container(
  margin: const EdgeInsets.only(bottom: AppTheme.paddingMedium),
  child: Column(
    children: [
      HallCard(hall),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.all(AppTheme.paddingSmall),
        decoration: BoxDecoration(
          color: AppTheme.primaryLight,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Starting at',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              '₹${(hall.price / 100000).toStringAsFixed(1)}L',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryDark,
              ),
            ),
          ],
        ),
      ),
    ],
  ),
)
```

---

## 3️⃣ Hall Details Price Summary Card

```dart
Container(
  padding: const EdgeInsets.all(AppTheme.paddingMedium),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Pricing Details',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Save 10%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: AppTheme.paddingMedium),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Base Price', style: Theme.of(context).textTheme.bodyMedium),
          Text(
            '₹${(hall.price / 100000).toStringAsFixed(1)}L',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      const SizedBox(height: AppTheme.paddingSmall),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('20% Advance', style: Theme.of(context).textTheme.bodyMedium),
          Text(
            '₹${(hall.price * 0.2 / 100000).toStringAsFixed(1)}L',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryDark,
            ),
          ),
        ],
      ),
    ],
  ),
)
```

---

## 4️⃣ Search Bar with Filter

```dart
Container(
  padding: const EdgeInsets.all(AppTheme.paddingMedium),
  child: Row(
    children: [
      Expanded(
        child: TextField(
          onChanged: (value) {
            ref.read(searchFilterProvider.notifier).updateSearch(value);
          },
          decoration: InputDecoration(
            hintText: 'Search halls...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: const Icon(Icons.clear),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),
      const SizedBox(width: AppTheme.paddingSmall),
      Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(30),
        ),
        child: IconButton(
          icon: Icon(
            Icons.tune,
            color: Colors.grey.shade600,
          ),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (context) => const FilterBottomSheet(),
            );
          },
        ),
      ),
    ],
  ),
)
```

---

## 5️⃣ Rating Display (Read-Only)

```dart
Row(
  children: [
    const Icon(Icons.star, color: Colors.amber, size: 18),
    const SizedBox(width: 4),
    Text(
      hall.rating.toStringAsFixed(1),
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    ),
    const SizedBox(width: 8),
    Text(
      '(${reviewCount} reviews)',
      style: TextStyle(
        fontSize: 12,
        color: Colors.grey[600],
      ),
    ),
  ],
)
```

---

## 6️⃣ Modern Info Card (Capacity + Price)

```dart
Container(
  padding: const EdgeInsets.all(AppTheme.paddingMedium),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  ),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: [
      /// Capacity
      Column(
        children: [
          Icon(Icons.people, size: 28, color: AppTheme.primaryDark),
          const SizedBox(height: 8),
          Text(
            '${hall.capacity}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Guests',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
      
      /// Divider
      Container(
        width: 1,
        height: 60,
        color: Colors.grey.shade300,
      ),
      
      /// Price
      Column(
        children: [
          Icon(Icons.currency_rupee, size: 28, color: AppTheme.primaryDark),
          const SizedBox(height: 8),
          Text(
            '₹${(hall.price / 100000).toStringAsFixed(1)}L',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Base Price',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    ],
  ),
)
```

---

## 7️⃣ Location Card with Google Maps

```dart
Container(
  padding: const EdgeInsets.all(AppTheme.paddingMedium),
  decoration: BoxDecoration(
    color: AppTheme.primaryLight,
    borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
    border: Border.all(color: AppTheme.primaryDark.withOpacity(0.2)),
  ),
  child: GestureDetector(
    onTap: () async {
      final String encodedLocation = Uri.encodeComponent(hall.location);
      final String googleMapsUrl = 
        "https://www.google.com/maps/search/$encodedLocation";
      
      if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
        await launchUrl(
          Uri.parse(googleMapsUrl),
          mode: LaunchMode.externalApplication,
        );
      }
    },
    child: Row(
      children: [
        const Icon(
          Icons.location_on,
          color: AppTheme.primaryDark,
          size: 24,
        ),
        const SizedBox(width: AppTheme.paddingMedium),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Location',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                hall.location,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryDark,
                ),
              ),
            ],
          ),
        ),
        const Icon(
          Icons.open_in_new,
          color: AppTheme.primaryDark,
          size: 18,
        ),
      ],
    ),
  ),
)
```

---

## 8️⃣ Empty State (No Results)

```dart
Center(
  child: Padding(
    padding: const EdgeInsets.all(AppTheme.paddingLarge),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppTheme.primaryLight,
            borderRadius: BorderRadius.circular(50),
          ),
          child: const Icon(
            Icons.search_off,
            size: 50,
            color: AppTheme.primaryDark,
          ),
        ),
        const SizedBox(height: AppTheme.paddingMedium),
        const Text(
          'No Halls Found',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppTheme.paddingSmall),
        Text(
          'Try adjusting your search or filters',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppTheme.paddingLarge),
        ElevatedButton.icon(
          onPressed: onClearFilters,
          icon: const Icon(Icons.clear),
          label: const Text('Clear Filters'),
        ),
      ],
    ),
  ),
)
```

---

## 9️⃣ Login Prompt Modal

```dart
showDialog(
  context: context,
  builder: (ctx) => AlertDialog(
    title: const Text('Login Required'),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
    ),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            color: AppTheme.lightBeige,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.favorite_border,
            size: 40,
            color: AppTheme.gold,
          ),
        ),
        const SizedBox(height: AppTheme.paddingMedium),
        Text(
          'Save Your Favorites',
          textAlign: TextAlign.center,
          style: Theme.of(ctx).textTheme.titleMedium,
        ),
        const SizedBox(height: AppTheme.paddingSmall),
        Text(
          'Sign in to add this hall to your wishlist',
          textAlign: TextAlign.center,
          style: Theme.of(ctx).textTheme.bodySmall,
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(ctx),
        child: const Text('Cancel'),
      ),
      ElevatedButton(
        onPressed: () {
          Navigator.pop(ctx);
          Navigator.pushNamed(context, '/login');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.gold,
        ),
        child: const Text('Login'),
      ),
    ],
  ),
)
```

---

## 🔟 Amenities Grid

```dart
GridView.count(
  crossAxisCount: 3,
  childAspectRatio: 1.2,
  mainAxisSpacing: AppTheme.paddingSmall,
  crossAxisSpacing: AppTheme.paddingSmall,
  children: hall.facilities
    .map((facility) => FacilityIcon(facilityName: facility))
    .toList(),
)
```

---

## 1️⃣1️⃣ Circular Loader

```dart
Center(
  child: Padding(
    padding: const EdgeInsets.all(AppTheme.paddingLarge),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          width: 50,
          height: 50,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation(AppTheme.primary),
          ),
        ),
        const SizedBox(height: AppTheme.paddingMedium),
        Text(
          'Loading halls...',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    ),
  ),
)
```

---

## 1️⃣2️⃣ Error State with Retry

```dart
Center(
  child: Padding(
    padding: const EdgeInsets.all(AppTheme.paddingMedium),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.error_outline,
          size: 60,
          color: Colors.red.shade400,
        ),
        const SizedBox(height: AppTheme.paddingMedium),
        Text(
          'Oops! Something went wrong',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppTheme.paddingSmall),
        Text(
          'Please check your connection and try again',
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppTheme.paddingLarge),
        ElevatedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: const Text('Retry'),
        ),
      ],
    ),
  ),
)
```

---

## 1️⃣3️⃣ Floating Action Button (Refresh)

```dart
floatingActionButton: FloatingActionButton(
  onPressed: () {
    ref.refresh(hallProvider);
  },
  backgroundColor: AppTheme.gold,
  tooltip: 'Refresh',
  child: const Icon(
    Icons.refresh,
    color: Colors.white,
  ),
)
```

---

## 1️⃣4️⃣ Success Message with Snackbar

```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: const Text('Added to wishlist ❤️'),
    backgroundColor: Colors.green,
    duration: const Duration(seconds: 2),
    behavior: SnackBarBehavior.floating,
    margin: const EdgeInsets.all(AppTheme.paddingMedium),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
    ),
  ),
)
```

---

## 1️⃣5️⃣ Complete Hall Card Integration

```dart
Container(
  margin: const EdgeInsets.all(AppTheme.paddingMedium),
  child: Column(
    children: [
      // Hall Card (with image, wishlist, rating)
      HallCard(hall),
      
      const SizedBox(height: AppTheme.paddingSmall),
      
      // Quick Info Row
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Capacity
          Row(
            children: [
              Icon(Icons.people, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                '${hall.capacity} guests',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          
          // Price Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '₹${(hall.price / 100000).toStringAsFixed(1)}L',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryDark,
              ),
            ),
          ),
        ],
      ),
    ],
  ),
)
```

---

## All Snippets Ready to Copy! ✨

Simply copy any snippet above and paste into your code.  
All imports are included in the snippets.

**Pro Tip**: Use VS Code snippets feature to save these for quick access!

```json
// In .vscode/dart.code-snippets
{
  "Hall Card": {
    "prefix": "hallcard",
    "body": [
      "HallCard($1)"
    ]
  }
}
```

---

**Last Updated**: March 2026
**Version**: 1.0
