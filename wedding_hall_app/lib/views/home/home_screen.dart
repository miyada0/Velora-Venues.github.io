import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodels/auth_vm.dart';
import '../../viewmodels/hall_vm.dart';
import '../../viewmodels/search_filter_vm.dart';
import '../../widgets/modern_hall_card.dart';
import '../../theme/app_theme.dart';
import '../hall/hall_details_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final hallAsyncValue = ref.watch(hallProvider);
    final searchFilterState = ref.watch(searchFilterProvider);
    final filteredHalls = ref.watch(filteredHallsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Velora Venues",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        toolbarHeight: 70,
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
        child: Column(
          children: [
            // ========== SEARCH & FILTER SECTION ==========
            Padding(
              padding: const EdgeInsets.all(AppTheme.paddingMedium),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onChanged: (value) {
                            ref
                                .read(searchFilterProvider.notifier)
                                .updateSearch(value);
                          },
                          decoration: InputDecoration(
                            hintText: "Search halls...",
                            hintStyle: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 14,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.grey.shade600,
                            ),
                            suffixIcon: searchFilterState.searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      ref
                                          .read(searchFilterProvider.notifier)
                                          .updateSearch('');
                                    },
                                  )
                                : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                color: AppTheme.primaryGold,
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: IconButton(
                            icon: Icon(
                              Icons.tune,
                              color: searchFilterState.hasActiveFilters()
                                  ? AppTheme.primaryGold
                                  : Colors.grey.shade600,
                            ),
                            onPressed: () {
                              _showFilterBottomSheet(context, ref);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (searchFilterState.hasActiveFilters())
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Wrap(
                              spacing: 8,
                              children: [
                                if (searchFilterState.searchQuery.isNotEmpty)
                                  _FilterChip(
                                    label: '"${searchFilterState.searchQuery}"',
                                    onRemove: () {
                                      ref
                                          .read(searchFilterProvider.notifier)
                                          .updateSearch('');
                                    },
                                  ),
                                if (searchFilterState.minRating > 0)
                                  _FilterChip(
                                    label:
                                        '${searchFilterState.minRating.toStringAsFixed(1)}+ ⭐',
                                    onRemove: () {
                                      ref
                                          .read(searchFilterProvider.notifier)
                                          .updateMinRating(0);
                                    },
                                  ),
                                if (searchFilterState.selectedLocation !=
                                        null &&
                                    searchFilterState
                                        .selectedLocation!.isNotEmpty)
                                  _FilterChip(
                                    label:
                                        '📍 ${searchFilterState.selectedLocation}',
                                    onRemove: () {
                                      ref
                                          .read(searchFilterProvider.notifier)
                                          .updateLocation(null);
                                    },
                                  ),
                                if (searchFilterState.minCapacity > 0 ||
                                    searchFilterState.maxCapacity < 2000)
                                  _FilterChip(
                                    label:
                                        '${searchFilterState.minCapacity.toInt()} - ${searchFilterState.maxCapacity.toInt()} 👥',
                                    onRemove: () {
                                      ref
                                          .read(searchFilterProvider.notifier)
                                          .updateCapacityRange(0, 2000);
                                    },
                                  ),
                                ...searchFilterState.selectedFacilities
                                    .map((facility) => _FilterChip(
                                          label: facility,
                                          onRemove: () {
                                            final updated = List<String>.from(
                                                searchFilterState
                                                    .selectedFacilities);
                                            updated.remove(facility);
                                            ref
                                                .read(searchFilterProvider
                                                    .notifier)
                                                .updateFacilities(updated);
                                          },
                                        ))
                                    ,
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              ref
                                  .read(searchFilterProvider.notifier)
                                  .clearFilters();
                            },
                            child: const Text(
                              'Clear all',
                              style: TextStyle(
                                color: AppTheme.primaryGold,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            // ========== HALLS LIST ==========
            Expanded(
              child: hallAsyncValue.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, stackTrace) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.paddingMedium),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline,
                            size: 60, color: Colors.red.shade400),
                        const SizedBox(height: AppTheme.paddingMedium),
                        Text(
                          "Failed to load halls",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppTheme.paddingLarge),
                        ElevatedButton.icon(
                          onPressed: () {
                            ref.read(hallProvider.notifier).refresh();
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text("Retry"),
                        ),
                      ],
                    ),
                  ),
                ),
                data: (halls) {
                  if (halls.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppTheme.paddingMedium),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.home_work_outlined,
                              size: 60,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: AppTheme.paddingMedium),
                            Text(
                              "No Halls Available",
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: AppTheme.paddingSmall),
                            Text(
                              "Check back later for available venues",
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (filteredHalls.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppTheme.paddingMedium),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 60,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: AppTheme.paddingMedium),
                            Text(
                              "No Results Found",
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: AppTheme.paddingSmall),
                            Text(
                              "Try adjusting your search or filters",
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: AppTheme.paddingLarge),
                            ElevatedButton(
                              onPressed: () {
                                ref
                                    .read(searchFilterProvider.notifier)
                                    .clearFilters();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryGold,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      AppTheme.borderRadiusMedium),
                                ),
                              ),
                              child: const Text(
                                "Clear Filters",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => ref.read(hallProvider.notifier).refresh(),
                    child: GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: filteredHalls.length + (user == null ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (user == null && index == filteredHalls.length) {
                          return Container(
                            padding:
                                const EdgeInsets.all(AppTheme.paddingMedium),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF8E1),
                              borderRadius: BorderRadius.circular(
                                  AppTheme.borderRadiusMedium),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Ready to Book?",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: AppTheme.paddingSmall),
                                Text(
                                  "Login to book",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        final hall = filteredHalls[index];

                        return ModernHallCard(
                          hall: hall,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    HallDetailsScreen(hall: hall),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context, WidgetRef ref) {
    // ✅ FIX 1: Get current filter state before opening
    final currentState = ref.read(searchFilterProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        // ✅ FIX 1: Local temporary state (not Riverpod)
        double tempRating = currentState.minRating;
        RangeValues tempPrice = RangeValues(
          currentState.minPrice,
          currentState.maxPrice,
        );
        RangeValues tempCapacity = RangeValues(
          currentState.minCapacity,
          currentState.maxCapacity,
        );
        String tempLocation = currentState.selectedLocation ?? '';
        List<String> tempFacilities =
            List.from(currentState.selectedFacilities);

        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              expand: false,
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(AppTheme.borderRadiusLarge),
                    ),
                  ),
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(AppTheme.paddingMedium),
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppTheme.paddingMedium),
                      const Text(
                        "Filters",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppTheme.paddingLarge),
                      const Text(
                        "Minimum Rating",
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      const SizedBox(height: 8),

                      /// ✅ FIX 2: ULTRA SMOOTH SLIDER - Local state only
                      Slider(
                        value: tempRating,
                        min: 0,
                        max: 5,
                        divisions: 10,
                        label: tempRating.toStringAsFixed(1),
                        activeColor: AppTheme.primaryGold,
                        onChanged: (value) {
                          /// ✅ Only update local UI state - NO heavy logic
                          setModalState(() {
                            tempRating = value;
                          });
                        },
                      ),
                      const SizedBox(height: AppTheme.paddingMedium),
                      const Text(
                        "Price Range",
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      const SizedBox(height: 8),

                      /// ✅ FIX 3: SMOOTH RANGE SLIDER - Local state only
                      RangeSlider(
                        values: tempPrice,
                        min: 0,
                        max: 1000000,
                        activeColor: AppTheme.primaryGold,
                        onChanged: (RangeValues values) {
                          /// ✅ Only update local UI state - NO heavy logic
                          setModalState(() {
                            tempPrice = values;
                          });
                        },
                      ),
                      Text(
                        "₹${tempPrice.start.toStringAsFixed(0)} - ₹${tempPrice.end.toStringAsFixed(0)}",
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: AppTheme.paddingMedium),

                      /// CAPACITY RANGE
                      const Text(
                        "Capacity Range",
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      RangeSlider(
                        values: tempCapacity,
                        min: 0,
                        max: 2000,
                        divisions: 20,
                        activeColor: AppTheme.primaryGold,
                        onChanged: (RangeValues values) {
                          setModalState(() {
                            tempCapacity = values;
                          });
                        },
                      ),
                      Text(
                        "Capacity: ${tempCapacity.start.toInt()} - ${tempCapacity.end.toInt()} 👥",
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: AppTheme.paddingLarge),

                      /// FACILITIES
                      const Text(
                        "Facilities",
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: const [
                          "AC",
                          "Parking",
                          "Dining",
                          "WiFi",
                          "Stage",
                          "Decoration",
                        ].map((facility) {
                          final selected = tempFacilities.contains(facility);
                          return FilterChip(
                            label: Text(facility),
                            selected: selected,
                            onSelected: (value) {
                              setModalState(() {
                                if (value) {
                                  tempFacilities.add(facility);
                                } else {
                                  tempFacilities.remove(facility);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: AppTheme.paddingLarge),

                      /// ✅ FIX 4: LOCATION FILTER WITH PROPER TEXT MATCHING
                      const Text(
                        "Location",
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        onChanged: (value) {
                          /// ✅ Update local state, not Riverpod
                          setModalState(() {
                            tempLocation = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Search by location (e.g., "Malappuram")',
                          hintStyle: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 13,
                          ),
                          prefixIcon: const Icon(Icons.location_on, size: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppTheme.primaryGold,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                      ),
                      const SizedBox(height: AppTheme.paddingLarge),

                      /// ✅ FIX 5: ACTION BUTTONS
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                /// ✅ FIX 7: CLEAR BUTTON
                                ref
                                    .read(searchFilterProvider.notifier)
                                    .clearFilters();
                                Navigator.pop(context);
                              },
                              child: const Text("Clear"),
                            ),
                          ),
                          const SizedBox(width: AppTheme.paddingMedium),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                /// ✅ FIX 5: APPLY FILTERS - Combine all filters correctly
                                _applyFilters(
                                  ref,
                                  tempRating,
                                  tempPrice,
                                  tempCapacity,
                                  tempLocation,
                                  tempFacilities,
                                );
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryGold,
                              ),
                              child: const Text(
                                "Apply",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  /// ✅ FIX 5: APPLY FILTER LOGIC - Combine all filters correctly
  void _applyFilters(
    WidgetRef ref,
    double rating,
    RangeValues price,
    RangeValues capacity,
    String location,
    List<String> facilities,
  ) {
    // Debug logs
    print("=== FILTERS APPLIED ===");
    print("Rating: $rating+");
    print("Price: ${price.start} - ${price.end}");
    print("Capacity: ${capacity.start} - ${capacity.end}");
    print("Location: '$location'");
    print("Facilities: ${facilities.join(', ')}");
    print("=====================");

    // Normalize location string for case-insensitive matching
    location = location.trim();

    // Update Riverpod state with ALL filters
    ref.read(searchFilterProvider.notifier).updateMinRating(rating);
    ref.read(searchFilterProvider.notifier).updatePriceRange(
          price.start,
          price.end,
        );
    ref.read(searchFilterProvider.notifier).updateCapacityRange(
          capacity.start,
          capacity.end,
        );
    ref.read(searchFilterProvider.notifier).updateLocation(
          location.isEmpty ? null : location,
        );
    ref.read(searchFilterProvider.notifier).updateFacilities(facilities);
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _FilterChip({
    required this.label,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryDark,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Icons.close,
              size: 14,
              color: AppTheme.primaryDark,
            ),
          ),
        ],
      ),
    );
  }
}
