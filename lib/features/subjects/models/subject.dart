import 'package:flutter/material.dart';

class Subject {
  final String id;
  final String name;
  final String? teacher;
  final String? schedule;
  final double progress;
  final Color color;

  Subject({
    required this.id,
    required this.name,
    this.teacher,
    this.schedule,
    this.progress = 0.0,
    Color? color, // 👈 ya no es required
  }) : color = color ?? Colors.indigo; // valor por defecto

  /// Construye desde la respuesta del backend (NestJS).
  /// El backend usa `title` (no `name`), y probablemente devuelve un `id` string.
  factory Subject.fromJson(Map<String, dynamic> json) {
    final title = (json['title'] ?? json['name'] ?? '') as String;
    final id = (json['id'] ?? json['_id'] ?? '').toString();

    final teacher = json['teacher'] as String?;
    final schedule = json['schedule'] as String?;
    final progressNum = json['progress'] as num? ?? 0;

    // Color estable a partir del título
    final colorIndex = (title.hashCode.abs()) % Colors.primaries.length;
    final generatedColor = Colors.primaries[colorIndex];

    return Subject(
      id: id,
      name: title,
      teacher: teacher,
      schedule: schedule,
      progress: progressNum.toDouble(),
      color: generatedColor,
    );
  }

  /// JSON que se envía al backend NestJS.
  /// Aquí resolvemos el 400: mandamos `title` y `code` como string.
  Map<String, dynamic> toJsonForBackend() {
    return {
      'title': name,
      'code': name, // por ahora usamos el mismo valor como código
      if (teacher != null && teacher!.trim().isNotEmpty) 'teacher': teacher,
      if (schedule != null && schedule!.trim().isNotEmpty) 'schedule': schedule,
    };
  }

  Subject copyWith({
    String? id,
    String? name,
    String? teacher,
    String? schedule,
    double? progress,
    Color? color,
  }) {
    return Subject(
      id: id ?? this.id,
      name: name ?? this.name,
      teacher: teacher ?? this.teacher,
      schedule: schedule ?? this.schedule,
      progress: progress ?? this.progress,
      color: color ?? this.color,
    );
  }
}
