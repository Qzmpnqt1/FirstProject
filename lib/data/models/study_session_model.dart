import '../../domain/entities/study_session_entity.dart';

/// Data model для учебной сессии с JSON сериализацией
class StudySessionModel extends StudySessionEntity {
  const StudySessionModel({
    required super.id,
    required super.title,
    required super.moduleTitle,
    required super.scheduledAt,
    required super.durationMinutes,
    required super.completed,
    super.repeatType = SessionRepeatType.none,
    super.repeatUntil,
    super.reminderEnabled = false,
    super.reminderMinutesBefore = 15,
    super.attendance = AttendanceStatus.notSet,
    super.taskIds = const [],
  });

  factory StudySessionModel.fromEntity(StudySessionEntity entity) => StudySessionModel(
        id: entity.id,
        title: entity.title,
        moduleTitle: entity.moduleTitle,
        scheduledAt: entity.scheduledAt,
        durationMinutes: entity.durationMinutes,
        completed: entity.completed,
        repeatType: entity.repeatType,
        repeatUntil: entity.repeatUntil,
        reminderEnabled: entity.reminderEnabled,
        reminderMinutesBefore: entity.reminderMinutesBefore,
        attendance: entity.attendance,
        taskIds: entity.taskIds,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'moduleTitle': moduleTitle,
        'scheduledAt': scheduledAt.toIso8601String(),
        'durationMinutes': durationMinutes,
        'completed': completed,
        'repeatType': repeatType.name,
        if (repeatUntil != null) 'repeatUntil': repeatUntil!.toIso8601String(),
        'reminderEnabled': reminderEnabled,
        'reminderMinutesBefore': reminderMinutesBefore,
        'attendance': attendance.name,
        'taskIds': taskIds,
      };

  factory StudySessionModel.fromJson(Map<String, dynamic> json) => StudySessionModel(
        id: json['id'] as String,
        title: json['title'] as String,
        moduleTitle: json['moduleTitle'] as String,
        scheduledAt: DateTime.parse(json['scheduledAt'] as String),
        durationMinutes: json['durationMinutes'] as int,
        completed: json['completed'] as bool? ?? false,
        repeatType: SessionRepeatType.values.firstWhere(
          (e) => e.name == (json['repeatType'] as String?),
          orElse: () => SessionRepeatType.none,
        ),
        repeatUntil: json['repeatUntil'] != null
            ? DateTime.parse(json['repeatUntil'] as String)
            : null,
        reminderEnabled: json['reminderEnabled'] as bool? ?? false,
        reminderMinutesBefore: json['reminderMinutesBefore'] as int? ?? 15,
        attendance: AttendanceStatus.values.firstWhere(
          (e) => e.name == (json['attendance'] as String?),
          orElse: () => AttendanceStatus.notSet,
        ),
        taskIds: (json['taskIds'] as List<dynamic>?)?.cast<String>() ?? const [],
      );
}

