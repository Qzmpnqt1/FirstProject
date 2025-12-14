/// Domain entity для учебной сессии
enum SessionRepeatType { none, daily, weekly, monthly }
enum AttendanceStatus { notSet, present, absent, late }

class StudySessionEntity {
  final String id;
  final String title;
  final String moduleTitle;
  final DateTime scheduledAt;
  final int durationMinutes;
  final bool completed;
  final SessionRepeatType repeatType;
  final DateTime? repeatUntil;
  final bool reminderEnabled;
  final int reminderMinutesBefore; // За сколько минут напомнить
  final AttendanceStatus attendance;
  final List<String> taskIds; // Привязанные задачи

  const StudySessionEntity({
    required this.id,
    required this.title,
    required this.moduleTitle,
    required this.scheduledAt,
    required this.durationMinutes,
    required this.completed,
    this.repeatType = SessionRepeatType.none,
    this.repeatUntil,
    this.reminderEnabled = false,
    this.reminderMinutesBefore = 15,
    this.attendance = AttendanceStatus.notSet,
    this.taskIds = const [],
  });

  StudySessionEntity copyWith({
    String? id,
    String? title,
    String? moduleTitle,
    DateTime? scheduledAt,
    int? durationMinutes,
    bool? completed,
    SessionRepeatType? repeatType,
    DateTime? repeatUntil,
    bool? reminderEnabled,
    int? reminderMinutesBefore,
    AttendanceStatus? attendance,
    List<String>? taskIds,
  }) =>
      StudySessionEntity(
        id: id ?? this.id,
        title: title ?? this.title,
        moduleTitle: moduleTitle ?? this.moduleTitle,
        scheduledAt: scheduledAt ?? this.scheduledAt,
        durationMinutes: durationMinutes ?? this.durationMinutes,
        completed: completed ?? this.completed,
        repeatType: repeatType ?? this.repeatType,
        repeatUntil: repeatUntil ?? this.repeatUntil,
        reminderEnabled: reminderEnabled ?? this.reminderEnabled,
        reminderMinutesBefore: reminderMinutesBefore ?? this.reminderMinutesBefore,
        attendance: attendance ?? this.attendance,
        taskIds: taskIds ?? this.taskIds,
      );

  /// Проверка конфликта с другой сессией
  bool hasConflict(StudySessionEntity other) {
    if (id == other.id) return false;
    final thisEnd = scheduledAt.add(Duration(minutes: durationMinutes));
    final otherEnd = other.scheduledAt.add(Duration(minutes: other.durationMinutes));
    return scheduledAt.isBefore(otherEnd) && thisEnd.isAfter(other.scheduledAt);
  }
}

