// lib/features/planner/providers/planner_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/planner_activity.dart';
import '../data/models/planner_schedule.dart';
import '../data/planner_repository.dart';

// -------------------- ACTIVIDADES --------------------

class PlannerActivitiesNotifier extends StateNotifier<AsyncValue<List<PlannerActivity>>> {
  final PlannerRepository repo;
  PlannerActivitiesNotifier(this.repo) : super(const AsyncValue.data([]));

  Future<void> addActivity({
    required String title,
    required int durationMin,
    required String priority,
    required String difficulty,
    required DateTime date,
  }) async {
    state = const AsyncValue.loading();
    try {
      final created = await repo.createActivity(
        title: title,
        durationMin: durationMin,
        priority: priority,
        difficulty: difficulty,
        date: date,
      );
      final current = state.value ?? [];
      state = AsyncValue.data([...current, created]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final plannerActivitiesProvider = StateNotifierProvider<PlannerActivitiesNotifier, AsyncValue<List<PlannerActivity>>>((ref) {
  final repo = ref.read(plannerRepositoryProvider);
  return PlannerActivitiesNotifier(repo);
});

// -------------------- HORARIO GENERADO --------------------

class PlannerScheduleNotifier extends StateNotifier<AsyncValue<List<PlannerSlot>>> {
  final PlannerRepository repo;
  PlannerScheduleNotifier(this.repo) : super(const AsyncValue.data([]));

  Future<void> generate({
    required DateTime date,
    required String start,
    required String end,
    required int focusMin,
    required int breakMin,
  }) async {
    state = const AsyncValue.loading();
    try {
      final items = await repo.generateSchedule(
        date: date,
        start: start,
        end: end,
        focusMin: focusMin,
        breakMin: breakMin,
      );
      state = AsyncValue.data(items);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void clear() {
    state = const AsyncValue.data([]);
  }
}

final plannerScheduleProvider =
    StateNotifierProvider<PlannerScheduleNotifier, AsyncValue<List<PlannerSlot>>>((ref) {
  final repo = ref.read(plannerRepositoryProvider);
  return PlannerScheduleNotifier(repo);
});
