// lib/features/calendar/data/event_service.dart
import 'package:dio/dio.dart';
import 'package:mi_app/core/api/api_client.dart';
import 'package:mi_app/features/calendar/models/calendar_models.dart';

class EventService {
  const EventService();

  ApiClient _buildClient(String accessToken) {
    return ApiClient(accessToken: accessToken);
  }

  /// ==========================
  /// GET /api/v1/events
  /// ==========================
  Future<List<CalendarEvent>> getEvents(String accessToken) async {
    final apiClient = _buildClient(accessToken);

    try {
      final Response response = await apiClient.client.get('/api/v1/events');

      final data = response.data;
      if (data is! List) {
        throw Exception('Formato inesperado de respuesta en /api/v1/events');
      }

      return data
          .map((e) => CalendarEvent.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      print('Error al obtener eventos: ${e.response?.data ?? e.message}');
      throw Exception(
        'Error al obtener eventos: ${e.response?.data ?? e.message}',
      );
    }
  }

  /// ==========================
  /// POST /api/v1/events
  /// Crear nuevo evento
  /// ==========================
  Future<CalendarEvent> createEvent(
    String accessToken,
    CalendarEvent event,
  ) async {
    final apiClient = _buildClient(accessToken);

    final payload = {
      'subjectId': event.subjectId,
      'title': event.title,
      'startsAt': event.start.toIso8601String(),
      'endsAt': event.end.toIso8601String(),
      'notes': event.notes,
    };

    try {
      final Response response = await apiClient.client.post(
        '/api/v1/events',
        data: payload,
      );

      return CalendarEvent.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      print('Error al crear evento: ${e.response?.data ?? e.message}');
      throw Exception(
        'Error al crear evento: ${e.response?.data ?? e.message}',
      );
    }
  }

  /// ==========================
  /// PATCH /api/v1/events/:id
  /// Actualizar evento existente
  /// ==========================
  Future<CalendarEvent> updateEvent(
    String accessToken,
    CalendarEvent event,
  ) async {
    final apiClient = _buildClient(accessToken);

    final payload = {
      'subjectId': event.subjectId,
      'title': event.title,
      'startsAt': event.start.toIso8601String(),
      'endsAt': event.end.toIso8601String(),
      'notes': event.notes,
    };

    try {
      final Response response = await apiClient.client.patch(
        '/api/v1/events/${event.id}',
        data: payload,
      );

      return CalendarEvent.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      print('Error al actualizar evento: ${e.response?.data ?? e.message}');
      throw Exception(
        'Error al actualizar evento: ${e.response?.data ?? e.message}',
      );
    }
  }

  /// ==========================
  /// DELETE /api/v1/events/:id
  /// ==========================
  Future<void> deleteEvent(String accessToken, String id) async {
    final apiClient = _buildClient(accessToken);

    try {
      await apiClient.client.delete('/api/v1/events/$id');
    } on DioException catch (e) {
      print('Error al eliminar evento: ${e.response?.data ?? e.message}');
      throw Exception(
        'Error al eliminar evento: ${e.response?.data ?? e.message}',
      );
    }
  }
}
