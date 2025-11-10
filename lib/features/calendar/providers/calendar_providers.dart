// lib/features/calendar/providers/calendar_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mi_app/core/auth/auth_token_provider.dart';
import 'package:mi_app/features/calendar/data/event_service.dart';
import 'package:mi_app/features/calendar/models/calendar_models.dart';

// 👇 Importa materias reales del backend
import 'package:mi_app/features/subjects/providers/subjects_providers.dart';

/// =============================================================
/// Servicio de eventos
/// =============================================================
final eventServiceProvider = Provider<EventService>((ref) {
  return const EventService();
});

/// =============================================================
/// FutureProvider para obtener eventos del backend
/// =============================================================
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
      print('❌ Error cargando eventos: $e');
    }
  }

  Future<void> refresh() => _loadFromBackend();

  /// Crear evento y actualizar estado
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

/// =============================================================
/// Provider principal usado por la UI del calendario
/// =============================================================
final eventsProvider =
    StateNotifierProvider<EventsNotifier, List<CalendarEvent>>(
  (ref) => EventsNotifier(ref),
);
