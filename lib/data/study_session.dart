class StudySession {
  final String id;
  final String title;
  final String moduleTitle;
  final DateTime scheduledAt;
  final int durationMinutes;
  final bool completed;

  const StudySession({
    required this.id,
    required this.title,
    required this.moduleTitle,
    required this.scheduledAt,
    required this.durationMinutes,
    required this.completed,
  });

  StudySession copyWith({
    String? id,
    String? title,
    String? moduleTitle,
    DateTime? scheduledAt,
    int? durationMinutes,
    bool? completed,
  }) {
    return StudySession(
      id: id ?? this.id,
      title: title ?? this.title,
      moduleTitle: moduleTitle ?? this.moduleTitle,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      completed: completed ?? this.completed,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'moduleTitle': moduleTitle,
        'scheduledAt': scheduledAt.toIso8601String(),
        'durationMinutes': durationMinutes,
        'completed': completed,
      };

  factory StudySession.fromJson(Map<String, dynamic> json) => StudySession(
        id: json['id'] as String,
        title: json['title'] as String,
        moduleTitle: json['moduleTitle'] as String,
        scheduledAt: DateTime.parse(json['scheduledAt'] as String),
        durationMinutes: json['durationMinutes'] as int,
        completed: json['completed'] as bool? ?? false,
      );
}

