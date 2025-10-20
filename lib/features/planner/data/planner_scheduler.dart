import '../models/planner_models.dart';

List<ScheduledBlock> buildSchedule({
  required List<ActivityInput> actividades,
  required PlannerSettings settings,
}) {
  // 1) ordenar por prioridad desc y dificultad desc
  final tasks = [...actividades]
    ..sort((a,b) {
      final p = b.prioridad.score.compareTo(a.prioridad.score);
      if (p != 0) return p;
      // pondera dificultad (avanzada primero)
      return b.dificultad.weight.compareTo(a.dificultad.weight);
    });

  final blocks = <ScheduledBlock>[];
  DateTime cursor = settings.start;

  bool fits(Duration d) => cursor.add(d).isBefore(settings.end) || cursor.add(d).isAtSameMomentAs(settings.end);

  for (final t in tasks) {
    var remaining = Duration(minutes: t.minutos);
    while (remaining.inMinutes > 0) {
      if (!fits(const Duration(minutes: 1))) break; // sin espacio

      // tamaño del bloque: menor entre foco y remaining
      final chunk = Duration(
        minutes: remaining.inMinutes.clamp(0, settings.focoMin),
      );

      if (!fits(chunk)) break;

      final start = cursor;
      final end = cursor.add(chunk);
      blocks.add(ScheduledBlock(
        activityId: t.id,
        titulo: t.titulo,
        start: start,
        end: end,
      ));
      cursor = end;
      remaining -= chunk;

      // descanso si aún queda tarea y hay espacio
      if (remaining.inMinutes > 0) {
        final rest = Duration(minutes: settings.breakMin);
        if (fits(rest)) {
          blocks.add(ScheduledBlock(
            activityId: '${t.id}-break-${start.millisecondsSinceEpoch}',
            titulo: 'Descanso',
            start: cursor,
            end: cursor.add(rest),
            isBreak: true,
          ));
          cursor = cursor.add(rest);
        } else {
          break; // no cabe el descanso
        }
      }
    }
    // si no terminó por falta de tiempo, continúa con la siguiente
    if (!fits(const Duration(minutes: 1))) break;
  }

  return blocks;
}
