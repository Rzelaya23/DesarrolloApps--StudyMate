enum Difficulty { facil, intermedia, avanzada }
enum Priority { baja, media, alta }

extension DifficultyX on Difficulty {
  double get weight => switch (this) {
    Difficulty.facil => 0.8,
    Difficulty.intermedia => 1.0,
    Difficulty.avanzada => 1.2,
  };
}

extension PriorityX on Priority {
  int get score => switch (this) {
    Priority.alta => 3,
    Priority.media => 2,
    Priority.baja => 1,
  };
}

class ActivityInput {
  final String id;
  final String titulo;
  final int minutos;            // duración estimada
  final Priority prioridad;
  final Difficulty dificultad;

  ActivityInput({
    required this.id,
    required this.titulo,
    required this.minutos,
    required this.prioridad,
    required this.dificultad,
  });
}

class PlannerSettings {
  final DateTime start;         // inicio del día
  final DateTime end;           // fin del día
  final int focoMin;            // bloque de foco (min)
  final int breakMin;           // descanso entre bloques (min)

  const PlannerSettings({
    required this.start,
    required this.end,
    this.focoMin = 50,
    this.breakMin = 10,
  });
}

class ScheduledBlock {
  final String activityId;
  final String titulo;
  final DateTime start;
  final DateTime end;
  final bool isBreak;

  ScheduledBlock({
    required this.activityId,
    required this.titulo,
    required this.start,
    required this.end,
    this.isBreak = false,
  });
}
