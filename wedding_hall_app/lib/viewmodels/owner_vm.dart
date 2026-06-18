import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/owner_service.dart';
import '../services/hall_service.dart';
import '../models/hall_model.dart';

final ownerProvider =
    StateNotifierProvider<OwnerViewModel, AsyncValue<Map<String, dynamic>>>(
  (ref) => OwnerViewModel(),
);

final ownerHallsProvider =
    StateNotifierProvider<OwnerHallsViewModel, AsyncValue<List<HallModel>>>(
  (ref) => OwnerHallsViewModel(),
);

final hallStatsProvider = FutureProvider.family<Map<String, dynamic>, String>(
  (ref, hallId) {
    final ownerService = OwnerService();
    return ownerService.getHallStats(hallId);
  },
);

class OwnerViewModel extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  OwnerViewModel() : super(const AsyncLoading()) {
    loadOwnerStats();
  }

  final OwnerService _service = OwnerService();

  Future<void> loadOwnerStats() async {
    state = const AsyncLoading();

    try {
      final data = await _service.getOwnerStats();

      state = AsyncData(data);
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }
}

class OwnerHallsViewModel extends StateNotifier<AsyncValue<List<HallModel>>> {
  OwnerHallsViewModel() : super(const AsyncLoading()) {
    loadMyHalls();
  }

  final HallService _service = HallService();

  Future<void> loadMyHalls() async {
    state = const AsyncLoading();

    try {
      final halls = await _service.getMyHalls();
      state = AsyncData(halls);
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }
}
