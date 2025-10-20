import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/planner_models.dart';
import '../data/planner_scheduler.dart'; // buildSchedule()

final _uuid = const Uuid();

class PlannerState {
  final List<ActivityInput> actividades;
  final PlannerSettings settings;
  final List<ScheduledBlock> resultado;

  const PlannerState({
    required this.actividades,
    required this.settings,
    this.resultado = const [],
  });

  PlannerState copyWith({
    List<ActivityInput>? actividades,
    PlannerSettings? settings,
    List<ScheduledBlock>? resultado,
  }) {
    return PlannerState(
      actividades: actividades ?? this.actividades,
      settings: settings ?? this.settings,
      resultado: resultado ?? this.resultado,
    );
  }
}

class PlannerNotifier extends Notifier<PlannerState> {
  @override
  PlannerState build() {
    final now = DateTime.now();
    final startTime = DateTime(now.year, now.month, now.day, 8);   // 08:00
    final endTime   = DateTime(now.year, now.month, now.day, 22);  // 22:00

    return PlannerState(
      actividades: const [],
      settings: PlannerSettings(
        start: startTime,
        end: endTime,
        focoMin: 50,
        breakMin: 10,
      ),
    );
  }

  void addActividad({
    required String titulo,
    required int minutos,
    required Priority prioridad,
    required Difficulty dificultad,
  }) {
    final a = ActivityInput(
      id: _uuid.v4(),
      titulo: titulo,
      minutos: minutos, // <- usamos 'minutos' (no 'duracion')
      prioridad: prioridad,
      dificultad: dificultad,
    );
    state = state.copyWith(actividades: [...state.actividades, a]);
  }

  void removeActividad(String id) {
    state = state.copyWith(
      actividades: state.actividades.where((e) => e.id != id).toList(),
    );
  }

  void setVentana(DateTime newStart, DateTime newEnd) {
    state = state.copyWith(
      settings: PlannerSettings(
        start: newStart,
        end: newEnd,
        focoMin: state.settings.focoMin,
        breakMin: state.settings.breakMin,
      ),
    );
  }

  void setParametros({int? focoMin, int? breakMin}) {
    state = state.copyWith(
      settings: PlannerSettings(
        start: state.settings.start,
        end: state.settings.end,
        focoMin: focoMin ?? state.settings.focoMin,
        breakMin: breakMin ?? state.settings.breakMin,
      ),
    );
  }

  /// Genera el horario a partir de actividades + settings
  void generar() {
    final result = buildSchedule(
      actividades: state.actividades,
      settings: state.settings,
    );
    state = state.copyWith(resultado: result);
  }

  void limpiarResultado() {
    state = state.copyWith(resultado: const []);
  }
}

final plannerProvider =
    NotifierProvider<PlannerNotifier, PlannerState>(PlannerNotifier.new);
