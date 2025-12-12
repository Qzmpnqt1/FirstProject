/// Domain entity для учебной сессии
class StudySessionEntity {
  final String id;
  final String title;
  final String moduleTitle;
  final DateTime scheduledAt;
  final int durationMinutes;
  final bool completed;

  const StudySessionEntity({
    required this.id,
    required this.title,
    required this.moduleTitle,
    required this.scheduledAt,
    required this.durationMinutes,
    required this.completed,
  });

  StudySessionEntity copyWith({
    String? id,
    String? title,
    String? moduleTitle,
    DateTime? scheduledAt,
    int? durationMinutes,
    bool? completed,
  }) =>
      StudySessionEntity(
        id: id ?? this.id,
        title: title ?? this.title,
        moduleTitle: moduleTitle ?? this.moduleTitle,
        scheduledAt: scheduledAt ?? this.scheduledAt,
        durationMinutes: durationMinutes ?? this.durationMinutes,
        completed: completed ?? this.completed,
      );
}

