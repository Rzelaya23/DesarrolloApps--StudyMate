import 'planner_activity.dart';

class PlannerSlot {
  final String title;
  final DateTime start;
  final DateTime end;
  final bool isBreak;
  final String? activityId;

  PlannerSlot({
    required this.title,
    required this.start,
    required this.end,
    required this.isBreak,
    required this.activityId,
  });

  factory PlannerSlot.fromJson(Map<String, dynamic> json) {
    return PlannerSlot(
      title: json['title'] as String,
      start: DateTime.parse(json['start'] as String),
      end: DateTime.parse(json['end'] as String),
      isBreak: json['isBreak'] as bool? ?? false,
      activityId: json['activityId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'start': start.toIso8601String(),
      'end': end.toIso8601String(),
      'isBreak': isBreak,
      'activityId': activityId,
    };
  }
}

class PlannerScheduleResponse {
  final DateTime date;
  final List<PlannerSlot> items;

  PlannerScheduleResponse({
    required this.date,
    required this.items,
  });

  factory PlannerScheduleResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['items'] as List<dynamic>? ?? [])
        .map((e) => PlannerSlot.fromJson(e as Map<String, dynamic>))
        .toList();
    return PlannerScheduleResponse(
      date: DateTime.parse(json['date'] as String),
      items: list,
    );
  }
}
