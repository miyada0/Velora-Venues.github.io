import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/hall_model.dart';
import 'hall_vm.dart';

class SearchFilterState {
  final String searchQuery;
  final double minPrice;
  final double maxPrice;
  final double minCapacity;
  final double maxCapacity;
  final double minRating;
  final String? selectedLocation;
  final List<String> selectedFacilities;

  SearchFilterState({
    this.searchQuery = '',
    this.minPrice = 0,
    this.maxPrice = 1000000,
    this.minCapacity = 0,
    this.maxCapacity = 2000,
    this.minRating = 0,
    this.selectedLocation,
    this.selectedFacilities = const [],
  });

  SearchFilterState copyWith({
    String? searchQuery,
    double? minPrice,
    double? maxPrice,
    double? minCapacity,
    double? maxCapacity,
    double? minRating,
    String? selectedLocation,
    List<String>? selectedFacilities,
  }) {
    return SearchFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      minCapacity: minCapacity ?? this.minCapacity,
      maxCapacity: maxCapacity ?? this.maxCapacity,
      minRating: minRating ?? this.minRating,
      selectedLocation: selectedLocation ?? this.selectedLocation,
      selectedFacilities: selectedFacilities ?? this.selectedFacilities,
    );
  }

  bool hasActiveFilters() {
    return searchQuery.isNotEmpty ||
        minRating > 0 ||
        minPrice > 0 ||
        maxPrice < 1000000 ||
        minCapacity > 0 ||
        maxCapacity < 2000 ||
        selectedLocation != null ||
        selectedFacilities.isNotEmpty;
  }
}

final searchFilterProvider =
    StateNotifierProvider<SearchFilterNotifier, SearchFilterState>(
  (ref) => SearchFilterNotifier(),
);

class SearchFilterNotifier extends StateNotifier<SearchFilterState> {
  SearchFilterNotifier() : super(SearchFilterState());

  void updateSearch(String query) {
    state = state.copyWith(searchQuery: query);
    print("[Filter] Search updated: '$query'");
  }

  void updatePriceRange(double minPrice, double maxPrice) {
    state = state.copyWith(minPrice: minPrice, maxPrice: maxPrice);
    print("[Filter] Price range updated: $minPrice - $maxPrice");
  }

  void updateCapacityRange(double minCapacity, double maxCapacity) {
    state = state.copyWith(minCapacity: minCapacity, maxCapacity: maxCapacity);
    print("[Filter] Capacity range updated: $minCapacity - $maxCapacity");
  }

  void updateMinRating(double rating) {
    state = state.copyWith(minRating: rating);
    print("[Filter] Rating filter updated: $rating+");
  }

  void updateLocation(String? location) {
    state = state.copyWith(selectedLocation: location);
    print("[Filter] Location updated: '$location'");
  }

  void updateFacilities(List<String> facilities) {
    state = state.copyWith(selectedFacilities: facilities);
    print("[Filter] Facilities updated: ${facilities.join(', ')}");
  }

  void clearFilters() {
    state = SearchFilterState();
    print("[Filter] All filters cleared");
  }
}

// Provider that returns filtered halls based on search/filter criteria
final filteredHallsProvider = Provider<List<HallModel>>((ref) {
  final hallAsyncValue = ref.watch(hallProvider);
  final filters = ref.watch(searchFilterProvider);

  final result = hallAsyncValue.when(
    data: (halls) {
      final filtered = _applyFilters(halls, filters);
      print(
          "[Filtered Halls] Total: ${halls.length}, Filtered: ${filtered.length}");
      return filtered;
    },
    loading: () => <HallModel>[],
    error: (_, __) => <HallModel>[],
  );

  return result;
});

/// Apply search and filter logic to halls list
List<HallModel> _applyFilters(
    List<HallModel> halls, SearchFilterState filters) {
  return halls.where((hall) {
    // Search filter (name and location)
    if (filters.searchQuery.isNotEmpty) {
      final query = filters.searchQuery.toLowerCase();
      final matchesName = hall.name.toLowerCase().contains(query);
      final matchesLocation = hall.location.toLowerCase().contains(query);
      if (!matchesName && !matchesLocation) {
        return false;
      }
    }

    // Price filter
    if (hall.price < filters.minPrice || hall.price > filters.maxPrice) {
      return false;
    }

    // Capacity filter
    if (hall.capacity < filters.minCapacity ||
        hall.capacity > filters.maxCapacity) {
      return false;
    }

    // Rating filter
    if (hall.rating < filters.minRating) {
      return false;
    }

    // Location filter
    if (filters.selectedLocation != null &&
        filters.selectedLocation!.isNotEmpty) {
      if (!hall.location
          .toLowerCase()
          .contains(filters.selectedLocation!.toLowerCase())) {
        return false;
      }
    }

    // Facilities filter - hall must have ALL selected facilities
    if (filters.selectedFacilities.isNotEmpty) {
      final hallFacilities = hall.facilities;
      final hasAllFacilities = filters.selectedFacilities
          .every((facility) => hallFacilities.contains(facility));
      if (!hasAllFacilities) {
        return false;
      }
    }

    return true;
  }).toList();
}
