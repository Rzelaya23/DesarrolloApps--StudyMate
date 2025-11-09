import 'package:flutter/material.dart';

/// =======================
/// Modelo de materia
/// =======================
class Subject {
  final String id;
  final String name;
  final Color color; // puedes usar Theme si prefieres centralizar colores

  const Subject({
    required this.id,
    required this.name,
    required this.color,
  });
}

/// =======================
/// Modelo de evento de calendario
/// =======================
class CalendarEvent {
  final String id;
  final String subjectId;
  final String title;
  final DateTime start;
  final DateTime end;
  final String? notes;

  const CalendarEvent({
    required this.id,
    required this.subjectId,
    required this.title,
    required this.start,
    required this.end,
    this.notes,
  });

  /// Helper interno para leer un string desde varias claves posibles.
  /// Ejemplo: ['start', 'startTime', 'start_at'].
  static String _readString(
    Map<String, dynamic> json,
    List<String> keys, {
    String? fallback,
    bool requiredField = false,
  }) {
    for (final key in keys) {
      final value = json[key];
      if (value != null) {
        return value.toString();
      }
    }

    if (requiredField && fallback == null) {
      // Lanzamos un error más claro para que se vea en el `eventsAsync.error`
      throw Exception(
        'Falta el campo obligatorio ${keys.join("/")} en el evento: $json',
      );
    }

    return fallback ?? '';
  }

  /// Helper para leer una fecha desde varias claves posibles.
  static DateTime _readDateTime(
    Map<String, dynamic> json,
    List<String> keys, {
    bool requiredField = false,
  }) {
    final str = _readString(
      json,
      keys,
      requiredField: requiredField,
    );

    if (str.isEmpty) {
      // Si no es obligatorio, devolvemos ahora
      if (!requiredField) {
        // Por si acaso, devolvemos ahora mismo, pero en tu caso
        // para start/end lo marcamos como requiredField:true.
        throw Exception(
          'Valor de fecha vacío para claves ${keys.join("/")}: $json',
        );
      }
    }

    return DateTime.parse(str);
  }

  /// =======================
  /// fromJson: ajusta NOMBRES DE CAMPOS al backend NestJS
  /// =======================
  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    // IMPORTANTE:
    // Ajusta estas listas de claves a lo que devuelva tu backend.
    // Si tu DTO usa, por ejemplo, "startsAt" y "endsAt",
    // solo agrégalo a las listas.
    final start = _readDateTime(
      json,
      ['start', 'startTime', 'start_at', 'startDate', 'startsAt'],
      requiredField: true,
    );

    final end = _readDateTime(
      json,
      ['end', 'endTime', 'end_at', 'endDate', 'endsAt'],
      requiredField: true,
    );

    return CalendarEvent(
      id: _readString(
        json,
        ['id', '_id'],
        requiredField: true,
      ),
      subjectId: _readString(
        json,
        ['subjectId', 'subject_id', 'subject', 'courseId'],
        fallback: '',
      ),
      title: _readString(
        json,
        ['title', 'name'],
        fallback: 'Sin título',
      ),
      start: start,
      end: end,
      notes: _readString(
        json,
        ['notes', 'description'],
        fallback: '',
      ).isEmpty
          ? null
          : _readString(
              json,
              ['notes', 'description'],
              fallback: '',
            ),
    );
  }

  /// =======================
  /// toJson: por si luego quieres enviar al backend
  /// =======================
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subjectId': subjectId,
      'title': title,
      'start': start.toIso8601String(),
      'end': end.toIso8601String(),
      'notes': notes,
    };
  }
}
