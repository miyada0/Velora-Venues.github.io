import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/hall_vm.dart';
import '../viewmodels/search_filter_vm.dart';

class FilterBottomSheet extends ConsumerStatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  ConsumerState<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<FilterBottomSheet> {
  final List<String> allLocations = [
    "Malappuram",
    "Perinthalmanna",
    "Vengara",
    "Kodur",
  ];

  List<String> selectedLocations = [];
  RangeValues priceRange = const RangeValues(20000, 300000);
  RangeValues capacityRange = const RangeValues(0, 2000);
  RangeValues ratingRange = const RangeValues(1.0, 5.0);
  String sort = "price_low";

  // Facilities filter
  final List<String> allFacilities = [
    "AC",
    "Parking",
    "Dining",
    "WiFi",
    "Stage",
    "Decoration",
  ];
  List<String> selectedFacilities = [];

  @override
  void initState() {
    super.initState();
    // Initialize local state from Riverpod state
    _initializeFromRiverpod();
  }

  void _initializeFromRiverpod() {
    final filters = ref.read(searchFilterProvider);
    setState(() {
      priceRange = RangeValues(filters.minPrice, filters.maxPrice);
      capacityRange = RangeValues(filters.minCapacity, filters.maxCapacity);
      ratingRange = RangeValues(filters.minRating, 5.0);
      selectedLocations =
          filters.selectedLocation != null ? [filters.selectedLocation!] : [];
      selectedFacilities = filters.selectedFacilities;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Filter Halls",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            /// MULTI LOCATION
            const Text("Locations"),
            Wrap(
              spacing: 8,
              children: allLocations.map((loc) {
                final selected = selectedLocations.contains(loc);

                return FilterChip(
                  label: Text(loc),
                  selected: selected,
                  onSelected: (value) {
                    setState(() {
                      if (value) {
                        selectedLocations = [loc]; // Single selection
                      } else {
                        selectedLocations = [];
                      }
                    });
                    // Sync to Riverpod
                    ref.read(searchFilterProvider.notifier).updateLocation(
                          selectedLocations.isNotEmpty
                              ? selectedLocations[0]
                              : null,
                        );
                    print(
                        "Location selected: ${selectedLocations.isNotEmpty ? selectedLocations[0] : 'none'}");
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            /// PRICE RANGE
            const Text("Price Range"),
            RangeSlider(
              values: priceRange,
              min: 10000,
              max: 200000,
              divisions: 10,
              labels: RangeLabels(
                "₹${priceRange.start.round()}",
                "₹${priceRange.end.round()}",
              ),
              onChanged: (values) {
                setState(() {
                  priceRange = values;
                });
                // Sync to Riverpod
                ref.read(searchFilterProvider.notifier).updatePriceRange(
                      values.start,
                      values.end,
                    );
                print("Price range changed: ${values.start} - ${values.end}");
              },
            ),

            const SizedBox(height: 20),

            /// CAPACITY RANGE
            const Text("Capacity Range"),
            RangeSlider(
              values: capacityRange,
              min: 0,
              max: 2000,
              divisions: 20,
              labels: RangeLabels(
                capacityRange.start.toInt().toString(),
                capacityRange.end.toInt().toString(),
              ),
              onChanged: (values) {
                setState(() {
                  capacityRange = values;
                });
                // Sync to Riverpod
                ref.read(searchFilterProvider.notifier).updateCapacityRange(
                      values.start,
                      values.end,
                    );
                print(
                    "Capacity range changed: ${values.start} - ${values.end}");
              },
            ),

            const SizedBox(height: 20),

            /// RATING RANGE
            const Text("Rating Range"),
            RangeSlider(
              values: ratingRange,
              min: 1.0,
              max: 5.0,
              divisions: 8,
              labels: RangeLabels(
                ratingRange.start.toStringAsFixed(1),
                ratingRange.end.toStringAsFixed(1),
              ),
              onChanged: (values) {
                setState(() {
                  ratingRange = values;
                });
                // Sync to Riverpod - use min rating only for filter
                ref.read(searchFilterProvider.notifier).updateMinRating(
                      values.start,
                    );
                print("Rating filter changed: ${values.start} and above");
              },
            ),

            const SizedBox(height: 20),

            /// FACILITIES FILTER
            const Text("Facilities"),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: allFacilities.map((facility) {
                final selected = selectedFacilities.contains(facility);

                return Theme(
                  data: Theme.of(context).copyWith(
                    
                  ),
                  child: FilterChip(
                    label: Text(facility),
                    selected: selected,
                    onSelected: (value) {
                      setState(() {
                        if (value) {
                          selectedFacilities.add(facility);
                        } else {
                          selectedFacilities.remove(facility);
                        }
                      });
                      // Sync to Riverpod
                      ref
                          .read(searchFilterProvider.notifier)
                          .updateFacilities(selectedFacilities);
                      print(
                          "Facilities changed: ${selectedFacilities.join(', ')}");
                    },
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            /// SORT
            const Text("Sort By"),
            DropdownButton<String>(
              value: sort,
              isExpanded: true,
              items: const [
                DropdownMenuItem(
                    value: "price_low", child: Text("Price: Low to High")),
                DropdownMenuItem(
                    value: "price_high", child: Text("Price: High to Low")),
                DropdownMenuItem(
                    value: "rating_high", child: Text("Rating: High to Low")),
                DropdownMenuItem(
                    value: "capacity_high",
                    child: Text("Capacity: High to Low")),
              ],
              onChanged: (value) {
                setState(() {
                  sort = value!;
                });
                print("Sort changed: $sort");
              },
            ),
            const SizedBox(height: 30),

            /// APPLY BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Debug logs
                  print("=== FILTERS APPLIED ===");
                  print("Price Range: ${priceRange.start} - ${priceRange.end}");
                  print(
                      "Capacity Range: ${capacityRange.start} - ${capacityRange.end}");
                  print("Rating Filter: ${ratingRange.start}+");
                  print("Location: ${selectedLocations.join(', ')}");
                  print("Facilities: ${selectedFacilities.join(', ')}");
                  print("Sort: $sort");
                  print("=====================");

                  // Sync final state to Riverpod
                  ref.read(searchFilterProvider.notifier).updatePriceRange(
                        priceRange.start,
                        priceRange.end,
                      );
                  ref.read(searchFilterProvider.notifier).updateCapacityRange(
                        capacityRange.start,
                        capacityRange.end,
                      );
                  ref.read(searchFilterProvider.notifier).updateMinRating(
                        ratingRange.start,
                      );
                  ref.read(searchFilterProvider.notifier).updateLocation(
                        selectedLocations.isNotEmpty
                            ? selectedLocations[0]
                            : null,
                      );
                  ref.read(searchFilterProvider.notifier).updateFacilities(
                        selectedFacilities,
                      );

                  // Fetch from API with filters
                  ref.read(hallProvider.notifier).fetchHalls(
                        locations: selectedLocations,
                        minPrice: priceRange.start,
                        maxPrice: priceRange.end,
                        minCapacity: capacityRange.start,
                        maxCapacity: capacityRange.end,
                        minRating: ratingRange.start,
                        maxRating: ratingRange.end,
                        facilities: selectedFacilities,
                        sort: sort,
                      );

                  Navigator.pop(context);
                },
                child: const Text("Apply Filters"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
