class PlannerActivity {
  final String id;
  final String title;
  final int durationMin;
  final String priority;
  final String difficulty;
  final DateTime date;

  PlannerActivity({
    required this.id,
    required this.title,
    required this.durationMin,
    required this.priority,
    required this.difficulty,
    required this.date,
  });

  factory PlannerActivity.fromJson(Map<String, dynamic> json) {
    return PlannerActivity(
      id: json['id'] as String,
      title: json['title'] as String,
      durationMin: json['durationMin'] as int,
      priority: json['priority'] as String,
      difficulty: json['difficulty'] as String,
      date: DateTime.parse(json['date'] as String),
    );
  }
}
