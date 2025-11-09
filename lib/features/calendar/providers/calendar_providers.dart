import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mi_app/core/auth/auth_token_provider.dart';
import 'package:mi_app/features/calendar/data/event_service.dart';
import 'package:mi_app/features/calendar/models/calendar_models.dart';

/// =============================================================
/// SUBJECTS (Materias) – dummy para la UI
/// =============================================================
final subjectsProvider = Provider<Map<String, Subject>>((ref) {
  return {
    'math': const Subject(
      id: 'math',
      name: 'Matemáticas',
      color: Colors.blue,
    ),
    'physics': const Subject(
      id: 'physics',
      name: 'Física',
      color: Colors.red,
    ),
    'history': const Subject(
      id: 'history',
      name: 'Historia',
      color: Colors.green,
    ),
  };
});

/// =============================================================
/// Servicio de eventos
/// =============================================================
final eventServiceProvider = Provider<EventService>((ref) {
  return const EventService();
});

/// Si en alguna pantalla quieres consumir directamente el Future:
final eventsFromBackendProvider =
    FutureProvider.autoDispose<List<CalendarEvent>>((ref) async {
  final token = ref.watch(authTokenProvider);

  if (token == null || token.isEmpty) {
    throw Exception('Usuario no autenticado');
  }

  final service = ref.read(eventServiceProvider);
  return service.getEvents(token);
});

/// =============================================================
/// STATE NOTIFIER: maneja lista de eventos + llamadas al backend
/// =============================================================
class EventsNotifier extends StateNotifier<List<CalendarEvent>> {
  EventsNotifier(this._ref) : super(const []) {
    _loadFromBackend();
  }

  final Ref _ref;

  EventService get _service => _ref.read(eventServiceProvider);

  String? get _token => _ref.read(authTokenProvider);

  Future<void> _loadFromBackend() async {
    final token = _token;
    if (token == null || token.isEmpty) return;

    try {
      final events = await _service.getEvents(token);
      state = List.unmodifiable(events);
    } catch (e) {
      // En prod podrías loguear el error
    }
  }

  Future<void> refresh() => _loadFromBackend();

  /// Crear evento: golpea backend y actualiza el estado
  Future<CalendarEvent> createEvent(CalendarEvent draft) async {
    final token = _token;
    if (token == null || token.isEmpty) {
      throw Exception('Usuario no autenticado');
    }

    final created = await _service.createEvent(token, draft);
    state = List.unmodifiable([...state, created]);
    return created;
  }

  /// Actualizar evento existente
  Future<CalendarEvent> updateEvent(CalendarEvent draft) async {
    final token = _token;
    if (token == null || token.isEmpty) {
      throw Exception('Usuario no autenticado');
    }

    final updated = await _service.updateEvent(token, draft);
    state = List.unmodifiable([
      for (final e in state) if (e.id == updated.id) updated else e,
    ]);
    return updated;
  }

  /// Eliminar evento
  Future<void> deleteEvent(String id) async {
    final token = _token;
    if (token == null || token.isEmpty) {
      throw Exception('Usuario no autenticado');
    }

    await _service.deleteEvent(token, id);
    state = List.unmodifiable(
      state.where((e) => e.id != id).toList(),
    );
  }
}

/// Provider que usa la UI (EventEditorSheet, calendar view, etc.)
final eventsProvider =
    StateNotifierProvider<EventsNotifier, List<CalendarEvent>>(
  (ref) => EventsNotifier(ref),
);
