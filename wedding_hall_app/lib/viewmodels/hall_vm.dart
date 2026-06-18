import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/hall_service.dart';
import '../models/hall_model.dart';

final hallProvider =
    StateNotifierProvider<HallViewModel, AsyncValue<List<HallModel>>>(
  (ref) => HallViewModel(),
);

class HallViewModel extends StateNotifier<AsyncValue<List<HallModel>>> {
  HallViewModel() : super(const AsyncLoading()) {
    loadInitialHalls();
  }

  final HallService _service = HallService();

  /// 🔹 Initial load when app starts
  Future<void> loadInitialHalls() async {
    try {
      final halls = await _service.getHalls();
      state = AsyncData(halls);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// 🔹 Fetch halls with filters
  Future<void> fetchHalls({
    List<String>? locations,
    double? minPrice,
    double? maxPrice,
    double? minCapacity,
    double? maxCapacity,
    double? minRating,
    double? maxRating,
    List<String>? facilities,
    String? sort,
    String? search,
  }) async {
    try {
      final halls = await _service.getHalls(
        locations: locations,
        minPrice: minPrice,
        maxPrice: maxPrice,
        minCapacity: minCapacity,
        maxCapacity: maxCapacity,
        minRating: minRating,
        maxRating: maxRating,
        facilities: facilities,
        sort: sort,
        search: search,
      );

      state = AsyncData(halls);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// 🔹 Refresh halls manually
  Future<void> refresh() async {
    state = const AsyncLoading();
    await loadInitialHalls();
  }
}
