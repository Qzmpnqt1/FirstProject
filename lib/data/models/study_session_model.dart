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
  });

  factory StudySessionModel.fromEntity(StudySessionEntity entity) => StudySessionModel(
        id: entity.id,
        title: entity.title,
        moduleTitle: entity.moduleTitle,
        scheduledAt: entity.scheduledAt,
        durationMinutes: entity.durationMinutes,
        completed: entity.completed,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'moduleTitle': moduleTitle,
        'scheduledAt': scheduledAt.toIso8601String(),
        'durationMinutes': durationMinutes,
        'completed': completed,
      };

  factory StudySessionModel.fromJson(Map<String, dynamic> json) => StudySessionModel(
        id: json['id'] as String,
        title: json['title'] as String,
        moduleTitle: json['moduleTitle'] as String,
        scheduledAt: DateTime.parse(json['scheduledAt'] as String),
        durationMinutes: json['durationMinutes'] as int,
        completed: json['completed'] as bool? ?? false,
      );
}

