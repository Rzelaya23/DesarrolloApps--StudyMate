import 'package:flutter/material.dart';

class Subject {
  final String id;
  final String name;
  final Color color; // usa Theme si prefieres centralizar

  const Subject({required this.id, required this.name, required this.color});
}

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
}
