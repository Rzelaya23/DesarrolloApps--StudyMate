import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/calendar_models.dart';

/// ----------------------
/// MATERIAS (igual que antes)
/// ----------------------
final subjectsProvider = Provider<Map<String, Subject>>((ref) {
  return const {
    'mate': Subject(id: 'mate', name: 'Matemáticas', color: Colors.blue),
    'prog': Subject(id: 'prog', name: 'Programación', color: Colors.green),
    'hist': Subject(id: 'hist', name: 'Historia', color: Colors.red),
  };
});

/// ----------------------
/// EVENTOS con Notifier (add / update / delete)
/// ----------------------

/// Notifier con operaciones CRUD
class EventsNotifier extends StateNotifier<List<CalendarEvent>> {
  EventsNotifier(super.state);

  void add(CalendarEvent e) {
    state = [...state, e];
  }

  void update(CalendarEvent e) {
    state = [
      for (final it in state) if (it.id == e.id) e else it,
    ];
  }

  void delete(String id) {
    state = state.where((e) => e.id != id).toList();
  }
}

/// Reemplaza el antiguo StateProvider<List<CalendarEvent>>
/// por un StateNotifierProvider que expone la LISTA igual,
/// pero ahora con métodos CRUD disponibles.
final eventsProvider =
StateNotifierProvider<EventsNotifier, List<CalendarEvent>>((ref) {
  final now = DateTime.now();
  DateTime at(int d, int h, int m) =>
      DateTime(now.year, now.month, d, h, m);

  return EventsNotifier([
    CalendarEvent(
      id: '1',
      subjectId: 'prog',
      title: 'Entrega Proyecto UI',
      start: at(2, 9, 0),
      end: at(2, 10, 30),
      notes: 'Subir a GitHub Classroom',
    ),
    CalendarEvent(
      id: '2',
      subjectId: 'mate',
      title: 'Quiz Derivadas',
      start: at(2, 13, 0),
      end: at(2, 13, 30),
    ),
    CalendarEvent(
      id: '3',
      subjectId: 'hist',
      title: 'Lectura Cap. 5',
      start: at(5, 8, 0),
      end: at(5, 9, 0),
    ),
  ]);
});

/// ----------------------
/// Mapa (día -> eventos) para TableCalendar (igual interfaz de antes)
/// ----------------------
final eventsByDayProvider = Provider<Map<DateTime, List<CalendarEvent>>>((ref) {
  final list = ref.watch(eventsProvider); // sigue devolviendo List<CalendarEvent>
  final map = <DateTime, List<CalendarEvent>>{};

  DateTime keyOf(DateTime d) => DateTime(d.year, d.month, d.day);

  for (final e in list) {
    final k = keyOf(e.start);
    (map[k] ??= <CalendarEvent>[]).add(e);
  }
  return map;
});
